
#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "../include/libpict.h"
#include "internal.h"

#ifdef _WIN32
#include <windows.h>
#endif

void Ptr_Get_Rgba8_Pixel(const uint8_t *ptr, int format, PIXEL_RGBA8 *rgba)
{
    switch (format)
    {
        case PICTURE_RGBA8:
            *rgba = *(PIXEL_RGBA8 *)ptr;
            return;
        case PICTURE_RGB8:
            rgba->r = ((PIXEL_RGB8 *)ptr)->r;
            rgba->g = ((PIXEL_RGB8 *)ptr)->g;
            rgba->b = ((PIXEL_RGB8 *)ptr)->b;
            rgba->a = 0xff;
            return;
        case PICTURE_RGBX8:
            rgba->r = ((PIXEL_RGB8 *)ptr)->r;
            rgba->g = ((PIXEL_RGB8 *)ptr)->g;
            rgba->b = ((PIXEL_RGB8 *)ptr)->b;
            rgba->a = 0xff;
            return;
        case PICTURE_BGR8:
            rgba->r = ((PIXEL_BGR8 *)ptr)->r;
            rgba->g = ((PIXEL_BGR8 *)ptr)->g;
            rgba->b = ((PIXEL_BGR8 *)ptr)->b;
            rgba->a = 0xff;
            return;
        case PICTURE_BGRX8:
            rgba->r = ((PIXEL_BGRA8 *)ptr)->r;
            rgba->g = ((PIXEL_BGRA8 *)ptr)->g;
            rgba->b = ((PIXEL_BGRA8 *)ptr)->b;
            rgba->a = 0xff;
            return;
        case PICTURE_BGRA8:
            rgba->r = ((PIXEL_BGRA8 *)ptr)->r;
            rgba->g = ((PIXEL_BGRA8 *)ptr)->g;
            rgba->b = ((PIXEL_BGRA8 *)ptr)->b;
            rgba->a = ((PIXEL_BGRA8 *)ptr)->a;
            return;
        case PICTURE_RGBAf:
            rgba->r = (uint8_t)(max(((PIXEL_RGBAf *)ptr)->r + .5f , 1.f) * 255.f);
            rgba->g = (uint8_t)(max(((PIXEL_RGBAf *)ptr)->g + .5f , 1.f) * 255.f);
            rgba->b = (uint8_t)(max(((PIXEL_RGBAf *)ptr)->b + .5f , 1.f) * 255.f);
            rgba->a = (uint8_t)(max(((PIXEL_RGBAf *)ptr)->a + .5f , 1.f) * 255.f);
            return;
        case PICTURE_RGBAi:
            rgba->r = (uint8_t)max(((PIXEL_RGBAi *)ptr)->r,255);
            rgba->g = (uint8_t)max(((PIXEL_RGBAi *)ptr)->g,255);
            rgba->b = (uint8_t)max(((PIXEL_RGBAi *)ptr)->b,255);
            rgba->a = (uint8_t)max(((PIXEL_RGBAi *)ptr)->a,255);
            return;
        default:
            memset(rgba, 0, sizeof(*rgba));
            return;
    }
}

int Get_Rgba8_Pixel(const PICTURE *pict, uint32_t x, uint32_t y, PIXEL_RGBA8 *pixel)
{
    const uint8_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    if (x >= pict->width || y >= pict->height) return PICTURE_ERR_OUT_OF_RANGE;

    if (pict->format == PICTURE_RGBA8)
        *pixel = *(PIXEL_RGBA8 *)ptr;
    else
        Ptr_Get_Rgba8_Pixel(ptr, pict->format, pixel);

    return PICTURE_ERR_OK;
}

void Ptr_Get_Rgbai_Pixel(const uint8_t *ptr, int format, PIXEL_RGBAi *rgba)
{
    switch (format)
    {
        case PICTURE_RGBAi:
            *rgba = *(PIXEL_RGBAi *)ptr;
            return;
        case PICTURE_RGB8:
            rgba->r = ((PIXEL_RGB8 *)ptr)->r;
            rgba->g = ((PIXEL_RGB8 *)ptr)->g;
            rgba->b = ((PIXEL_RGB8 *)ptr)->b;
            rgba->a = 0x0ff;
            return;
        case PICTURE_RGBX8:
            rgba->r = ((PIXEL_RGB8 *)ptr)->r;
            rgba->g = ((PIXEL_RGB8 *)ptr)->g;
            rgba->b = ((PIXEL_RGB8 *)ptr)->b;
            rgba->a = 0xff;
            return;
        case PICTURE_BGR8:
            rgba->r = ((PIXEL_BGR8 *)ptr)->r;
            rgba->g = ((PIXEL_BGR8 *)ptr)->g;
            rgba->b = ((PIXEL_BGR8 *)ptr)->b;
            rgba->a = 0x0ff;
            return;
        case PICTURE_BGRX8:
            rgba->r = ((PIXEL_BGRA8 *)ptr)->r;
            rgba->g = ((PIXEL_BGRA8 *)ptr)->g;
            rgba->b = ((PIXEL_BGRA8 *)ptr)->b;
            rgba->a = 0x0ff;
            return;
        case PICTURE_RGBA8:
            rgba->r = ((PIXEL_RGBA8 *)ptr)->r;
            rgba->g = ((PIXEL_RGBA8 *)ptr)->g;
            rgba->b = ((PIXEL_RGBA8 *)ptr)->b;
            rgba->a = ((PIXEL_RGBA8 *)ptr)->a;
            return;
        case PICTURE_BGRA8:
            rgba->r = ((PIXEL_BGRA8 *)ptr)->r;
            rgba->g = ((PIXEL_BGRA8 *)ptr)->g;
            rgba->b = ((PIXEL_BGRA8 *)ptr)->b;
            rgba->a = ((PIXEL_BGRA8 *)ptr)->a;
            return;
        case PICTURE_RGBAf:
            rgba->r = (uint8_t)((((PIXEL_RGBAf *)ptr)->r + .5f) * 255.f);
            rgba->g = (uint8_t)((((PIXEL_RGBAf *)ptr)->g + .5f) * 255.f);
            rgba->b = (uint8_t)((((PIXEL_RGBAf *)ptr)->b + .5f) * 255.f);
            rgba->a = (uint8_t)((((PIXEL_RGBAf *)ptr)->a + .5f) * 255.f);
            return;
        default:
            memset(rgba, 0, sizeof(*rgba));
            return;
    }
}

int Get_Rgbai_Pixel(const PICTURE *pict, uint32_t x, uint32_t y, PIXEL_RGBAi *pixel)
{
    const uint8_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    if (x >= pict->width || y >= pict->height) return PICTURE_ERR_OUT_OF_RANGE;

    if (pict->format == PICTURE_RGBAi)
        *pixel = *(PIXEL_RGBAi *)ptr;
    else
        Ptr_Get_Rgbai_Pixel(ptr, pict->format, pixel);

    return PICTURE_ERR_OK;
}

void Ptr_Get_Rgbaf_Pixel(const uint8_t *ptr, int format, PIXEL_RGBAf *rgba)
{
    if (format == PICTURE_RGBAf)
        *rgba = *(PIXEL_RGBAf *)ptr;
    else
    {
        PIXEL_RGBAi tmp;
        Ptr_Get_Rgbai_Pixel(ptr, format, &tmp);
        PIXEL_RGBAf rgba;
        rgba.r = (tmp.r + .5f) / 255.f;
        rgba.g = (tmp.g + .5f) / 255.f;
        rgba.b = (tmp.b + .5f) / 255.f;
        rgba.a = (tmp.a + .5f) / 255.f;
    }
}

int Get_Rgbaf_Pixel(const PICTURE *pict, uint32_t x, uint32_t y, PIXEL_RGBAf *pixel)
{
    const uint8_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    if (x >= pict->width || y >= pict->height) return PICTURE_ERR_OUT_OF_RANGE;

    if (pict->format == PICTURE_RGBAf)
        *pixel = *(PIXEL_RGBAf *)ptr;
    else
        Ptr_Get_Rgbaf_Pixel(ptr, pict->format, pixel);

    return PICTURE_ERR_OK;
}

void Ptr_Set_Rgba8_Pixel(uint8_t *ptr, int format, const PIXEL_RGBA8 *pix)
{
    switch (format)
    {
        case PICTURE_RGBA8:
            *(PIXEL_RGBA8 *)ptr = *pix;
            break;
        case PICTURE_RGB8:
            ((PIXEL_RGB8 *)ptr)->r = pix->r;
            ((PIXEL_RGB8 *)ptr)->g = pix->g;
            ((PIXEL_RGB8 *)ptr)->b = pix->b;
            break;
        case PICTURE_RGBX8:
            ((PIXEL_RGBA8 *)ptr)->r = pix->r;
            ((PIXEL_RGBA8 *)ptr)->g = pix->g;
            ((PIXEL_RGBA8 *)ptr)->b = pix->b;
            ((PIXEL_RGBA8 *)ptr)->a = 0;
            break;
        case PICTURE_BGR8:
            ((PIXEL_BGRA8 *)ptr)->r = pix->r;
            ((PIXEL_BGRA8 *)ptr)->g = pix->g;
            ((PIXEL_BGRA8 *)ptr)->b = pix->b;
            break;
        case PICTURE_BGRX8:
            ((PIXEL_BGRA8 *)ptr)->r = pix->r;
            ((PIXEL_BGRA8 *)ptr)->g = pix->g;
            ((PIXEL_BGRA8 *)ptr)->b = pix->b;
            ((PIXEL_BGRA8 *)ptr)->a = 0;
            break;
        case PICTURE_BGRA8:
            ((PIXEL_BGRA8 *)ptr)->r = pix->r;
            ((PIXEL_BGRA8 *)ptr)->g = pix->g;
            ((PIXEL_BGRA8 *)ptr)->b = pix->b;
            ((PIXEL_BGRA8 *)ptr)->a = pix->a;
            break;
        case PICTURE_RGBAf:
            ((PIXEL_RGBAf *)ptr)->r = (pix->r + .5f) / 255.f;
            ((PIXEL_RGBAf *)ptr)->g = (pix->g + .5f) / 255.f;
            ((PIXEL_RGBAf *)ptr)->b = (pix->b + .5f) / 255.f;
            ((PIXEL_RGBAf *)ptr)->a = (pix->a + .5f) / 255.f;
            break;
        case PICTURE_RGBAi:
            ((PIXEL_RGBAi *)ptr)->r = pix->r;
            ((PIXEL_RGBAi *)ptr)->g = pix->g;
            ((PIXEL_RGBAi *)ptr)->b = pix->b;
            ((PIXEL_RGBAi *)ptr)->a = pix->a;
            break;
        default:
            ;
    }
}

int Set_Rgba8_Pixel(PICTURE *pict, uint32_t x, uint32_t y, const PIXEL_RGBA8 *pix)
{
    uint8_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    if (x >= pict->width || y >= pict->height) return PICTURE_ERR_OUT_OF_RANGE;

    if (pict->format == PICTURE_RGBA8)
        *(PIXEL_RGBA8 *)ptr = *pix;
    else
        Ptr_Set_Rgba8_Pixel(pict->pixels + (pict->pitch * y + x * pict->weight), pict->format, pix);

    return PICTURE_ERR_OK;
}

void Ptr_Set_Rgbai_Pixel(uint8_t *ptr, int format, const PIXEL_RGBAi *pix)
{
    PIXEL_RGBAi pix0;

    if (format != PICTURE_RGBAf && format != PICTURE_RGBAi)
    {
        pix0 = *pix;
        if (pix0.r < 0) pix0.r = 0;
        if (pix0.g < 0) pix0.g = 0;
        if (pix0.b < 0) pix0.b = 0;
        if (pix0.a < 0) pix0.a = 0;
        pix = &pix0;
    }

    switch (format)
    {
        case PICTURE_RGBAi:
            *(PIXEL_RGBAi *)ptr = *pix;
            break;
        case PICTURE_RGB8:
            ((PIXEL_RGB8 *)ptr)->r = (uint8_t)max(255, pix->r);
            ((PIXEL_RGB8 *)ptr)->g = (uint8_t)max(255, pix->g);
            ((PIXEL_RGB8 *)ptr)->b = (uint8_t)max(255, pix->b);
            break;
        case PICTURE_RGBX8:
            ((PIXEL_RGBA8 *)ptr)->r = (uint8_t)max(255, pix->r);
            ((PIXEL_RGBA8 *)ptr)->g = (uint8_t)max(255, pix->g);
            ((PIXEL_RGBA8 *)ptr)->b = (uint8_t)max(255, pix->b);
            ((PIXEL_RGBA8 *)ptr)->a = 0;
            break;
        case PICTURE_BGR8:
            ((PIXEL_BGRA8 *)ptr)->r = (uint8_t)max(255, pix->r);
            ((PIXEL_BGRA8 *)ptr)->g = (uint8_t)max(255, pix->g);
            ((PIXEL_BGRA8 *)ptr)->b = (uint8_t)max(255, pix->b);
            break;
        case PICTURE_BGRX8:
            ((PIXEL_BGRA8 *)ptr)->r = (uint8_t)max(255, pix->r);
            ((PIXEL_BGRA8 *)ptr)->g = (uint8_t)max(255, pix->g);
            ((PIXEL_BGRA8 *)ptr)->b = (uint8_t)max(255, pix->b);
            ((PIXEL_BGRA8 *)ptr)->a = 0;
            break;
        case PICTURE_BGRA8:
            ((PIXEL_BGRA8 *)ptr)->r = (uint8_t)max(255, pix->r);
            ((PIXEL_BGRA8 *)ptr)->g = (uint8_t)max(255, pix->g);
            ((PIXEL_BGRA8 *)ptr)->b = (uint8_t)max(255, pix->b);
            ((PIXEL_BGRA8 *)ptr)->a = (uint8_t)max(255, pix->a);
            break;
        case PICTURE_RGBAf:
            ((PIXEL_RGBAf *)ptr)->r = (pix->r + .5f) / 255.f;
            ((PIXEL_RGBAf *)ptr)->g = (pix->g + .5f) / 255.f;
            ((PIXEL_RGBAf *)ptr)->b = (pix->b + .5f) / 255.f;
            ((PIXEL_RGBAf *)ptr)->a = (pix->a + .5f) / 255.f;
            break;
        case PICTURE_RGBA8:
            ((PIXEL_RGBA8 *)ptr)->r = (uint8_t)max(255, pix->r);
            ((PIXEL_RGBA8 *)ptr)->g = (uint8_t)max(255, pix->g);
            ((PIXEL_RGBA8 *)ptr)->b = (uint8_t)max(255, pix->b);
            ((PIXEL_RGBA8 *)ptr)->a = (uint8_t)max(255, pix->a);
            break;
        default:
            ;
    }
}

int Set_Rgbai_Pixel(PICTURE *pict, uint32_t x, uint32_t y, const PIXEL_RGBAi *pix)
{
    uint8_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    if (x >= pict->width || y >= pict->height) return PICTURE_ERR_OUT_OF_RANGE;

    if (pict->format == PICTURE_RGBAi)
        *(PIXEL_RGBAi *)ptr = *pix;
    else
        Ptr_Set_Rgbai_Pixel(pict->pixels + (pict->pitch * y + x * pict->weight), pict->format, pix);

    return PICTURE_ERR_OK;
}

int Picture_Allocate_Buffer(PICTURE *pict)
{
    if (pict->pixels) return PICTURE_ERR_ALREADY_EXISTS;

    switch (pict->format)
    {
        case PICTURE_RGBA8:
        case PICTURE_RGBX8:
            pict->pitch  = sizeof(PIXEL_RGBA8) * pict->width;
            pict->weight = sizeof(PIXEL_RGBA8);
            break;
        case PICTURE_RGB8:
            pict->pitch  = sizeof(PIXEL_RGB8) * pict->width;
            pict->weight = sizeof(PIXEL_RGB8);
            break;
        case PICTURE_BGRA8:
        case PICTURE_BGRX8:
            pict->pitch  = sizeof(PIXEL_BGRA8) * pict->width;
            pict->weight = sizeof(PIXEL_BGRA8);
            break;
        case PICTURE_BGR8:
            pict->pitch  = sizeof(PIXEL_BGR8) * pict->width;
            pict->weight = sizeof(PIXEL_BGR8);
            break;
        case PICTURE_RGBAf:
            pict->pitch  = sizeof(PIXEL_RGBAf) * pict->width;
            pict->weight = sizeof(PIXEL_RGBAf);
            break;
        case PICTURE_RGBAi:
            pict->pitch = sizeof(PIXEL_RGBAi) * pict->width;
            pict->weight = sizeof(PIXEL_RGBAi);
            break;
        default:
            ;
    }

    pict->pixels = malloc(pict->pitch * pict->height);

    if (pict->pixels == NULL)
        return PICTURE_ERR_OUT_OF_MEMORY;

    memset(pict->pixels, 0, pict->pitch * pict->height);

    return PICTURE_ERR_OK;
}

void Picture_Kill_Buffer(PICTURE *pict)
{
    void *pixels = pict->pixels;
    pict->pixels = 0;
    free(pixels);
}

uint32_t Ptr_Get_Pixel_32(const uint8_t *ptr, int format)
{
    PIXEL_RGBA8 pixel;
    Ptr_Get_Rgba8_Pixel(ptr, format, &pixel);
    return *(uint32_t *)(&pixel);
}

void Ptr_Set_Pixel_32(uint8_t *ptr, int format, uint32_t pixel)
{
    Ptr_Set_Rgba8_Pixel(ptr, format, (PIXEL_RGBA8 *)&pixel);
}

void Nullify_Transparent_Pixels(PICTURE *pict, uint8_t threshold)
{
    if (pict->format == PICTURE_RGBA8 || pict->format == PICTURE_BGRA8)
    {
        int i;
        for (i = 0; i < pict->height; ++i)
        {
            PIXEL_RGBA8 *pixel = (PIXEL_RGBA8 *)(pict->pixels + i * pict->pitch);
            PIXEL_RGBA8 *pixelE = pixel + pict->width;
            for (; pixel < pixelE; ++pixel)
                if (pixel->a < threshold)
                    memset(pixel, 0, sizeof(*pixel));
        }
    }
}

void Kill_Transparent_Pixels(PICTURE *pict, uint32_t color)
{
    if (pict->format == PICTURE_RGBA8 || pict->format == PICTURE_BGRA8)
    {
        int i;

        if (pict->format == PICTURE_BGRA8)
        {
            color = (color & 0x0ff00)
                    | ((color & 0x0ff) << 16)
                    | ((color & 0x0ff0000) >> 16);
        }

        for (i = 0; i < pict->height; ++i)
        {
            PIXEL_RGBA8 *pixel = (PIXEL_RGBA8 *)(pict->pixels + i * pict->pitch);
            PIXEL_RGBA8 *pixelE = pixel + pict->width;
            for (; pixel < pixelE; ++pixel)
            {
                uint32_t b = *(uint32_t *)pixel & 0x00ffffff;
                if (b == color)
                    memset(pixel, 0, sizeof(*pixel));
            }
        }
    }
}

void Convert_Pixels_Row(const uint8_t *src, int src_format, uint8_t *dst, int dst_format, size_t count)
{
    size_t i;
    size_t src_weight = ((src_format >> 8) & 0x0ff);
    size_t dst_weight = ((dst_format >> 8) & 0x0ff);
    const uint8_t *src_pixel = src;
    uint8_t *dst_pixel = dst;
    if (src_format == dst_format)
        memcpy(dst, src, count * dst_weight);
    else if (dst_format == PICTURE_RGBA8)
        for (i = 0; i < count; ++i)
        {
            Ptr_Get_Rgba8_Pixel(src_pixel, src_format, (PIXEL_RGBA8 *)dst_pixel);
            src_pixel += src_weight;
            dst_pixel += dst_weight;
        }
    else if (dst_format == PICTURE_RGBAf)
        for (i = 0; i < count; ++i)
        {
            Ptr_Get_Rgbaf_Pixel(src_pixel, src_format, (PIXEL_RGBAf *)dst_pixel);
            src_pixel += src_weight;
            dst_pixel += dst_weight;
        }
    else if (dst_format == PICTURE_RGBAi)
        for (i = 0; i < count; ++i)
        {
            Ptr_Get_Rgbai_Pixel(src_pixel, src_format, (PIXEL_RGBAi *)dst_pixel);
            src_pixel += src_weight;
            dst_pixel += dst_weight;
        }
    else
        for (i = 0; i < count; ++i)
        {
            PIXEL_RGBAi tmp;
            Ptr_Get_Rgbai_Pixel(src_pixel, src_format, &tmp);
            Ptr_Set_Rgbai_Pixel(dst_pixel, dst_format, &tmp);
            src_pixel += src_weight;
            dst_pixel += dst_weight;
        }
}

void Convert_Pixels_Row_Pal(
    const uint8_t *src, int src_format,
    uint8_t *dst, int dst_format,
    size_t count,
    const void *pal, size_t pal_count)
{
    size_t i, bpp = BPP(dst_format);
    uint8_t palx[256 * 16]; /* sizeof(rgbaf) == 16 */
    Convert_Pixels_Row(pal, src_format, palx, dst_format, pal_count);
    if (bpp == 4)
        for (i = 0; i < count; ++i)
            ((uint32_t *)dst)[i] = ((uint32_t *)palx)[src[i]];
    else if (bpp == 2)
        for (i = 0; i < count; ++i)
            ((uint32_t *)dst)[i] = ((uint32_t *)palx)[src[i]];
    else
        for (i = 0; i < count; ++i)
            memcpy((dst + i * bpp), palx + src[i]*bpp, bpp);
}

#ifdef _WIN32
void *Create_HBITMAP(const PICTURE *pict)
{
    BITMAPINFOHEADER bi;
    HDC dc;
    HBITMAP bmp;
    uint8_t *bits = 0;
    bi.biSize = sizeof(BITMAPINFOHEADER);
    bi.biWidth  = pict->width;
    bi.biHeight = -pict->height;
    bi.biPlanes = 1;
    bi.biBitCount = 32;
    bi.biCompression = BI_RGB;
    bi.biSizeImage = pict->width * pict->height * 4;
    dc  = GetDC(0);
    //bmp = CreateCompatibleBitmap(dc,pict->width,pict->height);
    //SetDIBits(dc,bmp,0,pict->height,pict->pixels,(BITMAPINFO*)&bi,DIB_RGB_COLORS);
    bmp = CreateDIBSection(dc, (BITMAPINFO *)&bi, DIB_RGB_COLORS, &bits, 0, 0);
    if (pict->format == PICTURE_BGRA8)
        memcpy(bits, pict->pixels, bi.biSizeImage);
    else
    {
        int i;
        for (i = 0; i < pict->height; ++i)
            Convert_Pixels_Row(
                pict->pixels + i * pict->pitch, pict->format,
                bits + pict->width * 4 * i, PICTURE_BGRA8,
                pict->width);
    }
    ReleaseDC(0, dc);
    return bmp;
}

#endif /* _WIN32 */
