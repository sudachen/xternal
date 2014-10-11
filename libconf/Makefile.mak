TOPDIR = ..
PROJECT=libconf
!INCLUDE $(TOPDIR)\Make.rules.mak
SRCDIR = src

CCFLAGS=$(CCFLAGS) -D_CBUFFER_PREFIX=_LIBCONF_CBUFFER_ -D_CDICTO_PREFIX=_LIBCONF_CDICTO_
INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)\include

OBJECTS = \
	$(OBJDIR)\xnode.obj \
	$(OBJDIR)\nodeformat.obj \
	$(OBJDIR)\crc8.obj \
	$(OBJDIR)\cdicto.obj \
	$(OBJDIR)\cbuffer.obj \

#	$(OBJDIR)\xmlpars.obj \

!if "$(STATIC_LIB)"!="YES"
DLL_OPTS=-DLIBCONF_BUILD_DLL -DLIBCONF_DLL
LIBRARIES=
!endif

$(SRCDIR)\README:
	@7z x -o$(SRCDIR) libconf.lzma

$(TARGET): $(SRCDIR)\README $(OBJECTS)
	$(METALINK) $(OBJECTS) $(LIBRARIES)
	-del $(EXPNAME)

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) $(DLL_OPTS) $(INCL) -Fo$@ $<

clean:
	-del /q $(OBJECTS)
	-del /q $(DLLNAME) $(LIBNAME) $(PDBNAME) $(EXPNAME)
