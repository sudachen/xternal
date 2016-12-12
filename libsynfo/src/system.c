
#include "../include/libsynfo.h"
#include <stdio.h>
#include <windows.h>

SYNFO_ERROR Synfo_Get_Os_String(char outbuf[SYNFO_OS_STRING_LENGTH])
{
	uint32_t Maj, Min;
	OSVERSIONINFOEXA osinfo;

	memset(outbuf, 0, SYNFO_OS_STRING_LENGTH);

	osinfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
	GetVersionExA((OSVERSIONINFOA*)&osinfo);
	Maj = osinfo.dwMajorVersion;
	Min = osinfo.dwMinorVersion;

	if (Maj == 5 && Min == 0)
		strcat(outbuf, "Windows 2000");
	else if (Maj == 5 && Min == 1)
		strcat(outbuf, "Windows XP");
	else if (Maj == 5 && Min == 2)
		strcat(outbuf, "Windows Server 2003");
	else if (Maj == 6 && Min == 0)
		if (osinfo.wProductType == VER_NT_WORKSTATION)
			strcat(outbuf, "Windows Vista");
		else
			strcat(outbuf, "Windows Server 2008");
	else if (Maj == 6 && Min == 1)
		if (osinfo.wProductType == VER_NT_WORKSTATION)
			strcat(outbuf, "Windows 7");
		else
			strcat(outbuf, "Windows Server 2008 R2");
	else
		sprintf(outbuf, "Unknwon Windows %d.%d", Maj, Min);
	sprintf(outbuf + strlen(outbuf), " (%d)", osinfo.dwBuildNumber);
	if (osinfo.szCSDVersion[0])
	{
		strcat(outbuf, " ");
		strcat(outbuf, osinfo.szCSDVersion);
	}
	return SYNFO_SUCESS;
}
