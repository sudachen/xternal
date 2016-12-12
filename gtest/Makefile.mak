

TOPDIR = ..
PROJECT = gtest
NO_DLL_TARGET=YES
!include $(TOPDIR)\Make.rules.mak

OBJECTS = \
  $(OBJDIR)\gtest-death-test.obj \
  $(OBJDIR)\gtest-filepath.obj \
  $(OBJDIR)\gtest-port.obj \
  $(OBJDIR)\gtest-printers.obj \
  $(OBJDIR)\gtest-test-part.obj \
  $(OBJDIR)\gtest-typed-test.obj \
  $(OBJDIR)\gtest.obj \

{$(SRCDIR)\src}.cc{$(OBJDIR)}.obj:
	$(CCX) -c $(CCXFLAGS) -D_LIB -I$(SRCDIR) -I..\include -Fo$@ $< 

$(SRCDIR)\README:
  @7z x -o$(SRCDIR) gtest.lzma

$(TARGET): $(SRCDIR)\README $(OBJECTS)
	$(METALINK) $(OBJECTS)

clean: 
	-del /q $(TARGET) $(PDBNAME)
	-del /q $(OBJECTS)
