
typedef struct C_BUFFER LIBCONF_BUFFER;
#define LIBCONF_BUILD

#include "../include/libconf.h"

enum XVALUE_OPT_VALTYPE
{
    XVALUE_OPT_VALTYPE_NONE     = 0x08000,
    XVALUE_OPT_VALTYPE_INT      = 0x08001,
    XVALUE_OPT_VALTYPE_FLT      = 0x08002,
    XVALUE_OPT_VALTYPE_STR      = 0x08003,
    XVALUE_OPT_VALTYPE_BIN      = 0x08004,
    XVALUE_OPT_VALTYPE_BOOL     = 0x08005,
    XVALUE_OPT_VALTYPE_LIT      = 0x08006,
    XVALUE_OPT_VALTYPE_STR_ARR  = 0x08007,
    XVALUE_OPT_VALTYPE_FLT_ARR  = 0x08008,
    XVALUE_OPT_VALTYPE_REFNODE  = 0x08009,
    XVALUE_OPT_VALTYPE_MASK     = 0x0800f,
    XVALUE_OPT_IS_VALUE         = 0x08000,
    XVALUE_DOWN_REFNODE         = 0x0ffff,
};

#define XNODE_MAX_NAME_INDEX_PTR  ((char*)0x07fff)
#define XNODE_NUMBER_OF_NODE_LISTS 9
#define Number_Of_Nodes_In_List(No) (1<<(5+(No)))

struct XNODE;
struct XDATA;
struct XVALUE_BINARY;

#define C_MAX_2(a,b) ((a) > (b) ? (a) : (b))
#define C_MAX_3(a,b,c) ((a) > C_MAX(b,c) ? (a) : C_MAX(b,c))

typedef struct XNODE
{
	uint16_t tag;
	uint16_t opt;
	uint16_t next;
	uint16_t down;
	union
	{
		char*    txt;
		double   flt;
		int64_t  dec;
		uint8_t  bval;
		LIBCONF_BUFFER* binary;
		//C_ARRAY*  strarr;
		struct XDATA* xdata;
		struct XNODE* refval;
		char holder[sizeof(uint64_t)];
	};
} XNODE;

typedef struct XDATA
{
	XNODE root;
	intptr_t refcount;
	XNODE* nodes[XNODE_NUMBER_OF_NODE_LISTS];
	char** tags;
	C_DICTO* dicto;
	uint16_t last_tag;
	uint16_t last_node;
} XDATA;

int Libconf_Error(int error, char *message);
int Xdata_Idxref_No(XDATA* doc, uint16_t idx, int* no);
void* Xdata_Idxref(XDATA* doc, uint16_t idx);
char* Xdata_Resolve_Name(XDATA* doc, char* tag, int create_if_doesnt_exist);
XNODE* Xnode_Refacc(XNODE* node);
XNODE* Xdata_Allocate(XDATA* doc, char* tag, uint16_t* idx);
XVALUE* Xdata_Create_Value(XDATA* doc, char* tag, uint16_t* idx);
XNODE* Xdata_Create_Node(XDATA* doc, char* tag, uint16_t* idx);
