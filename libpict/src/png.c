
#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "../include/libpict.h"
#include "internal.h"

#include <png.h>
#if PNG_LIBPNG_VER_SONUM >= 15
# include <pngstruct.h>
#endif

static void Picture_From_PNG_Read_Data(png_structp png_ptr, void *dest, png_size_t count)
{
	uint8_t **p = png_ptr->io_ptr;
	if (*p + count > p[1])
		png_error(png_ptr, "png read error in Pict_From_PNG_Read_Data");
	memcpy(dest, *p, count);
	*p += count;
}

int Picture_From_PNG_Specific_Rect(
	PICTURE *pict,
	const void *bytes, size_t count,
	int format,
	uint32_t left, uint32_t top,
	uint32_t width, uint32_t height)
{
	int err = PICTURE_ERR_OK;

	if (pict->pixels) return PICTURE_ERR_ALREADY_EXISTS;
	memset(pict, 0, sizeof(*pict));
	pict->format = format;

	if (1)
	{
		png_structp png_ptr = 0;
		png_infop   info_ptr = 0;
		png_infop   end_info_ptr = 0;
		uint8_t    *read_ptr[2];
		uint8_t    *row = 0;
		int stride;
		int jformat;
		int i;
		int png_width;
		int png_height;
		int bpp;

		if (0)
		{
		on_exit:
			png_destroy_read_struct(&png_ptr, &info_ptr, &end_info_ptr);
			if (row) free(row);
			if (err)
				Picture_Kill_Buffer(pict);
			return err;
		}

		if (!png_check_sig(bytes, 8))
		{
			err = PICTURE_ERR_NO_IMAGE;
		}

		png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, 0, 0, 0);
		info_ptr = png_create_info_struct(png_ptr);
		end_info_ptr = png_create_info_struct(png_ptr);

		if (!setjmp(png_jmpbuf(png_ptr)))
		{
			read_ptr[0] = (uint8_t*)bytes + 8;
			read_ptr[1] = (uint8_t*)bytes + (count - 8);
			png_set_read_fn(png_ptr, read_ptr, (png_rw_ptr)Picture_From_PNG_Read_Data);
			png_set_sig_bytes(png_ptr, 8);
			png_read_info(png_ptr, info_ptr);
			png_set_strip_16(png_ptr);
			png_set_packing(png_ptr);

			if (png_ptr->bit_depth < 8
				|| png_ptr->color_type == PNG_COLOR_TYPE_PALETTE
				|| png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS))
				png_set_expand(png_ptr);

			png_read_update_info(png_ptr, info_ptr);

			png_width = png_get_image_width(png_ptr, info_ptr);
			png_height = png_get_image_height(png_ptr, info_ptr);

			if (width >= INT_MAX) width = png_width;
			if (height >= INT_MAX) height = png_height;

			if (left + width > png_width || left < 0 || top + height > png_height || top < 0)
			{
			rect_out_of_picture:
				err = PICTURE_ERR_OUT_OF_RANGE;
				goto on_exit;
			}

			pict->width = width;
			pict->height = height;

			if (png_ptr->color_type == PNG_COLOR_TYPE_RGB_ALPHA)
				bpp = 4;
			else
				bpp = 3;

			stride = (bpp*png_width + 3) & ~3;
			jformat = (bpp == 4 ? PICTURE_RGBA8 : PICTURE_RGB8);
			if (jformat != pict->format
				|| png_width != width || png_width != height)
				row = malloc(stride);
		}
		else
		{
			if (!setjmp(png_jmpbuf(png_ptr)))
			{
				err = PICTURE_ERR_DECODE_IMAGE;
				goto on_exit;
			}
		}


		pict->format = format;
		if (pict->pixels) Picture_Kill_Buffer(pict);
		if ((err = Picture_Allocate_Buffer(pict)) != PICTURE_ERR_OK)
			goto on_exit;

		if (!setjmp(png_jmpbuf(png_ptr)))
		{
			for (i = 0; i < top; ++i)
				png_read_row(png_ptr, row, 0);

			for (i = 0; i < pict->height; ++i)
			{
				if (jformat != pict->format
					|| png_width != width)
				{
					png_read_row(png_ptr, row, 0);
					Convert_Pixels_Row(
						row + bpp*left,
						jformat,
						pict->pixels + i*pict->pitch,
						pict->format,
						pict->width);
				}
				else
					png_read_row(png_ptr, pict->pixels + i*pict->pitch, 0);
			}
			//png_read_end(png_ptr,info_ptr);
		}
		else
		{
			if (!setjmp(png_jmpbuf(png_ptr)))
			{
				err = PICTURE_ERR_DECODE_IMAGE;
				goto on_exit;
			}
		}
	}

	goto on_exit;
}

int Picture_From_PNG(PICTURE* pict, const void* bytes, size_t count, int format)
{
	return Picture_From_PNG_Specific_Rect(pict, bytes, count, format, 0, 0, INT_MAX, INT_MAX);
}
