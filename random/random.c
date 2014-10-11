
#include <stdint.h>
#include <time.h>
#include <stdio.h>

#include <libhash/Fortuna.h>

int main()
{
    uint32_t r = 0;
    Fortuna_Bytes(&r,4);
    printf("%lu\n",r);
	return 0;
}
