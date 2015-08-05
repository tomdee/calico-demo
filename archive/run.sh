tmux select-pane -t mydemo:0.0

echo "# Here is a comment to run somewhere" |randtype -m 10 -t 3,20000|./nuller|xargs --null -n 1 tmux send-keys -t mydemo

tmux select-pane -t mydemo:0.1

echo "\e[31m# Here is a comment to run somewhere" |randtype -m 10 -t 3,20000|./nuller|xargs --null -n 1 tmux send-keys -t mydemo
tmux select-pane -t mydemo:0.0
echo "# Here is a comment to run somewhere" |randtype -m 10 -t 3,20000|./nuller|xargs --null -n 1 tmux send-keys -t mydemo
