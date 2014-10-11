
TOPDIR  =..
INCLUDE = $(INCLUDE);$(TOPDIR)\include
EXECUTABLE = random
!include ..\Make.rules.mak

SRCDIR  = .
OBJECTS = \
    $(OBJDIR)\random.obj \

LIBRARIES=libhash$(LIBSFX).lib

!if "$(STATIC_LIB)"!="YES"
!else
!endif

!include ..\Make.exe.mak



