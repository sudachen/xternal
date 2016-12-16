
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_F02ABD1D_F661_464B_8226_CBED6A3DA7CE
#define C_once_F02ABD1D_F661_464B_8226_CBED6A3DA7CE

#ifdef _BUILTIN
#define _C_PICTBMP_BUILTIN
#endif

#include "../buffer.hc"
#include "../file.hc"
#include "picture.hc"  

#ifdef _C_PICTBMP_BUILTIN

enum { C_BI_BITFIELDS = 3, C_BI_RGB = 0, };

#pragma pack(push,2)
typedef struct _C_BITMAPFILEHEADER 
  {
    u16_t  bfType;
    u32_t  bfSize;
    u16_t  bfReserved1;
    u16_t  bfReserved2;
    u32_t  bfOffBits;
  } C_BITMAPFILEHEADER;
typedef struct _C_BITMAPINFOHEADER
  {
    u32_t  biSize;
    i32_t  biWidth;
    i32_t  biHeight;
    u16_t  biPlanes;
    u16_t  biBitCount;
    u32_t  biCompression;
    u32_t  biSizeImage;
    i32_t  biXPelsPerMeter;
    i32_t  biYPelsPerMeter;
    u32_t  biClrUsed;
    u32_t  biClrImportant;
  } C_BITMAPINFOHEADER;
#pragma pack(pop)

#endif

#define Pict_From_BMP(Bytes,Count) Pict_From_BMP_Specific(Bytes,Count,C_RGBA8_PICTURE)
C_PICTURE *Pict_From_BMP_Specific(void *bytes, int count, int format)
#ifdef _C_PICTBMP_BUILTIN
  {
    C_PICTURE *pict = __Object_Dtor(sizeof(C_PICTURE),C_PICTURE_Destruct);
    pict->format = format;

    if ( !pict->format ) pict->format = C_RGBA8_PICTURE;
    
    __Auto_Release
      {
        C_BITMAPFILEHEADER *bmFH = bytes;
        C_BITMAPINFOHEADER *bmIH = (C_BITMAPINFOHEADER *)((char*)bytes + sizeof(C_BITMAPFILEHEADER));
        u32_t  *palette = (u32_t*)((char*)bmIH+bmIH->biSize);
        byte_t *image  = (byte_t*)bmFH+bmFH->bfOffBits;
        
        if ( (bmFH->bfType == 0x4D42) && (bmFH->bfSize <= count) )
          {
            int bpp = (bmIH->biBitCount/8);
            int stride, jformat, i;
            byte_t *row = 0;
            if ( bmIH->biCompression != C_BI_RGB )
              __Raise(C_ERROR_CORRUPTED,"supporting BI_RGB comression bitmaps only");
            
            switch ( bmIH->biBitCount )
              {
                case 32: jformat = C_BGRA8_PICTURE; break;
                case 24: jformat = C_BGR8_PICTURE; break;
                case 8:  jformat = C_PAL8_PICTURE; break;
                case 16:
                  if ( bmIH->biCompression == C_BI_BITFIELDS && palette[1] != 0x03e0 )
                    jformat = C_BGR6_PICTURE;
                  else
                    jformat = C_BGR5A1_PICTURE; 
                  break;
                default:
                  __Raise_Format(C_ERROR_CORRUPTED,("bitCount %d is not supported",bmIH->biBitCount));
              }
            
            stride = (bmIH->biWidth*Pict_Format_Bytes_PP(jformat) + 3) & ~3;
            pict->width  = bmIH->biWidth;
            pict->height = C_Absi(bmIH->biHeight); /* sign selects direction of rendering rows down-to-up or up-to-down*/
            Pict_Allocate_Buffer(pict);

            for ( i = 0; i < pict->height; ++i )
              {
                int l = (bmIH->biHeight < 0) ? i : pict->height - i - 1; 
                if ( jformat != pict->format )
                  {
                    if ( jformat == C_PAL8_PICTURE )
                      Pict_Convert_Pixels_Row_Pal(
                        image + l*stride, C_BGRX8_PICTURE,
                        pict->pixels+i*pict->pitch, pict->format,
                        pict->width,
                        palette, bmIH->biClrUsed);
                    else
                      Pict_Convert_Pixels_Row(
                        image + l*stride, jformat,
                        pict->pixels+i*pict->pitch, pict->format,
                        pict->width);
                  }
                else
                  memcpy(pict->pixels+i*pict->pitch, image + l*stride, pict->width*Pict_Format_Bytes_PP(jformat));
              }
          }
      }
      
    return pict;
  }
#endif
  ;
  
#define Pict_From_BMP_File(Filename) Pict_From_BMP_File_Specific(Filename,C_RGBA8_PICTURE)
C_PICTURE *Pict_From_BMP_File_Specific(char *filename, int format)
#ifdef _C_PICTBMP_BUILTIN
  {
    C_PICTURE *pict = 0;
    __Auto_Ptr(pict)
      {
        C_BUFFER *bf = Oj_Read_All(Cfile_Open(filename,"r"));
        pict = Pict_From_BMP_Specific(bf->at,bf->count,format);
      }
    return pict;
  }
#endif
  ;

#endif /* C_once_F02ABD1D_F661_464B_8226_CBED6A3DA7CE */
