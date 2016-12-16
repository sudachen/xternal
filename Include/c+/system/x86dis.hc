
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_EC2E6B0C_F482_4C6B_8955_074DA127943C
#define C_once_EC2E6B0C_F482_4C6B_8955_074DA127943C

#ifdef _BUILTIN
#define _C_X86DIS_BUILTIN
#endif

#include "../C+.hc"

typedef struct _C_X86_INST
  {
    byte_t const *op;
    int rOffs_offset;
    int rOffs_size;
    int rOffs_rel;
    int rOffs_seg;
    int op_length;
    int is_rjc   :1;
    int is_rcall :1;
    int is_rjmp  :1;
  } C_X86_INST;

#ifdef _C_X86DIS_BUILTIN
enum
  {
    X86DIS_HAS_MODRM   = 0x010,
    X86DIS_JMP_REL1    = 0x020,
    X86DIS_JMP_REL4    = 0x040,
    X86DIS_JMP_ADDR6   = 0x080,
    // -1 invalid
    // -2 float operation
    X86DIS_LOCK_PREFIX = -5,
    X86DIS_REP_PREFIX  = -4,
    X86DIS_0F_PREFIX   = -6,
    X86DIS_SEG_PREFIX  = -7,
    X86DIS_O16_PREFIX  = -8,
    X86DIS_A16_PREFIX  = -9,
  };

static short X86dis_Opcodes_Info[256] =
  {
    // 00
    /*ADD*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, 1, 4,
    /*PUSH/POP ES*/ 0,0,

    // 08
    /*OR*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, 1, 4,
    /*PUSH CS*/ 0,
    X86DIS_0F_PREFIX,

    // 10
    /*ADC*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, 1, 4,
    /*PUSH/POP SS*/ 0, 0,

    // 18
    /*SBB*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, 1, 4,
    /*PUSH/POP DS*/ 0, 0,

    // 20
    /*AND*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, 1, 4,
    X86DIS_SEG_PREFIX /*ES*/,
    /*DAA*/ 0,

    // 28
    /*SUB*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, 1, 4,
    X86DIS_SEG_PREFIX /*CS*/,
    /*DAS*/ 0,

    // 30
    /*XOR*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, 1, 4,
    X86DIS_SEG_PREFIX /*SS*/,
    /*AAA*/ 0,

    // 38
    /*CMP*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, 1, 4,
    X86DIS_SEG_PREFIX /*DS*/,
    /*AAS*/ 0,

    // 40
    /*INC*/  0,0,0,0,0,0,0,0,
    /*DEC*/  0,0,0,0,0,0,0,0,
    /*PUSH*/ 0,0,0,0,0,0,0,0,
    /*POP*/  0,0,0,0,0,0,0,0,

    // 60
    /*PUSHA/POPA*/ 0,0,
    /*BOUND*/ 8|X86DIS_HAS_MODRM,
    /*ARPL*/  X86DIS_HAS_MODRM,
    X86DIS_SEG_PREFIX /*FS*/,
    X86DIS_SEG_PREFIX /*GS*/,
    X86DIS_O16_PREFIX, /*x16 oprerand*/
    X86DIS_A16_PREFIX, /*x16 address*/

    // 68
    /*PUSH*/ 4,
    /*IMUL*/ 4|X86DIS_HAS_MODRM,
    /*PUSH*/ 1,
    /*IMUL*/ 1|X86DIS_HAS_MODRM,
    /*INSB*/ 0,
    /*INS*/  0,
    /*OUTSB*/0,
    /*OUTS*/ 0,

    // 70
    /*Jx*/   X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1,
    /*Jx*/   X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1, X86DIS_JMP_REL1,

    // 80
    /*ADD,OR,ADC,SBB,AND,SUB,XOR,CMP*/ 1|X86DIS_HAS_MODRM,
    /*ADD,OR,ADC,SBB,AND,SUB,XOR,CMP*/ 4|X86DIS_HAS_MODRM,
    /*ADD,OR,ADC,SBB,AND,SUB,XOR,CMP*/ 1|X86DIS_HAS_MODRM,
    /*ADD,OR,ADC,SBB,AND,SUB,XOR,CMP*/ 1|X86DIS_HAS_MODRM,
    /*TEST*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    /*XCHG*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 88
    /*MOV*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    /*LEA*/ X86DIS_HAS_MODRM,
    /*MOV*/ X86DIS_HAS_MODRM,
    /*POP*/ X86DIS_HAS_MODRM,

    // 90
    0,
    /*XCHG*/ 0,0,0,0,0,0,0,

    // 98
    /*CBW,CWD*/ 0,0,
    /*CALL*/ 6,
    /*WAIT,PUSHF,POPF,SAHF,LAHF*/ 0,0,0,0,0,

    // A0
    /*MOV*/   4,4,4,4,
    /*MOVS(B/D)*/ 0,0,
    /*CMPS(B/D)*/ 0,0,

    // A8
    /*TEST*/  1, 4,
    /*STOSB*/ 0, 0,
    /*LODSB*/ 0, 0,
    /*SCASB*/ 0, 0,

    // B0
    /*MOV*/ 1,1,1,1, 1,1,1,1,
    // B8
    /*MOV*/ 4,4,4,4, 4,4,4,4,

    // C0
    /*ROL,ROR,RCL,SHL,SHR,SAR*/ 1|X86DIS_HAS_MODRM, 1|X86DIS_HAS_MODRM,
    /*RET*/ 2, 0,
    /*LDS,LES*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    /*MOV*/ 1|X86DIS_HAS_MODRM, 4|X86DIS_HAS_MODRM,

    // C8
    /*ENTER/LEAVE*/ 2+1, 0,
    /*RETFAR*/ 2, 0,
    /*INT3/INT/INT0/IRET*/ 0,1,0,0,

    // D0
    /*ROL,ROR,RCL,SHL,SHR,SAR*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM, X86DIS_HAS_MODRM,
    /*AAM,AAD*/ 0,0,
    -1,
    /*XLAT*/ 0,

    // D8
    -2,-2,-2,-2,-2,-2,-2,-2, /*FLOAT*/

    // E0
    /*LOOP/N/E*/ X86DIS_JMP_REL1,X86DIS_JMP_REL1,X86DIS_JMP_REL1,
    /*JCXZ*/ X86DIS_JMP_REL1,
    /*IN,OUT*/ 1,4,1,4,

    // E8
    /*CALL*/ X86DIS_JMP_REL4,
    /*JMP*/  X86DIS_JMP_REL4, X86DIS_JMP_ADDR6, X86DIS_JMP_REL1,
    /*IN,OUT*/ 0,0,0,0,

    // F0
    X86DIS_LOCK_PREFIX,
    -1,
    X86DIS_REP_PREFIX,X86DIS_REP_PREFIX,
    0,0,
    X86DIS_HAS_MODRM|1,X86DIS_HAS_MODRM|4,

    // F8
    0,0,0,0,0,0,
    X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
  };

static short X86dis_Opcodes_0f[256] =
  {
    // 0F 00
    /*SLDT,STR,LLDT,LTR,VERR,VERW*/ X86DIS_HAS_MODRM,
    /*SGDT, SIDT, LGDT, LIDT, SMSW,LMSW*/ X86DIS_HAS_MODRM,
    /*LAR,LSL*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    -1,-1,
    /*CLTS*/ 0,
    -1,

    // 0F 08
    -1, 0 -1, 0, -1, -1, -1, -1,

    // 0F 10
    -1,-1,-1,-1,-1,-1,-1,-1,

    // 0F 18
    -1,-1,-1,-1,-1,-1,-1,-1,

    // 0F 20
    /*MOV*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    -1,-1,-1,-1,
    // 0F 28
    -1,-1,-1,-1,-1,-1,-1,-1,

    // 0F 30
    /*WRMSR,RDTSC,RDMSR,RDPMC*/ 0,0,0,0,
    -1,-1,-1,-1,

    // 0F 38
    -1,-1,-1,-1,-1,-1,-1,-1,

    // 0F 40
    /*CMOVxx*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F 48
    /*CMOVxx*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F 50
    -1,-1,-1,-1,-1,-1,-1,-1,

    // 0F 58
    -1,-1,-1,-1,-1,-1,-1,-1,

    // 0F 60
    /*xMMX*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F 68
    /*xMMX*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    -1,-1,
    /*MOVD/Q*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F 70
    -1,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    /*_EMMS*/ 0,

    // 0F 78
    -1,-1,-1,-1,-1,-1,
    /*MOVD/Q*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F 80
    /*Jxx*/ X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,

    // 0F 88
    /*Jxx*/ X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,X86DIS_JMP_REL4,

    // 0F 90
    /*SETxx*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F 98
    /*SETxx*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F A0
    /*PUSH/POP/CPUID*/ 0,0,0,
    /*BT*/ X86DIS_HAS_MODRM,
    /*SHLD*/ 1|X86DIS_HAS_MODRM,
    /*SHLD*/ X86DIS_HAS_MODRM,
    -1,-1,

    // 0F A8
    /*PUSH/POP/RSM*/ 0,0,0,
    /*BTS*/ X86DIS_HAS_MODRM,
    /*SHRD*/ 1|X86DIS_HAS_MODRM,
    /*SHRD*/ X86DIS_HAS_MODRM,
    -1,
    /*IMUL*/ X86DIS_HAS_MODRM,

    // 0F B0
    /*CMPXCHG*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    /*LSS/BTR/LFS/LGS/MOVZX/MOVZX*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F B8
    /*Bxx*/ -1,-1,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    /*MOVSX*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,

    // 0F C0
    /*XADD*/ X86DIS_HAS_MODRM, X86DIS_HAS_MODRM,
    -1,-1,-1,-1,-1,-1,

    // 0F C8
    /*BSWAP*/ 0,0,0,0,0,0,0,0,

    // 0F D0
    -1,
    /*xMMX*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
    -1,
    /*PMULLW*/ X86DIS_HAS_MODRM,
    -1,-1,

    // 0F D8
    /*xMMX*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,-1,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,-1,X86DIS_HAS_MODRM,

    // 0F E0
    /*xMMX*/ -1,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,-1,X86DIS_HAS_MODRM,-1,-1,

    // 0F E8
    /*xMMX*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,-1,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,-1,X86DIS_HAS_MODRM,

    // 0F F0
    /*xMMX*/ -1,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,-1,X86DIS_HAS_MODRM,-1,-1,

    // 0F F8
    /*xMMX*/ X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,-1,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,X86DIS_HAS_MODRM,
  };

#endif

int X86_Inst_Length(void *inst_ptr,C_X86_INST *out_info)
#ifdef _C_X86DIS_BUILTIN
  {
    short code_info;
    int o_16 = 0, a_16 = 0;
    byte_t *op = inst_ptr;
    C_X86_INST info;
    memset(&info,0,sizeof(info));

    code_info = X86dis_Opcodes_Info[*op];
    info.op_length = 1;

  loop:
    if ( code_info < 0 )
      {
        if ( code_info >= -2 ) return 0;
        ++op;
        ++info.op_length;
        switch( code_info )
          {
            case X86DIS_0F_PREFIX:
              code_info = X86dis_Opcodes_0f[*op];
              goto loop;
            case X86DIS_O16_PREFIX:
              o_16 = 1;
              goto _1;
            case X86DIS_A16_PREFIX:
              a_16 = 1;
              goto _1;
            _1:
            default:
              code_info = X86dis_Opcodes_Info[*op];
              goto loop;
          }
      }
    else
      {
        int a_size;
        info.op = op;
        ++op; // skip opcode
        a_size = code_info & 0x0f;
        if ( o_16 && a_size >=4 ) a_size = (a_size>>1) + a_size&3;
        info.op_length += a_size;
        if ( code_info & X86DIS_HAS_MODRM )
          {
            int mod = *op >> 6;
            int r_m = *op & 7;
            if ( !a_16 )
              switch ( mod )
                {
                  case 0:
                    if ( r_m == 4 ) ++info.op_length;           // sib
                    else if ( r_m == 5 ) info.op_length += 4;   // offs32
                    break;
                  case 1:
                    ++info.op_length;                           // offs8
                    if ( r_m == 4 ) ++info.op_length;           // sib
                    break;
                  case 2:
                    info.op_length+=4;                          // offs32
                    if ( r_m == 4 ) ++info.op_length;           // sib
                }
            else // with ADDR16 prefix
              switch ( mod )
                {
                  case 0:
                    if ( r_m == 6 ) info.op_length += 2;        // offs16
                    break;
                  case 1:
                    ++info.op_length;                           // offs8
                    break;
                  case 2:
                    info.op_length+=2;                          // offs16
                    break;
                }
            ++op;
            ++info.op_length; // modr/m
          }

        if ( (code_info & 0x0e0) && !(code_info & 0x10) )
          {
            info.is_rjc = 1;
            info.rOffs_offset = info.op_length;
            info.rOffs_size = (code_info >> 4) & 0x0f;
            if ( info.rOffs_size == 2 ) info.rOffs_size = 1;
            switch ( info.rOffs_size )
              {
                case 1: info.rOffs_rel = *(ioct_t*)op; break;
                case 4: info.rOffs_rel = *(int*)op; break;
                case 6:
                  info.rOffs_seg = *(ushort_t*)op;
                  info.rOffs_rel = *(int*)(op+2);
                  break;
              }
            if ( *info.op == 0xe8 ) info.is_rcall = 1;
            if ( *info.op == 0xe9 || *info.op == 0xea || *info.op == 0xeb  ) info.is_rjmp = 1;
            info.op_length += info.rOffs_size;
          }
      }

    if ( out_info ) *out_info = info;
    return info.op_length;
  }
#endif
  ;
  
int X86_Steal_Five_Bytes(byte_t *code, byte_t *f)
#ifdef _C_X86DIS_BUILTIN
  {
    int orign_len = 0;

    while ( orign_len < 5 )
      {
        C_X86_INST ifn;
        int l = X86_Inst_Length(f+orign_len,&ifn);
        if ( l == 0 ) return 0; // oops, is there unknown instruction ?

        if ( ifn.is_rjmp && ifn.rOffs_size == 1 && !orign_len)
          f += ifn.rOffs_rel;
        else
          {
            memcpy(code+orign_len,f+orign_len,l);

            if ( ifn.is_rjmp )
              {
                if ( ifn.rOffs_size == 4 )
                  {
                    byte_t *offs = (code+orign_len+ifn.rOffs_offset);
                    *((uint_t*)offs) += (f-code);
                  }
                else 
                  return 0;
              }
            else if ( ifn.is_rcall )
              {
                if ( ifn.rOffs_size == 4 )
                  {
                    byte_t *offs = (code+orign_len+ifn.rOffs_offset);
                    *((uint_t*)offs) += (f-code);
                  }
                else
                  return 0;
              }
            else if ( ifn.is_rjc )
              return 0;

            orign_len += l;
          }
      }

    return orign_len;
  }
#endif
  ;

#endif /* C_once_EC2E6B0C_F482_4C6B_8955_074DA127943C */

