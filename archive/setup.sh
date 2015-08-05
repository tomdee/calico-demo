#!/bin/sh 
#tmux -2 attach-session -d -t mydemo
#tmux echo "pretty realistic virtual typing in window 1" | randtype -m 1 -t 5,20000
#echo i"pretty realistic virtual typing in window 2" | randtype -m 1 -t 5,20000

session_name=mydemo
window=${session}:0
pane=${window}.0
tmux new-session -d -s ${session_name} 
tmux split-window -v -t ${session_name}
#tmux send-keys -t "$pane" C-z 'some -new command' Enter
tmux select-pane -t "$pane"
tmux select-window -t "$window"
tmux attach-session -t "$session_name"
