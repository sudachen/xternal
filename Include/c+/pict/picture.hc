
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_E194EBE7_E43F_4305_A75C_3872532B12DB
#define C_once_E194EBE7_E43F_4305_A75C_3872532B12DB

#ifdef _BUILTIN
#define _C_PICTURE_BUILTIN
#endif

#ifdef _MSC_VER
#pragma comment (lib, "user32.lib")
#pragma comment (lib, "gdi32.lib")
#endif

#include "../C+.hc"

enum
  {
    C_PAL8_PICTURE  = __FOUR_CHARS('P',1,'8',0),
    C_RGBAf_PICTURE = __FOUR_CHARS('R',16,'f','A'),
    C_RGB8_PICTURE  = __FOUR_CHARS('R',3,'8',0),
    C_RGB5_PICTURE  = __FOUR_CHARS('R',2,'5',0),
    C_RGB6_PICTURE  = __FOUR_CHARS('R',2,'6',0),
    C_RGBA8_PICTURE = __FOUR_CHARS('R',4,'8','A'),
    C_RGBX8_PICTURE = __FOUR_CHARS('R',4,'8',0),
    C_RGB5A1_PICTURE= __FOUR_CHARS('R',2,'5','A'),
    C_BGR8_PICTURE  = __FOUR_CHARS('B',3,'8',0),
    C_BGR5_PICTURE  = __FOUR_CHARS('B',2,'5',0),
    C_BGR6_PICTURE  = __FOUR_CHARS('B',2,'6',0),
    C_BGRA8_PICTURE = __FOUR_CHARS('B',4,'8','A'),
    C_BGRX8_PICTURE = __FOUR_CHARS('B',4,'8',0),
    C_BGR5A1_PICTURE= __FOUR_CHARS('B',2,'5','A'),
  };

#define Pict_Format_Bytes_PP(Fmt) ((Fmt>>8)&0x0ff)
#define Pict_Format_Alpha(Fmt) (((Fmt>>24)&0x0ff) == 'A')

typedef struct _C_PICTURE
  {
    int width;
    int height;
    int pitch;
    int weight;
    int format;
    byte_t *pixels;
  } C_PICTURE;

void C_PICTURE_Destruct(C_PICTURE *pict)
#ifdef _C_PICTURE_BUILTIN
  {
    free(pict->pixels);
    __Destruct(pict);
  }
#endif
  ;

typedef struct _C_RGBA8
  {
    byte_t r;
    byte_t g;
    byte_t b;
    byte_t a;
  } C_RGBA8;

typedef struct _C_BGRA8
  {
    byte_t b;
    byte_t g;
    byte_t r;
    byte_t a;
  } C_BGRA8;

typedef struct _C_RGBAf
  {
    float r;
    float g;
    float b;
    float a;
  } C_RGBAf;

typedef struct _C_RGB8
  {
    byte_t r;
    byte_t g;
    byte_t b;
  } C_RGB8;

typedef struct _C_BGR8
  {
    byte_t b;
    byte_t g;
    byte_t r;
  } C_BGR8;

C_RGBA8 Pict_Get_RGBA8_Pixel(byte_t *ptr, int format)
#ifdef _C_PICTURE_BUILTIN
  {
    switch ( format )
      {
        case C_RGBA8_PICTURE:
          return *(C_RGBA8*)ptr;
        case C_RGB8_PICTURE:
          {
            C_RGBA8 rgba;
            rgba.r = ((C_RGB8*)ptr)->r;
            rgba.g = ((C_RGB8*)ptr)->g;
            rgba.b = ((C_RGB8*)ptr)->b;
            rgba.a = 0xff;
            return rgba;
          }
        case C_RGBX8_PICTURE:
          {
            C_RGBA8 rgba;
            rgba.r = ((C_RGB8*)ptr)->r;
            rgba.g = ((C_RGB8*)ptr)->g;
            rgba.b = ((C_RGB8*)ptr)->b;
            rgba.a = 0xff;
            return rgba;
          }
        case C_BGR8_PICTURE:
          {
            C_RGBA8 rgba;
            rgba.r = ((C_BGR8*)ptr)->r;
            rgba.g = ((C_BGR8*)ptr)->g;
            rgba.b = ((C_BGR8*)ptr)->b;
            rgba.a = 0xff;
            return rgba;
          }
        case C_BGRX8_PICTURE:
          {
            C_RGBA8 rgba;
            rgba.r = ((C_BGRA8*)ptr)->r;
            rgba.g = ((C_BGRA8*)ptr)->g;
            rgba.b = ((C_BGRA8*)ptr)->b;
            rgba.a = 0xff;
            return rgba;
          }
        case C_BGRA8_PICTURE:
          {
            C_RGBA8 rgba;
            rgba.r = ((C_BGRA8*)ptr)->r;
            rgba.g = ((C_BGRA8*)ptr)->g;
            rgba.b = ((C_BGRA8*)ptr)->b;
            rgba.a = ((C_BGRA8*)ptr)->a;
            return rgba;
          }
        case C_RGBAf_PICTURE:
          {
            C_RGBA8 rgba;
            rgba.r = (byte_t)(C_MAX(((C_RGBAf*)ptr)->r + .5f ,1.f) * 255.f);
            rgba.g = (byte_t)(C_MAX(((C_RGBAf*)ptr)->g + .5f ,1.f) * 255.f);
            rgba.b = (byte_t)(C_MAX(((C_RGBAf*)ptr)->b + .5f ,1.f) * 255.f);
            rgba.a = (byte_t)(C_MAX(((C_RGBAf*)ptr)->a + .5f ,1.f) * 255.f);
            return rgba;
          }
        default:
          {
            C_RGBA8 rgba = {0};
            __Raise(C_ERROR_UNSUPPORTED,"bad pixel format");
            return rgba;
          }
      }
  }
#endif
  ;

u32_t Pict_Get_Pixel(byte_t *ptr, int format)
#ifdef _C_PICTURE_BUILTIN
  {
    C_RGBA8 c = Pict_Get_RGBA8_Pixel(ptr,format);
    return Four_To_Unsigned(&c);
  }
#endif
  ;

C_RGBA8 Pict_Get_RGBA8(C_PICTURE *pict, int x, int y)
#ifdef _C_PICTURE_BUILTIN
  {
    byte_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    
    if ( pict->format == C_RGBA8_PICTURE )
      return *(C_RGBA8*)ptr;
    
    return Pict_Get_RGBA8_Pixel(ptr, pict->format);
  }
#endif
  ;

u32_t Pict_Get_Pixel_At(C_PICTURE *pict, int x, int y)
#ifdef _C_PICTURE_BUILTIN
  {
    C_RGBA8 c = Pict_Get_RGBA8(pict,x,y);
    return Four_To_Unsigned(&c);
  }
#endif
  ;

C_RGBAf Pict_Get_RGBAf_Pixel(byte_t *ptr, int format)
#ifdef _C_PICTURE_BUILTIN
  {
    if ( format == C_RGBAf_PICTURE )
      return *(C_RGBAf*)ptr;
    else if ( format == C_RGBA8_PICTURE )
      {
        C_RGBAf rgba;
        rgba.r = (((C_RGBA8*)ptr)->r + .5f) / 255.f;
        rgba.g = (((C_RGBA8*)ptr)->g + .5f) / 255.f;
        rgba.b = (((C_RGBA8*)ptr)->b + .5f) / 255.f;
        rgba.a = (((C_RGBA8*)ptr)->a + .5f) / 255.f;
        return rgba;
      }
    else
      {
        C_RGBA8 tmp = Pict_Get_RGBA8_Pixel(ptr,format);
        C_RGBAf rgba;
        rgba.r = (tmp.r + .5f) / 255.f;
        rgba.g = (tmp.g + .5f) / 255.f;
        rgba.b = (tmp.b + .5f) / 255.f;
        rgba.a = (tmp.a + .5f) / 255.f;
        return rgba;
      }
  }
#endif
  ;

void Pict_Set_RGBA8_Pixel(byte_t *ptr, C_RGBA8 pix, int format)
#ifdef _C_PICTURE_BUILTIN
  {
    switch ( format )
      {
        case C_RGBA8_PICTURE:
          *(C_RGBA8*)ptr = pix;
          break;
        case C_RGB8_PICTURE:
          ((C_RGB8*)ptr)->r = pix.r;
          ((C_RGB8*)ptr)->g = pix.g;
          ((C_RGB8*)ptr)->b = pix.b;
          break;
        case C_RGBX8_PICTURE:
          ((C_RGBA8*)ptr)->r = pix.r;
          ((C_RGBA8*)ptr)->g = pix.g;
          ((C_RGBA8*)ptr)->b = pix.b;
          ((C_RGBA8*)ptr)->a = 0;
          break;
        case C_BGR8_PICTURE:
          ((C_BGRA8*)ptr)->r = pix.r;
          ((C_BGRA8*)ptr)->g = pix.g;
          ((C_BGRA8*)ptr)->b = pix.b;
          break;
        case C_BGRX8_PICTURE:
          ((C_BGRA8*)ptr)->r = pix.r;
          ((C_BGRA8*)ptr)->g = pix.g;
          ((C_BGRA8*)ptr)->b = pix.b;
          ((C_BGRA8*)ptr)->a = 0;
          break;
        case C_BGRA8_PICTURE:
          ((C_BGRA8*)ptr)->r = pix.r;
          ((C_BGRA8*)ptr)->g = pix.g;
          ((C_BGRA8*)ptr)->b = pix.b;
          ((C_BGRA8*)ptr)->a = pix.a;
          break;
        case C_RGBAf_PICTURE:
          ((C_RGBAf*)ptr)->r = (pix.r + .5f) / 255.f;
          ((C_RGBAf*)ptr)->g = (pix.g + .5f) / 255.f;
          ((C_RGBAf*)ptr)->b = (pix.b + .5f) / 255.f;
          ((C_RGBAf*)ptr)->a = (pix.a + .5f) / 255.f;
          break;
        default:
          __Raise(C_ERROR_UNSUPPORTED,"bad pixel format");
      }
  }
#endif
  ;

void Pict_Set_RGBA8(C_PICTURE *pict, int x, int y, C_RGBA8 pix)
#ifdef _C_PICTURE_BUILTIN
  {
    byte_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    
    if ( pict->format == C_RGBA8_PICTURE )
      *(C_RGBA8*)ptr = pix;
    
    Pict_Set_RGBA8_Pixel(pict->pixels + (pict->pitch * y + x * pict->weight), pix, pict->format);
  }
#endif
  ;

void Pict_Allocate_Buffer(C_PICTURE *pict)
#ifdef _C_PICTURE_BUILTIN
  {
    if ( pict->pixels ) 
      __Raise(C_ERROR_ALREADY_EXISTS,"pixel buffer already exists");
    
    switch( pict->format )
      {
        case C_RGBA8_PICTURE:
        case C_RGBX8_PICTURE:
          pict->pitch  = sizeof(C_RGBA8)*pict->width;
          pict->weight = sizeof(C_RGBA8);
          break;
        case C_RGB8_PICTURE:
          pict->pitch  = sizeof(C_RGB8)*pict->width;
          pict->weight = sizeof(C_RGB8);
          break;
        case C_BGRA8_PICTURE:
        case C_BGRX8_PICTURE:
          pict->pitch  = sizeof(C_BGRA8)*pict->width;
          pict->weight = sizeof(C_BGRA8);
          break;
        case C_BGR8_PICTURE:
          pict->pitch  = sizeof(C_BGR8)*pict->width;
          pict->weight = sizeof(C_BGR8);
          break;
        case C_RGBAf_PICTURE:
          pict->pitch  = sizeof(C_RGBAf)*pict->width;
          pict->weight = sizeof(C_RGBAf);
          break;
        default:
          __Raise(C_ERROR_UNSUPPORTED,"bad pixel format");
      }
      
    pict->pixels = __Malloc_Npl(pict->pitch*pict->height);
  }
#endif
  ;
  
void Pict_Nullify_Transparent_Pixels(C_PICTURE *pict, byte_t threshold)
#ifdef _C_PICTURE_BUILTIN
  {
    if ( pict->format == C_RGBA8_PICTURE || pict->format == C_BGRA8_PICTURE )
      {
        int i;
        for ( i = 0; i < pict->height; ++i )
          {
            C_RGBA8 *pixel = (C_RGBA8 *)(pict->pixels+i*pict->pitch);
            C_RGBA8 *pixelE = pixel+pict->width;
            for ( ; pixel < pixelE; ++pixel  )
              if ( pixel->a < threshold ) 
                memset(pixel,0,sizeof(*pixel));
          }
      }
  }
#endif
  ;
  
void Pict_Kill_Transparent_Pixels(C_PICTURE *pict, u32_t color)
#ifdef _C_PICTURE_BUILTIN
  {
    if ( pict->format == C_RGBA8_PICTURE || pict->format == C_BGRA8_PICTURE )
      {
        int i;
        
        if ( pict->format == C_BGRA8_PICTURE )
          {
             color = (color & 0x0ff00) 
                   | ((color & 0x0ff)<<16)
                   | ((color & 0x0ff0000)>>16);
          }
          
        for ( i = 0; i < pict->height; ++i )
          {
            C_RGBA8 *pixel = (C_RGBA8 *)(pict->pixels+i*pict->pitch);
            C_RGBA8 *pixelE = pixel+pict->width;
            for ( ; pixel < pixelE; ++pixel  )
              {
                u32_t b = Four_To_Unsigned(pixel) & 0x00ffffff;
                if ( b == color ) 
                  memset(pixel,0,sizeof(*pixel));
              }
          }
      }
  }
#endif
  ;

void Pict_Convert_Pixels_Row(byte_t *src, int src_format, byte_t *dst, int dst_format, int count )
#ifdef _C_PICTURE_BUILTIN
  {
    int i;
    int src_weight = ((src_format >> 8) & 0x0ff);
    int dst_weight = ((dst_format >> 8) & 0x0ff);
    byte_t *src_pixel = src;
    byte_t *dst_pixel = dst;
    if ( src_format == dst_format )
      {
        memcpy(dst,src,count*dst_weight);
      }
    else if ( dst_format  == C_RGBAf_PICTURE )
      for ( i = 0; i < count; ++i )
        {
          *(C_RGBAf*)dst_pixel = Pict_Get_RGBAf_Pixel(src_pixel,src_format);
          src_pixel += src_weight;
          dst_pixel += dst_weight;
        }
    else if ( dst_format  == C_RGBA8_PICTURE )
      for ( i = 0; i < count; ++i )
        {
          *(C_RGBA8*)dst_pixel = Pict_Get_RGBA8_Pixel(src_pixel,src_format);
          src_pixel += src_weight;
          dst_pixel += dst_weight;
        }
    else
      for ( i = 0; i < count; ++i )
        {
          C_RGBA8 tmp = Pict_Get_RGBA8_Pixel(src_pixel,src_format);
          Pict_Set_RGBA8_Pixel(dst_pixel,tmp,dst_format);
          src_pixel += src_weight;
          dst_pixel += dst_weight;
        }
  }
#endif
  ;
  
void Pict_Convert_Pixels_Row_Pal(byte_t *src, int src_format, byte_t *dst, int dst_format, int count, void *pal, int pal_count )
#ifdef _C_PICTURE_BUILTIN
  {
    int i, bpp = Pict_Format_Bytes_PP(dst_format);
    byte_t palx[256*16]; /* sizeof(rgbaf) == 16 */
    Pict_Convert_Pixels_Row(pal,src_format,palx,dst_format,pal_count);
    if ( bpp == 4 )
      for ( i = 0; i < count; ++i )
        ((u32_t*)dst)[i] = ((u32_t*)palx)[src[i]];
    else if ( bpp == 2 )
      for ( i = 0; i < count; ++i )
        ((u32_t*)dst)[i] = ((u32_t*)palx)[src[i]];
    else
      for ( i = 0; i < count; ++i )
        memcpy((dst + i * bpp),palx + src[i]*bpp,bpp);
  }
#endif
  ;

#ifdef __windoze
HBITMAP Pict_Create_HBITMAP(C_PICTURE *pict)
#ifdef _C_PICTURE_BUILTIN
  {
    BITMAPINFOHEADER bi;
    HDC dc;
    HBITMAP bmp;
    byte_t *bits = 0;
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
    bmp = CreateDIBSection(dc, (BITMAPINFO*)&bi, DIB_RGB_COLORS, &bits, 0, 0);
    if ( pict->format == C_BGRA8_PICTURE )
      memcpy(bits,pict->pixels,bi.biSizeImage);
    else
      {
        int i;
        for ( i = 0; i < pict->height; ++i )
          Pict_Convert_Pixels_Row(
              pict->pixels+i*pict->pitch,pict->format,
              bits+pict->width*4*i,C_BGRA8_PICTURE,
              pict->width);          
      }
    ReleaseDC(0,dc);
    return bmp;
  }
#endif
  ;
#endif

#endif /* C_once_E194EBE7_E43F_4305_A75C_3872532B12DB */

