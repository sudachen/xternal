
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

#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include <errno.h>
#include <assert.h>

#include "../include/libpe.h"
#include "cbuffer.h"
#include "ctable.h"

#ifdef _WIN32
#include <windows.h>
#define fseeko(f,pos,how) _fseeki64(f,pos,how)
#endif

#define GET_NTH32(Base) \
	((PE_HEADERS_32*)((char*)(Base) + ((PE_DOS_HEADER*)(Base))->e_lfanew))
#define GET_SEC32(Base) \
	((PE_SECTION_HEADER*)((char*)(Base) + ((PE_DOS_HEADER*)(Base))->e_lfanew + 4 + sizeof(PE_FILE_HEADER) + GET_NTH32(Base)->FileHeader.SizeOfOptionalHeader ))
#define GET_NTH64(Base) \
	((PE_HEADERS_64*)((char*)(Base) + ((PE_DOS_HEADER*)(Base))->e_lfanew))
#define GET_SEC64(Base) \
	((PE_SECTION_HEADER*)((char*)(Base) + ((PE_DOS_HEADER*)(Base))->e_lfanew + 4 + sizeof(PE_FILE_HEADER) + GET_NTH64(Base)->FileHeader.SizeOfOptionalHeader ))

struct PE_SOURCE
{
	uint8_t* bytes;
	size_t      count;
	FILE*       file;
	size_t      headers_size;

	PE_DOS_HEADER *dh;
	
	union 
	{
		PE_HEADERS_32 *nth32;
		PE_HEADERS_64 *nth64;
	};

	PE_EXPORT_DIRECTORY exp_dir;
	uint32_t*   exp_names;
	uint32_t*   exp_names_2;
	uint32_t*   exp_functions;
	uint16_t*   exp_ordinals;
	C_BUFFER*   expt;
	C_BUFFER*   imports;
	C_BUFFER*   iat;
	C_BUFFER*   tmp;
	C_TABLE*    strings;

	uint32_t    delete_bytes : 1;
	uint32_t    from_file: 1;
	uint32_t    pe64: 1;
	uint32_t    exports_is_good: 1;
	uint32_t    imports_is_good: 1;
};

typedef struct PE_IMPORT_MODULE
{
	uint32_t    rva_name;
	uint32_t    rva_iat;
	uint32_t    start;
	uint32_t    number_of_functions;
} PE_IMPORT_MODULE;

typedef struct PE_NTH_PART
{
	uint32_t Signature;
	PE_FILE_HEADER FileHeader;
} PE_NTH_PART;

static int last_error = 0;
static char last_error_string[1024] = {0};

int Libpe_Last_Error()
{
	return last_error;
}

const char* Libpe_Last_Error_String()
{
	return last_error_string;
}

int Libpe_Error(int error, const char* fmt, ...)
{
	if (!error)
	{
		error = 0;
		last_error_string[0] = 0;
	}
	else
	{
		va_list va;
		va_start(va, fmt);
		vsnprintf(last_error_string, sizeof(last_error_string) - 1, fmt, va);
		va_end(va);
	}
	return error;
}

int Libpe_Type(PE_SOURCE* pe)
{
	return pe->pe64 ? 64 : 32;
}

static size_t Libpe_Headers_Size(uint8_t* bytes)
{
	PE_DOS_HEADER* dosh = (PE_DOS_HEADER*)bytes;
	PE_NTH_PART*   nthp = (PE_NTH_PART*)(bytes + dosh->e_lfanew);
	return dosh->e_lfanew + sizeof(PE_NTH_PART) + nthp->FileHeader.SizeOfOptionalHeader;
}

static int Libpe_Check_Image(uint8_t* bytes, size_t count, int from_file)
{
	PE_DOS_HEADER* dosh = (PE_DOS_HEADER*)bytes;
	PE_NTH_PART*   nthp;
	PE_OPTIONAL_HEADER_32* nth32;
	PE_OPTIONAL_HEADER_64* nth64;
	if (count < sizeof(PE_DOS_HEADER))
		return 0;
	if (count < dosh->e_lfanew + sizeof(PE_NTH_PART))
		return 0;

	nthp = (PE_NTH_PART*)(bytes + dosh->e_lfanew);
	if (count < dosh->e_lfanew + sizeof(PE_NTH_PART)
	    + nthp->FileHeader.SizeOfOptionalHeader
	    + sizeof(PE_SECTION_HEADER)*nthp->FileHeader.NumberOfSections)
		return 0;

	if (dosh->e_magic != PE_DOS_SIGNATURE)
		return 0;
	if (nthp->Signature != PE_NT_SIGNATURE)
		return 0;

	nth32 = (PE_OPTIONAL_HEADER_32*)(bytes + dosh->e_lfanew + sizeof(PE_NTH_PART));
	if (nth32->Magic != PE_OPT32_MAGIC && nth32->Magic != PE_OPT64_MAGIC)
		return 0;

	switch (nth32->Magic)
	{
		case PE_OPT32_MAGIC: return 32;
		case PE_OPT64_MAGIC: return 64;
	}

	return 0; /* unreachable */
}

static PE_SOURCE* Libpe_Open_FILE(FILE* f)
{
	int it;
	PE_DOS_HEADER dosh;
	PE_NTH_PART   nthp;
	PE_SOURCE* pe = calloc(1, sizeof(PE_SOURCE));
	pe->from_file = 1;
	pe->delete_bytes = 1;
	pe->file = f;

	if (fread(&dosh, sizeof(dosh), 1, pe->file) != 1)
	{
		Libpe_Error(PE_ERROR_READ, "read file error: %s", strerror(ferror(pe->file)));
		goto error;
	}

	if (dosh.e_magic != PE_DOS_SIGNATURE)
	{
		Libpe_Error(PE_ERROR_NO_64BIT_IMAGE, "MZ signature doesn't match");
		goto error;
	}

	if (fseek(pe->file, dosh.e_lfanew, SEEK_SET) < 0)
	{
		Libpe_Error(PE_ERROR_SEEK, "seek file error: %s", strerror(ferror(pe->file)));
		goto error;
	}

	if (fread(&nthp, sizeof(nthp), 1, pe->file) != 1)
	{
		Libpe_Error(PE_ERROR_READ, "read file error: %s", strerror(ferror(pe->file)));
		goto error;
	}

	if (nthp.Signature != PE_NT_SIGNATURE)
	{
		Libpe_Error(PE_ERROR_NO_64BIT_IMAGE, "PE signature doesn't match");
		goto error;
	}

	pe->count = dosh.e_lfanew + sizeof(nthp) + nthp.FileHeader.SizeOfOptionalHeader + sizeof(
	                PE_SECTION_HEADER) * nthp.FileHeader.NumberOfSections;
	pe->bytes = calloc(1, pe->count);
	pe->headers_size = dosh.e_lfanew + sizeof(nthp) + nthp.FileHeader.SizeOfOptionalHeader;

	if (fseek(pe->file, 0, SEEK_SET) < 0)
	{
		Libpe_Error(PE_ERROR_SEEK, "seek file error: %s", strerror(ferror(pe->file)));
		goto error;
	}

	if (fread(pe->bytes, pe->count, 1, pe->file) != 1)
	{
		Libpe_Error(PE_ERROR_READ, "read file error: %s", strerror(ferror(pe->file)));
		goto error;
	}

	it = Libpe_Check_Image(pe->bytes, pe->count, 1);
	if (it == 64)
		pe->pe64 = 1;
	else if (it == 0)
	{
		Libpe_Error(PE_ERROR_NO_PEIMAGE, "is not valid PE32/PE32+ image");
		goto error;
	}
	pe->dh = (PE_DOS_HEADER *)pe->bytes;
	pe->nth32 = GET_NTH32(pe->bytes);
	return pe;

error:
	Libpe_Close(pe);
	return 0;
}

PE_SOURCE* Libpe_Open_File_U(const char* filename)
{
#ifdef _WIN32
	wchar_t wbuffer[261] = {0,};
	if (!MultiByteToWideChar(65001/*CP_UTF8*/, 0, filename, -1, wbuffer, 260))
	{
		Libpe_Error(PE_ERROR_INTERNAL, "could not convert given filename from UTF'8 to windows UTF-16");
		return 0;
	}
	return Libpe_Open_File_W(wbuffer);
#else
	FILE* file = fopen(filename, "rb");
	if (!file)
	{
		Libpe_Error(PE_ERROR_OPEN, "openfile error: %s", strerror(errno));
		return 0;
	}
	return Libpe_Open_FILE(file);
#endif
}

#ifdef _WIN32
PE_SOURCE* Libpe_Open_File_W(const wchar_t* filename)
{
	FILE* file = _wfopen(filename, L"rb");
	if (!file)
	{
		Libpe_Error(PE_ERROR_OPEN, "openfile error: %s", strerror(errno));
		return 0;
	}
	return Libpe_Open_FILE(file);
}
#endif

PE_SOURCE* Libpe_Open_Memory(const void* bytes, size_t count)
{
	int it;
	PE_SOURCE* pe = calloc(1, sizeof(PE_SOURCE));
	pe->bytes = (uint8_t*)bytes;
	pe->count = count;
	it = Libpe_Check_Image(pe->bytes, pe->count, 0);
	if (it == 64)
		pe->pe64 = 1;
	else if (it == 0)
	{
		Libpe_Error(PE_ERROR_NO_PEIMAGE, "is not valid PE32/PE32+ image");
		return 0;
	}
	pe->headers_size = Libpe_Headers_Size(pe->bytes);
	return pe;
}

PE_BOOL Libpe_Close(PE_SOURCE* pe)
{
	if (pe)
	{
		if (pe->file) fclose(pe->file);
		if (pe->delete_bytes && pe->bytes) free(pe->bytes);
		Buffer_Kill(pe->expt);
		Buffer_Kill(pe->iat);
		Buffer_Kill(pe->imports);
		Buffer_Kill(pe->tmp);
		Table_Kill(pe->strings);
		free(pe);
		return 1;
	}
	return 0;
}

uint64_t Libpe_Get_Imagebase(PE_SOURCE* pe)
{
	assert(pe != 0);
	if (pe->pe64)
		return GET_NTH64(pe->bytes)->OptionalHeader.ImageBase;
	else
		return GET_NTH32(pe->bytes)->OptionalHeader.ImageBase;
}

uint64_t Libpe_Get_SizeOfImage(PE_SOURCE* pe)
{
	assert(pe != 0);
	if (pe->pe64)
		return GET_NTH64(pe->bytes)->OptionalHeader.SizeOfImage;
	else
		return GET_NTH32(pe->bytes)->OptionalHeader.SizeOfImage;
}

size_t Libpe_Get_FileAlignment(PE_SOURCE* pe)
{
	assert(pe != 0);
	if (pe->pe64)
		return GET_NTH64(pe->bytes)->OptionalHeader.FileAlignment;
	else
		return GET_NTH32(pe->bytes)->OptionalHeader.FileAlignment;
}

size_t Libpe_Get_SectionAlignment(PE_SOURCE* pe)
{
	assert(pe != 0);
	if (pe->pe64)
		return GET_NTH64(pe->bytes)->OptionalHeader.SectionAlignment;
	else
		return GET_NTH32(pe->bytes)->OptionalHeader.SectionAlignment;
}

size_t Libpe_Get_NumberOfSections(PE_SOURCE* pe)
{
	assert(pe != 0);
	return GET_NTH32(pe->bytes)->FileHeader.NumberOfSections;
}

uint64_t Libpe_Get_AddressOfEntryPoint(PE_SOURCE* pe)
{
	assert(pe != 0);
	if (pe->pe64)
		return GET_NTH64(pe->bytes)->OptionalHeader.AddressOfEntryPoint;
	else
		return GET_NTH32(pe->bytes)->OptionalHeader.AddressOfEntryPoint;
}

uint64_t Libpe_Align_To_Section(PE_SOURCE* pe, uint64_t offs)
{
	uint64_t alignment;
	assert(pe != 0);
	alignment = Libpe_Get_SectionAlignment(pe);
	return (offs + alignment - 1) & ~(alignment - 1);
}

uint64_t Libpe_Align_To_File(PE_SOURCE* pe, uint64_t offs)
{
	uint64_t alignment;
	assert(pe != 0);
	alignment = Libpe_Get_FileAlignment(pe);
	return (offs + alignment - 1) & ~(alignment - 1);
}

PE_BOOL Libpe_Get_Opt32(PE_SOURCE* pe, PE_OPTIONAL_HEADER_32* ret)
{
	assert(pe != 0);
	if (!pe->pe64)
	{
		*ret = GET_NTH32(pe)->OptionalHeader;
		return 1;
	}
	else
	{
		Libpe_Error(PE_ERROR_NO_32BIT_IMAGE, "is not 32-bit image");
		return 0;
	}
}

PE_BOOL Libpe_Get_Opt64(PE_SOURCE* pe, PE_OPTIONAL_HEADER_64* ret)
{
	assert(pe != 0);
	if (pe->pe64)
	{
		*ret = GET_NTH64(pe)->OptionalHeader;
		return 1;
	}
	else
	{
		Libpe_Error(PE_ERROR_NO_64BIT_IMAGE, "is not 64-bit image");
		return 0;
	}
}

PE_BOOL Libpe_Get_FileHeader(PE_SOURCE* pe, PE_FILE_HEADER* ret)
{
	assert(pe != 0);
	*ret = GET_NTH32(pe)->FileHeader;
	return 1;
}

size_t Libpe_RVA_To_Section_No(PE_SOURCE* pe, uint64_t rva)
{
	size_t i;
	uint64_t image_size;
	PE_FILE_HEADER* fh;
	PE_SECTION_HEADER* sec;

	assert(pe != 0);

	fh = &GET_NTH32(pe->bytes)->FileHeader;
	sec = (PE_SECTION_HEADER*)(pe->bytes + pe->headers_size);

	for (i = 0; i < fh->NumberOfSections - 1; ++i)
	{
		uint32_t sec_size = sec[i + 1].VirtualAddress - sec[i].VirtualAddress;
		if (sec[i].VirtualAddress <= rva
		    && sec[i].VirtualAddress + sec_size > rva)
			return i;
	}
	image_size = Libpe_Get_SizeOfImage(pe);
	if (sec[i].VirtualAddress <= rva && image_size > rva)
		return i;

	Libpe_Error(PE_ERROR_NOT_FOUND, "there is no section mapped to rva %llx", rva);
	return PE_INVALID_NO;
}

uint64_t Libpe_RVA_To_Offs(PE_SOURCE* pe, uint64_t rva)
{
	assert(pe != 0);

	if (rva < pe->headers_size)
		return rva;
	else
	{
		PE_SECTION_HEADER* sec = (PE_SECTION_HEADER*)(pe->bytes + pe->headers_size);
		size_t sec_no = Libpe_RVA_To_Section_No(pe, rva);
		if (sec_no != PE_INVALID_NO)
		{
			if (sec[sec_no].PointerToRawData &&
			    rva - sec[sec_no].VirtualAddress < sec[sec_no].SizeOfRawData)
				return rva - sec[sec_no].VirtualAddress + sec[sec_no].PointerToRawData;
		}
	}

	Libpe_Error(PE_ERROR_NOT_FOUND, "there is no section mapped to rva %llx", rva);
	return PE_INVALID_OFFSET;
}

uint64_t Libpe_Offs_To_RVA(PE_SOURCE* pe, uint64_t offs)
{
	assert(pe != 0);

	if (offs < pe->headers_size)
		return offs;
	else
	{
		size_t i;
		PE_FILE_HEADER* fh = &GET_NTH32(pe->bytes)->FileHeader;
		PE_SECTION_HEADER* sec = (PE_SECTION_HEADER*)(pe->bytes + pe->headers_size);
		for (i = 0; i < fh->NumberOfSections; ++i)
		{
			if (sec[i].PointerToRawData <= offs
			    && sec[i].PointerToRawData + sec[i].SizeOfRawData > offs)
				return sec[i].VirtualAddress + (offs - sec[i].PointerToRawData);
		}
	}

	Libpe_Error(PE_ERROR_NOT_FOUND, "there is no section mapped to file offset %llx", offs);
	return PE_INVALID_RVA;
}

size_t Libpe_Find_Section_No(PE_SOURCE* pe, const char* name)
{
	size_t i;
	PE_FILE_HEADER* fh;
	PE_SECTION_HEADER* sec;

	assert(pe != 0);

	fh = &GET_NTH32(pe->bytes)->FileHeader;
	sec = (PE_SECTION_HEADER*)(pe->bytes + pe->headers_size);

	if (strlen(name) <= 8)
		for (i = 0; i < fh->NumberOfSections; ++i)
		{
			if (!strncmp(sec[i].Name, name, 8)) return i;
		}

	Libpe_Error(PE_ERROR_NOT_FOUND, "there is no section with name %s", name);
	return PE_INVALID_NO;
}

PE_BOOL Libpe_Get_Section(PE_SOURCE* pe, size_t no, PE_SECTION_HEADER* ret)
{
	PE_FILE_HEADER* fh;
	PE_SECTION_HEADER* sec;

	assert(pe != 0);

	fh = &GET_NTH32(pe->bytes)->FileHeader;
	sec = (PE_SECTION_HEADER*)(pe->bytes + pe->headers_size);

	if (no >= fh->NumberOfSections)
	{
		Libpe_Error(PE_ERROR_INVALID_VALUE, "invalid section index %u", (unsigned int)no);
		return 0;
	}

	*ret = sec[no];

	return 1;
}

static PE_SECTION_HEADER* Libpe_Section(PE_SOURCE* pe, size_t no)
{
	PE_FILE_HEADER* fh;
	PE_SECTION_HEADER* sec;

	assert(pe != 0);

	fh = &GET_NTH32(pe->bytes)->FileHeader;
	sec = (PE_SECTION_HEADER*)(pe->bytes + pe->headers_size);

	if (no >= fh->NumberOfSections)
	{
		Libpe_Error(PE_ERROR_INVALID_VALUE, "invalid section index %u", (unsigned int)no);
		return 0;
	}

	return sec + no;
}

size_t Libpe_Section_Attrs(PE_SOURCE* pe, size_t no)
{
	PE_SECTION_HEADER* sec = Libpe_Section(pe, no);
	if (!sec) return PE_INVALID_VALUE;
	return sec->Characteristics;
}

size_t Libpe_Section_Raw_Size(PE_SOURCE* pe, size_t no)
{
	PE_SECTION_HEADER* sec = Libpe_Section(pe, no);
	if (!sec) return PE_INVALID_VALUE;
	return sec->SizeOfRawData;
}

size_t Libpe_Section_Size(PE_SOURCE* pe, size_t no)
{
	PE_FILE_HEADER* fh;
	PE_SECTION_HEADER* sec;

	assert(pe != 0);

	fh = &GET_NTH32(pe->bytes)->FileHeader;
	sec = (PE_SECTION_HEADER*)(pe->bytes + pe->headers_size);

	if (no >= fh->NumberOfSections)
	{
		Libpe_Error(PE_ERROR_INVALID_VALUE, "invalid section index %u", (unsigned int)no);
		return PE_INVALID_VALUE;
	}

	if (no + 1 == fh->NumberOfSections)
	{
		uint64_t image_size = Libpe_Get_SizeOfImage(pe);
		return image_size - sec[no].VirtualAddress;
	}
	else
	{
		return sec[no + 1].VirtualAddress - sec[no].VirtualAddress;
	}
}

uint64_t Libpe_Section_Offs(PE_SOURCE* pe, size_t no)
{
	PE_SECTION_HEADER* sec = Libpe_Section(pe, no);
	if (!sec) return PE_INVALID_OFFSET;
	return sec->PointerToRawData;
}

uint64_t Libpe_Section_RVA(PE_SOURCE* pe, size_t no)
{
	PE_SECTION_HEADER* sec = Libpe_Section(pe, no);
	if (!sec) return PE_INVALID_RVA;
	return sec->VirtualAddress;
}

const char* Libpe_Section_Name(PE_SOURCE* pe, size_t no)
{
	int i;
	static char name[9] = {0};
	PE_SECTION_HEADER* sec = Libpe_Section(pe, no);
	
	if (!sec) 
		return 0;

	memcpy(name, sec->Name, 8);
	for (i = 7; i >= 0; --i)
	{
		if (name[i] == ' ')
			name[i] = 0;
		else
			break;
	}
	return name;
}

static PE_DATA_DIRECTORY* Libpe_Direntry(PE_SOURCE* pe, size_t no)
{
	assert(pe != 0);
	if (no >= 0x10)
	{
		Libpe_Error(PE_ERROR_INVALID_VALUE, "invalid derectory index %u", (unsigned int)no);
		return 0;
	}
	if (pe->pe64)
	{
		PE_HEADERS_64 *nth = GET_NTH64(pe->bytes);
		return &(nth->OptionalHeader.DataDirectory[no]);
	}
	else
	{
		PE_HEADERS_32 *nth = GET_NTH32(pe->bytes);
		return &(nth->OptionalHeader.DataDirectory[no]);
	}
}

PE_BOOL Libpe_Get_Direntry(PE_SOURCE* pe, size_t no, PE_DATA_DIRECTORY* ret)
{
	PE_DATA_DIRECTORY* de = Libpe_Direntry(pe, no);

	if (de)
	{
		*ret = *de;
		return 1;
	}

	return 0;
}

size_t Libpe_Direntry_Size(PE_SOURCE* pe, size_t no)
{
	PE_DATA_DIRECTORY* de = Libpe_Direntry(pe, no);

	if (de)
	{
		return de->Size;
	}

	return PE_INVALID_VALUE;
}

uint64_t Libpe_Direntry_Offs(PE_SOURCE* pe, size_t no)
{
	PE_DATA_DIRECTORY* de = Libpe_Direntry(pe, no);

	if (de)
	{
		return Libpe_RVA_To_Offs(pe, de->VirtualAddress);
	}

	return PE_INVALID_OFFSET;
}

uint64_t Libpe_Direntry_RVA(PE_SOURCE* pe, size_t no)
{
	PE_DATA_DIRECTORY* de = Libpe_Direntry(pe, no);

	if (de)
	{
		return de->VirtualAddress;
	}

	return PE_INVALID_RVA;
}

size_t Libpe_RVA_To_Direntry_No(PE_SOURCE* pe, uint64_t rva)
{
	size_t i;
	PE_DATA_DIRECTORY* de;

	assert(pe != 0);

	if (pe->pe64)
		de = &(GET_NTH64(pe)->OptionalHeader.DataDirectory[0]);
	else
		de = &(GET_NTH32(pe)->OptionalHeader.DataDirectory[0]);

	for (i = 0; i < 0x10; ++i)
	{
		if (de[i].VirtualAddress <= rva && de[i].Size + de[i].VirtualAddress > rva)
			return i;
	}

	Libpe_Error(PE_ERROR_NOT_FOUND, "there is no direentry with rva %llx", rva);
	return PE_INVALID_NO;
}

static PE_BOOL Libpe_Prepare_Exports(PE_SOURCE* pe)
{
	size_t i;
	PE_DATA_DIRECTORY exp = {0,};

	if (!Libpe_Get_Direntry(pe, PE_DIRECTORY_ENTRY_EXPORT, &exp))
		return 0;

	if (!Libpe_Copy_RVA(pe, exp.VirtualAddress, &pe->exp_dir, sizeof(pe->exp_dir)))
		return 0;

	if (!pe->expt) pe->expt = Buffer_Init(0);
	Buffer_Resize(pe->expt,
	              sizeof(uint32_t)*pe->exp_dir.NumberOfNames +
	              sizeof(uint16_t)*pe->exp_dir.NumberOfNames +
	              sizeof(uint32_t)*pe->exp_dir.NumberOfFunctions +
	              sizeof(uint32_t)*pe->exp_dir.NumberOfFunctions);

	pe->exp_names = (uint32_t*)pe->expt->at;
	if (!Libpe_Copy_RVA(pe, pe->exp_dir.AddressOfNames, pe->exp_names,
	                    sizeof(uint32_t)*pe->exp_dir.NumberOfNames))
		return 0;

	pe->exp_ordinals  = (uint16_t*)(pe->expt->at
	                                + sizeof(uint32_t) * pe->exp_dir.NumberOfNames);
	if (!Libpe_Copy_RVA(pe, pe->exp_dir.AddressOfNameOrdinals, pe->exp_ordinals,
	                    sizeof(uint16_t)*pe->exp_dir.NumberOfNames))
		return 0;

	pe->exp_functions = (uint32_t*)(pe->expt->at
	                                + sizeof(uint32_t) * pe->exp_dir.NumberOfNames
	                                + sizeof(uint16_t) * pe->exp_dir.NumberOfNames);
	if (!Libpe_Copy_RVA(pe, pe->exp_dir.AddressOfFunctions, pe->exp_functions,
	                    sizeof(uint32_t)*pe->exp_dir.NumberOfFunctions))
		return 0;

	pe->exp_names_2 = (uint32_t*)(pe->expt->at
	                              + sizeof(uint32_t) * pe->exp_dir.NumberOfNames
	                              + sizeof(uint16_t) * pe->exp_dir.NumberOfNames
	                              + sizeof(uint32_t) * pe->exp_dir.NumberOfFunctions);

	memset(pe->exp_names_2, 0xff, sizeof(uint32_t) * pe->exp_dir.NumberOfFunctions);
	for (i = 0; i < pe->exp_dir.NumberOfNames; ++i)
	{
		uint16_t ord = pe->exp_ordinals[i];
		if (ord > pe->exp_dir.NumberOfFunctions)
		{
			Libpe_Error(PE_ERROR_INTERNAL, "corrupted exports");
			return 0;
		}
		pe->exp_names_2[ord] = pe->exp_names[i];
	}

	pe->exports_is_good = 1;
	return 1;
}

enum { MAX_STRING_LENGTH = 512 };

const char* Libpe_Cache_Str(PE_SOURCE* pe, uint64_t rva)
{
	const C_TABLE_VALUE* val;
	assert(pe != 0);

	if (!pe->strings)
	{
		pe->strings = Table_Init();
	}

	val = Table_Get(pe->strings, rva);
	if (!val)
	{
		uint64_t offs = Libpe_RVA_To_Offs(pe,rva);
		if (offs == PE_INVALID_OFFSET) return 0;
		if (pe->from_file)
		{
			int r;
			size_t i = 0;
			char bf[MAX_STRING_LENGTH + 1] = {0};
			if (fseeko(pe->file, offs, SEEK_SET) < 0)
			{
				Libpe_Error(PE_ERROR_SEEK, "seek file error: %s", strerror(ferror(pe->file)));
				return 0;
			}
			while (i < MAX_STRING_LENGTH)
			{
				r = fread(&bf[i], 1, MAX_STRING_LENGTH - i, pe->file);
				if (r <= 0 && feof(pe->file))
				{
					break;
				}
				else if (r < 0)
				{
					Libpe_Error(PE_ERROR_READ, "read file error: %s", strerror(ferror(pe->file)));
					return 0;
				}
				i += r;
			}
			val = Table_Put_Copy_Z(pe->strings, rva, bf, i);
		}
		else
		{
			size_t i;
			for (i = 0; i < pe->count - offs && i < MAX_STRING_LENGTH; ++i)
				if (pe->bytes[(size_t)offs + i] == 0)
					break;
			val = Table_Put_Copy_Z(pe->strings, rva, pe->bytes + (size_t)offs, i);
		}
	}
	return val->ptr;
}

size_t Libpe_Find_Export_No(PE_SOURCE* pe, const char* name)
{
	int L,R;

	assert(pe != 0);
	
	if (!pe->exports_is_good)
	{
		if (!Libpe_Prepare_Exports(pe))
			return PE_INVALID_NO;
	}

	L = 0;
	R = pe->exp_dir.NumberOfNames - 1;

	while (L <= R)
	{
		int cmp, k = (L + R) / 2;
		const char* r_name = Libpe_Cache_Str(pe, pe->exp_names[k]);
		if (!r_name)
		{
			return PE_INVALID_NO;
		}
		cmp = strncmp(name, r_name, 127);
		if (!cmp)
		{
			uint16_t ord;
			assert(k >= 0);
			assert(k < pe->exp_dir.NumberOfNames);
			ord = pe->exp_ordinals[k];
			if (ord > pe->exp_dir.NumberOfFunctions)
			{
				Libpe_Error(PE_ERROR_INTERNAL, "ordinal in export table out of functions range");
				return PE_INVALID_NO;
			}
			return ord;
		}
		else if (cmp > 0) L = k + 1;
		else R = k - 1;
	}

	return PE_INVALID_NO;
}

uint64_t Libpe_Export_RVA(PE_SOURCE* pe, size_t no)
{
	assert(pe != 0);
	if (!pe->exports_is_good)
	{
		if (!Libpe_Prepare_Exports(pe))
			return PE_INVALID_RVA;
	}
	if (no >= pe->exp_dir.NumberOfFunctions)
	{
		return PE_INVALID_RVA;
	}
	return pe->exp_functions[no];
}

uint64_t Libpe_Find_Export_RVA(PE_SOURCE* pe, const char* name)
{
	size_t no = Libpe_Find_Export_No(pe, name);
	if (no == PE_INVALID_NO)
		return PE_INVALID_RVA;
	return Libpe_Export_RVA(pe, no);
}

uint64_t Libpe_Export_Offs(PE_SOURCE* pe, size_t no)
{
	uint64_t rva = Libpe_Export_RVA(pe, no);
	if (rva != PE_INVALID_RVA)
		return Libpe_RVA_To_Offs(pe, rva);
	return PE_INVALID_OFFSET;
}

const char* Libpe_Export_Name(PE_SOURCE* pe, size_t no)
{
	assert(pe != 0);
	if (!pe->exports_is_good)
	{
		if (!Libpe_Prepare_Exports(pe))
			return 0;
	}

	Libpe_Error(0, 0);

	if (no >= pe->exp_dir.NumberOfFunctions)
		return 0;

	if (pe->exp_names_2[no] == (~(uint32_t)0))
		return 0;
	return Libpe_Cache_Str(pe, pe->exp_names_2[no]);
}

size_t Libpe_Get_NumberOfExports(PE_SOURCE* pe)
{
	assert(pe != 0);
	if (!pe->exports_is_good)
	{
		if (!Libpe_Prepare_Exports(pe))
			return PE_INVALID_VALUE;
	}

	return pe->exp_dir.NumberOfFunctions;
}

PE_BOOL Libpe_Prepare_Imports(PE_SOURCE* pe)
{
	size_t i, j;
	PE_DATA_DIRECTORY di;

	assert(pe != 0);
	if (!pe->imports) pe->imports = Buffer_Init(0);
	if (!pe->iat) pe->iat = Buffer_Init(0);
	if (!pe->tmp) pe->tmp = Buffer_Init(0);

	Buffer_Clear(pe->imports);
	Buffer_Clear(pe->iat);
	Buffer_Resize(pe->tmp, 0);

	if (!Libpe_Get_Direntry(pe, PE_DIRECTORY_ENTRY_IMPORT, &di))
		return 0;

	Buffer_Resize(pe->tmp, di.Size);
	if (!Libpe_Copy_RVA(pe, di.VirtualAddress, pe->tmp->at, pe->tmp->count))
		return 0;

	for (i = 0; i < di.Size / sizeof(PE_IMPORT_DESCRIPTOR); ++i)
	{
		uint64_t names_offs;
		size_t val_size = pe->pe64 ? 8 : 4;
		PE_IMPORT_MODULE   imod = {0,};
		PE_IMPORT_DESCRIPTOR* dsc = (PE_IMPORT_DESCRIPTOR*)pe->tmp->at + i;
		if (!dsc->Name || !dsc->OriginalFirstThunk) break;
		imod.rva_name = dsc->Name;
		imod.rva_iat = dsc->FirstThunk;
		imod.start = pe->iat->count / 4;
		names_offs = Libpe_RVA_To_Offs(pe, dsc->OriginalFirstThunk);
		if (names_offs == PE_INVALID_OFFSET)
			return 0;
		if (pe->from_file)
		{
			int r;
			uint8_t names[512];
			for (;;)
			{
				if (fseeko(pe->file, names_offs, SEEK_SET) < 0)
				{
					Libpe_Error(PE_ERROR_SEEK, "seek file error: %s", strerror(ferror(pe->file)));
					return 0;
				}
				r = fread(names, val_size, 64, pe->file);
				if (r < 0 || feof(pe->file))
				{
					Libpe_Error(PE_ERROR_READ, "read file error: %s", strerror(ferror(pe->file)));
					return 0;
				}
				for (j = 0; j < (size_t)r; ++j)
				{
					uint32_t rva = *(uint32_t*)(names + j * val_size);
					if (val_size == 8)
					{
						uint32_t hrva = *(uint32_t*)(names + j * val_size + 4);
						if (hrva == 0x80000000)
							rva |= 0x80000000;
						else
							assert(hrva == 0);
					}
					if (!rva) goto ready;
					Buffer_Append(pe->iat, &rva, 4);
					++imod.number_of_functions;
				}
			}
		}
		else
		{
			uint8_t* names = pe->bytes + names_offs;
			for (j = 0; j < (pe->count - names_offs) / val_size; ++j)
			{
				uint32_t rva = *(uint32_t*)(names + j * val_size);
				if (val_size == 8)
				{
					uint32_t hrva = *(uint32_t*)(names + j * val_size + 4);
					if (hrva == 0x80000000)
						rva |= 0x80000000;
					else
						assert(hrva == 0);
				}
				if (!rva) goto ready;
				Buffer_Append(pe->iat, &rva, 4);
				++imod.number_of_functions;
			}
		}
	ready:
		Buffer_Append(pe->imports, &imod, sizeof(imod));
	}

	pe->imports_is_good = 1;
	return 1;
}

size_t Libpe_Get_NumberOfModules(PE_SOURCE* pe)
{
	assert(pe != 0);
	if (!pe->imports_is_good)
		if (!Libpe_Prepare_Imports(pe))
			return PE_INVALID_VALUE;
	return pe->imports->count / sizeof(PE_IMPORT_MODULE);
}

size_t Libpe_Get_NumberOfImports(PE_SOURCE* pe, size_t module_no)
{
	assert(pe != 0);
	if (!pe->imports_is_good)
		if (!Libpe_Prepare_Imports(pe))
			return PE_INVALID_VALUE;
	if (module_no >= pe->imports->count / sizeof(PE_IMPORT_MODULE))
	{
		Libpe_Error(PE_ERROR_INVALID_VALUE, "module index out of range");
		return PE_INVALID_VALUE;
	}
	return ((PE_IMPORT_MODULE*)pe->imports->at)[module_no].number_of_functions;
}

const char* Libpe_Module_Name(PE_SOURCE* pe, size_t no)
{
	assert(pe != 0);
	if (!pe->imports_is_good)
		if (!Libpe_Prepare_Imports(pe))
			return 0;
	if (no >= pe->imports->count / sizeof(PE_IMPORT_MODULE))
	{
		Libpe_Error(PE_ERROR_INVALID_VALUE, "module index out of range");
		return 0;
	}
	return Libpe_Cache_Str(pe, ((PE_IMPORT_MODULE*)pe->imports->at)[no].rva_name);
}

static size_t Libpe_Import_RVA(PE_SOURCE* pe, size_t module_no, size_t import_no)
{
	uint32_t rva;
	PE_IMPORT_MODULE* mod;
	assert(pe != 0);
	if (!pe->imports_is_good)
		if (!Libpe_Prepare_Imports(pe))
			return PE_INVALID_VALUE;
	if (module_no >= pe->imports->count / sizeof(PE_IMPORT_MODULE))
	{
		Libpe_Error(PE_ERROR_INVALID_VALUE, "module index out of range");
		return PE_INVALID_VALUE;
	}
	mod = ((PE_IMPORT_MODULE*)pe->imports->at) + module_no;
	if (mod->number_of_functions <= import_no)
	{
		Libpe_Error(PE_ERROR_INVALID_VALUE, "import index out of range");
		return PE_INVALID_VALUE;
	}
	return ((uint32_t*)(pe->iat->at + mod->start))[import_no];
}

const char* Libpe_Import_Name(PE_SOURCE* pe, size_t module_no, size_t import_no)
{
	size_t rva = Libpe_Import_RVA(pe, module_no, import_no);
	if (rva == PE_INVALID_VALUE)
		return 0;

	if (rva & 0x80000000)
	{
		Libpe_Error(0, 0);
		return 0;
	}
	else
		return Libpe_Cache_Str(pe, rva);
}

size_t Libpe_Import_Ord(PE_SOURCE* pe, size_t module_no, size_t import_no)
{
	size_t rva = Libpe_Import_RVA(pe, module_no, import_no);
	if (rva == PE_INVALID_VALUE)
		return PE_INVALID_VALUE;

	if (rva & 0x80000000)
	{
		return rva & 0x0ffffU;
	}
	else
		return PE_INVALID_VALUE;
}

PE_BOOL Libpe_Copy_Offs(PE_SOURCE* pe, uint64_t offs, void* buf, size_t count)
{
	assert(pe != 0);
	if (pe->from_file)
	{
		int r;
		if (fseeko(pe->file, offs, SEEK_SET) < 0)
		{
			Libpe_Error(PE_ERROR_SEEK, "seek file error: %s", strerror(ferror(pe->file)));
			return 0;
		}
		r = fread(buf, count, 1, pe->file);
		if (r != 1)
		{
			Libpe_Error(PE_ERROR_READ, "read file error: %s", strerror(ferror(pe->file)));
			return 0;
		}
		return 1;
	}
	else
	{
		if (count + offs > pe->count)
		{
			Libpe_Error(PE_ERROR_INVALID_VALUE, "to much bytes requested");
			return 0;
		}

		memcpy(buf, pe->bytes + offs, count);
		return 1;
	}
}

PE_BOOL Libpe_Copy_RVA(PE_SOURCE* pe, uint64_t rva, void* buf, size_t count)
{
	uint64_t off1, off2;
	assert(pe != 0);
	if (!count) return 1;
	off1 = Libpe_RVA_To_Offs(pe, rva);
	if (off1 == PE_INVALID_OFFSET) return 0;
	off2 = Libpe_RVA_To_Offs(pe, rva + count - 1);
	if (off2 == PE_INVALID_OFFSET) return 0;
	return Libpe_Copy_Offs(pe, off1, buf, count);
}
