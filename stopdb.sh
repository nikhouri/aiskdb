#!/bin/bash
session="aiskdb"

tmux send-keys -t $session:tick '\\' C-m
tmux send-keys -t $session:hdb '\\' C-m
tmux send-keys -t $session:wdb '\\' C-m
tmux send-keys -t $session:chainedtick '\\' C-m
tmux send-keys -t $session:chainedrdb '\\' C-m
tmux send-keys -t $session:rte '\\' C-m
tmux send-keys -t $session:gw '\\' C-m
tmux send-keys -t $session:aisfeed 'quit()' C-m

tmux kill-session -t $session