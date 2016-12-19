
typedef struct PIXEL_BGRA8
{
	uint8_t b;
	uint8_t g;
	uint8_t r;
	uint8_t a;
} PIXEL_BGRA8;

typedef struct PIXEL_RGB8
{
	uint8_t r;
	uint8_t g;
	uint8_t b;
} PIXEL_RGB8;

typedef struct PIXEL_BGR8
{
	uint8_t b;
	uint8_t g;
	uint8_t r;
} PIXEL_BGR8;

void Ptr_Get_Rgba8_Pixel(const uint8_t *ptr, int format, PIXEL_RGBA8 *pixel);
void Ptr_Set_Rgba8_Pixel(uint8_t *ptr, int format, const PIXEL_RGBA8 *pixel);
void Ptr_Get_Rgbai_Pixel(const uint8_t *ptr, int format, PIXEL_RGBAi *pixel);
void Ptr_Set_Rgbai_Pixel(uint8_t *ptr, int format, const PIXEL_RGBAi *pixel);
void Ptr_Get_Rgbaf_Pixel(const uint8_t *ptr, int format, PIXEL_RGBAf *pixel);
void Ptr_Set_Rgbaf_Pixel(uint8_t *ptr, int format, const PIXEL_RGBAf *pixel);

uint32_t Ptr_Get_Pixel_32(const uint8_t* ptr, int format);
void Ptr_Set_Pixel_32(uint8_t* ptr, int format, uint32_t pixel);

#ifndef max
#  define max(a,b) ((a) < (b) ? (a) : (b))
#endif

#ifndef absi
#define absi(a)  ((a) >= 0 ? (a) : -(a))
#endif

#define BPP(Fmt)    ((Fmt>>8)&0x0ff)
#define Alpha(Fmt)  (((Fmt>>24)&0x0ff) == 'A')


