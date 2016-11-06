
#pragma once

#include "Common.hxx"
#include "Refcounted.hxx"
#include "RccPtr.hxx"
#include "Stream.hxx"

namespace foobar
{
    struct LineReaderObject : Refcounted
    {
        Stream stream;
        std::array<char, 512> buf;
        std::array<char, 512>::iterator pos_S;
        std::array<char, 512>::iterator pos_E;

        LineReaderObject(Stream stream)
            : stream(stream)
        {
            pos_E = pos_S = buf.begin();
        }

        std::string NextLine()
        {
            std::string str;
            NextLine(str);
            return str;
        }

        void StepBack()
        {
            if ( pos_S != pos_E )
            {
                stream->Seek(-(pos_E-pos_S),SEEK_CUR);
                pos_S = pos_E = buf.begin();
            }
        }

        bool NextLine(std::string& str)
        {
            bool nl_found = false;
            str.clear();

            while ( !nl_found )
            {
                if ( pos_S != pos_E )
                {
                    auto pos_Sx = pos_S;
                    auto nlpos = (pos_S = std::find(pos_S,pos_E,'\n'));
                    if ( pos_S != pos_E )
                    {
                        ++pos_S;
                        nl_found = true;
                    }
                    while ( nlpos != pos_Sx && (*(nlpos-1) == '\r' || *(nlpos-1) == '\n') )
                        --nlpos;
                    str.append(pos_Sx,nlpos);
                }

                if ( !nl_found )
                {
                    int read = 0;
                    pos_E = pos_S = buf.begin();
                    while ( read == 0 && !stream->Eof() )
                        read = stream->ReadData(&buf[0],buf.size(),0);
                    if ( read > 0 )
                        pos_E += read;
                    else
                        break;
                }
            }

            return str.length() || nl_found;
        }
    };

    struct LineReader : RccPtr<LineReaderObject>
    {
        static LineReader Chain(Stream stream)
        {
            return LineReader(new LineReaderObject(stream));
        }

        LineReader(LineReaderObject* o = 0) : RccPtr<LineReaderObject>(o) {}
    };

}