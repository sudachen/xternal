
#include "../include/libsynfo.h"

static void Cpu_ID(uint32_t rgs[], int id)
{
#ifdef _MSC_VER
	__asm mov eax, id
	__asm push esi
	__asm push ebx
	__asm push ecx
	__asm push edx
	__asm _emit 0x0f
	__asm _emit 0xa2
	__asm mov esi, rgs
	__asm mov [esi], eax
	__asm mov [esi+4], ebx
	__asm mov [esi+8], ecx
	__asm mov [esi+12], edx
	__asm pop edx
	__asm pop ecx
	__asm pop ebx
	__asm pop esi
#else
	__asm__ volatile(\
	                 " \
          mov %0,%%eax\n\
          .byte 0x0f\n\
          .byte 0xa2\n\
          mov %%eax,(%1)\n\
          mov %%ebx,4(%1)\n\
          mov %%ecx,8(%1)\n\
          mov %%edx,12(%1)\n"
	                 :: "r"(id), "r"(rgs) : "eax", "ebx", "ecx", "edx", "memory");
#endif
}

SYNFO_ERROR Synfo_Get_Cpu(SYNFO_CPU* cpu)
{
	int i;
	uint32_t r[4];
	memset(cpu->id, 0, sizeof(cpu->id));
	memset(cpu->tag, 0, sizeof(cpu->tag));

	Cpu_ID(r, 0);
	memcpy(cpu->id + 0, &r[1], 4);
	memcpy(cpu->id + 4, &r[3], 4);
	memcpy(cpu->id + 8, &r[2], 4);

	Cpu_ID(r, 1);
	cpu->family = (r[0] >> 8) & 0x0f;
	cpu->model = (r[0] >> 4) & 0x0f;
	cpu->stepping = r[0] & 0x0f;
	cpu->number = (r[1] >> 16) & 0xff;

	if (r[3] & (1 << 23)) cpu->has_MMX = 1;
	if (r[3] & (1 << 24)) cpu->has_MMX2 = 1;
	if (r[3] & (1 << 25)) cpu->has_SSE = 1;
	if (r[3] & (1 << 26)) cpu->has_SSE2 = 1;
	if (r[3] & (1 << 28)) cpu->has_HTT = 1;
	if (r[2] & (1 << 0))  cpu->has_SSE3 = 1;
	if (r[2] & (1 << 9))  cpu->has_SSSE3 = 1;

	Cpu_ID((uint32_t*)cpu->tag + 0, 0x80000002);
	Cpu_ID((uint32_t*)cpu->tag + 4, 0x80000003);
	Cpu_ID((uint32_t*)cpu->tag + 8, 0x80000004);

	while (isspace(cpu->tag[0]))
		memmove(cpu->tag, cpu->tag + 1, sizeof(cpu->tag) - 1);

	for (i = 2; i < sizeof(cpu->tag) - 1 && cpu->tag[i];)
	{
		if (cpu->tag[i] == cpu->tag[i - 1] && cpu->tag[i] == ' ')
			memmove(cpu->tag + i - 1, cpu->tag + i, sizeof(cpu->tag) - i);
		else
			++i;
	}

	return SYNFO_SUCESS;
}

SYNFO_ERROR Synfo_Get_Cpu_String(char outbuf[SYNFO_CPU_STRING_LENGTH])
{
	int space = 1;
	SYNFO_CPU cpu = {0,};
	Synfo_Get_Cpu(&cpu);
	memset(outbuf, 0, SYNFO_CPU_STRING_LENGTH);
	strcat(outbuf, cpu.id);
	strcat(outbuf, " {");
	if (cpu.has_MMX)    { strcat(outbuf, "mmx"); space = 0; }
	if (cpu.has_MMX2)   { strcat(outbuf, " mmx2" + space); space = 0; }
	if (cpu.has_SSE)    { strcat(outbuf, " sse" + space); space = 0; }
	if (cpu.has_SSE2)   { strcat(outbuf, " sse2" + space); space = 0; }
	if (cpu.has_SSE3)   { strcat(outbuf, " sse3" + space); space = 0; }
	if (cpu.has_SSSE3)  { strcat(outbuf, " sse4" + space); space = 0; }
	if (cpu.has_HTT)    { strcat(outbuf, " htt" + space); space = 0; }
	strcat(outbuf, "} ");
	strcat(outbuf, cpu.tag);

	return SYNFO_SUCESS;
}
