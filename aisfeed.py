from datetime import datetime, timezone
import threading
import pyais
import pykx as kx

DEBUG = False
HOST = '153.44.253.27'
PORT = 5631
 
def epoch2dt(ts):
    dt = datetime.fromtimestamp(int(ts),tz=timezone.utc)
    return dt

def upd(table, rows):
    with kx.SyncQConnection(port=5010, wait=False) as q:
        updresult = q('.u.upd',table,rows)

def feed():
    for msg in pyais.stream.TCPConnection(HOST, port=PORT):
        receivets=datetime.now(tz=timezone.utc)

        # Skip any messages without a tag block (which happens sometimes) 
        if not msg.tag_block:
            continue

        # Globals for troubleshooting, why not
        global tags, ais, raw, update, updresult

        # Extract tags & message contents
        msg.tag_block.init()
        tags = msg.tag_block.asdict() 
        ais = msg.decode().asdict()
        raw = msg.raw.decode('UTF-8')

        # Handle each message type
        if ais['msg_type'] in (1,2,3): # Position message
            update = {
                'time': kx.toq(receivets.time()),
                'mmsi': kx.toq(ais['mmsi'],ktype=kx.LongAtom),
                'lat': kx.toq(ais['lat'],ktype=kx.FloatAtom),
                'lon': kx.toq(ais['lon'],ktype=kx.FloatAtom),
                'heading': kx.toq(ais['heading'],ktype=kx.FloatAtom),
                'speed': kx.toq(ais['speed'],ktype=kx.FloatAtom),
                'status': kx.toq(ais['status'].name,ktype=kx.SymbolAtom),
                'maneuver': kx.toq(ais['maneuver'].name,ktype=kx.SymbolAtom),
                'msgtype': kx.toq(ais['msg_type'],ktype=kx.LongAtom),
                'source': kx.toq(int(tags['source_station']),ktype=kx.LongAtom),
                'sourcets': kx.toq(epoch2dt(tags['receiver_timestamp'])),
                'receivets': kx.toq(receivets),
                'raw': kx.toq(raw,ktype=kx.CharVector)
            }
            upd('position',list(update.values()))
        elif ais['msg_type'] == 5: # Static data message
            # Shiptype is really up to 2 enums mashed together - split them out
            #   https://www.navcen.uscg.gov/ais-class-a-static-voyage-message-5
            shiptype, *shipsubtype = ais['ship_type'].name.split('_')
            shipsubtype = shipsubtype[0] if shipsubtype else None
            update = {
                'time': kx.toq(receivets.time()),
                'mmsi': kx.toq(ais['mmsi'],ktype=kx.LongAtom),
                'shipname': kx.toq(ais['shipname'],ktype=kx.CharVector),
                'callsign': kx.toq(ais['callsign'],ktype=kx.SymbolAtom),
                'shiptype': kx.toq(shiptype,ktype=kx.SymbolAtom),
                'shipsubtype': kx.toq(shipsubtype,ktype=kx.SymbolAtom),
                'destination': kx.toq(ais['destination'],ktype=kx.CharVector),
                'msgtype': kx.toq(ais['msg_type'],ktype=kx.LongAtom),
                'source': kx.toq(int(tags['source_station']),ktype=kx.LongAtom),
                'sourcets': kx.toq(epoch2dt(tags['receiver_timestamp'])),
                'receivets': kx.toq(receivets),
                'raw': kx.toq(raw,ktype=kx.CharVector)
            }
            upd('static',list(update.values()))
        
        # Show everything
        if DEBUG:
            print(str(datetime.now(tz=timezone.utc)) + ' ' + ' *** TAGS: ' + str(tags) + ' *** RAW: ' + str(raw) + ' *** MSG: ' + str(msg) + ' *** UPDATE: ' + str(update))
            print('####')

def run():
    thread = threading.Thread(target=feed)
    thread.daemon = True
    thread.start()

if __name__ == "__main__":
    run()