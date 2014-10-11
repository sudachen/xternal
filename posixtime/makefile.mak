
TOPDIR  =..
INCLUDE = $(INCLUDE);$(TOPDIR)\include
EXECUTABLE = posixtime
!include ..\Make.rules.mak

SRCDIR  = .
OBJECTS = \
    $(OBJDIR)\posixtime.obj \

LIBRARIES=

!if "$(STATIC_LIB)"!="YES"
!else
!endif

!include ..\Make.exe.mak



