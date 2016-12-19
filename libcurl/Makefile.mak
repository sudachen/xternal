TOPDIR=$(XTERNAL)
PROJECT=libcurl
!INCLUDE $(TOPDIR)\Make.rules.mak

SRCDIR = $(SRCDIR)_$(TARGET_CPU) 

!if "$(CONFIG)"=="Release"
OBJDIR=R
!else
OBJDIR=D
!endif

!if "$(STATIC_LIB)"!="YES"
CFG=$(CONFIG)-dll-ssl-dll-zlib-dll
OBJDIR=$(OBJDIR)l
!else
CFG=$(CONFIG)-ssl-zlib
OBJDIR=$(OBJDIR)s
!endif


$(SRCDIR)\README:
	@7z x -o$(SRCDIR) curl-7.51.0.lzma 

$(SRCDIR)\lib\Makefile.Lib: Makefile.Lib
	copy Makefile.Lib $(SRCDIR)\lib

$(SRCDIR)\src\Makefile.Src: Makefile.Src
	copy Makefile.Src $(SRCDIR)\src

$(TARGET): $(SRCDIR)\README $(SRCDIR)\lib\Makefile.Lib $(SRCDIR)\src\Makefile.Src libcurl curl
	-del $(EXPNAME)

libcurl:
	cd $(SRCDIR)\lib
	$(MAKE) -f Makefile.Lib LIBSFX=$(LIBSFX) DLLSFX=$(DLLSFX) MACHINE=$(TARGET_CPU) CFG=$(CFG)
	cd $(XTERNAL)\libcurl
curl:
!if "$(STATIC_LIB)"!="YES"
	cd $(SRCDIR)\src
	$(MAKE) -f Makefile.Src LIBSFX=$(LIBSFX) DLLSFX=$(DLLSFX) MACHINE=$(TARGET_CPU) CONFIG=$(CONFIG)
	cd $(XTERNAL)\libcurl
!endif

clean:
	-del /q $(XTERNAL)\~$(CONFIG)\.lib\libcurl$(LIBSFX).lib
	-del /q $(XTERNAL)\~$(CONFIG)\.pdb\libcurl$(DLLSFX).pdb
	-del /q $(XTERNAL)\~$(CONFIG)\libcurl$(DLLSFX).dll
	-del /q $(SRCDIR)\lib\$(OBJDIR)\*
