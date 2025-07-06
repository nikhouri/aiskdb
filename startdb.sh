#!/bin/bash
# From https://how-to.dev/how-to-create-tmux-session-with-a-script

# Create DB folder if it doesn't exist
mkdir -p db/aiskdb

# Remove any .DS_Store if running on a mac
find . -name .DS_Store -exec rm -f -- {} \;

session="aiskdb"
tmux new-session -d -s $session

# Tickerplant
window=0
tmux rename-window -t $session:$window 'tick'
tmux send-keys -t $session:$window 'q tick.q aiskdb db -p 5010' C-m

# HDB
window=1
tmux new-window -t $session:$window -n 'hdb'
tmux send-keys -t $session:$window 'q tick/hdb.q db/aiskdb -p 5012' C-m

# RDB
window=2
tmux new-window -t $session:$window -n 'rdb'
tmux send-keys -t $session:$window 'q tick/rdb.q :5010 :5012 -p 5011' C-m

# Chained tickerplant
window=3
tmux new-window -t $session:$window -n 'chainedtick'
tmux send-keys -t $session:$window 'q tick/chainedtick.q :5010 -p 5110 -t 1000' C-m

# Chained RDB
window=4
tmux new-window -t $session:$window -n 'chainedrdb'
tmux send-keys -t $session:$window 'q tick/chainedrdb.q :5110 -p 5111' C-m

# RTE
window=5
tmux new-window -t $session:$window -n 'rte'
tmux send-keys -t $session:$window 'q tick/rte.q :5010 -p 5200' C-m

# GW
window=6
tmux new-window -t $session:$window -n 'gw'
tmux send-keys -t $session:$window 'q tick/gw.q -p 5114' C-m

# AIS feed
window=7
tmux new-window -t $session:$window -n 'aisfeed'
tmux send-keys -t $session:$window 'uv run python3 -i aisfeed.py' C-m

# Attach to the tmux session
tmux attach -t $session