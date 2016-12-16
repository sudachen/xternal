/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_694F4096_7219_47D5_8C2F_7456AB482DDB
#define C_once_694F4096_7219_47D5_8C2F_7456AB482DDB

#include "../C+.hc"
#include "../datetime.hc"
#include "../text/url.hc"

#include "xddb.hc"
#include "xddbsql_.hc"

#ifdef _BUILTIN
#define _C_XDDBSQL3_BUILTIN
#endif

#ifdef _C_XDDBSQL3_BUILTIN
#include "../../external/include/sqlite3.c"
#else
#include "../../external/include/sqlite3.h"
#endif

typedef struct _C_XDDBSQL3
{
	sqlite3 *con;
} C_XDDBSQL3;

void C_XDDBSQL3_Destruct(C_XDDBSQL3 *sqldb)
#ifdef _C_XDDBSQL3_BUILTIN
{
	sqlite3_close(sqldb->con);
	__Destruct(sqldb);
}
#endif
;

int XddbSql3_Fill(void *rows, int argc, char **argv, char **colName)
#ifdef _C_XDDBSQL3_BUILTIN
{
	__Try
	{
		int i;
		C_ARRAY *row = Array_Pchars();
		Array_Resize(row,argc);
		for ( i = 0; i < argc; ++i )
		{
			row->at[i] = Str_Copy_Npl(argv[i],-1);
		}
		Array_Push(rows,__Refe(row));
	}
	__Except
	{
		return -1;
	}
	return 0;
}
#endif
;

void XddbSql3_Unquote_Append(C_BUFFER *bf, void *S, int len)
#ifdef _C_XDDBSQL3_BUILTIN
{
	byte_t *q = S;
	byte_t *p = q;
	byte_t *E;

	if ( len < 0 ) 
		len = S?strlen(S):0;

	E = p + len;

	while ( p != E )
	{
		if ( *p == '^' )
		{
			switch(p[1])
			{
			case 'n':	Buffer_Append(bf,"\n",1); break;
			case 't':	Buffer_Append(bf,"\t",1); break;
			case 'r':	Buffer_Append(bf,"\r",1); break;
			case 'b':	Buffer_Append(bf,"\b",1); break;
			case '^':	Buffer_Append(bf,"^",1); break;
			case '"':	Buffer_Append(bf,"\"",1); break;
			case '\'':	Buffer_Append(bf,"'",1); break;
			case '%':	Buffer_Append(bf,"%",1); break;
			case '_':	Buffer_Append(bf,"_",1); break;
			case 'Z':	Buffer_Fill_Append(bf,26,1); break;
			default:	Buffer_Fill_Append(bf,p[1],1); break;
			}
			p+=2;
		}
		else if ( *p == '\'' && p[1] == '\'' )
		{
			Buffer_Fill_Append(bf,'\'',1);
			p+=2;
		}
		else
		{
			Buffer_Fill_Append(bf,*p,1);
			++p;
		}
	}
}
#endif
;

C_BUFFER *XddbSql3_Query_Doc(C_XDDBSQL3 *sqldb, char *colid, char *docid, char **dtt)
#ifdef _C_XDDBSQL3_BUILTIN
{
	C_BUFFER *bf = 0;
	char *errmsg;
	int err;

	__Auto_Ptr(bf)
	{ 
		C_ARRAY *results = Array_Refs();
		if (( err = sqlite3_exec(sqldb->con
			,__Format("SELECT body,dtt FROM _%s WHERE docid = '%s'",colid,docid)
			,XddbSql3_Fill,results
			,&errmsg) ))
		{
			__Pool_Ptr(errmsg,sqlite3_free);
			//if ( err != ER_NO_SUCH_TABLE )
				__Raise_Format(C_ERROR_INVALID_PARAM
					,("Sqlite failed to retrive document: %s/%s",sqlite3_errstr(err),errmsg));
		}
		else if ( results->count )
		{
			C_ARRAY *row;
			__Verify( results->at[0] );
			
			row = results->at[0];
			if ( row )
			{
				int len = Str_Length(row->at[0]);
				bf = Buffer_Reserve(0,len);
				XddbSql3_Unquote_Append(bf,row->at[0],len);
				*dtt = strdup(row->at[1]);
			}
		}
	}

	if (*dtt) __Pool_Ptr(*dtt,free);
	return bf;
}
#endif
;

C_XDDBSQL_STATS XddbSql3_Stats_Doc(C_XDDBSQL3 *sqldb, char *colid, char *docid)
#ifdef _C_XDDBSQL3_BUILTIN
{
	int err;
	char *errmsg;
	C_XDDBSQL_STATS stats;
	memset(&stats,0,sizeof(stats));

	__Auto_Release
	{ 
		C_ARRAY *results = Array_Refs();
		if (( err = sqlite3_exec(sqldb->con
			,__Format("SELECT revision,dtt FROM _%s WHERE docid = '%s'",colid,docid)
			,XddbSql3_Fill,results
			,&errmsg) ))
		{
			__Pool_Ptr(errmsg,sqlite3_free);
			//if ( err != ER_NO_SUCH_TABLE )
				__Raise_Format(C_ERROR_INVALID_PARAM
					,("Sqlite failed to retrive document stats: %s/%s",sqlite3_errstr(err),errmsg));
		}
		else if (results->count)
		{
			C_ARRAY *row;
			__Verify( results->at[0] );
			
			row = results->at[0];
			if ( row )
			{
				stats.revision = Str_To_Int(row->at[0]);
				stats.datetime = 0;
				stats.f.exists = 1;
			}
		}
	}

	return stats;
}
#endif
;

void XddbSql3_Create_Doc_Table(C_XDDBSQL3 *sqldb, char *colid)
#ifdef _C_XDDBSQL3_BUILTIN
{
	int err;
	char *errmsg;
	__Auto_Release
	{ 
		if (( err = sqlite3_exec(sqldb->con,
			__Format("CREATE TABLE IF NOT EXISTS _%s "
			"(docid char(%d) PRIMARY KEY,"
			" revision INTEGER, dtt VARCHAR(20), body BLOB)",
			colid,XDDBSQL_DOC_ENCODED_ID_LEN),0,0,&errmsg) ))
		{
			__Pool_Ptr(errmsg,sqlite3_free);
			__Raise_Format(C_ERROR_IO,
				("failed to create collection: %d/%s",sqlite3_errstr(err),errmsg));
		}
	}
}
#endif
;

void XddbSql3_Quote_Append(C_BUFFER *bf, void *S, int len)
#ifdef _C_XDDBSQL3_BUILTIN
{
	byte_t *q = S;
	byte_t *p = q;
	byte_t *E;

	if ( len < 0 ) 
		len = S?strlen(S):0;

	E = p + len;

	while ( p != E )
	{
		do 
		{ 
			if ( *p == 0 || *p == '\n' || *p == '\r' || *p == '^' || *p == '\'' )
				break; 
			++p; 
		} 
		while ( p != E );

		if ( q != p )
			Buffer_Append(bf,q,p-q);

		if ( p != E )
		{
			if ( !*p )             Buffer_Append(bf,"^0",2);
			else if ( *p == '\n' ) Buffer_Append(bf,"^n",2);
			else if ( *p == '\r' ) Buffer_Append(bf,"^r",2);
            else if ( *p == '^' )  Buffer_Append(bf,"^^",2);
			else if ( *p == '\'' ) Buffer_Append(bf,"\'\'",2);
			else PANICA("");
			++p;
		}

		q = p;
	}
}
#endif
;

int XddbSql3_Insert_Doc(
	C_XDDBSQL3 *sqldb, 
	char *colid, char *docid, 
	int newrev, void *data, int len )
#ifdef _C_XDDBSQL3_BUILTIN
{
	int err;
	int success = 0;
	char *errmsg;
	__Auto_Release
	{
		char *dtt = YmdHMS_Curr_Datetime(0,0,0);
		C_BUFFER *bf = Buffer_Grow_Reserve(0,len+len/25+128);
		Buffer_Printf(bf,"INSERT INTO _%s VALUES( '%s', %d, '%s', '",colid,docid,newrev,dtt);
		XddbSql3_Quote_Append(bf,data,len);
		Buffer_Append(bf,"')",2);
repeat:
		if (( err = sqlite3_exec(sqldb->con,bf->at,0,0,&errmsg) ))
		{
			__Pool_Ptr(errmsg,sqlite3_free);
			if ( err == SQLITE_ERROR && Str_Starts_With(errmsg,"no such table") )
			{
				XddbSql3_Create_Doc_Table(sqldb,colid);
				goto repeat;
			}
			else
			{
				__Raise_Format( C_ERROR_IO
						 ,("failed to insert new document: %s/%s"
						 ,sqlite3_errstr(err),errmsg));
			}
		}
	}
	return 1;
}
#endif
;

int XddbSql3_Update_Doc(
	C_XDDBSQL3 *sqldb, 
	char *colid, char *docid, 
	int newrev, void *data, int len, int oldrev )
#ifdef _C_XDDBSQL3_BUILTIN
{
	int err;
	int success = 0;
	char *errmsg;

	__Auto_Release
	{
		char *dtt = YmdHMS_Curr_Datetime(0,0,0);
		C_BUFFER *bf = Buffer_Grow_Reserve(0,len+len/25+128);
		Buffer_Printf(bf,"UPDATE _%s SET revision = %d, dtt = '%s', body = '",colid,newrev,dtt);
		XddbSql3_Quote_Append(bf,data,len);
		Buffer_Printf(bf,"' WHERE docid = '%s'",docid);
		if ( oldrev )
			Buffer_Printf(bf," and revision = %d",oldrev);
		if (( err = sqlite3_exec(sqldb->con,bf->at,0,0,&errmsg) ))
		{
			__Pool_Ptr(errmsg,sqlite3_free);
			if ( err == SQLITE_ERROR && Str_Starts_With(errmsg,"no such table") )
				;
			else
			{
				__Raise_Format(C_ERROR_IO
				,("failed to insert new document: %s/%s",sqlite3_errstr(err),errmsg));      
			}
		}
		else
			success = sqlite3_changes(sqldb->con);
	}
	return success;
}
#endif
;

int XddbSql3_Delete_Doc(C_XDDBSQL3 *sqldb, char *colid, char *docid)
#ifdef _C_XDDBSQL3_BUILTIN
{
	int err;
	int success = 0;
	char *errmsg;

	__Auto_Release
	{
		if (( err = sqlite3_exec(sqldb->con,
			__Format("DELETE FROM _%s WHERE docid = '%s'",colid,docid),0,0,&errmsg) ))
		{
			__Pool_Ptr(errmsg,sqlite3_free);
			if ( err == SQLITE_ERROR && Str_Starts_With(errmsg,"no such table") )
				;
			else
			{
				__Raise_Format(C_ERROR_IO
				,("failed to insert new document: %s/%s",sqlite3_errstr(err),errmsg));      
			}
		}
		else
			success = sqlite3_changes(sqldb->con);
	}
	return success;
}
#endif
;

/*
typedef struct _C_XDDBSQL3_CURSOR
{
	C_XDDBSQL3 *sqldb;
	MYSQL_RES *rset;  
} C_XDDBSQL3_CURSOR;

void C_XDDBSQL3_CURSOR_Destruct(C_XDDBSQL3_CURSOR *cursor)
#ifdef _C_XDDBSQL3_BUILTIN
{
	if ( cursor->rset )
		mysql_free_result(cursor->rset);
	__Unrefe(cursor->sqldb);
	__Destruct(cursor);
}
#endif
;

char *XddbSql3_Cursor_Next(C_XDDBSQL3_CURSOR *cursor)
#ifdef _C_XDDBSQL3_BUILTIN
{
	char *doc_id = 0;
	MYSQL_ROW row = mysql_fetch_row(cursor->rset);

	if ( row )
	{
		doc_id = Str_Copy_L(row[0],*mysql_fetch_lengths(cursor->rset));
	}

	return doc_id;
}
#endif
;

void *XddbSql3_Open_Cursor(C_XDDBSQL3 *sqldb, char *colid, char *seqid)
#ifdef _C_XDDBSQL3_BUILTIN
{
	C_XDDBSQL3_CURSOR *cursor = 0;
	__Auto_Ptr(cursor)
	{
		char *query = seqid ? __Format("select docid from %s__%s order by usec",sqldb->dbpfx,seqid)
			: __Format("select docid from %s_%s",sqldb->dbpfx,colid);

		if ( mysql_query(sqldb->con, query) )
		{
			int err = mysql_errno(sqldb->con);
			if ( err != ER_NO_SUCH_TABLE )
				__Raise_Format(C_ERROR_INVALID_PARAM
				,("failed to select sequence elements: %s"
				,mysql_error(sqldb->con)));      
			else if ( err )
				__Raise(C_ERROR_DSNT_EXIST,"sequence does not exist");
		}
		else
		{
			static C_FUNCTABLE funcs[] = 
			{ {0},
			{Oj_Destruct_OjMID,         C_XDDBSQL3_CURSOR_Destruct},
			{Xddbsql_Cursor_Next_OjMID, XddbSql3_Cursor_Next},
			{0}};
			cursor = __Object(sizeof(C_XDDBSQL3_CURSOR),funcs);
			cursor->sqldb = __Refe(sqldb);
			cursor->rset = mysql_store_result(sqldb->con);
		}
	}

	return cursor;
}
#endif
;
*/

C_XDDB *XddbSql3_Connect(char *source, int format, int kind)
#ifdef _C_XDDBSQL3_BUILTIN
{
	static C_FUNCTABLE funcs[] = 
	{ {0},
	{Oj_Destruct_OjMID,         C_XDDBSQL3_Destruct},
	{Xddbsql_Query_Doc_OjMID,   XddbSql3_Query_Doc},
	{Xddbsql_Stats_Doc_OjMID,   XddbSql3_Stats_Doc},
	{Xddbsql_Delete_Doc_OjMID,  XddbSql3_Delete_Doc},
	{Xddbsql_Update_Doc_OjMID,  XddbSql3_Update_Doc},
	{Xddbsql_Insert_Doc_OjMID,  XddbSql3_Insert_Doc},
	//{Xddbsql_Cursor_Open_OjMID, XddbSql3_Open_Cursor},
	{0}
	};

	C_XDDB *ret = 0;

	__Auto_Ptr(ret)
	{
		C_ARRAY *results = Array_Refs();
		C_XDDBSQL3 *sqldb = __Object(sizeof(C_XDDBSQL3),funcs);
		int flags = 0, err;
		char *errmsg;

		if ( !strcmp(source,"sql3://*") )
			source = 0;
		else if ( Str_Starts_With(source,"sql3://") )
		{
			source = source+7;
		}
		else
			__Raise(C_ERROR_ILLFORMED,
				"database url should start with 'sql3://' or be 'sql3://*'");

		if ( !source ) 
			flags = SQLITE_OPEN_MEMORY;
		else switch ( kind )
		{
		case XDDB_CREATE_ALWAYS:
			if ( File_Exists(source) )
				File_Unlink(source,0);
			flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
			break;
		case XDDB_CREATE_NEW:
			if ( File_Exists(source) )
				__Raise(C_ERROR_ALREADY_EXISTS,"Sqlite database alrady exists");
			flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
			break;
		case XDDB_OPEN_EXISTING:
			flags = SQLITE_OPEN_READWRITE;
			break;
		case XDDB_OPEN_READONLY:
			flags = SQLITE_OPEN_READONLY;
			break;
		}

		if (( err = sqlite3_open_v2((source?source:":memory:"),&sqldb->con,flags,0) ))
		{
			__Raise_Sformat1(C_ERROR_IO,
				"Sqlite falied to connect to '%s' database",
				$S(sqlite3_errstr(err)));
		}

		if (( err = sqlite3_exec(sqldb->con,
			"CREATE TABLE IF NOT EXISTS XDDB_INFO "
			"( name varchar(128) UNIQUE, value varchar(128) )",
			0,0,&errmsg)  ))
		{
			char *msg = __Sformat1("Sqlite failed to create INFO table: %?",
			                       $S(errmsg));
			sqlite3_free(errmsg);
			__Raise(C_ERROR_IO,msg);
		}

		Array_Clear(results);
		if (( err = sqlite3_exec(sqldb->con,
			"SELECT value FROM XDDB_INFO WHERE name = 'doc_format'",
			XddbSql3_Fill,results,
			&errmsg) ))
		{
			char *msg = __Sformat1("Sqlite failed to query doc format: %?",
			                       $S(errmsg));
			sqlite3_free(errmsg);
			__Raise(C_ERROR_IO,msg);
		}

		if ( results->count )
		{
			C_ARRAY *row = results->at[0];
			__Verify( row && row->count );
			format = Str_To_Int(row->at[0]);
		}
		else
		{
			if (( err = sqlite3_exec(sqldb->con,
				__Format("INSERT INTO XDDB_INFO VALUES('doc_format','%d')",format),
				0,0,&errmsg)  ))
			{
				char *msg = __Sformat1("Sqlite failed to set doc format: %?",
									   $S(errmsg));
				sqlite3_free(errmsg);
				__Raise(C_ERROR_IO,msg);
			}
		}

		ret = Xddbsql_Init(sqldb,format,source);
	}

	return ret;
}
#endif
;

#endif /* C_once_694F4096_7219_47D5_8C2F_7456AB482DDB */
