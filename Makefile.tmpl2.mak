
TOPDIR  =..
EXECUTABLE = $(PROJECT)

!include $(XTERNAL)\Make.rules.mak

SRCDIR  = .
OBJECTS = \
	$(OBJDIR)\main.obj

LIBRARIES=libconf$(LIBSFX).lib zlib$(LIBSFX).lib expatw$(LIBSFX).lib 

!include $(XTERNAL)\Make.exe.mak



