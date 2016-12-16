
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#undef malloc
#undef calloc
#undef free
#undef realloc
#undef _msize

#define _C_INSPECTOR_PATTERN 0xaa
#define _C_INSPECTOR_PROTAG ((uint16_t)'P'|((uint16_t)'T'<<8))

typedef struct _INSPECTOR_PROLOG
{
	uint16_t crc;
	uint16_t tag;
	uint32_t size;
	byte_t pattern[8];
} INSPECTOR_PROLOG;

#define	_INSPECTOR_PROLOG_SIZE 16
__Static_Assert(sizeof(INSPECTOR_PROLOG) == _INSPECTOR_PROLOG_SIZE);

enum { _C_INSPECTOR_MAX_HEAP_BLOCKS = (uint16_t)~0 };
enum { _C_INSPECTOR_MAX_BT_DEPTH = 9 };
#define __Inspector_Mem_Align(Count) (((size_t)Count + 7)&~(size_t)7)

typedef struct _INSPECTOR_NFO_REC
{
	INSPECTOR_PROLOG *ptr;
	const char *source;
	int line;
	void *bt[_C_INSPECTOR_MAX_BT_DEPTH];
	size_t bt_count;
} INSPECTOR_NFO_REC;

typedef struct _INSPECTOR_NFO
{
	size_t count;
	INSPECTOR_NFO_REC r[_C_INSPECTOR_MAX_HEAP_BLOCKS];
	uint32_t crc;
} INSPECTOR_NFO;

extern INSPECTOR_NFO __Inspector_Nfo
#ifdef _C_CORE_BUILTIN
= { 0, }
#endif
;

typedef struct _INSPECTOR_GRAVEYARD_REC
{
	void *ptr;
	size_t mark;
	void *bt[_C_INSPECTOR_MAX_BT_DEPTH];
	size_t bt_count;
} INSPECTOR_GRAVEYARD_REC;

typedef struct _INSPECTOR_GRAVEYARD
{
	size_t mark;
	INSPECTOR_GRAVEYARD_REC r[_C_INSPECTOR_MAX_HEAP_BLOCKS];
} INSPECTOR_GRAVEYARD;

enum { _C_INSPECTOR_GRAVEYARD_DEPTH = 32 };

extern INSPECTOR_GRAVEYARD __Inspector_Graveyard
#ifdef _C_CORE_BUILTIN
= { 0, }
#endif
;

extern int __Inspector_Interlock_Point
#ifdef _C_CORE_BUILTIN
= 0
#endif
;

#define __Inspector_Interlock \
	switch ( 0 ) while ( 1 ) \
		if ( 1 ) \
			goto C_LOCAL_ID(Do_Unlock); \
		else if ( 1 ) \
			case 0: \
			{ \
				C_Wait_Xchg_Lock(&__Inspector_Interlock_Point); \
				goto C_LOCAL_ID(Do_Code); \
			C_LOCAL_ID(Do_Unlock): \
				C_Xchg_Unlock(&__Inspector_Interlock_Point); \
				break; \
			} \
		else \
			C_LOCAL_ID(Do_Code):

#ifdef _C_CORE_BUILTIN
ushort_t __Inspector_Crc_16(ushort_t crc, void *_buf, int len)
{
	byte_t *buf = _buf;
	static ushort_t crc_table[256] =
	{
		0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241,
		0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
		0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
		0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
		0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40,
		0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
		0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641,
		0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
		0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
		0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
		0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41,
		0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
		0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41,
		0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
		0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
		0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
		0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240,
		0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
		0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41,
		0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
		0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
		0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
		0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
		0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
		0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241,
		0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
		0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
		0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
		0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40,
		0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
		0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641,
		0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040
	};

	while (len--)
		crc = (crc >> 8) ^ crc_table[(crc & 0xFF) ^ *buf++];

	return crc;
}
#endif

enum 
{
	_C_INSPECT_ON_ALLOC = 2, 
	_C_INSPECT_ON_FREE = 4, 
	_C_INSPECT_ON_INFO = 8, 
	_C_INSPECT_GUARD = 16, /* one inaccessable page after every block, if not guard before */
	_C_INSPECT_GUARD_BEFORE = 32, /* one inaccessable page before every block */
	_HEAPINSPECTOR_DEFAULT = 0,
};

__No_Return
void __Inspector_Fatal_Error(const char *text)
{
	size_t bt_count;
	void *bt[_C_INSPECTOR_MAX_BT_DEPTH];
	char bf[1024] = { 0 };
	snprintf(bf, sizeof(bf) - 1, "Fatal error (HEAP INSPECTOR):\n\t%s\n", text);
	fputs(bf, stderr);
	bt_count = backtrace(bt,_C_INSPECTOR_MAX_BT_DEPTH);
	C_Btrace_Format(bt_count, bt, bf, sizeof(bf), 1);
	fputs(bf, stderr);
	fputc('\n', stderr);
	abort();
}

__No_Return
void __Inspector_Mem_Error(const char *text, INSPECTOR_NFO_REC *nfo, INSPECTOR_GRAVEYARD_REC *gy)
{
	size_t bt_count;
	void *bt[_C_INSPECTOR_MAX_BT_DEPTH];
	char bf[1024];

	snprintf(bf, sizeof(bf) - 1, "Memory error (HEAP INSPECTOR): %s\n", text);
	fputs(bf, stderr);
	bt_count = backtrace(bt, _C_INSPECTOR_MAX_BT_DEPTH);
	C_Btrace_Format(bt_count, bt, bf, sizeof(bf), 1);
	fputs(bf, stderr);
	fputc('\n', stderr);

	if (nfo)
	{
		snprintf(bf, sizeof(bf) - 1, "memory was allocated at line %d of source %s\n", nfo->line, nfo->source);
		fputs(bf, stderr);
		C_Btrace_Format(nfo->bt_count, nfo->bt, bf, sizeof(bf), 1);
	}
	else
	{
		snprintf(bf, sizeof(bf) - 1, "memory was free at\n");
		fputs(bf, stderr);
		C_Btrace_Format(gy->bt_count, gy->bt, bf, sizeof(bf), 1);
	}
	fputs(bf, stderr);
	fputc('\n', stderr);
	abort();
}

void __Inspector_Verify_Rec(INSPECTOR_NFO_REC *r)
{
	int i;
	uint8_t *pat;
	uint16_t crc;
	INSPECTOR_PROLOG *pro = r->ptr;
	if (r->ptr->tag != _C_INSPECTOR_PROTAG)
		__Inspector_Mem_Error("invalid tag", r, 0);
	crc = __Inspector_Crc_16(0xffff, (uint8_t*)pro + sizeof(pro->crc), _INSPECTOR_PROLOG_SIZE - sizeof(pro->crc));
	if ( crc != pro->crc )
		__Inspector_Mem_Error("crc does not match", r, 0);
	for (i = 0; i < sizeof(pro->pattern); ++i)
		if (pro->pattern[i] != _C_INSPECTOR_PATTERN)
			__Inspector_Mem_Error("found memory underwriter", r, 0);
	pat = (uint8_t*)(pro + 1) + pro->size;
	for (i = 0; i < 8; ++i)
		if (pat[i] != _C_INSPECTOR_PATTERN)
			__Inspector_Mem_Error("found memory overwrite", r, 0);
}

void __Inspector_Verify_Heap(int line, const char *source)
{
	__Inspector_Interlock
	{
		int i;
		for (i = 0; i < _C_INSPECTOR_MAX_HEAP_BLOCKS; ++i)
			if (__Inspector_Nfo.r[i].ptr)
				__Inspector_Verify_Rec(&__Inspector_Nfo.r[i]);

	}
}

void __Inspector_Verify_Before(int when, int line, const char *source)
{
	int mask = _HEAPINSPECTOR;
	if (mask == 1) mask = _HEAPINSPECTOR_DEFAULT;
	if (mask & when) __Inspector_Verify_Heap(line, source);
}

void __Inspector_Verify_After(int when, int line, const char *source)
{
	int mask = _HEAPINSPECTOR;
	if (mask == 1) mask = _HEAPINSPECTOR_DEFAULT;
	if (mask & when) __Inspector_Verify_Heap(line, source);
}

void __Inspector_Graveyard_Rise(void *ptr)
{
	size_t count = 0;
	size_t idx = __Inspector_Crc_16(0xffff, &ptr, sizeof(ptr));
	for (; count < _C_INSPECTOR_GRAVEYARD_DEPTH; ++count)
	{
		if (__Inspector_Graveyard.r[idx].ptr == ptr)
		{
			__Inspector_Graveyard.r[idx].ptr = 0;
			break;
		}
		idx = (idx + 1) % _C_INSPECTOR_GRAVEYARD_DEPTH;
	}
}

INSPECTOR_GRAVEYARD_REC *__Inspector_Graveyard_Bury(void *ptr)
{
	size_t count = 0;
	size_t idx = __Inspector_Crc_16(0xffff, &ptr, sizeof(ptr));
	size_t older_idx = idx, older_mark = 0; __Inspector_Graveyard.mark++;
	for (; count < _C_INSPECTOR_GRAVEYARD_DEPTH; ++count)
	{
		if (__Inspector_Graveyard.r[idx].ptr == 0)
		{
			older_idx = idx; break;
		}
		if (__Inspector_Graveyard.mark - __Inspector_Graveyard.r[idx].mark > older_mark)
		{
			older_idx = idx; older_mark = __Inspector_Graveyard.mark - __Inspector_Graveyard.r[idx].mark;
		}
		idx = (idx + 1) % _C_INSPECTOR_MAX_HEAP_BLOCKS;
	}
	__Inspector_Graveyard.r[older_idx].ptr = ptr;
	__Inspector_Graveyard.r[older_idx].mark = __Inspector_Graveyard.mark;
	return &__Inspector_Graveyard.r[older_idx];
}

INSPECTOR_GRAVEYARD_REC *__Inspector_Graveyard_Find(void *ptr)
{
	size_t count = 0;
	size_t idx = __Inspector_Crc_16(0xffff, &ptr, sizeof(ptr));
	for (; count < _C_INSPECTOR_GRAVEYARD_DEPTH; ++count)
	{
		if (__Inspector_Graveyard.r[idx].ptr == ptr) 
			return &__Inspector_Graveyard.r[idx];
		idx = (idx + 1) % _C_INSPECTOR_MAX_HEAP_BLOCKS;
	}
	return 0;
}

INSPECTOR_NFO_REC *__Inspector_Nfo_Allocate(void *ptr, int line, const char *source)
{
	size_t idx = __Inspector_Crc_16(0xffff, &ptr, sizeof(ptr));
	size_t count = 0;
	for (; count < _C_INSPECTOR_MAX_HEAP_BLOCKS; ++count)
	{
		if (!__Inspector_Nfo.r[idx].ptr) goto found;
		idx = (idx + 1) % _C_INSPECTOR_MAX_HEAP_BLOCKS;
	}
	__Inspector_Fatal_Error("out of records");

found:
	++__Inspector_Nfo.count;
	__Inspector_Nfo.r[idx].line = line;
	__Inspector_Nfo.r[idx].source = source;
	return &__Inspector_Nfo.r[idx];
}

size_t __Inspector_Find(INSPECTOR_PROLOG *pro)
{
	size_t idx = __Inspector_Crc_16(0xffff, &pro, sizeof(pro));
	size_t count = 0;
	for (; count < _C_INSPECTOR_MAX_HEAP_BLOCKS; ++count)
	{
		if (__Inspector_Nfo.r[idx].ptr == pro) goto found;
		idx = (idx + 1) % _C_INSPECTOR_MAX_HEAP_BLOCKS;
	}
	__Inspector_Fatal_Error("unknown heap address");

found:
	return idx;
}

void __Inspector_Nfo_Release(INSPECTOR_PROLOG *pro)
{
	size_t idx = __Inspector_Find(pro);
	__Inspector_Verify_Rec(&__Inspector_Nfo.r[idx]);
	__Inspector_Nfo.r[idx].ptr = 0;
	--__Inspector_Nfo.count;
}

INSPECTOR_PROLOG *__Inspector_Find_And_Verify(void *ptr)
{
	INSPECTOR_PROLOG *pro = (INSPECTOR_PROLOG *)ptr - 1;
	size_t idx = __Inspector_Find(pro);
	__Inspector_Verify_Rec(&__Inspector_Nfo.r[idx]);
	return __Inspector_Nfo.r[idx].ptr;
}

void *__Inspector_Malloc(size_t size, int line, const char *source)
#ifdef _C_CORE_BUILTIN
{
	void *result = 0;
	__Inspector_Verify_Before(_C_INSPECT_ON_ALLOC, line, source);
	__Inspector_Interlock
	{
		INSPECTOR_PROLOG *pro;
		INSPECTOR_NFO_REC *nfo;
		size_t total = __Inspector_Mem_Align(size) + _INSPECTOR_PROLOG_SIZE + 8;
		uint8_t *ptr = (uint8_t*)malloc(total);

		if (!ptr) 
			__Inspector_Fatal_Error("out of memory");

		nfo = __Inspector_Nfo_Allocate(ptr,line,source);
		nfo->ptr = pro = (INSPECTOR_PROLOG *)ptr;
		memset(pro->pattern, 0xaa, sizeof(pro->pattern));
		memset(ptr + _INSPECTOR_PROLOG_SIZE + size, 0xaa, __Inspector_Mem_Align(size) - size + 8 );
		pro->size = size;
		pro->tag = _C_INSPECTOR_PROTAG;
		pro->crc = __Inspector_Crc_16(0xffff, (uint8_t*)pro + sizeof(pro->crc), _INSPECTOR_PROLOG_SIZE - sizeof(pro->crc));
		nfo->bt_count = backtrace(nfo->bt, _C_INSPECTOR_MAX_BT_DEPTH);
		result = pro + 1;
		__Inspector_Graveyard_Rise(result);
	}
	__Inspector_Verify_After(_C_INSPECT_ON_ALLOC, line, source);
	return result;
}
#endif
;

void *__Inspector_Calloc(size_t num, size_t size, int line, const char *source)
#ifdef _C_CORE_BUILTIN
{
	void *result = __Inspector_Malloc(num*size, line, source);
	memset(result, 0, size);
	return result;
}
#endif
;

void __Inspector_Free(void *ptr)
#ifdef _C_CORE_BUILTIN
{
	__Inspector_Verify_Before(_C_INSPECT_ON_FREE, 0, 0);
	if (ptr != 0)
		__Inspector_Interlock
		{
			INSPECTOR_PROLOG *pro = (INSPECTOR_PROLOG *)ptr - 1;
			INSPECTOR_GRAVEYARD_REC *gy = __Inspector_Graveyard_Find(ptr);
			if ( gy )
				__Inspector_Mem_Error("trying to free memory twice", 0, gy);
			__Inspector_Nfo_Release(pro);
			free(pro);
			gy = __Inspector_Graveyard_Bury(ptr);
			gy->bt_count = backtrace(gy->bt, _C_INSPECTOR_MAX_BT_DEPTH);
		}
	__Inspector_Verify_After(_C_INSPECT_ON_FREE, 0, 0);
}
#endif
;

void *__Inspector_Realloc(void *ptr, size_t size, int line, const char *source)
#ifdef _C_CORE_BUILTIN
{
	void *result = __Inspector_Malloc(size, line, source);
	if (ptr)
	{
		INSPECTOR_PROLOG *pro = __Inspector_Find_And_Verify(ptr);
		size_t count = pro->size;
		if (count > size) count = size;
		memcpy(result, ptr, count);
		__Inspector_Free(ptr);
	}
	return result;
}
#endif
;

size_t __Inspector_Msize(void *ptr, int line, const char *source)
#ifdef _C_CORE_BUILTIN
{
	size_t result = 0;
	__Inspector_Verify_Before(_C_INSPECT_ON_INFO, line, source);
	__Inspector_Interlock
	{
		INSPECTOR_PROLOG *pro = __Inspector_Find_And_Verify(ptr);
		result = pro->size;
	}
	__Inspector_Verify_After(_C_INSPECT_ON_INFO, line, source);
	return result;
}
#endif
;

#define malloc(Size)      __Inspector_Malloc(Size,__LINE__,__FILE__)
#define calloc(Num,Size)  __Inspector_Calloc(Num,Size,__LINE__,__FILE__)
#define realloc(Ptr,Size) __Inspector_Realloc(Ptr,Size,__LINE__,__FILE__)
#define _msize(Ptr)       __Inspector_Msize(Ptr,__LINE__,__FILE__)
#define free			  __Inspector_Free


