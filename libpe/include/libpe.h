
/*

(C)2014, Alexey Sudachen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#ifndef C_once_EA617668_2E48_4AC6_9079_699B387A0662
#define C_once_EA617668_2E48_4AC6_9079_699B387A0662

#if ( defined _DLL && !defined LIBPE_STATIC ) || defined LIBPE_DLL || defined LIBPE_BUILD_DLL
#  if defined LIBPE_BUILD_DLL
#    define LIBPE_EXPORTABLE __declspec(dllexport)
#  else
#    define LIBPE_EXPORTABLE __declspec(dllimport)
#  endif
#else
#define LIBPE_EXPORTABLE
#endif

#include <stdint.h>

typedef enum PE_MACHINE
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
} PE_MACHINE;

typedef enum PE_CHARACTERISTICS
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
} PE_CHARACTERISTICS;

typedef enum PE_MAGIC
{
    PE_OPT32_MAGIC        = 0x10b,
    PE_OPT64_MAGIC        = 0x20b,
    PE_DOS_SIGNATURE      = 0x5A4D,
    PE_NT_SIGNATURE       = 0x00004550,
} PE_MAGIC;

typedef enum PE_SUBSYSTEM
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
} PE_SUBSYSTEM;

typedef enum PE_DLL_CHARACTERISTICS
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
} PE_DLL_CHARACTERISTICS;

typedef enum PE_DIRECTORY_INDEX
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
} PE_DIRECTORY_INDEX;

typedef enum PE_SCN
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
} PE_SCN;

typedef struct PE_DOS_HEADER
{
	uint16_t   e_magic;       // Magic number
	uint16_t   e_cblp;        // Bytes on last page of file
	uint16_t   e_cp;          // Pages in file
	uint16_t   e_crlc;        // Relocations
	uint16_t   e_cparhdr;     // Size of header in paragraphs
	uint16_t   e_minalloc;    // Minimum extra paragraphs needed
	uint16_t   e_maxalloc;    // Maximum extra paragraphs needed
	uint16_t   e_ss;          // Initial (relative) SS value
	uint16_t   e_sp;          // Initial SP value
	uint16_t   e_csum;        // Checksum
	uint16_t   e_ip;          // Initial IP value
	uint16_t   e_cs;          // Initial (relative) CS value
	uint16_t   e_lfarlc;      // File address of relocation table
	uint16_t   e_ovno;        // Overlay number
	uint16_t   e_res[4];      // Reserved words
	uint16_t   e_oemid;       // OEM identifier (for e_oeminfo)
	uint16_t   e_oeminfo;     // OEM information; e_oemid specific
	uint16_t   e_res2[10];    // Reserved words
	uint32_t   e_lfanew;      // File address of new exe header
} PE_DOS_HEADER;

typedef struct PE_FILE_HEADER
{
	uint16_t Machine;
	uint16_t NumberOfSections;
	uint32_t TimeDateStamp;
	uint32_t PointerToSymbolTable;
	uint32_t NumberOfSymbols;
	uint16_t SizeOfOptionalHeader;
	uint16_t Characteristics;
} PE_FILE_HEADER;

typedef struct PE_DATA_DIRECTORY
{
	uint32_t VirtualAddress;
	uint32_t Size;
} PE_DATA_DIRECTORY;

typedef struct PE_SECTION_HEADER
{
	uint8_t Name[8];
	union
	{
		uint32_t PhysicalAddress;
		uint32_t VirtualSize;
	} Misc;
	uint32_t VirtualAddress;
	uint32_t SizeOfRawData;
	uint32_t PointerToRawData;
	uint32_t PointerToRelocations;
	uint32_t PointerToLinenumbers;
	uint16_t NumberOfRelocations;
	uint16_t NumberOfLinenumbers;
	uint32_t Characteristics;
} PE_SECTION_HEADER;

#define PE_OPTIONAL_HEADER_32_64(Arch,Dptr) \
	struct _PE_OPTINAL_HEADER_##Arch \
	{\
		uint16_t  Magic;\
		uint8_t   MajorLinkerVersion;\
		uint8_t   MinorLinkerVersion;\
		uint32_t  SizeOfCode;\
		uint32_t  SizeOfInitializedData;\
		uint32_t  SizeOfUninitializedData;\
		uint32_t  AddressOfEntryPoint;\
		uint32_t  BasOfCode;\
		PE_OPTIONAL_HEADER_BASEOF_DATA_##Arch \
		Dptr      ImageBase;\
		uint32_t  SectionAlignment;\
		uint32_t  FileAlignment;\
		uint16_t  MajorOperatingSystemVersion;\
		uint16_t  MinorOperatingSystemVersion;\
		uint16_t  MajorImageVersion;\
		uint16_t  MinorImageVersion;\
		uint16_t  MajorSubsystemVersion;\
		uint16_t  MinorSubsystemVersion;\
		uint32_t  Win32VersionValue;\
		uint32_t  SizeOfImage;\
		uint32_t  SizeOfHeaders;\
		uint32_t  CheckSum;\
		uint16_t  Subsystem;\
		uint16_t  DllCharacteristics;\
		Dptr      SizeOfStackReserve;\
		Dptr      SizeOfStackCommit;\
		Dptr      SizeOfHeapReserve;\
		Dptr      SizeOfHeapCommit;\
		uint32_t  LoaderFlags;\
		uint32_t  NumberOfRvaAndSizes;\
		PE_DATA_DIRECTORY DataDirectory[0x10];\
	}

#define PE_OPTIONAL_HEADER_BASEOF_DATA_32 uint32_t Data;
#define PE_OPTIONAL_HEADER_BASEOF_DATA_64

typedef PE_OPTIONAL_HEADER_32_64(32, uint32_t) PE_OPTIONAL_HEADER_32;
typedef PE_OPTIONAL_HEADER_32_64(64, uint64_t) PE_OPTIONAL_HEADER_64;

typedef struct PE_HEADERS_32
{
	uint32_t Signature;
	PE_FILE_HEADER FileHeader;
	PE_OPTIONAL_HEADER_32 OptionalHeader;
} PE_HEADERS_32;

typedef struct PE_HEADERS_64
{
	uint32_t Signature;
	PE_FILE_HEADER FileHeader;
	PE_OPTIONAL_HEADER_64 OptionalHeader;
} PE_HEADERS_64;

typedef struct PE_EXPORT_DIRECTORY
{
	uint32_t Characteristics;
	uint32_t TimeDateStamp;
	uint16_t MajorVersion;
	uint16_t MinorVersion;
	uint32_t Name;
	uint32_t Base;
	uint32_t NumberOfFunctions;
	uint32_t NumberOfNames;
	uint32_t AddressOfFunctions;
	uint32_t AddressOfNames;
	uint32_t AddressOfNameOrdinals;
} PE_EXPORT_DIRECTORY;

typedef struct PE_IMPORT_DESCRIPTOR
{
	union
	{
		// 0 for terminating null import descriptor
		uint32_t Characteristics;
		// RVA to original unbound IAT (PIMAGE_THUNK_DATA)
		uint32_t OriginalFirstThunk;
	};

	uint32_t TimeDateStamp;
	// -1 if forwarders
	uint32_t ForwarderChain;
	uint32_t Name;
	// RVA to IAT (if bound this IAT has actual addresses)
	uint32_t FirstThunk;
} PE_IMPORT_DESCRIPTOR;

typedef struct PE_RESOURCE_DIRECTORY
{
	uint32_t Characteristics;
	uint32_t TimeDateStamp;
	uint16_t MajorVersion;
	uint16_t MinorVersion;
	uint16_t NumberOfNamedEntries;
	uint16_t NumberOfIdEntries;
	//  IMAGE_RESOURCE_DIRECTORY_ENTRY DirectoryEntries[];
} PE_RESOURCE_DIRECTORY;

typedef struct PE_RESOURCE_DIRECTORY_ENTRY
{
	union
	{
		struct
		{
			uint32_t NameOffset: 31;
			uint32_t NameIsString: 1;
		};
		uint32_t Name;
		uint16_t Id;
	};
	union
	{
		uint32_t OffsetToData;
		struct
		{
			uint32_t OffsetToDirectory: 31;
			uint32_t DataIsDirectory: 1;
		};
	};
} PE_RESOURCE_DIRECTORY_ENTRY;

typedef struct PE_RESOURCE_DATA_ENTRY
{
	uint32_t OffsetToData;
	uint32_t Size;
	uint32_t CodePage;
	uint32_t Reserved;
} PE_RESOURCE_DATA_ENTRY;

typedef struct PE_SOURCE PE_SOURCE;

typedef int PE_BOOL;
#define PE_INVALID_VALUE     (~(size_t)0)
#define PE_INVALID_NO        (~(size_t)0)
#define PE_INVALID_RVA       (~(uint64_t)0)
#define PE_INVALID_OFFSET    (~(uint64_t)0)

typedef enum PE_ERROR
{
    PE_ERROR_SUCCESS = 0,
    PE_ERROR_OPEN,
    PE_ERROR_NO_PEIMAGE,
    PE_ERROR_READ,
    PE_ERROR_SEEK,
    PE_ERROR_NO_32BIT_IMAGE,
    PE_ERROR_NO_64BIT_IMAGE,
    PE_ERROR_INTERNAL,
    PE_ERROR_INVALID_VALUE,
    PE_ERROR_NOT_FOUND,
} PE_ERROR;

#ifdef __cplusplus
extern "C" {
#endif

LIBPE_EXPORTABLE int Libpe_Last_Error();
LIBPE_EXPORTABLE const char* Libpe_Last_Error_String();

#ifdef _WIN32
LIBPE_EXPORTABLE PE_SOURCE* Libpe_Open_File_W(const wchar_t* filename);
#endif

LIBPE_EXPORTABLE PE_SOURCE* Libpe_Open_File_U(const char* filename);
LIBPE_EXPORTABLE PE_SOURCE* Libpe_Open_Memory(const void* bytes, size_t count);

LIBPE_EXPORTABLE PE_BOOL  Libpe_Close(PE_SOURCE*);
LIBPE_EXPORTABLE int      Libpe_Type(PE_SOURCE*); /* 32 or 64 */
LIBPE_EXPORTABLE uint64_t Libpe_Get_Imagebase(PE_SOURCE*);
LIBPE_EXPORTABLE uint64_t Libpe_Get_SizeOfImage(PE_SOURCE*);
LIBPE_EXPORTABLE size_t   Libpe_Get_FileAlignment(PE_SOURCE*);
LIBPE_EXPORTABLE size_t   Libpe_Get_SectionAlignment(PE_SOURCE*);
LIBPE_EXPORTABLE size_t   Libpe_Get_NumberOfSections(PE_SOURCE*);
LIBPE_EXPORTABLE size_t   Libpe_Get_NumberOfExports(PE_SOURCE*);
LIBPE_EXPORTABLE size_t   Libpe_Get_NumberOfModules(PE_SOURCE*);
LIBPE_EXPORTABLE size_t   Libpe_Get_NumberOfImports(PE_SOURCE*, size_t module_no);
LIBPE_EXPORTABLE uint64_t Libpe_Get_AddressOfEntryPoint(PE_SOURCE*);
LIBPE_EXPORTABLE uint64_t Libpe_Align_To_Section(PE_SOURCE*, uint64_t offs);
LIBPE_EXPORTABLE uint64_t Libpe_Align_To_File(PE_SOURCE*, uint64_t offs);
LIBPE_EXPORTABLE PE_BOOL  Libpe_Get_Opt32(PE_SOURCE*, PE_OPTIONAL_HEADER_32* ret);
LIBPE_EXPORTABLE PE_BOOL  Libpe_Get_Opt64(PE_SOURCE*, PE_OPTIONAL_HEADER_64* ret);
LIBPE_EXPORTABLE PE_BOOL  Libpe_Get_FileHeader(PE_SOURCE*, PE_FILE_HEADER* ret);
LIBPE_EXPORTABLE uint64_t Libpe_RVA_To_Offs(PE_SOURCE*, uint64_t rva);
LIBPE_EXPORTABLE uint64_t Libpe_Offs_To_RVA(PE_SOURCE*, uint64_t offs);
LIBPE_EXPORTABLE size_t   Libpe_Find_Section_No(PE_SOURCE*, const char* name);
LIBPE_EXPORTABLE PE_BOOL  Libpe_Get_Section(PE_SOURCE*, size_t no, PE_SECTION_HEADER* ret);
LIBPE_EXPORTABLE size_t   Libpe_Section_Attrs(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE size_t   Libpe_Section_Size(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE size_t   Libpe_Section_Raw_Size(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE uint64_t Libpe_Section_Offs(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE uint64_t Libpe_Section_RVA(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE size_t   Libpe_RVA_To_Section_No(PE_SOURCE*, uint64_t rva);
LIBPE_EXPORTABLE size_t   Libpe_Find_Export_No(PE_SOURCE*, const char* name);
LIBPE_EXPORTABLE uint64_t Libpe_Find_Export_RVA(PE_SOURCE*, const char* name);
LIBPE_EXPORTABLE uint64_t Libpe_Export_Offs(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE uint64_t Libpe_Export_RVA(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE PE_BOOL  Libpe_Get_Direntry(PE_SOURCE*, size_t no, PE_DATA_DIRECTORY* ret);
LIBPE_EXPORTABLE size_t   Libpe_Direntry_Size(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE uint64_t Libpe_Direntry_Offs(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE uint64_t Libpe_Direntry_RVA(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE size_t   Libpe_RVA_To_Direntry_No(PE_SOURCE*, uint64_t rva);
LIBPE_EXPORTABLE PE_BOOL  Libpe_Copy_Offs(PE_SOURCE*, uint64_t offs, void* buf, size_t count);
LIBPE_EXPORTABLE PE_BOOL  Libpe_Copy_RVA(PE_SOURCE*, uint64_t rva, void* buf, size_t count);

LIBPE_EXPORTABLE const char* Libpe_Section_Name(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE const char* Libpe_Export_Name(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE const char* Libpe_Module_Name(PE_SOURCE*, size_t no);
LIBPE_EXPORTABLE const char* Libpe_Import_Name(PE_SOURCE*, size_t module_no, size_t import_no);
LIBPE_EXPORTABLE size_t Libpe_Import_Ord(PE_SOURCE*, size_t module_no, size_t import_no);

LIBPE_EXPORTABLE void Libpe_Kill_Cstr(char*);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* C_once_EA617668_2E48_4AC6_9079_699B387A0662 */

