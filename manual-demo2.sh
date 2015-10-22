#!/usr/bin/env bash
source functions.sh
tmux set -g status-position top
status "Start the Calico agents on the hosts"
type 0 "calicoctl node"
sleep 1
type 1 "calicoctl node"
sleep 3

status "Routes are now being shared between the hosts"
sleep 1
type 0 "calicoctl status"
sleep 4

status "Start two containers without networking on the first host"
sleep 2
type 0 "docker run --net=none --name conA -tid busybox"
sleep 2
type 0 "docker run --net=none --name conB -tid busybox"
sleep 2

status "Add calico to both workloads"
sleep 2
type 0 "calicoctl container add conA 192.168.0.1"
sleep 2
type 0 "calicoctl container add conB 192.168.0.2"
sleep 2
status "And now the containers have interfaces"
sleep 2
type 0 "docker exec conA ifconfig"
sleep 3


status "The containers can't ping each other since they don't have permissions"
sleep 3
status "Create a profile - DEMO"
sleep 1
type 0 "calicoctl profile add DEMO"
sleep 3
status "And add both workloads to the profile"
sleep 2
type 0 "calicoctl container conA profile append DEMO"
sleep 2
type 0 "calicoctl container conB profile append DEMO"
sleep 3

status "And now pings work - from ConA"
sleep 1
type 0 "docker exec conA ping -c 5 192.168.0.2"
sleep 6
status "And now pings work - from ConB"
type 0 "docker exec conB ping -c 5 192.168.0.1"
sleep 6

tmux set -g status-position bottom
status "Now we add a container to the second host"
sleep 3
type 1 "docker run --net=none --name conC -tid busybox"
sleep 2
status "Give it an IP address"
sleep 1
type 1 "calicoctl container add conC 192.168.0.3"
sleep 2

status "Add it to the same profile"
sleep 1
type 1 "calicoctl container conC profile append DEMO"
sleep 2

status "And it can ping containers on the first host"
type 1 "docker exec conC ping -c 5 192.168.0.1"

sleep 8
#type 0 "exit"
#type 1 "exit"
