
TOPDIR  = ..
PROJECT = libhash
SRCDIR  = src

!INCLUDE $(TOPDIR)\Make.rules.mak

OBJECTS = \
    $(OBJDIR)\crc.obj \
    $(OBJDIR)\md5.obj \
    $(OBJDIR)\sha1.obj \
    $(OBJDIR)\sha2.obj \
    $(OBJDIR)\aes.obj \
    $(OBJDIR)\fortuna.obj \
    $(OBJDIR)\rot13.obj \
    $(OBJDIR)\faq6.obj \
    $(OBJDIR)\murmur2.obj \
    $(OBJDIR)\blowfish.obj \
    $(OBJDIR)\ndes.obj \


LIBRARIES=

!if "$(STATIC_LIB)"!="YES"
DLL_OPTS=-DLIBHASH_BUILD_DLL
!else
DLL_OPTS=-DLIBHASH_STATIC
!endif

!include $(TOPDIR)\Make.dll.mak



