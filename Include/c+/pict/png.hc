
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_324CA35F_3399_4699_91FD_FC523999882D
#define C_once_324CA35F_3399_4699_91FD_FC523999882D

#ifdef _BUILTIN
#define _C_PICTPNG_BUILTIN
#endif

#include "picture.hc"

#ifdef _C_PICTPNG_BUILTIN
#include <png.h>

#if PNG_LIBPNG_VER_SONUM >= 15
# include <pngstruct.h>
#endif

static void Pict_From_PNG_Read_Data(png_structp png_ptr, void *dest, png_size_t count)
  {
    byte_t **p = png_ptr->io_ptr;
    if ( *p + count > p[1] ) 
      png_error(png_ptr, "png read error in Pict_From_PNG_Read_Data"); 
    memcpy(dest,*p,count);
    *p += count;
  }

#endif

#define Pict_From_PNG(Bytes,Count) \
            Pict_From_PNG_Specific_Rect( \
                Bytes,Count,C_RGBA8_PICTURE,0,0,-1,-1)
            
#define Pict_From_PNG_Specific(Bytes,Count,Fmt) \
            Pict_From_PNG_Specific_Rect( \
                Bytes,Count,Fmt,0,0,-1,-1)

C_PICTURE *Pict_From_PNG_Specific_Rect(
  void *bytes, int count
, int format
, int left, int top
, int width, int height)
#ifdef _C_PICTPNG_BUILTIN
  {
    C_PICTURE *pict = __Object_Dtor(sizeof(C_PICTURE),C_PICTURE_Destruct);
    pict->format = format;
    
    __Auto_Release
      {
        png_struct *png_ptr;
        png_info   *info_ptr;
        byte_t     *read_ptr[2];
        byte_t     *row = 0;
        int stride;
        int jformat;
        int i;
        int png_width;
        int png_height;
        int bpp;
        
        if ( !png_check_sig(bytes,8) )
          __Raise(C_ERROR_UNSUPPORTED,"is not PNG image");

        png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING,0,0,0);
        info_ptr = png_create_info_struct(png_ptr);
        
        if ( !setjmp(png_jmpbuf(png_ptr)) ) 
          {
            read_ptr[0] = (byte_t*)bytes+8;
            read_ptr[1] = (byte_t*)bytes+(count-8);
            png_set_read_fn(png_ptr,read_ptr,(png_rw_ptr)Pict_From_PNG_Read_Data);
            png_set_sig_bytes(png_ptr,8);
            png_read_info(png_ptr,info_ptr);
            png_set_strip_16(png_ptr);
            png_set_packing(png_ptr);
      
            if ( png_ptr->bit_depth < 8 
              || png_ptr->color_type == PNG_COLOR_TYPE_PALETTE
              || png_get_valid(png_ptr,info_ptr,PNG_INFO_tRNS) )
              png_set_expand(png_ptr);
      
            png_read_update_info(png_ptr,info_ptr);
            
            png_width = png_get_image_width(png_ptr,info_ptr);
            png_height = png_get_image_height(png_ptr,info_ptr);
            
            if ( width < 0 ) width = png_width;
            if ( height < 0 ) height = png_height;
            
            if ( left + width > png_width || left < 0 
              || top + height > png_height || top < 0 )
          rect_out_of_picture:
              __Raise_Format(C_ERROR_INVALID_PARAM
                            ,("rect (%d,%d)x(%d,%d) out of picture (%d,%d)"
                              ,left,top,width,height,png_width,png_height));
            
            pict->width  = width;
            pict->height = height;

            if (  png_ptr->color_type == PNG_COLOR_TYPE_RGB_ALPHA )
              bpp = 4;
            else 
              bpp = 3;

            stride = (bpp*png_width + 3) & ~3;
            jformat = (bpp==4?C_RGBA8_PICTURE:C_RGB8_PICTURE);
            if ( jformat != pict->format 
              || png_width != width || png_width != height )
              row = __Malloc(stride);
          }
        else
          {
            if ( !setjmp(png_jmpbuf(png_ptr)) )
              png_destroy_read_struct(&png_ptr,&info_ptr,0);
            __Raise(C_ERROR_CORRUPTED,"failed to decode PNG info");
          }
          
        Pict_Allocate_Buffer(pict);
        
        if ( !setjmp(png_jmpbuf(png_ptr)) ) 
          {
            for ( i = 0; i < top; ++i )
              png_read_row(png_ptr,row,0);
               
            for ( i = 0; i < pict->height; ++i )
              {
                if ( jformat != pict->format
                  || png_width != width )
                  {
                    png_read_row(png_ptr,row,0);
                    Pict_Convert_Pixels_Row(
                       row+bpp*left
                      ,jformat
                      ,pict->pixels+i*pict->pitch
                      ,pict->format
                      ,pict->width);
                  }
                else
                  png_read_row(png_ptr,pict->pixels+i*pict->pitch,0);
              }
            //png_read_end(png_ptr,info_ptr);
          }
        else
          {
            if ( !setjmp(png_jmpbuf(png_ptr)) )
              png_destroy_read_struct(&png_ptr,&info_ptr,0);
            __Raise(C_ERROR_CORRUPTED,"failed to decode PNG bits");
          }
      }
      
    return pict;
  }
#endif
  ;

#define Pict_From_PNG_File(Filename,Fmt) \
            Pict_From_PNG_File_Specific( \
                Filename,C_RGBA8_PICTURE,0,0,-1,-1)
#define Pict_From_PNG_File_Rect(Filename,Left,Top,Width,Height) \
            Pict_From_PNG_File_Specific_Rect( \
                Filename,C_RGBA8_PICTURE,Left,Top,Width,Height)
#define Pict_From_PNG_File_Specific(Filename,Fmt) \
            Pict_From_PNG_File_Specific_Rect( \
                Filename,Fmt,0,0,-1,-1)

C_PICTURE *Pict_From_PNG_File_Specific_Rect(
  char *filename
, int format
, int left, int top
, int width, int height )
#ifdef _C_PICTPNG_BUILTIN
  {
    C_PICTURE *pict = 0;
    __Auto_Ptr(pict)
      {
        C_BUFFER *bf = Oj_Read_All(Cfile_Open(filename,"r"));
        pict = Pict_From_PNG_Specific_Rect(
                    bf->at,bf->count,format,left,top,width,height);
      }
    return pict;
  }
#endif
  ;

#endif /* C_once_324CA35F_3399_4699_91FD_FC523999882D */

