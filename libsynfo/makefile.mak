
TOPDIR  = ..
PROJECT = libsynfo
SRCDIR  = src

!INCLUDE $(TOPDIR)\Make.rules.mak

OBJECTS = \
    $(OBJDIR)\system.obj \
    $(OBJDIR)\cpu.obj \

LIBRARIES=

!if "$(STATIC_LIB)"!="YES"
DLL_OPTS=-DLIBSYNFO_BUILD_DLL
!else
DLL_OPTS=-DLIBSYNFO_STATIC
!endif

!include $(TOPDIR)\Make.dll.mak


