﻿module dpq2.args;

@safe:

public import dpq2.types.from_d_types;
public import dpq2.types.from_bson;

import dpq2;

/// Query parameters
struct QueryParams
{
    string sqlCommand; /// SQL command
    Value[] args; /// SQL command arguments
    ValueFormat resultFormat = ValueFormat.BINARY; /// Result value format

    @property void argsFromArray(in string[] arr)
    {
        args.length = arr.length;

        foreach(i, ref a; args)
            a = toValue(arr[i]);
    }

    @property string preparedStatementName() const { return sqlCommand; }
    @property void preparedStatementName(string s){ sqlCommand = s; }

    private
    {
        Oid[] oids;
        int[] formats;
        int[] lengths;
        const(ubyte)*[] values;
    }

    private void prepareArgs() pure
    {
        oids = new Oid[args.length];
        formats = new int[args.length];
        lengths = new int[args.length];
        values = new const(ubyte)* [args.length];

        for(int i = 0; i < args.length; ++i)
        {
            oids[i] = args[i].oidType;
            formats[i] = args[i].format;

            if(!args[i].isNull)
            {
                lengths[i] = args[i].data.length.to!int;
                values[i] = args[i].data.ptr;
            }
        }
    }

    package:

    /// used by PQexecParams-like functions
    const(char)* command() pure const
    {
        return cast(const(char)*) sqlCommand.toStringz;
    }

    /// ditto
    int nParams() pure const
    {
        return args.length.to!int;
    }

    /// ditto
    int paramResultFormat() pure
    {
        return resultFormat.to!int;
    }

    /// ditto
    Oid* paramTypes() pure
    {
        prepareArgs();
        return oids.ptr;
    }

    /// ditto
    const(ubyte)** paramValues() pure
    {
        prepareArgs();
        return values.ptr;
    }

    /// ditto
    int* paramLengths() pure
    {
        prepareArgs();
        return lengths.ptr;
    }

    /// ditto
    int* paramFormats() pure
    {
        prepareArgs();
        return formats.ptr;
    }
}
