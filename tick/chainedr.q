/ no dayend except 0#, can connect to tick.q or chainedtick.q tickerplant
/ q chainedr.q :5110 -p 5111 </dev/null >foo 2>&1 & 

/ q tick/chainedr.q [host]:port[:usr:pwd] [-p 5111] 

if[not "w"=first string .z.o;system "sleep 1"]

upd:insert

/ get the chained ticker plant port, default is 5110
.u.x:.z.x,(count .z.x)_enlist":5110"

/ end of day: clear ONLY
.u.end:{@[`.;.q.tables`.;@[;`mmsi;`g#]0#];}

/ init schema and sync up from log file
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y}

/ connect to tickerplant or chained ticker plant for (schema;(logcount;log))
.u.rep .(hopen`$":",.u.x 0)"(.u.sub[`;`];$[`m in key`.u;(`.u `m)\"`.u `i`L\";`.u `i`L])"

/ Query functions
positionHist:{[mmsiq;startTS;endTS]
    startTime:$[.z.d<`date$startTS;0Wt;.z.d>`date$startTS;-0Wt;`time$startTS];
    endTime:$[.z.d<`date$endTS;0Wt;.z.d>`date$endTS;-0Wt;`time$endTS];
    res:select from position where time>startTime,time<endTime,mmsi=mmsiq;
    delete time from res }

staticHist:{[mmsiq;startTS;endTS]
    startTime:$[.z.d<`date$startTS;0Wt;.z.d>`date$startTS;-0Wt;`time$startTS];
    endTime:$[.z.d<`date$endTS;0Wt;.z.d>`date$endTS;-0Wt;`time$endTS];
    res:select from static where time>startTime,time<endTime,mmsi=mmsiq;
    delete time from res }