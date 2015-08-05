#!/usr/bin/env bash
TMUX_PTS=`tmux list-clients |cut -d: -f 1`
send () {
tmux send-keys -t $1 "$2" Enter
}

type () {
#echo "# Here is a comment to run somewhere" |randtype -m 10 -t 3,20000|./nuller|xargs --null -n 1 tmux send-keys -t mydemo:0.1
echo "hi"
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