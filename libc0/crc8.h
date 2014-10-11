
#ifndef C_once_8DDBDB83_5E44_43E7_84D3_D256D13C3FFB
#define C_once_8DDBDB83_5E44_43E7_84D3_D256D13C3FFB

#include <stdint.h>
#include <string.h>

#ifndef _CRC_PREFIX
#define _CRC_PREFIX Crc
#endif

#define Crc_8 			_CRC_PREFIX##_8
#define Crc_8_Of_Cstr	_CRC_PREFIX##_8_Of_Cstr

uint8_t Crc_8(uint8_t crc, void *, int len);
uint8_t Crc_8_Of_Cstr(char *S);

#endif /* C_once_8DDBDB83_5E44_43E7_84D3_D256D13C3FFB */
