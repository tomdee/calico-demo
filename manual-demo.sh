#!/usr/bin/env bash
source functions.sh
status "Start the Calico agents on the hosts"
send 0 "calicoctl node"
send 1 "calicoctl node"
sleep 3

status "Start a container without networking on the first host - workload-A"
sleep 2
send 0 "docker run --net=none --name workload-A -tid busybox"
sleep 2

status "Start a container without networking on the second host - workload-B"
sleep 2
send 1 "docker run --net=none --name workload-B -tid busybox"
sleep 2

status "Add calico to both workloads"
sleep 2
send 0 "calicoctl container add workload-A 192.168.1.1"
send 1 "calicoctl container add workload-B 192.168.1.2"
sleep 2
status "And now the containers have interfaces"
sleep 2
send 0 "docker exec workload-A ifconfig"
send 1 "docker exec workload-B ifconfig"
sleep 3


status "The containers can't ping each other since they don't have permissions"
sleep 3
status "Create a profile - WORKLOADS"
send 0 "calicoctl profile add WORKLOADS"
sleep 3
status "And add both workloads to the profile"
sleep 2
send 0 "calicoctl container workload-A profile append WORKLOADS"
send 1 "calicoctl container workload-B profile append WORKLOADS"
sleep 3

status "And now we can ping"
sleep 1
send 0 "docker exec workload-A ping -c 5 192.168.1.2"
send 1 "docker exec workload-B ping -c 5 192.168.1.1"

sleep 8
send 0 "exit"
send 1 "exit"
