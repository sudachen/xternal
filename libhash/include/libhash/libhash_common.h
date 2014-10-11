
#ifndef C_once_AA414B58_5AAD_46B4_A515_711B267459C2
#define C_once_AA414B58_5AAD_46B4_A515_711B267459C2

#if ( defined _DLL && !defined LIBHASH_STATIC ) || defined LIBHASH_DLL || defined LIBHASH_BUILD_DLL
#  if defined LIBHASH_BUILD_DLL
#    define LIBHASH_EXPORTABLE __declspec(dllexport)
#  else
#    define LIBHASH_EXPORTABLE __declspec(dllimport)
#  endif
#else
#define LIBHASH_EXPORTABLE
#endif

#endif /* C_once_AA414B58_5AAD_46B4_A515_711B267459C2 */

