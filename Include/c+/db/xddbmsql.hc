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
#define _C_XDDBmSQL_BUILTIN
#endif

#ifdef _C_XDDBmSQL_BUILTIN
#include "mysql.hc"
#endif

typedef struct _C_XDDBmSQL
{
	char *dbpfx;
	void *con;
} C_XDDBmSQL;

void C_XDDBmSQL_Destruct(C_XDDBmSQL *sqldb)
#ifdef _C_XDDBmSQL_BUILTIN
{
	free(sqldb->dbpfx);
	mysql_close(sqldb->con);
	__Destruct(sqldb);
}
#endif
;

C_BUFFER *XddbMsql_Query_Doc(C_XDDBmSQL *sqldb, char *colid, char *docid, char **dtt)
#ifdef _C_XDDBmSQL_BUILTIN
{
	MYSQL_ROW row;
	MYSQL_RES *rset;
	C_BUFFER *bf = 0;

	__Auto_Ptr(bf)
	{ 
		if ( mysql_query(sqldb->con
			,__Format("SELECT body,dtt FROM %s_%s WHERE docid = '%s'"
			,sqldb->dbpfx,colid,docid)) )
		{
			int err = mysql_errno(sqldb->con);
			if ( err != ER_NO_SUCH_TABLE )
				__Raise_Format(C_ERROR_INVALID_PARAM
				,("failed to retrive document: %s"
				,mysql_error(sqldb->con)));      
		}
		else __Mysql_Results(sqldb->con,rset)
		{
			row = mysql_fetch_row(rset);
			if ( row )
			{
				long *lengths = mysql_fetch_lengths(rset);
				bf = Buffer_Init(lengths[0]);
				*dtt = strdup(row[1]);
				memcpy(bf->at,row[0],bf->count);
			}
		}
	}

	if (*dtt) __Pool_Ptr(*dtt,free);
	return bf;
}
#endif
;

C_XDDBSQL_STATS XddbMsql_Stats_Doc(C_XDDBmSQL *sqldb, char *colid, char *docid)
#ifdef _C_XDDBmSQL_BUILTIN
{
	C_XDDBSQL_STATS stats;
	MYSQL_ROW row;
	MYSQL_RES *rset;

	memset(&stats,0,sizeof(stats));

	__Auto_Release
	{ 
		if ( mysql_query(sqldb->con
			,__Format("SELECT revision,dtt FROM %s_%s"
			" WHERE docid = '%s'"
			,sqldb->dbpfx,colid,docid)) )
		{
			int err = mysql_errno(sqldb->con);
			if ( err != ER_NO_SUCH_TABLE )
				__Raise_Format(C_ERROR_INVALID_PARAM
				,("failed to retrive document stats: %s"
				,mysql_error(sqldb->con)));      
		}
		else __Mysql_Results(sqldb->con,rset)
		{
			row = mysql_fetch_row(rset);
			if ( row )
			{
				stats.revision = Str_To_Int(row[0]);
				stats.datetime = 0;
				stats.f.exists = 1;
			}
		}
	}

	return stats;
}
#endif
;

void XddbMsql_Create_Doc_Table(C_XDDBmSQL *sqldb, char *colid)
#ifdef _C_XDDBmSQL_BUILTIN
{
	if ( mysql_query(sqldb->con,
		__Format("CREATE TABLE IF NOT EXISTS %s_%s "
		"( docid char(%d) PRIMARY KEY,"
		" revision INTEGER, dtt VARCHAR(20), body BLOB)",
		sqldb->dbpfx,colid,XDDBSQL_DOC_ENCODED_ID_LEN)) )
	{
		__Raise_Format(C_ERROR_IO,
			("failed to create collection: %s",
			mysql_error(sqldb->con)));      
	}
}
#endif
;

void XddbMsql_Quote_Append(C_BUFFER *bf, void *S, int len)
#ifdef _C_XDDBmSQL_BUILTIN
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
			if ( *p == '\\' || *p == '"' 
				|| *p == '\'' || *p == 0 
				|| *p == '\b' || *p == '\n'
				|| *p == '\r' || *p == '\t'
				//|| *p == '%' 
				//|| *p == '_' 
				|| *p == 26  ) 
				break; 
			++p; 
		} 
		while ( p != E );

		if ( q != p )
			Buffer_Append(bf,q,p-q);

		if ( p != E )
		{
			if ( !*p )             Buffer_Append(bf,"\\0",2);
			else if ( *p == '\n' ) Buffer_Append(bf,"\\n",2);
			else if ( *p == '\t' ) Buffer_Append(bf,"\\t",2);
			else if ( *p == '\r' ) Buffer_Append(bf,"\\r",2);
			else if ( *p == '\\' ) Buffer_Append(bf,"\\\\",2);
			else if ( *p == '"'  ) Buffer_Append(bf,"\\\"",2);
			else if ( *p == '\'' ) Buffer_Append(bf,"\\'",2);
			else if ( *p == '\b' ) Buffer_Append(bf,"\\b",2);
			else if ( *p == '%'  ) Buffer_Append(bf,"\\%",2);
			else if ( *p == '_'  ) Buffer_Append(bf,"\\_",2);
			else if ( *p == 26   ) Buffer_Append(bf,"\\Z",2);
			else PANICA("");
			++p;
		}

		q = p;
	}
}
#endif
;

int XddbMsql_Insert_Doc(
	C_XDDBmSQL *sqldb, 
	char *colid, char *docid, 
	int newrev, void *data, int len )
#ifdef _C_XDDBmSQL_BUILTIN
{
	int success = 0;
	__Auto_Release
	{
		char *dtt = YmdHMS_Curr_Datetime(0,0,0);
		C_BUFFER *bf = Buffer_Grow_Reserve(0,len+len/25+128);
		Buffer_Printf(bf,"INSERT INTO %s_%s VALUES( '%s', %d, '%s', '"
			,sqldb->dbpfx,colid,docid,newrev,dtt);
		XddbMsql_Quote_Append(bf,data,len);
		Buffer_Append(bf,"')",2);
repeat:
		if ( mysql_real_query(sqldb->con,bf->at,bf->count) )
		{
			int err = mysql_errno(sqldb->con);
			if ( err != ER_NO_SUCH_TABLE )
				__Raise_Format( (err == ER_DUP_ENTRY ? C_ERROR_ALREADY_EXISTS : C_ERROR_IO)
						 ,("failed to insert new document: %s"
						 ,mysql_error(sqldb->con)));      
			XddbMsql_Create_Doc_Table(sqldb,colid);
			goto repeat;
		}
		else
			success = mysql_affected_rows(sqldb->con);
	}
	return success;
}
#endif
;

int XddbMsql_Update_Doc(
	C_XDDBmSQL *sqldb, 
	char *colid, char *docid, 
	int newrev, void *data, int len, int oldrev )
#ifdef _C_XDDBmSQL_BUILTIN
{
	int success = 0;
	__Auto_Release
	{
		char *dtt = YmdHMS_Curr_Datetime(0,0,0);
		C_BUFFER *bf = Buffer_Grow_Reserve(0,len+len/25+128);
		Buffer_Printf(bf,"UPDATE %s_%s SET revision = %d, dtt = '%s', body = '"
			,sqldb->dbpfx,colid,newrev,dtt);
		XddbMsql_Quote_Append(bf,data,len);
		Buffer_Printf(bf,"' WHERE docid = '%s'",docid);
		if ( oldrev )
			Buffer_Printf(bf,"and revision = %d",oldrev);
		if ( mysql_real_query(sqldb->con,bf->at,bf->count) )
		{
			int err = mysql_errno(sqldb->con);
			if ( err != ER_NO_SUCH_TABLE )
				__Raise_Format(C_ERROR_IO
				,("failed to insert new document: %s"
				,mysql_error(sqldb->con)));      
			// table already exists or table dsnt exist - is not an error
		}
		else
			success = mysql_affected_rows(sqldb->con);
	}
	return success;
}
#endif
;

int XddbMsql_Delete_Doc(C_XDDBmSQL *sqldb, char *colid, char *docid)
#ifdef _C_XDDBmSQL_BUILTIN
{
	int success = 0;
	__Auto_Release
	{
		if ( mysql_query(sqldb->con,
			__Format("DELETE FROM %s_%s WHERE docid = '%s'"
			,sqldb->dbpfx,colid,docid)) )
		{
			int err = mysql_errno(sqldb->con);
			if ( err != ER_NO_SUCH_TABLE )
				__Raise_Format(C_ERROR_IO
				,("failed to insert new document: %s"
				,mysql_error(sqldb->con)));      
			// table already exists or table dsnt exist - is not an error            
		}
		else
			success = mysql_affected_rows(sqldb->con);
	}
	return success;
}
#endif
;

typedef struct _C_XDDBmSQL_CURSOR
{
	C_XDDBmSQL *sqldb;
	MYSQL_RES *rset;  
} C_XDDBmSQL_CURSOR;

void C_XDDBmSQL_CURSOR_Destruct(C_XDDBmSQL_CURSOR *cursor)
#ifdef _C_XDDBmSQL_BUILTIN
{
	if ( cursor->rset )
		mysql_free_result(cursor->rset);
	__Unrefe(cursor->sqldb);
	__Destruct(cursor);
}
#endif
;

char *XddbMsql_Cursor_Next(C_XDDBmSQL_CURSOR *cursor)
#ifdef _C_XDDBmSQL_BUILTIN
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

void *XddbMsql_Open_Cursor(C_XDDBmSQL *sqldb, char *colid, char *seqid)
#ifdef _C_XDDBmSQL_BUILTIN
{
	C_XDDBmSQL_CURSOR *cursor = 0;
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
			{Oj_Destruct_OjMID,         C_XDDBmSQL_CURSOR_Destruct},
			{Xddbsql_Cursor_Next_OjMID, XddbMsql_Cursor_Next},
			{0}};
			cursor = __Object(sizeof(C_XDDBmSQL_CURSOR),funcs);
			cursor->sqldb = __Refe(sqldb);
			cursor->rset = mysql_store_result(sqldb->con);
		}
	}

	return cursor;
}
#endif
;

// user@host:port/dbname

C_XDDB *XddbMsql_Connect(char *source, char *pwd, int format, int kind)
#ifdef _C_XDDBmSQL_BUILTIN
{
	static C_FUNCTABLE funcs[] = 
	{ {0},
	{Oj_Destruct_OjMID,         C_XDDBmSQL_Destruct},
	{Xddbsql_Query_Doc_OjMID,   XddbMsql_Query_Doc},
	{Xddbsql_Stats_Doc_OjMID,   XddbMsql_Stats_Doc},
	{Xddbsql_Delete_Doc_OjMID,  XddbMsql_Delete_Doc},
	{Xddbsql_Update_Doc_OjMID,  XddbMsql_Update_Doc},
	{Xddbsql_Insert_Doc_OjMID,  XddbMsql_Insert_Doc},
	{Xddbsql_Cursor_Open_OjMID, XddbMsql_Open_Cursor},
	{0}
	};

	C_XDDB *ret = 0;

	__Auto_Ptr(ret)
	{
		C_XDDBmSQL *sqldb = __Object(sizeof(C_XDDBmSQL),funcs);
		C_URL *url = Url_Parse(source);
		char *dbp, *dbname = 0, *dbpfx = 0;

		dbp = url->query;

		while ( dbp && *dbp == '/' ) ++dbp;
		if ( dbp && *dbp )
		{
			dbpfx = Path_Basename(dbp);
			dbname = Path_Dirname(dbp);
			if ( !dbname ) { dbname = dbpfx; dbpfx = "xddb";} 
		}

		if ( !dbname )
			__Raise_Format(C_ERROR_INVALID_PARAM
			,("mySQL source %s doesn't contain database name"
			,source));      

		sqldb->con = mysql_init(0);
		sqldb->dbpfx = Str_Copy_Npl(dbpfx,-1);

		if ( !mysql_real_connect(sqldb->con,url->host,url->user,pwd,0,0,0,0) )
			__Raise_Format(C_ERROR_IO
			,("failed to connect to %s: %s"
			,source,mysql_error(sqldb->con)));

		mysql_autocommit(sqldb->con, 1);

		if ( kind == XDDB_CREATE_ALWAYS )
		{
			if ( mysql_query(sqldb->con
				,__Format("DROP DATABASE IF EXISTS %s",dbname))
				||mysql_query(sqldb->con
				,__Format("CREATE DATABASE %s",dbname)) )
				__Raise_Format(C_ERROR_IO
				,("failed to (re)create databsae %s: %s"
				,dbname,mysql_error(sqldb->con)));
		}
		else if ( kind == XDDB_CREATE_NEW )
		{
			if ( mysql_query(sqldb->con,__Format("CREATE DATABASE %s",dbname)))
				__Raise_Format(C_ERROR_IO
				,("failed to create databsae %s: %s"
				,dbname,mysql_error(sqldb->con)));
		}
		else if ( kind == XDDB_CREATE_IF_DSNT_EXIST )
		{
			if ( mysql_query(sqldb->con
				,__Format("CREATE DATABASE IF NOT EXISTS %s",dbname)) )
				__Raise_Format(C_ERROR_IO
				,("failed to create database %s: %s"
				,dbname,mysql_error(sqldb->con)));
		}
		else if ( kind == XDDB_OPEN_EXISTING || kind == XDDB_OPEN_READONLY )
		{
			; /* nothing */
		}
		if ( mysql_select_db(sqldb->con,dbname) )
			__Raise_Format(C_ERROR_IO
			,("failed to select database %s: %s"
			,dbname,mysql_error(sqldb->con)));
		if ( mysql_query(sqldb->con
			,__Format("CREATE TABLE IF NOT EXISTS %s_XDDB_INFO "
			"( name varchar(128) UNIQUE, value varchar(128) )"
			,sqldb->dbpfx)) )
			__Raise_Format(C_ERROR_IO
			,("failed to create INFO table: %s"
			,mysql_error(sqldb->con)));
		if ( mysql_query(sqldb->con
			,__Format("SELECT value FROM %s_XDDB_INFO"
			" WHERE name = 'doc_format'"
			,sqldb->dbpfx)) )
			__Raise_Format(C_ERROR_IO
			,("failed to query doc format: %s"
			,mysql_error(sqldb->con)));
		else
		{
			MYSQL_RES *rset;
			MYSQL_ROW row;
			__Mysql_Results(sqldb->con,rset)
			{
				if (( row = mysql_fetch_row(rset) ))
					format = Str_To_Int(*row);
				else
					if ( mysql_query(sqldb->con
						,__Format("INSERT INTO %s_XDDB_INFO VALUES" 
						" ('doc_format','%d')"
						,sqldb->dbpfx,format)) )
						__Raise_Format(C_ERROR_IO
						,("failed to set doc format: %s"
						,mysql_error(sqldb->con)));
			}
		}

		ret = Xddbsql_Init(sqldb,format,source);
	}

	return ret;
}
#endif
;

#endif /* C_once_694F4096_7219_47D5_8C2F_7456AB482DDB */
