
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

#include <map>
#include <string>
#include <vector>
#include <memory>
#include <functional>
#include <algorithm>
#include <array>

#ifdef _FOOBAR
#include "Common.hxx"
#include "Strarg.hxx"
#endif

namespace foobar
{
    struct CmdlineObject
    {
        struct OptValues
        {
            bool specified;
            std::vector<std::string> lst;
            OptValues() : specified(false) {}
        };

        struct Opt
        {
            enum Fetaures { NO_ARGUMENT, MAY_ARGUMENT, HAS_ARGUMENT } _fts;
            std::shared_ptr<OptValues> _values;

            bool Exists() const { return _values && (_values->specified || Count() != 0); }
            bool Specified() const { return Exists(); } // compatibility with existing code
            size_t Count() const { return _values && _values->lst.size(); }
            operator std::string() const { return Str(); }
            std::string Str(size_t no = 0) const
            {
                if (_values && no < _values->lst.size())
                    return _values->lst.at(no);
                else
                    return std::string();
            }
            const char* Cstr(size_t no = 0) const
            {
                if (_values && no < _values->lst.size())
                    return _values->lst.at(no).c_str();
                else
                    return 0;
            }
            size_t Length(size_t no = 0) const
            {
                if (_values && no < _values->lst.size())
                    return _values->lst.at(no).length();
                else
                    return 0;
            }
        };

        struct OptSet
        {
            std::map<std::string, Opt> _options;
            const Opt& operator[](const std::string& name) const
            {
                static const Opt empty = {};
                auto i = _options.find(name);
                if (i == _options.end()) return empty;
                return i->second;
            }
        };

        bool Good() const { return errors.size() == 0; }

        std::vector<std::string> errors;
        std::vector<std::string> argv;
        OptSet opt;

        static void Apply(const char* S, const char* E, char d, std::function<void(const char*, const char*)> action)
        {
            while (S != E)
            {
                while (S != E && isspace(*S)) ++S;
                auto q = S;
                S = std::find(S, E, d);
                auto p = S;
                while (p != q && isspace(*(p - 1))) --p;
                if (p != q)
                    action(q, p);
                if (S != E) ++S;
            }
        }

        void Initialize(const char* patt)
        {
            Apply(patt, patt + strlen(patt), ',', [this](const char* S, const char* E)
            {
                OptSet& opt = this->opt;
                std::shared_ptr<OptValues> values(new OptValues());
                Apply(S, E, '|', [&opt, &values](const char* S, const char* E)
                {
                    typedef ::foobar::CmdlineObject::Opt Opt;
                    Opt::Fetaures fts = Opt::NO_ARGUMENT;

                    switch ( *(E - 1) )
                    {
                        case ':':
                            fts = Opt::HAS_ARGUMENT;
                            --E;
                            break;
                        case '=':
                            fts = Opt::MAY_ARGUMENT;
                            --E;
                            break;
                    }

                    auto name = std::string(S, E);
                    auto& option = opt._options[name];
                    option._fts = fts;
                    option._values = values;
                });
            });
        }

        void Parse(const char* const* argv, int argc, unsigned /*flags*/ = 0)
        {
            std::array<char, 128> bf;
            for (int arg_no = 1; arg_no < argc; ++arg_no)
            {
                const char* arg = argv[arg_no];
                size_t arglen = strlen(arg);

                if (*arg != '-')
                {
                    this->argv.push_back(std::string(arg, arglen));
                }
                else /* option */
                {
                    ++arg; --arglen;

                    const char* argE = std::find(arg, arg + arglen, '=');
                    auto expected = this->opt._options.find(std::string(arg, argE).c_str());
                    if (expected != this->opt._options.end())
                    {
                        if (argE != arg + arglen)
                        {
                            if (expected->second._fts != Opt::NO_ARGUMENT)
                            {
                                expected->second._values->lst.push_back(std::string(argE + 1, arg + arglen));
                                expected->second._values->specified = true;
                            }
                            else
                            {
                                _snprintf(&bf[0], bf.size(), "option -%s could not have argument", expected->first.c_str());
                                this->errors.push_back(std::string(&bf[0]));
                            }
                        }
                        else if (expected->second._fts == Opt::HAS_ARGUMENT)
                        {
                            if (arg_no + 1 == argc)
                            {
                                _snprintf(&bf[0], bf.size(), "option -%s requires argument", expected->first.c_str());
                                this->errors.push_back(std::string(&bf[0]));
                            }
                            else
                            {
                                ++arg_no;
                                expected->second._values->lst.push_back(std::string(argv[arg_no]));
                                expected->second._values->specified = true;
                            }
                        }
                        else
                            expected->second._values->specified = true;
                    }
                    else
                    {
                        _snprintf(&bf[0], bf.size(), "bad option -%s", std::string(arg, argE).c_str());
                        this->errors.push_back(std::string(&bf[0]));
                    }
                }
            }
        }
    };

    struct Cmdline : std::shared_ptr<const CmdlineObject>
    {
        static Cmdline Parse(const char* optlist, const char* const* argv, int argc)
        {
            auto cmdl = std::unique_ptr<CmdlineObject>(new CmdlineObject());
            cmdl->Initialize(optlist);
            cmdl->Parse(argv, argc);
            return Cmdline(cmdl.release());
        }

        #ifdef _FOOBAR
        static Cmdline Parse(const char* optlist, const wchar_t* const* argv, int argc)
        {
            std::vector<std::string> u8;
            for ( int i = 0; i < argc; ++i )
                u8.push_back(Strarg<char>(argv[i]).Str());
            std::vector<char*> u8argv;
            for ( int i = 0; i < argc; ++i )
                u8argv.push_back((char*)u8[i].c_str());
            return Parse(optlist,&u8argv[0],argc);
        }
        #endif

        Cmdline() {}

    private:
        Cmdline(CmdlineObject* o) : std::shared_ptr<const CmdlineObject>(o) {}
    };
}
