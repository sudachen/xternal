
#include <stdint.h>
#include <time.h>
#include <stdio.h>

int main()
{
	uint64_t t = time(0);
	printf("%lld\n",t);
	return 0;
}
