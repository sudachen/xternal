
TOPDIR  = ..
PROJECT = libsynfo
SRCDIR  = src

!if "$(TARGET_CPU)" != "X86"
all:
build:
rebuild:
info:
clean:
!else
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
!endif

