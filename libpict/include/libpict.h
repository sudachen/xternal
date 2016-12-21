
/*

(C)2014, Alexey Sudachen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#ifndef C_once_D02B3778_0F00_417B_9CEF_8757BC2676E8
#define C_once_D02B3778_0F00_417B_9CEF_8757BC2676E8

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#if ( defined _DLL && !defined LIBPICT_STATIC ) || defined LIBPICT_DLL || defined LIBPICT_BUILD_DLL
#  if defined LIBPICT_BUILD_DLL
#    define LIBPICT_EXPORTABLE __declspec(dllexport)
#  else
#    define LIBPICT_EXPORTABLE __declspec(dllimport)
#  endif
#else
#define LIBPICT_EXPORTABLE
#endif


#define PICTURE_FOUR_CHARS(a,b,c,d) \
    (((uint32_t)(d)<<24)|((uint32_t)(c)<<16)|((uint32_t)(b)<<8)|((uint32_t)(a)))

enum
{
    PICTURE_PAL8        = PICTURE_FOUR_CHARS('P', 1, '8', 0),
    PICTURE_RGBAf       = PICTURE_FOUR_CHARS('R', 16, 'f', 'A'),
    PICTURE_RGBAi       = PICTURE_FOUR_CHARS('R', 32, 'i', 'A'),
    PICTURE_RGB8        = PICTURE_FOUR_CHARS('R', 3, '8', 0),
    PICTURE_RGB5        = PICTURE_FOUR_CHARS('R', 2, '5', 0),
    PICTURE_RGB6        = PICTURE_FOUR_CHARS('R', 2, '6', 0),
    PICTURE_RGBA8       = PICTURE_FOUR_CHARS('R', 4, '8', 'A'),
    PICTURE_RGBX8       = PICTURE_FOUR_CHARS('R', 4, '8', 0),
    PICTURE_RGB5A1      = PICTURE_FOUR_CHARS('R', 2, '5', 'A'),
    PICTURE_BGR8        = PICTURE_FOUR_CHARS('B', 3, '8', 0),
    PICTURE_BGR5        = PICTURE_FOUR_CHARS('B', 2, '5', 0),
    PICTURE_BGR6        = PICTURE_FOUR_CHARS('B', 2, '6', 0),
    PICTURE_BGRA8       = PICTURE_FOUR_CHARS('B', 4, '8', 'A'),
    PICTURE_BGRX8       = PICTURE_FOUR_CHARS('B', 4, '8', 0),
    PICTURE_BGR5A1      = PICTURE_FOUR_CHARS('B', 2, '5', 'A'),
};

enum
{
    PICTURE_ERR_OK                = 0,
    PICTURE_ERR_OUT_OF_RANGE      = 1,
    PICTURE_ERR_DECODE_IMAGE      = 2,
    PICTURE_ERR_NO_IMAGE          = 3,
    PICTURE_ERR_OUT_OF_MEMORY     = 4,
    PICTURE_ERR_ALREADY_EXISTS    = 5,
};

typedef struct PICTURE
{
    uint8_t *pixels;
    uint32_t width;
    uint32_t height;
    uint32_t pitch;
    uint32_t weight;
    uint32_t format;
} PICTURE;

typedef struct PIXEL_RGBAf
{
    float r;
    float g;
    float b;
    float a;
} PIXEL_RGBAf;

typedef struct PIXEL_RGBAi
{
    int32_t r;
    int32_t g;
    int32_t b;
    int32_t a;
} PIXEL_RGBAi;

typedef struct PIXEL_RGBA8
{
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} PIXEL_RGBA8;

LIBPICT_EXPORTABLE int Get_Rgbai_Pixel(const PICTURE *pict, uint32_t x, uint32_t y, PIXEL_RGBAi *pixel);
LIBPICT_EXPORTABLE int Get_Rgbaf_Pixel(const PICTURE *pict, uint32_t x, uint32_t y, PIXEL_RGBAf *pixel);
LIBPICT_EXPORTABLE int Get_Rgba8_Pixel(const PICTURE *pict, uint32_t x, uint32_t y, PIXEL_RGBA8 *pixel);
LIBPICT_EXPORTABLE int Set_Rgbai_Pixel(PICTURE *pict, uint32_t x, uint32_t y, const PIXEL_RGBAi *pixel);
LIBPICT_EXPORTABLE int Set_Rgbaf_Pixel(PICTURE *pict, uint32_t x, uint32_t y, const PIXEL_RGBAf *pixel);
LIBPICT_EXPORTABLE int Set_Rgba8_Pixel(PICTURE *pict, uint32_t x, uint32_t y, const PIXEL_RGBA8 *pixel);

LIBPICT_EXPORTABLE void Picture_Kill_Buffer(PICTURE *pict);
LIBPICT_EXPORTABLE int Picture_Allocate_Buffer(PICTURE *pict);

LIBPICT_EXPORTABLE void Convert_Pixels_Row(
    const uint8_t *src, int src_format,
    uint8_t *dst, int dst_format,
    size_t count);

LIBPICT_EXPORTABLE void Convert_Pixels_Row_Pal(
    const uint8_t *src, int src_format,
    uint8_t *dst, int dst_format,
    size_t count,
    const void *pal,
    size_t pal_count);

#ifdef _WIN32
LIBPICT_EXPORTABLE void *Create_HBITMAP(const PICTURE *pict);
#endif

LIBPICT_EXPORTABLE int Picture_From_BMP(PICTURE *pict, const void *bytes, size_t count, int format);
LIBPICT_EXPORTABLE int Picture_From_PNG(PICTURE *pict, const void *bytes, size_t count, int format);

#ifdef __cplusplus
}
#endif

#endif /* C_once_D02B3778_0F00_417B_9CEF_8757BC2676E8 */

