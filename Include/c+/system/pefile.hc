
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_EA617668_2E48_4AC6_9079_699B387A0662
#define C_once_EA617668_2E48_4AC6_9079_699B387A0662

#ifdef _BUILTIN
#define _C_PEFILE_BUILTIN
#endif

#include "../file.hc"

// The Machine field has one of the following values that specifies its CPU type. 
// An image file can be run only on the specified machine or on a system that emulates the specified machine.

enum _PE_MACHINE
{
	PE_FILE_MACHINE_UNKNOWN   = 0x0,    // The contents of this field are assumed to be applicable to any machine type
	PE_FILE_MACHINE_AM33      = 0x1d3,  // Matsushita AM33
	PE_FILE_MACHINE_AMD64     = 0x8664, // x64
	PE_FILE_MACHINE_ARM       = 0x1c0,  // ARM little endian
	PE_FILE_MACHINE_EBC       = 0xebc,  // EFI byte code
	PE_FILE_MACHINE_I386      = 0x14c,  // Intel 386 or later processors and compatible processors
	PE_FILE_MACHINE_IA64      = 0x200,  // Intel Itanium processor family
	PE_FILE_MACHINE_M32R      = 0x9041, // Mitsubishi M32R little endian
	PE_FILE_MACHINE_MIPS16    = 0x266,  // MIPS16
	PE_FILE_MACHINE_MIPSFPU   = 0x366,  // MIPS with FPU
	PE_FILE_MACHINE_MIPSFPU16 = 0x466,  // MIPS16 with FPU
	PE_FILE_MACHINE_POWERPC   = 0x1f0,  // Power PC little endian
	PE_FILE_MACHINE_POWERPCFP = 0x1f1,  // Power PC with floating point support
	PE_FILE_MACHINE_R4000     = 0x166,  // MIPS little endian
	PE_FILE_MACHINE_SH3       = 0x1a2,  // Hitachi SH3
	PE_FILE_MACHINE_SH3DSP    = 0x1a3,  // Hitachi SH3 DSP
	PE_FILE_MACHINE_SH4       = 0x1a6,  // Hitachi SH4
	PE_FILE_MACHINE_SH5       = 0x1a8,  // Hitachi SH5
	PE_FILE_MACHINE_THUMB     = 0x1c2,  // Thumb
	PE_FILE_MACHINE_WCEMIPSV2 = 0x169,  // MIPS little-endian WCE v2      
};

// The Characteristics field contains flags that indicate attributes of the object or image file. 
// The following flags are currently defined.    
enum _PE_CHARACTERISTICS 
{

	PE_FILE_RELOCS_STRIPPED   = 0x0001,
	// Image only, Windows CE, and Windows NT® and later. 
	// This indicates that the file does not contain base 
	// relocations and must therefore be loaded at its preferred 
	// base address. If the base address is not available, 
	// the loader reports an error. The default behavior of the 
	// linker is to strip base relocations from executable (EXE) files.
	PE_FILE_EXECUTABLE_IMAGE  = 0x0002,
	// Image only. This indicates that the image file is valid 
	// and can be run. If this flag is not set, it indicates a linker error.
	PE_FILE_LINE_NUMS_STRIPPED = 0x0004,
	// COFF line numbers have been removed. 
	// This flag is deprecated and should be zero.
	PE_FILE_LOCAL_SYMS_STRIPPED = 0x0008,
	// COFF symbol table entries for local symbols have been removed. 
	// This flag is deprecated and should be zero.
	PE_FILE_AGGRESSIVE_WS_TRIM = 0x0010,
	// Obsolete. Aggressively trim working set. This flag is deprecated 
	// for Windows 2000 and later and must be zero.
	PE_FILE_LARGE_ADDRESS_AWARE = 0x0020,
	// Application can handle > 2-GB addresses.
	// = 0x0040 - This flag is reserved for future use.
	PE_FILE_BYTES_REVERSED_LO = 0x0080,
	// Little endian: the least significant bit (LSB) precedes 
	// the most significant bit (MSB) in memory. 
	// This flag is deprecated and should be zero.
	PE_FILE_32BIT_MACHINE = 0x0100,
	// Machine is based on a 32-bit-word architecture.
	PE_FILE_DEBUG_STRIPPED = 0x0200,
	// Debugging information is removed from the image file.
	PE_FILE_REMOVABLE_RUN_FROM_SWAP = 0x0400,
	// If the image is on removable media, fully load it and copy it to the swap file.
	PE_FILE_NET_RUN_FROM_SWAP = 0x0800,
	// If the image is on network media, fully load it and copy it to the swap file.
	PE_FILE_SYSTEM = 0x1000,
	// The image file is a system file, not a user program.
	PE_FILE_DLL = 0x2000,
	// The image file is a dynamic-link library (DLL). 
	// Such files are considered executable files for almost all purposes, 
	// although they cannot be directly run.
	PE_FILE_UP_SYSTEM_ONLY = 0x4000,
	// The file should be run only on a uniprocessor machine.
	PE_FILE_BYTES_REVERSED_HI = 0x8000,
	// Big endian: the MSB precedes the LSB in memory. 
	//This flag is deprecated and should be zero.      
};

enum _PE_MAGIC
{
	PE_OPT32_MAGIC        = 0x10b,
	PE_OPT64_MAGIC        = 0x20b,
	PE_DOS_SIGNATURE      = 0x5A4D,
	PE_NT_SIGNATURE       = 0x00004550,
};

// The following values defined for the Subsystem field of the optional header determine 
// which Windows subsystem (if any) is required to run the image.
enum _PE_SUBSYSTEM
{
	PE_SUBSYSTEM_UNKNOWN        = 0,    // An unknown subsystem
	PE_SUBSYSTEM_NATIVE         = 1,    // Device drivers and native Windows processes
	PE_SUBSYSTEM_WINDOWS_GUI    = 2,    // The Windows graphical user interface (GUI) subsystem
	PE_SUBSYSTEM_WINDOWS_CUI    = 3,    // The Windows character subsystem
	PE_SUBSYSTEM_POSIX_CUI      = 7,    // The Posix character subsystem
	PE_SUBSYSTEM_WINDOWS_CE_GUI = 9,    // Windows CE
	PE_SUBSYSTEM_EFI_APPLICATION  = 10, // An Extensible Firmware Interface (EFI) application
	PE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER = 11, //An EFI driver with boot services
	PE_SUBSYSTEM_EFI_RUNTIME_DRIVER  = 12, // An EFI driver with run-time services
	PE_SUBSYSTEM_EFI_ROM        = 13, // An EFI ROM image
	PE_SUBSYSTEM_XBOX           = 14, // XBOX    
};

// The following values are defined for the DllCharacteristics field of the optional header.
enum _PE_DLL_CHARACTERISTICS
{
	// = 0x0001  - Reserved, must be zero.
	// = 0x0002  - Reserved, must be zero.
	// = 0x0004  - Reserved, must be zero.
	// = 0x0008  - Reserved, must be zero.
	PE_DLL_CHARACTERISTICS_DYNAMIC_BASE     = 0x0040, // DLL can be relocated at load time.
	PE_DLL_CHARACTERISTICS_FORCE_INTEGRITY  = 0x0080, // Code Integrity checks are enforced.
	PE_DLL_CHARACTERISTICS_NX_COMPAT        = 0x0100, // Image is NX compatible.
	PE_DLL_CHARACTERISTICS_NO_ISOLATION     = 0x0200, // Isolation aware, but do not isolate the image.
	PE_DLL_CHARACTERISTICS_NO_SEH           = 0x0400, 
	// Does not use structured exception (SE) handling. No SE handler may be called in this image.
	PE_IMAGE_DLLCHARACTERISTICS_NO_BIND     = 0x0800, // Do not bind the image.
	// = 0x1000 - Reserved, must be zero.
	PE_DLL_CHARACTERISTICS_WDM_DRIVER       = 0x2000, // A WDM driver.
	PE_DLL_CHARACTERISTICS_TERMINAL_SERVER_AWARE = 0x8000 // Terminal Server aware.      
};

enum _PE_DIRECTORY_INDEX
{
	PE_DIRECTORY_ENTRY_EXPORT          = 0,
	PE_DIRECTORY_ENTRY_IMPORT          = 1,
	PE_DIRECTORY_ENTRY_RESOURCE        = 2,
	PE_DIRECTORY_ENTRY_EXCEPTION       = 3,
	PE_DIRECTORY_ENTRY_SECURITY        = 4,
	PE_DIRECTORY_ENTRY_BASERELOC       = 5,
	PE_DIRECTORY_ENTRY_DEBUG           = 6,
	PE_DIRECTORY_ENTRY_COPYRIGHT       = 7,
	PE_DIRECTORY_ENTRY_ARCHITECTURE    = 7,
	PE_DIRECTORY_ENTRY_GLOBALPTR       = 8,
	PE_DIRECTORY_ENTRY_TLS             = 9,
	PE_DIRECTORY_ENTRY_LOAD_CONFIG     = 10,
	PE_DIRECTORY_ENTRY_BOUND_IMPORT    = 11,
	PE_DIRECTORY_ENTRY_IAT             = 12,
	PE_DIRECTORY_ENTRY_DELAY_IMPORT    = 13,
	PE_DIRECTORY_ENTRY_COM_DESCRIPTOR  = 14,
};

enum _PE_SCN
{
	PE_SCN_TYPE_NO_PAD                 = 0x00000008,  // Reserved.
	PE_SCN_CNT_CODE                    = 0x00000020,  // Section contains code.
	PE_SCN_CNT_INITIALIZED_DATA        = 0x00000040,  // Section contains initialized data.
	PE_SCN_CNT_UNINITIALIZED_DATA      = 0x00000080,  // Section contains uninitialized data.
	PE_SCN_LNK_OTHER                   = 0x00000100,  // Reserved.
	PE_SCN_LNK_INFO                    = 0x00000200,  // Section contains comments or some other type of information.
	PE_SCN_LNK_REMOVE                  = 0x00000800,  // Section contents will not become part of image.
	PE_SCN_LNK_COMDAT                  = 0x00001000,  // Section contents comdat.
	PE_SCN_NO_DEFER_SPEC_EXC           = 0x00004000,  // Reset speculative exceptions handling bits in the TLB entries for this section.
	PE_SCN_GPREL                       = 0x00008000,  // Section content can be accessed relative to GP
	PE_SCN_MEM_FARDATA                 = 0x00008000,
	PE_SCN_MEM_PURGEABLE               = 0x00020000,
	PE_SCN_MEM_16BIT                   = 0x00020000,
	PE_SCN_MEM_LOCKED                  = 0x00040000,
	PE_SCN_MEM_PRELOAD                 = 0x00080000,
	PE_SCN_ALIGN_1BYTES                = 0x00100000,  //
	PE_SCN_ALIGN_2BYTES                = 0x00200000,  //
	PE_SCN_ALIGN_4BYTES                = 0x00300000,  //
	PE_SCN_ALIGN_8BYTES                = 0x00400000,  //
	PE_SCN_ALIGN_16BYTES               = 0x00500000,  // Default alignment if no others are specified.
	PE_SCN_ALIGN_32BYTES               = 0x00600000,  //
	PE_SCN_ALIGN_64BYTES               = 0x00700000,  //
	PE_SCN_ALIGN_128BYTES              = 0x00800000,  //
	PE_SCN_ALIGN_256BYTES              = 0x00900000,  //
	PE_SCN_ALIGN_512BYTES              = 0x00A00000,  //
	PE_SCN_ALIGN_1024BYTES             = 0x00B00000,  //
	PE_SCN_ALIGN_2048BYTES             = 0x00C00000,  //
	PE_SCN_ALIGN_4096BYTES             = 0x00D00000,  //
	PE_SCN_ALIGN_8192BYTES             = 0x00E00000,  //
	PE_SCN_ALIGN_MASK                  = 0x00F00000,
	PE_SCN_LNK_NRELOC_OVFL             = 0x01000000,  // Section contains extended relocations.
	PE_SCN_MEM_DISCARDABLE             = 0x02000000,  // Section can be discarded.
	PE_SCN_MEM_NOT_CACHED              = 0x04000000,  // Section is not cachable.
	PE_SCN_MEM_NOT_PAGED               = 0x08000000,  // Section is not pageable.
	PE_SCN_MEM_SHARED                  = 0x10000000,  // Section is shareable.
	PE_SCN_MEM_EXECUTE                 = 0x20000000,  // Section is executable.
	PE_SCN_MEM_READ                    = 0x40000000,  // Section is readable.
	PE_SCN_MEM_WRITE                   = 0x80000000,  // Section is writeable.
};

typedef struct _PE_DOS_HEADER
{
	ushort_t   e_magic;       // Magic number
	ushort_t   e_cblp;        // Bytes on last page of file
	ushort_t   e_cp;          // Pages in file
	ushort_t   e_crlc;        // Relocations
	ushort_t   e_cparhdr;     // Size of header in paragraphs
	ushort_t   e_minalloc;    // Minimum extra paragraphs needed
	ushort_t   e_maxalloc;    // Maximum extra paragraphs needed
	ushort_t   e_ss;          // Initial (relative) SS value
	ushort_t   e_sp;          // Initial SP value
	ushort_t   e_csum;        // Checksum
	ushort_t   e_ip;          // Initial IP value
	ushort_t   e_cs;          // Initial (relative) CS value
	ushort_t   e_lfarlc;      // File address of relocation table
	ushort_t   e_ovno;        // Overlay number
	ushort_t   e_res[4];      // Reserved words
	ushort_t   e_oemid;       // OEM identifier (for e_oeminfo)
	ushort_t   e_oeminfo;     // OEM information; e_oemid specific
	ushort_t   e_res2[10];    // Reserved words
	uint_t     e_lfanew;      // File address of new exe header
} PE_DOS_HEADER;

typedef struct _PE_FILE_HEADER
{
	ushort_t Machine;
	ushort_t NumberOfSections;
	uint_t   TimeDateStamp;
	uint_t   PointerToSymbolTable;
	uint_t   NumberOfSymbols;
	ushort_t SizeOfOptionalHeader;
	ushort_t Characteristics;
} PE_FILE_HEADER;

typedef struct _PE_DATA_DIRECTORY 
{
	uint_t   VirtualAddress;
	uint_t   Size;
} PE_DATA_DIRECTORY;

typedef struct _PE_SECTION_HEADER 
{
	byte_t Name[8];
	union {
		uint_t   PhysicalAddress;
		uint_t   VirtualSize;
	} Misc;
	uint_t   VirtualAddress;
	uint_t   SizeOfRawData;
	uint_t   PointerToRawData;
	uint_t   PointerToRelocations;
	uint_t   PointerToLinenumbers;
	ushort_t NumberOfRelocations;
	ushort_t NumberOfLinenumbers;
	uint_t   Characteristics;
} PE_SECTION_HEADER;

#define PE_OPTIONAL_HEADER_32_64(Arch,Dptr) \
struct _PE_OPTINAL_HEADER_##Arch \
{\
	ushort_t   Magic;\
	byte_t     MajorLinkerVersion;\
	byte_t     MinorLinkerVersion;\
	uint_t     SizeOfCode;\
	uint_t     SizeOfInitializedData;\
	uint_t     SizeOfUninitializedData;\
	uint_t     AddressOfEntryPoint;\
	uint_t     BasOfCode;\
	PE_OPTIONAL_HEADER_BASEOF_DATA_##Arch \
	Dptr       ImageBase;\
	uint_t     SectionAlignment;\
	uint_t     FileAlignment;\
	ushort_t   MajorOperatingSystemVersion;\
	ushort_t   MinorOperatingSystemVersion;\
	ushort_t   MajorImageVersion;\
	ushort_t   MinorImageVersion;\
	ushort_t   MajorSubsystemVersion;\
	ushort_t   MinorSubsystemVersion;\
	uint_t     Win32VersionValue;\
	uint_t     SizeOfImage;\
	uint_t     SizeOfHeaders;\
	uint_t     CheckSum;\
	ushort_t   Subsystem;\
	ushort_t   DllCharacteristics;\
	Dptr       SizeOfStackReserve;\
	Dptr       SizeOfStackCommit;\
	Dptr       SizeOfHeapReserve;\
	Dptr       SizeOfHeapCommit;\
	uint_t     LoaderFlags;\
	uint_t     NumberOfRvaAndSizes;\
	PE_DATA_DIRECTORY DataDirectory[0x10];\
}

#define PE_OPTIONAL_HEADER_BASEOF_DATA_32 uint_t Data;
#define PE_OPTIONAL_HEADER_BASEOF_DATA_64 

typedef PE_OPTIONAL_HEADER_32_64(32,uint_t) PE_OPTIONAL_HEADER_32;
typedef PE_OPTIONAL_HEADER_32_64(64,quad_t) PE_OPTIONAL_HEADER_64;

typedef struct _PE_HEADERS_32
{
	uint_t Signature;
	PE_FILE_HEADER FileHeader;
	PE_OPTIONAL_HEADER_32 OptionalHeader;
} PE_HEADERS_32;

typedef struct _PE_HEADERS_64
{
	uint_t Signature;
	PE_FILE_HEADER FileHeader;
	PE_OPTIONAL_HEADER_64 OptionalHeader;
} PE_HEADERS_64;

typedef struct _PE_EXPORT_DIRECTORY 
{
	uint_t   Characteristics;
	uint_t   TimeDateStamp;
	ushort_t MajorVersion;
	ushort_t MinorVersion;
	uint_t   Name;
	uint_t   Base;
	uint_t   NumberOfFunctions;
	uint_t   NumberOfNames;
	uint_t   AddressOfFunctions;
	uint_t   AddressOfNames;
	uint_t   AddressOfNameOrdinals;
} PE_EXPORT_DIRECTORY;

typedef struct _PE_RESOURCE_DIRECTORY 
{
	uint_t   Characteristics;
	uint_t   TimeDateStamp;
	ushort_t MajorVersion;
	ushort_t MinorVersion;
	ushort_t NumberOfNamedEntries;
	ushort_t NumberOfIdEntries;
	//  IMAGE_RESOURCE_DIRECTORY_ENTRY DirectoryEntries[];
} PE_RESOURCE_DIRECTORY;

typedef struct _PE_RESOURCE_DIRECTORY_ENTRY 
{
	union {
		struct {
			uint_t NameOffset:31;
			uint_t NameIsString:1;
		};
		uint_t   Name;
		ushort_t Id;
	};
	union {
		uint_t OffsetToData;
		struct {
			uint_t OffsetToDirectory:31;
			uint_t DataIsDirectory:1;
		};
	};
} PE_RESOURCE_DIRECTORY_ENTRY;

typedef struct _PE_RESOURCE_DATA_ENTRY 
{
	uint_t OffsetToData;
	uint_t Size;
	uint_t CodePage;
	uint_t Reserved;
} PE_RESOURCE_DATA_ENTRY;

#define IMAGE_RESOURCE_NAME_IS_STRING        0x80000000
#define IMAGE_RESOURCE_DATA_IS_DIRECTORY     0x80000000

#define Pe_GET_NTH_32(Pe) \
	((PE_HEADERS_32*)((char*)(Pe) + ((PE_DOS_HEADER*)(Pe))->e_lfanew))
#define Pe_GET_SEC_32(Pe) \
	((PE_SECTION_HEADER*)((char*)(Pe) + ((PE_DOS_HEADER*)(Pe))->e_lfanew + 4 + sizeof(PE_FILE_HEADER) + Pe_GET_NTH_32(Pe)->FileHeader.SizeOfOptionalHeader ))
#define Pe_GET_NTH_64(Pe) \
	((PE_HEADERS_64*)((char*)(Pe) + ((PE_DOS_HEADER*)(Pe))->e_lfanew))
#define Pe_GET_SEC_64(Pe) \
	((PE_SECTION_HEADER*)((char*)(Pe) + ((PE_DOS_HEADER*)(Pe))->e_lfanew + 4 + sizeof(PE_FILE_HEADER) + Pe_GET_NTH_64(Pe)->FileHeader.SizeOfOptionalHeader ))

#define Is_PE_32(Pe) (Pe_GET_NTH_32(Pe)->OptionalHeader.Magic == PE_OPT32_MAGIC)
#define Is_PE_64(Pe) (Pe_GET_NTH_64(Pe)->OptionalHeader.Magic == PE_OPT64_MAGIC)

int Pe_Headers_Is_Valid(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	return 1;
}
#endif
;

void Pe_Validate_Headers(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	if ( !Pe_Headers_Is_Valid(pe) )
		__Raise(C_ERROR_CORRUPTED,"there is not PE headers");
}
#endif
;

PE_HEADERS_32 *Pe_Get_Nth_32(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	return ((PE_HEADERS_32*)((char*)pe + ((PE_DOS_HEADER*)pe)->e_lfanew));
}
#endif
;

PE_HEADERS_64 *Pe_Get_Nth_64(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	return ((PE_HEADERS_64*)((char*)pe + ((PE_DOS_HEADER*)pe)->e_lfanew));
}
#endif
;

PE_FILE_HEADER *Pe_Get_File_Header(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	if ( Is_PE_32(pe) )
		return &Pe_GET_NTH_32(pe)->FileHeader;
	else
		return &Pe_GET_NTH_64(pe)->FileHeader;
}
#endif
;

#define Pe_Section_Number(Pe) (Pe_File_Header(Pe)->NumberOfSections)

PE_SECTION_HEADER *Pe_Get_First_Section(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	if ( Is_PE_32(pe) )
		return Pe_GET_SEC_32(pe);
	else
		return Pe_GET_SEC_64(pe);
}
#endif
;

PE_SECTION_HEADER *Pe_Find_Section(void *pe,char *name)
#ifdef _C_PEFILE_BUILTIN
{
	PE_SECTION_HEADER *sec = Pe_Get_First_Section(pe);
	PE_SECTION_HEADER *seE = sec + Pe_Get_File_Header(pe)->NumberOfSections;
	for ( ; sec != seE; ++sec )
	{
		if ( !strncmp(sec->Name,name,8) )
			return sec;
	}
	return 0;
}
#endif
;

quad_t Pe_Get_ImageBase(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	if ( Is_PE_32(pe) )
		return Pe_GET_NTH_32(pe)->OptionalHeader.ImageBase;
	else
		return Pe_GET_NTH_64(pe)->OptionalHeader.ImageBase;
}
#endif
;

quad_t Pe_Get_SizeOfImage(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	if ( Is_PE_32(pe) )
		return Pe_GET_NTH_32(pe)->OptionalHeader.SizeOfImage;
	else
		return Pe_GET_NTH_64(pe)->OptionalHeader.SizeOfImage;
}
#endif
;

PE_DATA_DIRECTORY *Pe_Get_Dir(void *pe, int idx)
#ifdef _C_PEFILE_BUILTIN
{
	REQUIRE(idx < 16 && idx >= 0 );
	if ( Is_PE_32(pe) )
		return &Pe_GET_NTH_32(pe)->OptionalHeader.DataDirectory[idx];
	else
		return &Pe_GET_NTH_64(pe)->OptionalHeader.DataDirectory[idx];
}
#endif
;

longptr_t Pe_Get_File_Alignment(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	if ( Is_PE_32(pe) )
		return Pe_GET_NTH_32(pe)->OptionalHeader.FileAlignment;
	else
		return Pe_GET_NTH_64(pe)->OptionalHeader.FileAlignment;
}
#endif
;

longptr_t Pe_Get_Section_Alignment(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	if ( Is_PE_32(pe) )
		return Pe_GET_NTH_32(pe)->OptionalHeader.SectionAlignment;
	else
		return Pe_GET_NTH_64(pe)->OptionalHeader.SectionAlignment;
}
#endif
;

#define Pe_ALIGN_TO_q(Val,Mod)  ((Val)+(Mod)-1)&~((Mod)-1)
#define Pe_ALIGN_TO_FILE(Val,Nth)  Pe_ALIGN_TO_q((Val),(Nth)->OptionalHeader.FileAlignment)
#define Pe_ALIGN_TO_SECTION(Val,Nth) Pe_ALIGN_TO_q((Val),(Nth)->OptionalHeader.SectionAlignment)
#define Pe_SECION_SIZE(Sec,Nth) C_Max( Pe_ALIGN_TO_FILE(Sec->SizeOfRawData,Nth), Pe_ALIGN_TO_SECTION(Sec->Misc.VirtualSize,Nth))

longptr_t Pe_Align_To_File(void *pe,longptr_t val)
#ifdef _C_PEFILE_BUILTIN
{
	return Pe_ALIGN_TO_q(val,Pe_Get_File_Alignment(pe));
}
#endif
;

longptr_t Pe_Align_To_Section(void *pe,longptr_t val)
#ifdef _C_PEFILE_BUILTIN
{
	return Pe_ALIGN_TO_q(val,Pe_Get_Section_Alignment(pe));
}
#endif
;

longptr_t Pe_Section_Size(void *pe, PE_SECTION_HEADER *sec)
#ifdef _C_PEFILE_BUILTIN
{
	longptr_t FileAlignment = Pe_Get_File_Alignment(pe);
	longptr_t SectionAlignment = Pe_Get_Section_Alignment(pe);
	return C_MAX( Pe_ALIGN_TO_q(sec->SizeOfRawData,FileAlignment), 
		Pe_ALIGN_TO_q(sec->Misc.VirtualSize,SectionAlignment));
}
#endif
;

PE_SECTION_HEADER *Pe_RVA_To_Section(void *pe, longptr_t rva)
#ifdef _C_PEFILE_BUILTIN
{
	if ( rva )
	{
		PE_SECTION_HEADER *sec = Pe_Get_First_Section(pe);
		PE_SECTION_HEADER *seE = sec + Pe_Get_File_Header(pe)->NumberOfSections;

		for ( ; sec != seE; ++sec )
		{
			if ( rva >= sec->VirtualAddress 
				&& rva < sec->VirtualAddress+Pe_Section_Size(pe,sec) )
				return sec;
		}
	}

	return 0;
}
#endif
;

longptr_t Pe_RVA_To_Offs(void *pe, longptr_t rva)
#ifdef _C_PEFILE_BUILTIN
{
	if ( rva )
	{
		PE_SECTION_HEADER *sec = Pe_RVA_To_Section(pe,rva);
		if ( sec )
		{
			longptr_t offs = rva - sec->VirtualAddress;
			longptr_t datasize = Pe_Align_To_File(pe,sec->SizeOfRawData);
			if ( offs <= datasize )
				return sec->PointerToRawData + offs;
		}
	}

	return 0;
}
#endif
;

void *Pe_RVA_To_Ptr(void *pe, longptr_t rva)
#ifdef _C_PEFILE_BUILTIN
{
	longptr_t offs = Pe_RVA_To_Offs(pe,rva);
	return offs ? (byte_t*)pe+offs : 0;
}
#endif
;

void *Pe_Get_Dir_Ptr(void *pe, int idx)
#ifdef _C_PEFILE_BUILTIN
{
	return Pe_RVA_To_Ptr(pe,Pe_Get_Dir(pe,idx)->VirtualAddress);
}
#endif
;

longptr_t Pe_Export_Bsearch(void *pe,PE_EXPORT_DIRECTORY *dir,char *name)
#ifdef _C_PEFILE_BUILTIN
{
	uint_t   *AddressOfNames        = Pe_RVA_To_Ptr(pe,dir->AddressOfNames);
	ushort_t *AddressOfNameOrdinals = Pe_RVA_To_Ptr(pe,dir->AddressOfNameOrdinals);
	uint_t   *AddressOfFunctions    = Pe_RVA_To_Ptr(pe,dir->AddressOfFunctions);

	int L = 0;
	int R = dir->NumberOfNames-1;

	while ( L<=R )
	{
		int k = (L+R)/2;
		char *r_name = Pe_RVA_To_Ptr(pe,AddressOfNames[k]);
		int cmp = strncmp(name,r_name,127);
		if ( !cmp )
			return AddressOfFunctions[AddressOfNameOrdinals[k]];
		else
			if ( cmp > 0 ) L = k+1;
			else R = k-1;
	}

	return 0;
}
#endif
;

#define Pe_Get_Proc_Ptr(Pe,Name) Pe_RVA_To_Ptr(Pe_Get_Proc_RVA(Pe,Name))
longptr_t Pe_Get_Proc_RVA(void *pe, char *procname)
#ifdef _C_PEFILE_BUILTIN
{
	PE_DATA_DIRECTORY expo = *Pe_Get_Dir(pe,PE_DIRECTORY_ENTRY_EXPORT);
	if ( expo.Size )
	{
		PE_EXPORT_DIRECTORY *edir = Pe_RVA_To_Ptr(pe,expo.VirtualAddress);
		if ( (longptr_t)procname >> 16 )
			return Pe_Export_Bsearch(pe,edir,procname);
		else
			return ((uint_t*)Pe_RVA_To_Ptr(pe,edir->AddressOfFunctions))
			[(longptr_t)procname - edir->Base];
	}

	return 0;
}
#endif
;

void Pe_Fixup_Rsrc_Req(byte_t *rsrc, longptr_t rva, PE_RESOURCE_DIRECTORY *dir)
#ifdef _C_PEFILE_BUILTIN
{
	PE_RESOURCE_DIRECTORY_ENTRY *r = (PE_RESOURCE_DIRECTORY_ENTRY *)((byte_t*)dir + sizeof(*dir));
	PE_RESOURCE_DIRECTORY_ENTRY *rE = r+dir->NumberOfIdEntries+dir->NumberOfNamedEntries;
	for ( ; r != rE; ++r )
		if ( r->DataIsDirectory )
			Pe_Fixup_Rsrc_Req(rsrc,rva,(PE_RESOURCE_DIRECTORY *)(rsrc+r->OffsetToDirectory));
		else
		{
			PE_RESOURCE_DATA_ENTRY *e = (PE_RESOURCE_DATA_ENTRY *)(rsrc+r->OffsetToData);
			e->OffsetToData += rva;
		}
}
#endif
;

void Pe_Fixup_Rsrc(void *rsrc, longptr_t rva)
#ifdef _C_PEFILE_BUILTIN
{
	Pe_Fixup_Rsrc_Req(rsrc,rva,(PE_RESOURCE_DIRECTORY *)rsrc);
}
#endif
;

C_BUFFER *Pe_Copy_Rsrc(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	PE_SECTION_HEADER *S = Pe_RVA_To_Section(pe,Pe_Get_Dir(pe,PE_DIRECTORY_ENTRY_RESOURCE)->VirtualAddress);
	C_BUFFER *bf = 0;

	if ( S )
	{
		int q = S->SizeOfRawData;
		if ( q > S->Misc.VirtualSize && S->Misc.VirtualSize && q-S->Misc.VirtualSize < 0x1000)
		{
			q = S->Misc.VirtualSize;
		}
		bf = Buffer_Copy((byte_t*)pe+S->PointerToRawData,q);
		Pe_Fixup_Rsrc(bf->at,-S->VirtualAddress);
	}

	return bf;
}
#endif
;

longptr_t Pe_Get_Executable_Size(void *pe)
#ifdef _C_PEFILE_BUILTIN
{
	PE_SECTION_HEADER *S = Pe_Get_First_Section(pe);
	PE_SECTION_HEADER *E = S + Pe_Get_File_Header(pe)->NumberOfSections;

	--E;
	for ( ; E >= S; --E )
	{
		if ( E->SizeOfRawData && E->PointerToRawData )
			return Pe_Align_To_File(pe,E->PointerToRawData + E->SizeOfRawData);
	}

	return 0;
}
#endif
;

void *Pe_Read_NT_Headers(char *filename,int magic)
#ifdef _C_PEFILE_BUILTIN
{
	PE_DOS_HEADER dos;
	void *hdr = __Zero_Malloc(sizeof(PE_HEADERS_64));
	C_FILE *f = Cfile_Open(filename,"r");
	Cfile_Read(f,&dos,sizeof(dos),sizeof(dos));
	if ( dos.e_magic != PE_DOS_SIGNATURE )
		__Raise(C_ERROR_INCONSISTENT,"MZ signature doesn´t match");
	Cfile_Seek(f,dos.e_lfanew,0);
	Cfile_Read(f,hdr,sizeof(PE_HEADERS_64),sizeof(PE_HEADERS_64));
	if ( ((PE_HEADERS_64*)hdr)->Signature != PE_NT_SIGNATURE )
		__Raise(C_ERROR_INCONSISTENT,"PE signature doesn´t match");
	if ( ((PE_HEADERS_64*)hdr)->OptionalHeader.Magic != magic )
		__Raise(C_ERROR_INCONSISTENT,"magic doesn´t match");
	return hdr;
}
#endif
;

PE_HEADERS_32 *Pe_Read_NT_Headers_32(char *filename)
#ifdef _C_PEFILE_BUILTIN
{
	return (PE_HEADERS_32*)Pe_Read_NT_Headers(filename,PE_OPT32_MAGIC);
}
#endif
;

PE_HEADERS_64 *Pe_Read_NT_Headers_64(char *filename)
#ifdef _C_PEFILE_BUILTIN
{
	return (PE_HEADERS_64*)Pe_Read_NT_Headers(filename,PE_OPT64_MAGIC);
}
#endif
;

#endif /* C_once_EA617668_2E48_4AC6_9079_699B387A0662 */


