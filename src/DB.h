#ifndef DB_LAB4_DB
#define DB_LAB4_DB

#include <string>
#include <stdexcept>
#include <sql.h>
#include <sqlext.h>


class DatabaseError : public std::runtime_error {
public:
    const int err_code;
    DatabaseError(int err_code, const std::string& msg)
        : std::runtime_error(msg)
        , err_code(err_code) {};
};


class Database {

    unsigned char* dsn;
    SQLHENV h_env;
    SQLHDBC h_dbc;
    SQLHSTMT h_statement;

public:
    Database(const std::string &dsn_)
    : dsn(nullptr), h_env(nullptr)
    , h_dbc(nullptr), h_statement(nullptr) {

        dsn = new unsigned char[dsn_.size()+1];
        strcpy((char*)dsn, dsn_.c_str());

        if (SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &h_env) == SQL_ERROR) {
            throw DatabaseError(SQL_ERROR, "alloc env");
        }
        int rc = SQLSetEnvAttr(h_env,
                               SQL_ATTR_ODBC_VERSION,
                               (SQLPOINTER)SQL_OV_ODBC3,
                               0);
        if (rc != SQL_SUCCESS) {
            throw DatabaseError(rc, "set odbc version");
        }

        rc = SQLAllocHandle(SQL_HANDLE_DBC, h_env, &h_dbc);
        if (rc != SQL_SUCCESS) {
            throw DatabaseError(rc, "allocate connection");
        }

        rc = SQLDriverConnect(h_dbc,
                         nullptr,
                         dsn,
                         SQL_NTS,
                         NULL,
                         0,
                         NULL,
                         SQL_DRIVER_COMPLETE);
        if (rc != SQL_SUCCESS) {

            SQLSMALLINT iRec = 0;
            SQLINTEGER  iError;
            SQLCHAR     wszMessage[1000];
            SQLCHAR     wszState[SQL_SQLSTATE_SIZE+1];

            while (SQLGetDiagRec(SQL_HANDLE_DBC,
                                 h_dbc,
                                 ++iRec,
                                 wszState,
                                 &iError,
                                 wszMessage,
                                 (SQLSMALLINT)(sizeof(wszMessage) / sizeof(WCHAR)),
                                 (SQLSMALLINT *)NULL) == SQL_SUCCESS)
            {
                // Hide data truncated..
                if (wcsncmp((wchar_t *)wszState, L"01004", 5)) {
                    fwprintf(stderr, L"[%5.5s] %s (%d)\n", wszState, wszMessage, iError);
                }
            }
            throw DatabaseError(rc, "driver connect");
        }

        rc = SQLAllocHandle(SQL_HANDLE_STMT, h_dbc, &h_statement);
        if (rc != SQL_SUCCESS) {
            throw DatabaseError(rc, "allocate statement");
        }
    }

    ~Database() {

        delete[] dsn;

        if (h_statement) {
            SQLFreeHandle(SQL_HANDLE_STMT, h_statement);
        }

        if (h_dbc) {
            SQLDisconnect(h_dbc);
            SQLFreeHandle(SQL_HANDLE_DBC, h_dbc);
        }

        if (h_env) {
            SQLFreeHandle(SQL_HANDLE_ENV, h_env);
        }
    }

};


#endif // DB_LAB4_DB
