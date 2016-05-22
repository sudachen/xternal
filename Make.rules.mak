
.SUFFIXES: .c .cc .cxx .obj .lib .dll .exe .S .txt

xEXE = .exe
xDLL = .dll
XOBJ = .obj
XPDB = .pdb

!if "$(WORKSPACE)" == ""
WORKSPACE=UNKNOWN
!endif

!if "$(OUTDIR_ROOT)" == ""
OUTDIR_ROOT = $(TOPDIR)\out
!endif

!if "$(MASTER_INCLUDE)" == ""
MASTER_INCLUDE = $(TOPDIR)\include
!endif

!if "$(DEBUG)" != "YES"
CONFIG=Release
!else
CONFIG=Debug
!endif

BINDIR = $(OUTDIR_ROOT)\~$(CONFIG)
LIBDIR = $(OUTDIR_ROOT)\~$(CONFIG)\.lib
PDBDIR = $(OUTDIR_ROOT)\~$(CONFIG)\.pdb

LIB = $(LIB);$(XTERNAL)\~$(CONFIG)\.lib

!if "$(CPU)" == "" || ("$(CPU)" != "X64" && "$(CPU)" != "AMD64")
CPU = X86
!else
CPU = X64
!endif

LIB=$(LIB);$(LIBDIR)
INCLUDE=$(INCLUDE);$(MASTER_INCLUDE)

!if "$(TEMP_BUILD)"==""
TEMP_BUILD=$(TEMP)
!endif

NOLOGO = -nologo
_CCFLAGS = /Gy /FC /GF /Zi /DWIN32 /D_WIN32_WINNT=0x0600
_CCXFLAGS = $(_CCFLAGS) /EHsc /GR -wd4530 /DWIN32 /D_WIN32_WINNT=0x0600

!if "$(STATIC)" == "YES" || "$(STATIC)" == "YENO"
!if "$(STATIC)" == "YES"
STATIC_LIB = YES
LINKSFX = _Lib
LIBSFX = $(TARGET_INFIX)-mt
!else
STATIC_LIB = NO
DLLSFX = $(TARGET_INFIX)
LINKSFX = _DLL1
LIBSFX1 = $(TARGET_INFIX)
!endif
LINKAGE = Static
VCRT=T
!if "$(DEBUG)" != "YES"
DBGSFX =
LIBSFX = $(TARGET_INFIX)-mt
_ECCFLAGS = /O2 /Oy- /MT
!else
DLLSFX = $(DLLSFX)d 
LIBSFX1 = $(LIBSFX1)d
DBGSFX = _Dbg
LIBSFX = $(TARGET_INFIX)d-mt
_ECCFLAGS = /Od /GS /RTC1 /D_DEBUG /MTd
VCRT=$(VCRT)d
!endif
!else
STATIC_LIB = NO
LINKAGE = Dynamic
VCRT=D
LINKSFX = _DLL
!if "$(DEBUG)" != "YES"
DBGSFX = 
LIBSFX = $(TARGET_INFIX)-md
DLLSFX = $(TARGET_INFIX)
_ECCFLAGS = /O1 /Oy- /GL /MD
LTCG=/LTCG
!else
DBGSFX = _Dbg
LIBSFX = $(TARGET_INFIX)d-md
DLLSFX = $(TARGET_INFIX)d
_ECCFLAGS = /Od /GS /RTC1 /D_DEBUG /MDd
VCRT=$(VCRT)d
!endif
!endif

!if "$(CPU)" == "X64"
ASFLAGS = -64
_ECCFLAGS = $(_ECCFLAGS) /D_AMD64_
!else
ASFLAGS = -32
!endif

!if "$(STATIC)" == "YENO"
DLLNAME=$(BINDIR)\$(PROJECT)$(DLLSFX).dll
LIBNAME=$(LIBDIR)\$(PROJECT)$(LIBSFX1).lib
EXPNAME=$(LIBDIR)\$(PROJECT)$(LIBSFX1).exp
!else
DLLNAME=$(BINDIR)\$(PROJECT)$(DLLSFX).dll
LIBNAME=$(LIBDIR)\$(PROJECT)$(LIBSFX).lib
EXPNAME=$(LIBDIR)\$(PROJECT)$(LIBSFX).exp
!endif

!if "$(STATIC)" == "YENO" || "$(STATIC)" == "YES"
EXERT=
!else
EXERT=-vc$(COMPIGEN)0d
!endif

!if "$(DEBUG)" != "YES"
EXESFX = $(TARGET_INFIX)d
!else
EXESFX = -$(CPU)$(EXERT)
!endif

!if "$(EXECUTABLE)" != "" && "$(EXECUTABLE)" != "YES"
!if "$(DEBUG)" != "YES"
EXENAME=$(BINDIR)\$(EXECUTABLE).exe
!else
EXENAME=$(BINDIR)\$(EXECUTABLE)-dbg.exe
!endif
!else
EXENAME=$(BINDIR)\$(PROJECT)$(EXESFX).exe
!endif

!if "$(STATIC)" == "YES" || "$(NO_DLL_TARGET)" == "YES"
PDBNAME=$(PDBDIR)\$(PROJECT)$(LIBSFX).pdb
!else
PDBNAME=$(PDBDIR)\$(PROJECT)$(DLLSFX).pdb
!endif

!if "$(BUILDTIME)" == ""
BUILDTIME=0
!endif

TMPDIR = $(TEMP_BUILD)\$(WORKSPACE)\$(PROJECT)$(MSRT)_$(CPU)$(DBGSFX)$(LINKSFX)
OBJDIR = $(TMPDIR)\obj

!if "$(SRCDIR)"==""
SRCDIR = $(TEMP_BUILD)\$(WORKSPACE)\S\$(PROJECT)
!endif

!if "$(TARGET)" == ""
!if "$(STATIC)" == "YES" || "$(NO_DLL_TARGET)" == "YES"
_ECCFLAGS= $(_ECCFLAGS) /Fd$(PDBNAME)
!else
_ECCFLAGS= $(_ECCFLAGS) /Fd$(TMPDIR)\$(PROJECT).pdb
!endif
!endif

CCFLAGS = $(CFLAGS) $(_CCFLAGS) $(_ECCFLAGS) -DPOSIXBUILDTIME=$(BUILDTIME) -D_RANDOM=$(BUILDRANDOM) $(EXTCFLAGS)
CCXFLAGS = $(CFLAGS) $(_CCXFLAGS) $(_ECCFLAGS) -DPOSIXBUILDTIME=$(BUILDTIME) -D_RANDOM=$(BUILDRANDOM) $(EXTCFLAGS)

CC = cl $(NOLOGO)
CCX = cl $(NOLOGO)
RC = rc
AS = GNU_as

LIBLINK = link /lib /machine:$(CPU) $(NOLOGO)
DLLLINK = link /dll /debug /machine:$(CPU) $(NOLOGO) /opt:icf=10 /opt:ref /incremental:no $(LTCG)
EXELINK = link /debug /machine:$(CPU) $(NOLOGO) /opt:icf=10 /opt:ref /incremental:no $(LTCG)

!if "$(EXECUTABLE)" != ""
TARGETNAME=$(EXENAME) 
METALINK=$(EXELINK) /pdb:$(PDBNAME) /out:$(EXENAME)
!elseif "$(STATIC)" == "YES" || "$(NO_DLL_TARGET)" == "YES"
TARGETNAME=$(LIBNAME) 
METALINK=$(LIBLINK) /out:$(LIBNAME)
!else
TARGETNAME=$(DLLNAME) 
METALINK=$(DLLLINK) /pdb:$(PDBNAME) /implib:$(LIBNAME) /out:$(DLLNAME)
!endif

!if "$(TARGET)" == ""
TARGET=$(TARGETNAME)
!endif

TSTDIR = $(OUTDIR_ROOT)\~$(CONFIG)\.$(PROJECT)$(LIBSFX)

build:  $(OBJDIR) $(BINDIR) $(LIBDIR) $(PDBDIR) $(TARGET)
rebuild: $(OBJDIR) $(BINDIR) $(LIBDIR) $(PDBDIR) clean $(TARGET)

$(OBJDIR) $(LIBDIR) $(BINDIR) $(PDBDIR) $(TSTDIR):
	@if not exist $@ md $@

info:
	@echo --------------------------------------------
	@echo .~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~
	@echo WORKSPACE $(WORKSPACE)
	@echo all relative paths have base at PROJECT dir $(PROJECT_DIR)
	@echo --------------------------------------------
	@echo build $(LINKAGE) $(CONFIG) $(PROJECT) on $(CPU)
	@echo target is $(TARGET)
	@echo --------------------------------------------
	@echo SRCDIR $(SRCDIR)
	@echo BINDIR $(BINDIR)
	@echo LIBDIR $(LIBDIR)
	@echo OBJDIR $(OBJDIR)
	@echo TMPDIR $(TMPDIR)
	@echo LIB %%LIB%%
	@echo INCLUDE %%INCLUDE%%
	@echo PATH %%PATH%%
	@echo --------------------------------------------
#	@echo $(PATH)
#	@echo $(INCLUDE)
#	@echo $(LIB)

	