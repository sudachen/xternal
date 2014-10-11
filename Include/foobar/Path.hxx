
/*

(C)2014, Alexey Sudachen, alexey@sudachen.name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#pragma once

#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "Common.hxx"
#include "Strarg.hxx"

#if defined _WIN32 && !defined S_IWUSR
enum
{
    S_IWUSR = _S_IWRITE,
    S_IRUSR = _S_IREAD,
    S_IXUSR = _S_IEXEC,
};
#endif

namespace foobar
{

	struct FileAttributes
	{
		bool exists : 1;
		bool isDirectory : 1;
		bool isReadonly : 1;
		int64_t size;
		time_t  ctime;
		time_t  mtime;
	};

	template <class Tchr>
	struct Path
	{
		std::basic_string<Tchr> path;

		static const Tchr delim;
		static const Tchr delim_str[2];
		static const Tchr delim_set[3];

		Path(NoneValue = None)
			: path()
		{
		}

		Path(const Strarg<Tchr>& path)
			: path(path.Str())
		{
		}

		Path& operator = (const Strarg<Tchr>& path)
		{
			this->path = path.Str();
			return *this;
		}

		bool operator ==(NoneValue) const { return path.length() == 0; }
		bool operator !=(NoneValue) const { return path.length() != 0; }

		NO_INLINE Path<Tchr> Append(const Strarg<Tchr>& part) const
		{
			if ( *this == None ) 
				return Path<Tchr>(part);

			const Tchr* str = part.Cstr();
			while (*str == '\\' || *str == '/') ++str;
			if (path.back() == '\\' || path.back() == '//')
				return Path<Tchr>(path + str);
			else
				return Path<Tchr>(path + delim_str + str);
		}

		Path<Tchr> Parent() const
		{
			return Path(Dirname());
		}

		NO_INLINE Path<Tchr> Fullpath() const
		{
			if ( *this == None ) 
				return None;
#ifdef _WIN32
			std::array<wchar_t, 260> tmp;
			DWORD r = GetFullPathNameW(Strarg<wchar_t>(path).Cstr(), tmp.size(), &tmp[0], 0);
			assert(r < tmp.size());
			return Path<Tchr>(&tmp[0]);
#else
			if (path.front() != delim)
				return Cwd().Append(path);
			else
				return *this;
#endif
		}

		Path<Tchr> Normalize() const
		{
			if ( *this == None ) 
				return None;			
#ifdef _WIN32
			return Fullpath();
#else
			/* not implemented yet */
			return Fullpath();
// 			Tchr patt[] = {'\\','.','.','\\'};
// 			Tchr slhslh[] = {'\\','\\'};
// 			
// 			std::basic_string<Tchr> p = Fullpath().path;
// 
// 			auto i = std::search(p.begin(),p.end(),slhslh,patt+sizeof(slhslh));
// 			while ( i != p.end() )
// 			{
// 				p.erase(i);
// 			}
// 			
// 			i = std::search(p.begin(),p.end(),patt,patt+sizeof(patt));
// 			while ( i != p.begin() && i != p.end() )
// 			{
// 				auto pos_patt = (i-p.begin());
// 				auto pos = p.rfind('\\',pos_patt-1);
// 				if ( pos != p.npos ) 
// 					p.erase(pos,pos_patt-pos+3);
// 				i = std::search(p.begin(),p.end(),patt,patt+sizeof(patt)-1);
// 			}
// 			return Path<Tchr>(p);
#endif
		}

		std::basic_string<Tchr> Name() const
		{
			size_t pos = path.find_last_of(delim_set);
			if (pos == std::basic_string<Tchr>::npos)
				return path;
			return path.substr(pos + 1);
		}

		NO_INLINE std::basic_string<Tchr> Dirname() const
		{
			size_t pos = path.find_last_of(delim_set);
			if (pos != std::basic_string<Tchr>::npos)
				return path.substr(0, pos);
			return std::basic_string<Tchr>();
		}

		NO_INLINE std::vector< std::basic_string<Tchr> > Split() const
		{
			std::vector< std::basic_string<Tchr> > ret;
			size_t start = 0;
			size_t pos = path.find_first_of(delim_set);
			while (pos != std::basic_string<Tchr>::npos)
			{
				if (pos != start)
					ret.push_back(path.substr(start, pos - start));
				start = pos + 1;
				pos = path.find_first_of(delim_set, start);
			}
			return ret;
		}

		static Path<Tchr> Cwd()
		{
#ifdef _WIN32
			std::array<wchar_t, 260> tmp = {0};
			_wgetcwd(&tmp[0], tmp.size());
			return Path<Tchr>(&tmp[0]);
#else
			std::array<char, 260> tmp = {0};
			getcwd(&tmp[0], tmp.size());
#endif
			return Path<Tchr>(&tmp[0]);
		}

		typedef bool(Path<Tchr>::*BoolType)() const;
		operator BoolType() const
		{
			return ( *this == None ) ? 0 : &Path<Tchr>::Chdir;
		}

		bool Chdir() const
		{
#ifdef _WIN32
			return _wchdir(Strarg<wchar_t>(path).Cstr()) == 0;
#else
			return chdir(Strarg<char>(path).Cstr()) == 0;
#endif
		}

		NO_INLINE Path<Tchr> Temp() const
		{
#ifdef _WIN32
			array<wchar_t, 260> tmp = {0};
			DWORD r = GetTempPathW(tmp.size(), &tmp[0]);
			assert(r < tmp.size());
			return Path<Tchr>(&tmp[0]);
#else
			char* tmp = getenv("TEMP");
			if (!tmp) tmp = "/tmp";
			return Path<Tchr>(tmp);
#endif
		}

		const Tchr* Cstr() const
		{
			return path.c_str();
		}

		std::basic_string<Tchr> Str() const
		{
			return path;
		}

		NO_INLINE bool Delete() const
		{
			if ( *this == None )
				return false;

			if (IsDirectory())
			{
				auto ls = List();
				for ( auto entry = ls.begin(); entry != ls.end(); ++entry)
					if ( !Append(*entry).Delete() ) return false;
#ifdef _WIN32
				return _wrmdir(Strarg<wchar_t>(path).Cstr()) == 0;
#else
				return rmdir(Strarg<char>(path).Cstr()) == 0;
#endif
			}
			else
#ifdef _WIN32
				return _wunlink(Strarg<wchar_t>(path).Cstr()) == 0;
#else
				return unlink(Strarg<char>(path).Cstr()) == 0;
#endif
		}

		NO_INLINE bool MkDir() const
		{
			if ( *this == None )
				return false;

			Path<Tchr> parent = Parent();
			if (parent != None && !parent.Exists())
				if (!parent.MkDir()) return false;
#ifdef _WIN32
			return _wmkdir(Strarg<wchar_t>(path).Cstr()) == 0;
#else
			return mkdir(Strarg<char>(path).Cstr()) == 0;
#endif
		}

		NO_INLINE FileAttributes Attributes() const
		{
			FileAttributes attr;
			memset(&attr, 0, sizeof(attr));

			if ( *this == None )
				return attr;

#ifdef _WIN32
			struct _stat64 st;
			if (_wstat64(Strarg<wchar_t>(path).Cstr(), &st) < 0)
			{
				return attr;
			}
#else
			struct stat st;
			if (stat(Strarg<char>(path).Cstr(), &st) < 0)
			{
				return attr;
			}
#endif

			attr.exists = true;
			attr.isDirectory = !!((st.st_mode & S_IFMT) & S_IFDIR);
			attr.isReadonly  = !(st.st_mode & S_IWUSR) != 0;
			attr.mtime = st.st_mtime;
			attr.ctime = st.st_ctime;
			attr.size  = st.st_size;
			return attr;
		}

		NO_INLINE std::vector<std::basic_string<Tchr>> List() const
		{
			std::vector<std::basic_string<Tchr>> ls;
			if ( *this == None )
				return ls;

#ifdef _WIN32
			WIN32_FIND_DATAW wfd;
			HANDLE ff = FindFirstFileW(Strarg<wchar_t>(Append("*.*").Name()).Cstr(), &wfd);
			if (ff != INVALID_HANDLE_VALUE)
			{
				do if (wcscmp(wfd.cFileName, L".") && wcscmp(wfd.cFileName, L".."))
					{
						ls.push_back(Strarg<Tchr>(wfd.cFileName).Str());
					}
				while (FindNextFileW(ff, &wfd));
				FindClose(ff);
			}
#else
			DIR* dir = opendir(Strarg<wchar_t>(Name()).Cstr());
			if (dir)
			{
				struct dirent* dp = 0;
				while (0 != (dp = readdir(dir)))
					if (strcmp(dp->d_name, ".") && strcmp(dp->d_name, ".."))
						ls.push_back(Strarg<Tchr>(dp->d_name).Str());
				closedir(dir);
			}
#endif
			return ls;
		}

		bool Exists() const
		{
			return Attributes().exists;
		}

		bool IsDirectory() const
		{
			return Attributes().isDirectory;
		}

		bool IsReadonly() const
		{
			return Attributes().isReadonly;
		}

		int64_t Size() const
		{
			return Attributes().size;
		}
	};

	template < class Tchr >
	const Tchr Path<Tchr>::delim_str[2] = {Path<Tchr>::delim, 0};
	template < class Tchr >
	const Tchr Path<Tchr>::delim_set[3] = {(Tchr)'/',(Tchr)'\\',0};

	template < class Tchr >
#ifdef _WIN32
	const Tchr Path<Tchr>::delim = (Tchr)'\\';
#else
	const Tchr Path<Tchr>::delim = (Tchr)'/';
#endif

	template < class Tchr >
	typename Strarg<Tchr>::Converter strarg_cvt_from(ExactType2<Path<Tchr>,Tchr>)
	{
		return [](Tchr*& o, size_t& length)
		{
			const Path<Tchr>& path = *(const Path<Tchr>*)o;
			length = path.path.length();
			o = (Tchr*)path.path.c_str();
		};
	}

	template < class Tchr >
	typename Strarg<Tchr>::Converter strarg_cvt_from(ExactType2<Path<typename Opposite<Tchr>::Type>,Tchr>)
	{
		return [](Tchr*& o, size_t& length)
		{
			o = (Tchr*)&((const Path<typename Opposite<Tchr>::Type>*)o)->path;
			Strarg<Tchr>::_StringConvert(o,length);
		};
	}
}
