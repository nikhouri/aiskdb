/ q tick/gw.q :RDBPORT :HDBPORT :RTEPORT
h_rdb:hopen 5111;
h_hdb:hopen 5012;
h_rte:hopen 5200;

/ stored procedure in gateway
/ sd:start date; ed:end date; ids:list of ids or symbols
staticHist:{[mmsi;startTS;endTS]
  rdb:h_rdb(`staticHist;mmsi;startTS;endTS);
  hdb:h_hdb(`staticHist;mmsi;startTS;endTS);
  hdb,rdb }

positionHist:{[mmsi;startTS;endTS]
  rdb:h_rdb(`positionHist;mmsi;startTS;endTS);
  hdb:h_hdb(`positionHist;mmsi;startTS;endTS);
  hdb,rdb }

latest:{
  h_rte(`latest) }