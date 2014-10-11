TOPDIR = ..
PROJECT=libpe
!INCLUDE $(TOPDIR)\Make.rules.mak
SRCDIR = src

CCFLAGS=$(CCFLAGS) -D_CBUFFER_PREFIX=_LIBPE_CBUFFER_ -D_CTABLE_PREFIX=_LIBPE_CTABLE_ -D_CDICTO_PREFIX=_LIBPE_CDICTO_
INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)\include

OBJECTS = \
	$(OBJDIR)\libpe.obj \
	$(OBJDIR)\ctable.obj \
	$(OBJDIR)\cbuffer.obj \

#	$(OBJDIR)\xmlpars.obj \

!if "$(STATIC_LIB)"!="YES"
DLL_OPTS=-DLIBPE_BUILD_DLL -DLIBPE_DLL
LIBRARIES=
!endif

$(SRCDIR)\README:
	@7z x -o$(SRCDIR) libpe.lzma

$(TARGET): $(SRCDIR)\README $(OBJECTS)
	$(METALINK) $(OBJECTS) $(LIBRARIES)
	-del $(EXPNAME)

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) $(DLL_OPTS) $(INCL) -Fo$@ $<

clean:
	-del /q $(OBJECTS)
	-del /q $(DLLNAME) $(LIBNAME) $(PDBNAME) $(EXPNAME)
