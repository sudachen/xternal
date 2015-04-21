
#pragma once

#include <stdio.h>
#include <io.h>

#ifdef _WIN32
#include <fcntl.h>
#endif

#include "Strarg.hxx"
#include "Format.hxx"
#include "RccPtr.hxx"
#include "Refcounted.hxx"

namespace foobar
{
	struct ConsoleObject : Ireferred
	{
		virtual void Println(const Strarg<wchar_t>& text) = 0;
		virtual void Print(const Strarg<wchar_t>& text) = 0;
	};

	struct StdConioObject : ConsoleObject
	{
		void AddRef()  OVERRIDE {}
		void Release() OVERRIDE {}

		StdConioObject()
		{
		}

		int setup_output_mode(Option<int> mod = None)
		{
#ifdef _WIN32
			return _setmode(_fileno(stdout), mod == None ? _O_U16TEXT : mod.Get());
#else	
			return 0;			
#endif
		}

		void Println(const Strarg<wchar_t>& text) OVERRIDE
		{
			int old = setup_output_mode();
			_putws(text.Cstr());
			setup_output_mode(old);
		}

		void Print(const Strarg<wchar_t>& text) OVERRIDE
		{
			int old = setup_output_mode();
			fputws(text.Cstr(),stdout);
			setup_output_mode(old);
		}
	};

	struct ConsoleGate
	{
		RccPtr<ConsoleObject> object;
		ConsoleObject* Get() const { return object ? object.Get() : DefaultConsole(); }
		ConsoleObject* operator->() const {return Get();}
		
		NO_INLINE static ConsoleObject *DefaultConsole()
		{
			static StdConioObject stdconio;
			return &stdconio;
		}

		void operator | (const Strarg<wchar_t>& text) const { Get()->Println(text); }
	};

	static const ConsoleGate Console; 

	FAKE_INLINE void print_to_console(const wchar_t* fmt, const FormatParam* const args[], size_t count)
	{
		std::wstring str;
		std::back_insert_iterator<std::wstring> w(str);
		WriterFormatToolkit<wchar_t, decltype(w)>(w).Format(fmt, args, count);
		Console->Print(str);
	}

	inline void print( const Strarg<wchar_t>& fmt,
		const FormatParam& a0 = None)
	{
		const FormatParam* const args[] = {&a0};
		return print_to_console(fmt.Cstr(), args, sizeof(args) / sizeof(args[0]));
	}

	inline void print( const Strarg<wchar_t>& fmt,
		const FormatParam& a0,
		const FormatParam& a1,
		const FormatParam& a2 = None)
	{
		const FormatParam* const args[] = {&a0, &a1, &a2};
		return print_to_console(fmt.Cstr(), args, sizeof(args) / sizeof(args[0]));
	}

	inline void print( const Strarg<wchar_t>& fmt,
		const FormatParam& a0,
		const FormatParam& a1,
		const FormatParam& a2,
		const FormatParam& a3,
		const FormatParam& a4 = None,
		const FormatParam& a5 = None,
		const FormatParam& a6 = None,
		const FormatParam& a7 = None,
		const FormatParam& a8 = None,
		const FormatParam& a9 = None)
	{
		const FormatParam* const args[] = {&a0, &a1, &a2, &a3, &a4, &a5, &a6, &a7, &a8, &a9};
		return print_to_console(fmt.Cstr(), args, sizeof(args) / sizeof(args[0]));
	}

	FAKE_INLINE void println_to_console(const wchar_t* fmt, const FormatParam* const args[], size_t count)
	{
		std::wstring str;
		std::back_insert_iterator<std::wstring> w(str);
		WriterFormatToolkit<wchar_t, decltype(w)>(w).Format(fmt, args, count);
		Console->Println(str);
	}

	inline void println( const Strarg<wchar_t>& fmt,
		const FormatParam& a0 = None)
	{
		const FormatParam* const args[] = {&a0};
		return println_to_console(fmt.Cstr(), args, sizeof(args) / sizeof(args[0]));
	}

	inline void println( const Strarg<wchar_t>& fmt,
		const FormatParam& a0,
		const FormatParam& a1,
		const FormatParam& a2 = None)
	{
		const FormatParam* const args[] = {&a0, &a1, &a2};
		return println_to_console(fmt.Cstr(), args, sizeof(args) / sizeof(args[0]));
	}

	inline void println( const Strarg<wchar_t>& fmt,
		const FormatParam& a0,
		const FormatParam& a1,
		const FormatParam& a2,
		const FormatParam& a3,
		const FormatParam& a4 = None,
		const FormatParam& a5 = None,
		const FormatParam& a6 = None,
		const FormatParam& a7 = None,
		const FormatParam& a8 = None,
		const FormatParam& a9 = None)
	{
		const FormatParam* const args[] = {&a0, &a1, &a2, &a3, &a4, &a5, &a6, &a7, &a8, &a9};
		return println_to_console(fmt.Cstr(), args, sizeof(args) / sizeof(args[0]));
	}

	inline void println( const Strarg<wchar_t>& fmt,
		const FormatParam& a0,
		const FormatParam& a1,
		const FormatParam& a2,
		const FormatParam& a3,
		const FormatParam& a4,
		const FormatParam& a5,
		const FormatParam& a6,
		const FormatParam& a7,
		const FormatParam& a8,
		const FormatParam& a9,
		const FormatParam& aA = None,
		const FormatParam& aB = None,
		const FormatParam& aC = None,
		const FormatParam& aD = None,
		const FormatParam& aE = None,
		const FormatParam& aF = None)
	{
		const FormatParam* const args[] = {&a0, &a1, &a2, &a3, &a4, &a5, &a6, &a7, &a8, &a9, &aA, &aB, &aC, &aD, &aE, &aF};
		return println_to_console(fmt.Cstr(), args, sizeof(args) / sizeof(args[0]));
	}
}
