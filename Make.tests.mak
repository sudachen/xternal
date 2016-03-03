
!if "$(SOURCE_ZIP)"!=""
UNPACK = unpack
!else
UNPACK =
!endif

unpack: $(SRCDIR)\README
$(SRCDIR)\README:
	@7z x -o$(SRCDIR) "$(SOURCE_ZIP)"

$(TARGETNAME): $(UNPACK) $(TESTS)

{$(SRCDIR)}.c{$(TSTDIR)}.exe:
	$(CC) -c $(CCFLAGS) $(DLL_OPTS) $(INCL) -Fo$*.obj $<
	-del /q $*.pdb
	$(EXELINK) /pdb:$*.pdb /out:$@ $*.obj $(LIBRARIES)

{$(SRCDIR)}.txt{$(TSTDIR)}.txt:
	copy "$<" "$@"

clean:
	-del $(TESTS) $(TESTS:.exe=.pdb) $(TESTS:.exe=.obj)
