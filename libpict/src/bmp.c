
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "../include/libpict.h"
#include "internal.h"

enum { C_BI_BITFIELDS = 3, C_BI_RGB = 0, };

#pragma pack(push,2)

typedef struct C_BITMAPFILEHEADER
{
	uint16_t  bfType;
	uint32_t  bfSize;
	uint16_t  bfReserved1;
	uint16_t  bfReserved2;
	uint32_t  bfOffBits;
} C_BITMAPFILEHEADER;

typedef struct C_BITMAPINFOHEADER
{
	uint32_t  biSize;
	int32_t   biWidth;
	int32_t   biHeight;
	uint16_t  biPlanes;
	uint16_t  biBitCount;
	uint32_t  biCompression;
	uint32_t  biSizeImage;
	int32_t   biXPelsPerMeter;
	int32_t   biYPelsPerMeter;
	uint32_t  biClrUsed;
	uint32_t  biClrImportant;
} C_BITMAPINFOHEADER;
#pragma pack(pop)

int Picture_From_BMP(PICTURE* pict, const void* bytes, size_t count, int format)
{
	int err;
	
	const C_BITMAPFILEHEADER* bmFH;
	const C_BITMAPINFOHEADER* bmIH;
	uint32_t* palette;
	uint8_t* image;

	if (pict->pixels) return PICTURE_ERR_ALREADY_EXISTS;
	memset(pict, 0, sizeof(*pict));
	pict->format = format;

	bmFH = bytes;
	bmIH = (C_BITMAPINFOHEADER*)((char*)bytes + sizeof(C_BITMAPFILEHEADER));
	palette = (uint32_t*)((char*)bmIH + bmIH->biSize);
	image  = (uint8_t*)bmFH + bmFH->bfOffBits;

	if ((bmFH->bfType == 0x4D42) && (bmFH->bfSize <= count))
	{
		int bpp = (bmIH->biBitCount / 8);
		int stride, jformat, i;
		uint8_t* row = 0;

		if (bmIH->biCompression != C_BI_RGB)
		{
			err = PICTURE_ERR_DECODE_IMAGE;
			goto on_error;
		}

		switch (bmIH->biBitCount)
		{
			case 32: jformat = PICTURE_BGRA8; break;
			case 24: jformat = PICTURE_BGR8; break;
			case 8:  jformat = PICTURE_PAL8; break;
			case 16:
				if (bmIH->biCompression == C_BI_BITFIELDS && palette[1] != 0x03e0)
					jformat = PICTURE_BGR6;
				else
					jformat = PICTURE_BGR5A1;
				break;
			default:
				err = PICTURE_ERR_DECODE_IMAGE;
				goto on_error;
		}

		stride = (bmIH->biWidth * BPP(jformat) + 3) & ~3;
		pict->width  = bmIH->biWidth;
		pict->height = absi(bmIH->biHeight); /* sign selects direction of rendering rows down-to-up or up-to-down*/

		if ((err = Picture_Allocate_Buffer(pict)) != PICTURE_ERR_OK)
			goto on_error;

		for (i = 0; i < pict->height; ++i)
		{
			int l = (bmIH->biHeight < 0) ? i : pict->height - i - 1;
			if (jformat != pict->format)
			{
				if (jformat == PICTURE_PAL8)
					Convert_Pixels_Row_Pal(
					    image + l * stride, PICTURE_BGRX8,
					    pict->pixels + i * pict->pitch, pict->format,
					    pict->width,
					    palette, bmIH->biClrUsed);
				else
					Convert_Pixels_Row(
					    image + l * stride, jformat,
					    pict->pixels + i * pict->pitch, pict->format,
					    pict->width);
			}
			else
				memcpy(pict->pixels + i * pict->pitch,
				       image + l * stride,
				       pict->width * BPP(jformat));
		}
	}

	return PICTURE_ERR_OK;

on_error:
	Picture_Kill_Buffer(pict);
	return err;
}
