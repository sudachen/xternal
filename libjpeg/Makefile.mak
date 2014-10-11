TOPDIR = ..
PROJECT=libjpeg
!INCLUDE $(TOPDIR)\Make.rules.mak

INCL = -I $(TOPDIR)\..\include -I $(SRCDIR)

OBJECTS = \
	$(OBJDIR)\jaricom.obj \
	$(OBJDIR)\jcomapi.obj \
	$(OBJDIR)\jutils.obj \
	$(OBJDIR)\jerror.obj \
	$(OBJDIR)\jmemmgr.obj \
	$(OBJDIR)\jmemnobs.obj \
	$(OBJDIR)\jcapimin.obj \
	$(OBJDIR)\jcapistd.obj \
	$(OBJDIR)\jcarith.obj \
	$(OBJDIR)\jctrans.obj \
	$(OBJDIR)\jcparam.obj \
	$(OBJDIR)\jdatadst.obj \
	$(OBJDIR)\jcinit.obj \
	$(OBJDIR)\jcmaster.obj \
	$(OBJDIR)\jcmarker.obj \
	$(OBJDIR)\jcmainct.obj \
	$(OBJDIR)\jcprepct.obj \
	$(OBJDIR)\jccoefct.obj \
	$(OBJDIR)\jccolor.obj \
	$(OBJDIR)\jcsample.obj \
	$(OBJDIR)\jchuff.obj \
	$(OBJDIR)\jcdctmgr.obj \
	$(OBJDIR)\jfdctfst.obj \
	$(OBJDIR)\jfdctflt.obj \
	$(OBJDIR)\jfdctint.obj \
	$(OBJDIR)\jdapimin.obj \
	$(OBJDIR)\jdapistd.obj \
	$(OBJDIR)\jdarith.obj \
	$(OBJDIR)\jdtrans.obj \
	$(OBJDIR)\jdatasrc.obj \
	$(OBJDIR)\jdmaster.obj \
	$(OBJDIR)\jdinput.obj \
	$(OBJDIR)\jdmarker.obj \
	$(OBJDIR)\jdhuff.obj \
	$(OBJDIR)\jdmainct.obj \
	$(OBJDIR)\jdcoefct.obj \
	$(OBJDIR)\jdpostct.obj \
	$(OBJDIR)\jddctmgr.obj \
	$(OBJDIR)\jidctfst.obj \
	$(OBJDIR)\jidctflt.obj \
	$(OBJDIR)\jidctint.obj \
	$(OBJDIR)\jdsample.obj \
	$(OBJDIR)\jdcolor.obj \
	$(OBJDIR)\jquant1.obj \
	$(OBJDIR)\jquant2.obj \
	$(OBJDIR)\jdmerge.obj

!if "$(STATIC_LIB)"!="YES"
JPEG_DLL=-DJPEG_BUILD_DLL
!endif

$(SRCDIR)\README:
	@7z x -o$(SRCDIR) libjpeg.lzma

$(TARGET): $(SRCDIR)\README $(OBJECTS)
	$(METALINK) $(OBJECTS)
	-del $(EXPNAME)

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
	$(CC) -c $(CCFLAGS) $(JPEG_DLL) $(INCL) -Fo$@ $<

clean:
	-del $(OBJECTS)
	-del $(DLLNAME) $(LIBNAME) $(PDBNAME) $(EXPNAME)
