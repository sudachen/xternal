
#pragma once

#include <time.h>

#include "Common.hxx"
#include "Strarg.hxx"
#include "Format.hxx"

namespace foobar
{
    struct LongDate
    {
#if !defined _BIGENDIAN
        uint32_t segundes : 16;
        uint32_t day : 5;
        uint32_t month : 4;
        uint32_t year : 7;
#else
        uint32_t year : 7;
        uint32_t month : 4;
        uint32_t day : 5;
        uint32_t segundes : 16;
#endif

        uint32_t Hour() const
        {
            return segundes * 2 / 3600;
        }

        uint32_t Minute() const
        {
            return (segundes * 2 % 3600) / 60;
        }

        uint32_t Segundo() const
        {
            return segundes * 2 % 60;
        }
    };

    static_assert(sizeof (LongDate) == 4,"sizeof(foobar::LongDate) is not 4 bytes");

    struct DateTime
    {

        enum DT_NOW
        {
            now
        };

        enum DT_NOTIME
        {
            notime
        };

        enum DT_INFINITY
        {
            infinity
        };

        enum DT_RAW
        {
            raw
        };

        enum
        {
            CC_BARIER = 0
        };

        int32_t millis;

        struct
        {
#if !defined _BIGENDIAN
            uint32_t day : 5;
            uint32_t month : 4;
            uint32_t year : 22;
            uint32_t cc : 1;
#else
            uint32_t cc : 1;
            uint32_t year : 22;
            uint32_t month : 4;
            uint32_t day : 5;
#endif
        } dmyc;

        uint32_t _first_word() const
        {
            return (uint32_t)millis;
        }

        uint32_t _second_word() const
        {
            uint32_t q = dmyc.year;
            q = q << 5 | dmyc.day;
            q = q << 4 | dmyc.month;
            q = q << 1 | dmyc.cc;
            return q;
        }

        void _from_two_words(uint32_t first, uint32_t second)
        {
            millis = (int32_t)first;
            dmyc.cc = second & 1;
            second >>= 1;
            dmyc.month = second & 15;
            second >>= 4;
            dmyc.day = second & 31;
            second >>= 5;
            dmyc.year = second;
        }

        uint16_t ToL16date()
        {
            return uint16_t(((CcYear() - 1970) % 128) << 9 | dmyc.month << 5 | dmyc.day);
        }

        static DateTime FromL16date(uint16_t q)
        {
            DateTime d = raw;
            d.millis = 0;
            d.dmyc.cc = 1;
            d.dmyc.day = q & 31;
            q >>= 5;
            d.dmyc.month = q & 15;
            q >>= 4;
            d.dmyc.year = q + 1970;
            return d;
        }

        uint32_t ToL32date()
        {
            uint32_t q = ((CcYear() - 1970) % 128) << 25 | dmyc.month << 21 | dmyc.day << 16 | (millis / 2000 % 3600 * 12);
            return q;
        }

        static inline uint32_t MakeL32date(unsigned day, unsigned month, unsigned year, unsigned millis = 0)
        {
            uint32_t q = ((year - 1970) % 128) << 25 | (month & 15) << 21 | (day & 31) << 16 | (millis / 2000 % 3600 * 12);
            return q;
        }

        LongDate ToLongDate()
        {
            uint32_t q = ToL32date();
            return *(LongDate*) & q;
        }

        static inline LongDate MakeLongDate(unsigned day, unsigned month, unsigned year, unsigned millis = 0)
        {
            uint32_t q = MakeL32date(day, month, year, millis);
            return *(LongDate*) & q;
        }

        static DateTime FromL32date(uint32_t q)
        {
            DateTime d = raw;
            d.dmyc.cc = 1;
            d.millis = (q & 0x0ffff) * 2000;
            q >>= 16;
            d.dmyc.day = q & 31;
            q >>= 5;
            d.dmyc.month = q & 15;
            q >>= 4;
            d.dmyc.year = q + 1970;
            return d;
        }

        static DateTime FromLongDate(LongDate ld)
        {
            return FromL32date(*(uint32_t*) & ld);
        }

        unsigned Day() const
        {
            return dmyc.day;
        }

        unsigned Month() const
        {
            return dmyc.month;
        }

        unsigned Year() const
        {
            return dmyc.cc ? CcYear() : -CcYear();
        }

        signed CcYear()const
        {
            return dmyc.year;
        }

        bool AD() const
        {
            return !!dmyc.cc;
        }

        bool BC() const
        {
            return !dmyc.cc;
        }

        const char* Smon(bool shortform = true) const
        {
            static const char* m[12][2] = {
                {"Jan", "January"},
                {"Feb", "February"},
                {"Mar", "March"},
                {"Apr", "April"},
                {"May", "May"},
                {"Jun", "June"},
                {"Jul", "July"},
                {"Aug", "August"},
                {"Sep", "September"},
                {"Oct", "October"},
                {"Nov", "November"},
                {"Dec", "December"},
            };

            if ( millis == -1 ) // is not valid date
                return shortform ? "Inv" : "Invalid";

            unsigned month = Month();
            FOOBAR_ASSERT(month > 0 && month <= 12);
            return m[month - 1][shortform ? 0 : 1];
        }

        const char *Lmon() const
        {
            return Smon(false);
        }

        DateTime& Day(unsigned d)
        {
            FOOBAR_ASSERT(d > 0 && d <= 31);
            dmyc.day = d;
            return *this;
        }

        DateTime& Month(unsigned m)
        {
            FOOBAR_ASSERT(m > 0 && m <= 12);
            dmyc.month = m;
            return *this;
        }

        DateTime& Year(signed y)
        {
            y < 0 ? dmyc.year = -y, dmyc.cc = 0 : dmyc.year = y, dmyc.cc = 1;
            return *this;
        }

        DateTime& Time(unsigned h, unsigned m, unsigned s, unsigned u)
        {
            millis = h * 60 * 60 * 1000 + m * 60 * 1000 + s * 1000 + u;
            return *this;
        }

        enum
        {
            USECONDS_COUNT = 1
        };

        unsigned Hour() const
        {
            return (millis / (60 * 60 * 1000 * USECONDS_COUNT)) % 24;
        }

        unsigned Minute() const
        {
            return (millis / (60 * 1000 * USECONDS_COUNT)) % 60;
        }

        unsigned Segundo() const
        {
            return (millis / (1000 * USECONDS_COUNT)) % 60;
        }

        unsigned Millis() const
        {
            return (millis / USECONDS_COUNT) % 1000;
        }

        DateTime(DT_RAW) { }

        DateTime(DT_NOTIME)
        {
            millis = -1;
            memset(&dmyc, 0xff, sizeof (dmyc));
            dmyc.cc = 0;
        }

        DateTime(DT_INFINITY)
        {
            millis = -1;
            memset(&dmyc, 0xff, sizeof (dmyc));
        }

        DateTime(LongDate d)
        {
            *this = FromLongDate(d);
        }

        bool Isnotime()
        {
            return millis == -1 && !dmyc.cc;
        }

        bool Isinfinity()
        {
            return millis == -1 && dmyc.cc;
        }

        DateTime()
        {
            memset(&dmyc, 0, sizeof (dmyc));
            millis = 0;
        }

        DateTime(DT_NOW)
        {
            InitWholeFromPOSIXtime(time(0));
        }

        DateTime(time_t const& t)
        {
            InitWholeFromPOSIXtime(t);
        }

        DateTime ShiftYear(int y)
        {
            if ( millis == -1 )
                return *this;
            DateTime d = *this;
            d.Year(d.Year() + y);
            return d;
        }

        void InitWholeFromPOSIXtime(time_t t)
        {
            if ( tm * xtm = localtime(&t) )
            {
                tm tm = *xtm;
                Year(tm.tm_year + 1900);
                Month(tm.tm_mon + 1);
                Day(tm.tm_mday);
                Time(tm.tm_hour, tm.tm_min, tm.tm_sec, 0);
            }
            else
                *this = notime;
        }

        static DateTime FromPOSIXtime(time_t t)
        {
            DateTime dt(raw);
            dt.InitWholeFromPOSIXtime(t);
            return dt;
        }

        static DateTime FromCstring(const Strarg<char>& cStr)
        {
            DateTime dt(raw);
            dt.InitWholeFromCstr(cStr);
            return dt;
        }

        void InitWholeFromCstr(const Strarg<char>& cStr)
        {
            unsigned day, mon, h, m, s, u;
            signed year;
            char b, c;

            // M$VC swscanf isn't able to use constant strings
            sscanf(cStr.Cstr(), "%d-%d-%d %c%c %d:%d:%d %d",
                &day, &mon, &year, &b, &c, &h, &m, &s, &u);

            if ( b == 'b' || b == 'B' ) year = -year;
            Day(day).Month(mon).Year(year).Time(h, m, s, u);
        }

        std::string Str(bool show_time = true, bool ad_bc = false) const
        {
            std::string str = format("%02d-%02d-%04d", Day(), Month(), CcYear());
            if ( ad_bc )
                str += (BC() ? "BC" : "AD");
            if ( show_time )
                str += format(" %02d:%02d:%02d", Hour(), Minute(), Segundo());
            return str;
        }

        time_t PosixTime()
        {
            tm tm;
            tm.tm_year = Year() - 1900;
            tm.tm_mon = Month() - 1;
            tm.tm_mday = Day();
            tm.tm_hour = Hour();
            tm.tm_min = Minute();
            tm.tm_sec = Segundo();
            return mktime(&tm);
        }
    };

    //date_Of*<m>/<d>/<y>
    //date_Of*11/24/2009
    //date_Of*<d>-<m>-<y>
    //date_Of*24-11-2009

    struct date_Of
    {
        uint8_t none;
    };

    struct date_Of_0
    {
        int d;

        date_Of_0(int d) : d(d) { }
    };

    struct date_Of_Us
    {
        int day;
        int month;

        date_Of_Us(int d, int m) : day(d), month(m) { }
    };

    struct date_Of_Eu : date_Of_Us
    {

        date_Of_Eu(int d, int m) : date_Of_Us(m, d) { }
    };

    inline LongDate operator /(date_Of_Us const& n, int y)
    {
        return DateTime::MakeLongDate(n.day, n.month, y);
    }

    inline LongDate operator -(date_Of_Eu const& n, int y)
    {
        return DateTime::MakeLongDate(n.day, n.month, y);
    }

    inline date_Of_Us operator /(date_Of_0 const& n, int u)
    {
        return date_Of_Us(u, n.d);
    }

    inline date_Of_Eu operator -(date_Of_0 const& n, int u)
    {
        return date_Of_Eu(u, n.d);
    }

    inline date_Of_0 operator *(date_Of const&, int d)
    {
        return date_Of_0(d);
    }

    struct date_Of date_Of = {0};

    struct SecondsTag
    {
        char _;
    };
    const struct SecondsTag Seconds = {0};

    struct MilliSecondsTag
    {
        char _;
    };
    const struct MilliSecondsTag Milliseconds = {0};

    struct MicroSecondsTag
    {
        char _;
    };
    const struct MicroSecondsTag Microseconds = {0};

    struct Timeout
    {
        uint64_t timeout;

        explicit Timeout(uint64_t val) : timeout(val) { };

        uint64_t MicroSeconds() const
        {
            return timeout;
        }

        uint64_t MilliSeconds() const
        {
            return timeout / 1000;
        }

        uint64_t Seconds() const
        {
            return timeout / 1000000;
        }
    };

    const Timeout Immediate = Timeout(0);

    // 0.5^seconds

    Timeout operator ^(double value, SecondsTag)
    {
        return Timeout((uint64_t)(value * 1000000));
    }
    // 3^seconds

    Timeout operator ^(int value, SecondsTag)
    {
        return Timeout((uint64_t)value * 1000000);
    }
    // 3000^milliseconds

    Timeout operator ^(int value, MilliSecondsTag)
    {
        return Timeout((uint64_t)value * 1000);
    }
    // 3000000^microseconds

    Timeout operator ^(int value, MicroSecondsTag)
    {
        return Timeout((uint64_t)value);
    }

    inline void timeout(Timeout tm)
    {
#ifdef _WIN32
		Sleep(tm.MilliSeconds());
#else
		usleep(tm.MilliSeconds());
#endif
    }
    
    inline NO_INLINE uint64_t SystemUseconds()
    {
#ifdef _WIN32
        SYSTEMTIME systime = {0};
        FILETIME ftime;
        uint64_t Q;
        GetSystemTime(&systime);
        SystemTimeToFileTime(&systime, &ftime);
        Q = ((uint64_t)ftime.dwHighDateTime << 32) + (uint64_t)ftime.dwLowDateTime;
#    if defined _MSC_VER && _MSC_VER < 1300
        {
            uint64_t QQ = 116444736;
            QQ *= 1000000000;
            Q -= QQ;
        }
#    else
        Q -= 116444736000000000LL; /* posix epoche */
#    endif
        return Q / 10;
#else
        struct timeval tv = {0};
        gettimeofday(&tv, 0);
        return ((uint64_t)tv.tv_sec * 1000 * 1000 + (uint64_t)tv.tv_usec);
#endif
    }

    inline uint64_t SystemMillis()
    {
        return SystemUseconds() / 1000;
    }

    inline double SystemSeconds()
    {
        return double(SystemUseconds()) / 1000000;
    }

    const uint64_t startedAt = SystemUseconds();

    inline double SecondsFromStart()
    {
        return double(SystemUseconds() - startedAt) / 1000000;
    }
}

