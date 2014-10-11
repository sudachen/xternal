TOPDIR = ..
PROJECT=zlib
!INCLUDE $(TOPDIR)\Make.rules.mak

INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)

OBJECTS = \
	$(OBJDIR)\adler32.obj \
	$(OBJDIR)\compress.obj \
	$(OBJDIR)\crc32.obj \
	$(OBJDIR)\deflate.obj \
	$(OBJDIR)\gzclose.obj \
	$(OBJDIR)\gzlib.obj \
	$(OBJDIR)\gzread.obj \
	$(OBJDIR)\gzwrite.obj \
	$(OBJDIR)\infback.obj \
	$(OBJDIR)\inflate.obj \
	$(OBJDIR)\inftrees.obj \
	$(OBJDIR)\inffast.obj \
	$(OBJDIR)\trees.obj \
	$(OBJDIR)\uncompr.obj \
	$(OBJDIR)\zutil.obj

!if "$(CPU)"=="X64"
OBJECTS = $(OBJECTS) $(OBJDIR)\gvmat64.obj $(OBJDIR)\inffasx64.obj $(OBJDIR)\inffas8664.obj
!else
OBJECTS = $(OBJECTS) $(OBJDIR)\inffas32.obj $(OBJDIR)\match686.obj
!endif

!if "$(STATIC_LIB)"!="YES"
ZLIB_DLL=-DZLIB_DLL -DZLIB_INTERNAL
!endif

$(SRCDIR)\README:
	@7z x -o$(SRCDIR) zlib.lzma

$(TARGET): $(SRCDIR)\README $(OBJECTS)
	$(METALINK) $(OBJECTS)
	-del $(EXPNAME)

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) -DASMV -DASMINF $(INCL) -Fo$@ $< 

{$(SRCDIR)\contrib\masmx64}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) -DASMV -DASMINF $(INCL) -Fo$@ $<

{$(SRCDIR)\contrib\masmx64}.asm{$(OBJDIR)}.obj:
	ml64 -c -DASMV -DASMINF -Fo$@ $<

{$(SRCDIR)\contrib\masmx86}.asm{$(OBJDIR)}.obj:
	ml -c -DASMV -DASMINF -Fo$@ $<

clean:
	-del $(OBJECTS)
	-del $(DLLNAME) $(LIBNAME) $(PDBNAME) $(EXPNAME)
