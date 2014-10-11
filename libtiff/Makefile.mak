#
# Copyright (C) 2004, Andrey Kiselev <dron@ak4719.spb.edu>
#
# Permission to use, copy, modify, distribute, and sell this software and 
# its documentation for any purpose is hereby granted without fee, provided
# that (i) the above copyright notices and this permission notice appear in
# all copies of the software and related documentation, and (ii) the names of
# Sam Leffler and Silicon Graphics may not be used in any advertising or
# publicity relating to the software without the specific, prior written
# permission of Sam Leffler and Silicon Graphics.
# 
# THE SOFTWARE IS PROVIDED "AS-IS" AND WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS, IMPLIED OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY 
# WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  
# 
# IN NO EVENT SHALL SAM LEFFLER OR SILICON GRAPHICS BE LIABLE FOR
# ANY SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND,
# OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
# WHETHER OR NOT ADVISED OF THE POSSIBILITY OF DAMAGE, AND ON ANY THEORY OF 
# LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE 
# OF THIS SOFTWARE.
#

TOPDIR=..
PROJECT=libtiff
!INCLUDE $(TOPDIR)\Make.rules.mak

INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)
DEFS = -DJPEG_SUPPORT -DZIP_SUPPORT -DMDI_SUPPORT

OBJECTS	= \
	$(OBJDIR)\tif_aux.obj \
	$(OBJDIR)\tif_close.obj \
	$(OBJDIR)\tif_codec.obj \
	$(OBJDIR)\tif_color.obj \
	$(OBJDIR)\tif_compress.obj \
	$(OBJDIR)\tif_dir.obj \
	$(OBJDIR)\tif_dirinfo.obj \
	$(OBJDIR)\tif_dirread.obj \
	$(OBJDIR)\tif_dirwrite.obj \
	$(OBJDIR)\tif_dumpmode.obj \
	$(OBJDIR)\tif_error.obj \
	$(OBJDIR)\tif_extension.obj \
	$(OBJDIR)\tif_fax3.obj \
	$(OBJDIR)\tif_fax3sm.obj \
	$(OBJDIR)\tif_getimage.obj \
	$(OBJDIR)\tif_jbig.obj \
	$(OBJDIR)\tif_jpeg.obj \
	$(OBJDIR)\tif_jpeg_12.obj \
	$(OBJDIR)\tif_ojpeg.obj \
	$(OBJDIR)\tif_flush.obj \
	$(OBJDIR)\tif_luv.obj \
	$(OBJDIR)\tif_lzw.obj \
	$(OBJDIR)\tif_next.obj \
	$(OBJDIR)\tif_open.obj \
	$(OBJDIR)\tif_packbits.obj \
	$(OBJDIR)\tif_pixarlog.obj \
	$(OBJDIR)\tif_predict.obj \
	$(OBJDIR)\tif_print.obj \
	$(OBJDIR)\tif_read.obj \
	$(OBJDIR)\tif_stream.obj \
	$(OBJDIR)\tif_swab.obj \
	$(OBJDIR)\tif_strip.obj \
	$(OBJDIR)\tif_thunder.obj \
	$(OBJDIR)\tif_tile.obj \
	$(OBJDIR)\tif_version.obj \
	$(OBJDIR)\tif_warning.obj \
	$(OBJDIR)\tif_write.obj \
	$(OBJDIR)\tif_zip.obj \
	$(OBJDIR)\tif_win32.obj

$(SRCDIR)\tif_config.h: $(SRCDIR)\tif_config.vc.h
	copy $(SRCDIR)\tif_config.vc.h $(SRCDIR)\tif_config.h

$(SRCDIR)\tiffconf.h:	$(SRCDIR)\tiffconf.vc.h
	copy $(SRCDIR)\tiffconf.vc.h $(SRCDIR)\tiffconf.h

!if "$(STATIC_LIB)"!="YES"
LIBRARIES=$(LIBDIR)\zlib$(LIBSFX).lib $(LIBDIR)\libpng$(LIBSFX).lib $(LIBDIR)\libjpeg$(LIBSFX).lib user32.lib
EXPORTS=/def:$(SRCDIR)\libtiff.def
!endif

$(SRCDIR)\README:
	@7z x -o$(SRCDIR) libtiff.lzma

$(TARGET): $(SRCDIR)\README $(SRCDIR)\tif_config.h $(SRCDIR)\tiffconf.h $(SRCDIR)\libtiff.def $(OBJECTS)
	$(METALINK) $(OBJECTS) $(LIBRARIES) $(EXPORTS)
	-del $(EXPNAME)

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) $(INCL) $(DEFS) -Fo$@ $<
{$(SRCDIR)}.cxx{$(OBJDIR)}.obj:
	$(CCX) -c $(CCXFLAGS) $(INCL) $(DEFS) -Fo$@ $<

clean:
	-del $(OBJECTS)
	-del $(DLLNAME) $(LIBNAME) $(PDBNAME) $(EXPNAME)
