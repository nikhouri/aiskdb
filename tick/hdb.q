/q tick/hdb.q sym -p 5012
system"l tick/aiskdb-schema.q"

if[1>count .z.x;show"Supply directory of historical database";exit 0];
hdb:.z.x 0
/Mount the Historical Date Partitioned Database
@[{system"l ",x};hdb;{show "Error message - ",x;exit 0}]

/ Query functions
positionHist:{[mmsiq;startTS;endTS]
    res:select from position where receivets within (startTS;endTS),mmsi=mmsiq;
    delete date,time from res }

staticHist:{[mmsiq;startTS;endTS]
    res:select from static where receivets within (startTS;endTS),mmsi=mmsiq;
    delete date,time from res }