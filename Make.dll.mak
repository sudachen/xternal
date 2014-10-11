
INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)\include

!if "$(SOURCE_ZIP)"!=""
unpack: $(SRCDIR)\README
$(SRCDIR)\README:
	@7z x -o$(SRCDIR) "$(SOURCE_ZIP)"
!else
unpack:
!endif

$(TARGET): unpack $(OBJECTS)
	$(METALINK) $(OBJECTS) $(LIBRARIES)
	-del $(EXPNAME)

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) $(DLL_OPTS) $(INCL) -Fo$@ $<
{$(SRCDIR)}.cpp{$(OBJDIR)}.obj:
	$(CC) -c $(CCXFLAGS) $(DLL_OPTS) $(INCL) -Fo$@ $<
{$(SRCDIR)}.S{$(OBJDIR)}.obj:
	$(AS) $(ASFLAGS) -o$@ $<

clean:
	-del $(OBJECTS)
	-del $(DLLNAME) $(LIBNAME) $(PDBNAME) $(EXPNAME)
