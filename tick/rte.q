/ q tick/rte.q 
system"l tick/aiskdb-schema.q"

/ Define keyed tables
latestPosition: `mmsi xkey 0#position;
latestStatic: `mmsi xkey 0#static;

/ Update function
upd:{[t;d]
    dt:select from t; / Define temporary table w/ same schema as position or static
    dt:dt upsert d;   / Put rows results into the temporary table (easier to troubleshoot)
    if[(t~`position) and (0<count latest); / String columns are messed up if static update isn't first in latest
        `latest upsert select mmsi,lat,lon,heading,speed,status,maneuver,updated:sourcets from dt;
        `latestPosition upsert select by mmsi from dt];
    if[t~`static;
        `latest upsert select mmsi,shipname,callsign,shiptype,shipsubtype,destination,updated:sourcets from dt;
        `latestStatic upsert select by mmsi from dt]};

/ Load the last saved snapshot
$[()~key`:db/latest;system"l tick/aislatest-schema.q";latest: get `:db/latest]

/ get the chained ticker plant port, default is 5110
.u.x:.z.x,(count .z.x)_enlist":5110"

/ init schema and sync up from log file
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y}

/ connect to tickerplant or chained ticker plant for (schema;(logcount;log))
.u.rep .(hopen`$":",.u.x 0)"(.u.sub[`;`];$[`m in key`.u;(`.u `m)\"`.u `i`L\";`.u `i`L])"

/ Write the latest snapshot down
.u.end:{`:db/latest set latest}