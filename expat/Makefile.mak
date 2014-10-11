TOPDIR = ..
PROJECT=expat
TARGET=ALL
!INCLUDE $(TOPDIR)\Make.rules.mak

DLLNAME1=$(BINDIR)\$(PROJECT)a$(DLLSFX).dll
LIBNAME1=$(LIBDIR)\$(PROJECT)a$(LIBSFX).lib
EXPNAME1=$(LIBDIR)\$(PROJECT)a$(LIBSFX).exp
!if "$(STATIC)" == "YES"
PDBNAME1=$(PDBDIR)\$(PROJECT)a$(LIBSFX).pdb
LPDBNAME1=$(PDBDIR)\$(PROJECT)a$(LIBSFX).pdb
!else
PDBNAME1=$(PDBDIR)\$(PROJECT)a$(DLLSFX).pdb
LPDBNAME1=$(TMPDIR)\$(PROJECT)a$(LIBSFX).pdb
!endif

DLLNAME2=$(BINDIR)\$(PROJECT)w$(DLLSFX).dll
LIBNAME2=$(LIBDIR)\$(PROJECT)w$(LIBSFX).lib
EXPNAME2=$(LIBDIR)\$(PROJECT)w$(LIBSFX).exp
!if "$(STATIC)" == "YES"
PDBNAME2=$(PDBDIR)\$(PROJECT)w$(LIBSFX).pdb
LPDBNAME2=$(PDBDIR)\$(PROJECT)w$(LIBSFX).pdb
!else
PDBNAME2=$(PDBDIR)\$(PROJECT)w$(DLLSFX).pdb
LPDBNAME2=$(TMPDIR)\$(PROJECT)w$(LIBSFX).pdb
!endif

INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)\lib

OBJECTS1 = \
	$(OBJDIR)\1\xmlparse.obj \
	$(OBJDIR)\1\xmlrole.obj \
	$(OBJDIR)\1\xmltok.obj \
	$(OBJDIR)\1\xmltok_impl.obj \
	$(OBJDIR)\1\xmltok_ns.obj \

OBJECTS2 = \
	$(OBJDIR)\2\xmlparse.obj \
	$(OBJDIR)\2\xmlrole.obj \
	$(OBJDIR)\2\xmltok.obj \
	$(OBJDIR)\2\xmltok_impl.obj \
	$(OBJDIR)\2\xmltok_ns.obj \

!if "$(STATIC_LIB)"!="YES"
EXPAT_DLL=-DXML_BUILDING_EXPAT
!else
EXPAT_DLL=-DXML_BUILDING_EXPAT -DXML_STATIC
!endif

!if "$(STATIC)" == "YES" 
ALL: $(SRCDIR)\README $(LIBNAME1) $(LIBNAME2)
!else
#ALL: $(SRCDIR)\README $(DLLNAME1) $(DLLNAME2)
ALL: $(SRCDIR)\README $(DLLNAME2)
!endif

$(SRCDIR)\README:
	@7z x -o$(SRCDIR) expat.lzma

$(LIBNAME1) : $(OBJDIR)\1 $(OBJECTS1)
	$(LIBLINK) /out:$(LIBNAME1) $(OBJECTS1)
$(LIBNAME2) : $(OBJDIR)\2 $(OBJECTS2)
	$(LIBLINK) /out:$(LIBNAME2) $(OBJECTS2)
$(DLLNAME1) : $(OBJDIR)\1 $(OBJECTS1)
	$(DLLLINK) /pdb:$(PDBNAME1) /implib:$(LIBNAME1) /out:$(DLLNAME1) $(OBJECTS1) /def:$(SRCDIR)\lib\libexpat.def
	-del $(EXPNAME1)
$(DLLNAME2) : $(OBJDIR)\2 $(OBJECTS2)
	$(DLLLINK) /pdb:$(PDBNAME2) /implib:$(LIBNAME2) /out:$(DLLNAME2) $(OBJECTS2) /def:$(SRCDIR)\lib\libexpatw.def
	-del $(EXPNAME2)

$(OBJDIR)\1 $(OBJDIR)\2:
	@if not exist $@ md $@

{$(SRCDIR)\lib}.c{$(OBJDIR)\1}.obj:
	$(CC) -c -DCOMPILED_FROM_DSP $(CCFLAGS) $(EXPAT_DLL) $(INCL) -Fo$@ $< /Fd$(LPDBNAME1)

{$(SRCDIR)\lib}.c{$(OBJDIR)\2}.obj:
	$(CC) -c -DCOMPILED_FROM_DSP  $(CCFLAGS) $(EXPAT_DLL) $(INCL) -DXML_UNICODE_WCHAR_T -Fo$@ $< /Fd$(LPDBNAME2)

clean:
	-del $(OBJECTS1) $(OBJECTS2)
	-del $(DLLNAME1) $(LIBNAME1) $(PDBNAME1) $(EXPNAME1)
	-del $(DLLNAME2) $(LIBNAME2) $(PDBNAME2) $(EXPNAME2)
