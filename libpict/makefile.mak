
TOPDIR  = ..
PROJECT = libpict
SRCDIR  = src

!INCLUDE $(TOPDIR)\Make.rules.mak

OBJECTS = \
    $(OBJDIR)\picture.obj \
    $(OBJDIR)\bmp.obj \
    $(OBJDIR)\png.obj \

!if "$(STATIC_LIB)"!="YES"
DLL_OPTS=-DLIBPICT_BUILD_DLL
LIBRARIES= libpng$(LIBSFX).lib zlib$(LIBSFX).lib user32.lib gdi32.lib
!else
DLL_OPTS=-DLIBPICT_STATIC
!endif

!include $(TOPDIR)\Make.dll.mak



