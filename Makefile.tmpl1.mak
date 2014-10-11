
TOPDIR  =..
!include $(XTERNAL)\src\Make.rules.mak

SRCDIR  = .
OBJECTS = \
	$(OBJDIR)\dllmain.obj

LIBRARIES=libconf$(LIBSFX).lib zlib$(LIBSFX).lib expatw$(LIBSFX).lib 

!if "$(STATIC_LIB)"!="YES"
DLL_OPTS=-DMYOWN_BUILD_DLL
!else
DLL_OPTS=-DMYOWN_STATIC
!endif

!include $(XTERNAL)\src\Make.dll.mak



