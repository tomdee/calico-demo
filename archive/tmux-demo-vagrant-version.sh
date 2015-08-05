#!/bin/bash 
set -x
# Ensure the terminal is a good size
resize -s 30 120

# SSH commands for accessing the demo servers
SSH_CMD="ssh -o LogLevel=quiet -i $HOME/.ssh/vagrant -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@172.17.8.10"
CALICO1="$SSH_CMD"1
CALICO2="$SSH_CMD"2

$CALICO1 'docker rm -f $(docker ps -qa)'
$CALICO2 'docker rm -f $(docker ps -qa)'
$CALICO1 sudo systemctl stop consul etcd2
$CALICO1 'sudo rm -rf /var/lib/etcd2/*'
$CALICO1 'sudo rm -rf /tmp/consul'
$CALICO1 sudo systemctl start consul etcd2

# Supress login messages
$CALICO1 touch .hushlogin
$CALICO2 touch .hushlogin

# Start a tmux session, split the window in two and login to the server demo servers
tmux -f tmux-demo.conf new -d -s CalicoDemo -n Window "$CALICO1"
tmux split-window -d -h "$CALICO2"
tmux select-p  -t 0
