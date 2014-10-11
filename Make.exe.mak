
INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)\include

!if "$(SOURCE_ZIP)"!=""
UNPACK = unpack
!else
UNPACK =
!endif

unpack: $(SRCDIR)\README
$(SRCDIR)\README:
	@7z x -o$(SRCDIR) "$(SOURCE_ZIP)"

$(TARGETNAME): $(UNPACK) $(OBJECTS)
	$(METALINK) $(OBJECTS) $(LIBRARIES)

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) $(DLL_OPTS) $(INCL) -Fo$@ $<
{$(SRCDIR)}.cpp{$(OBJDIR)}.obj:
	$(CC) -c $(CCXFLAGS) $(DLL_OPTS) $(INCL) -Fo$@ $<
{$(SRCDIR)}.rc{$(OBJDIR)}.obj:
	$(RC) /fo$@ $<

clean:
	-del $(OBJECTS)
	-del $(DLLNAME) $(LIBNAME) $(PDBNAME) $(EXPNAME)
