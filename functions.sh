#!/usr/bin/env bash
TMUX_PTS=`tmux list-clients |cut -d: -f 1`
send () {
tmux send-keys -t $1 "$2" Enter
sleep 1
}

type () {
#echo -n "$2" |randtype -m 0 |./nuller|xargs --null -n 1 tmux send-keys -t $1
echo -n "$2" |randtype -m 0 -t 3,20000 |./nuller|xargs --null -n 1 tmux send-keys -t $1
sleep 1
tmux send-keys -t $1 Enter
}

send_bold () {
tmux dislay-message -t $1 $2
#echo -en "\e[1m$2\e[0m" >$TMUX_PTS
#tmux send-keys -t $1 Enter
#tmux send-keys -t $1 Here is another line Enter
}

status () {
tmux set -g window-status-current-format "$1"
}