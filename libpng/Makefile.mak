TOPDIR = ..
PROJECT=libpng
!INCLUDE $(TOPDIR)\Make.rules.mak

INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)

OBJECTS = \
	$(OBJDIR)\png.obj \
	$(OBJDIR)\pngerror.obj \
	$(OBJDIR)\pngget.obj \
	$(OBJDIR)\pngmem.obj \
	$(OBJDIR)\pngread.obj \
	$(OBJDIR)\pngpread.obj \
	$(OBJDIR)\pngrio.obj \
	$(OBJDIR)\pngrtran.obj \
	$(OBJDIR)\pngrutil.obj \
	$(OBJDIR)\pngset.obj \
	$(OBJDIR)\pngtrans.obj \
	$(OBJDIR)\pngwio.obj \
	$(OBJDIR)\pngwrite.obj \
	$(OBJDIR)\pngwtran.obj \
	$(OBJDIR)\pngwutil.obj

!if "$(STATIC_LIB)"!="YES"
PNG_DLL=-DPNG_BUILD_DLL -DZLIB_DLL
LIBRARIES=$(LIBDIR)\zlib$(LIBSFX).lib
!endif

$(SRCDIR)\README:
	@7z x -o$(SRCDIR) libpng.lzma
	del $(SRCDIR)\pnglibconf.h 

$(TARGET): $(SRCDIR)\README $(OBJECTS)
	$(METALINK) $(OBJECTS) $(LIBRARIES)
	-del $(EXPNAME)

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) $(PNG_DLL) $(INCL) -Fo$@ $<

clean:
	-del $(OBJECTS)
	-del $(DLLNAME) $(LIBNAME) $(PDBNAME) $(EXPNAME)
