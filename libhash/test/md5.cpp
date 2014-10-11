#include "../include/libhash/MD5.h"

uint8_t Data_Buf[3][57] = 
{
    { "abc" },
    { "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" },
    { "" }
};

int Data_Buflen[3] =
{
    3, 56, 1000
};

uint8_t Data_Sum[3][16] =
{
    { 0xA9, 0x99, 0x3E, 0x36, 0x47, 0x06, 0x81, 0x6A, 0xBA, 0x3E,
      0x25, 0x71, 0x78, 0x50, 0xC2, 0x6C },
    { 0x84, 0x98, 0x3E, 0x44, 0x1C, 0x3B, 0xD2, 0x6E, 0xBA, 0xAE,
      0x4A, 0xA1, 0xF9, 0x51, 0x29, 0xE5 },
    { 0x34, 0xAA, 0x97, 0x3C, 0xD4, 0xC4, 0xDA, 0xA4, 0xF6, 0x1E,
      0xEB, 0x2B, 0xDB, 0xAD, 0x27, 0x31 }
};

int main()
{
	uint8_t buf[1000];
	int i,j, buflen;

    for ( i = 0; i < 3; i++ )
    {
        printf( "  MD5-1 test #%d: ", i + 1 );

        if ( i == 2 )
        {
        	MD5_CONTEXT ctx;
	        MD5_Start( &ctx );
            memset( buf, 'a', buflen = 1000 );

            for ( j = 0; j < 1000; j++ )
                MD5_Update( &ctx, buf, buflen );
            MD5_Finish( &ctx, buf );
        }
        else
        {
        	libhash::md5_digest(Data_Buf[i],Data_Buflen[i], buf, 16);
        }

        if ( memcmp( buf,Data_Sum[i], 16 ) != 0 )
        {
            puts("failed");
            return 1;
        }
        else
		    puts("passed");
    }

    return 0;
}
