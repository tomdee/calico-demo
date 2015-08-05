#!/usr/bin/env bash
source functions.sh
status "Start the Calico agents on the hosts"
send 0 "calicoctl node"
send 1 "calicoctl node"
sleep 3

status "Start some containers on the first host"
sleep 2
send 0 "docker run --publish-service srvA.net1.calico --name workload-A -tid busybox"
send 0 "docker run --publish-service srvB.net2.calico --name workload-B -tid busybox"
send 0 "docker run --publish-service srvC.net1.calico --name workload-C -tid busybox"
status "These each have unique service names and are spread over two networks"
sleep 3

status "Start some containers on the second host"
sleep 2
send 1 "docker run --publish-service srvD.net3.calico --name workload-D -tid busybox"
send 1 "docker run --publish-service srvE.net1.calico --name workload-E -tid busybox"
status "Only one shares a network with the first host."
sleep 3

status "Workload-A can ping containers on the same network - srvC and srvE"
sleep 1
send 0 "docker exec workload-A ping -c 1 srvC"
send 0 "docker exec workload-A ping -c 1 srvE"
sleep 3

status "But it can't ping containers on different networks - srvB and srvD"
sleep 1
send 0 "docker exec workload-A ping -c 1 -W 1 -w 1 192.168.0.2"
send 0 "docker exec workload-A ping -c 1 -W 1 -w 1 192.168.0.4"
sleep 2

status "Both hosts share a consistent view of the networks and services"
sleep 1
send 0 "docker network ls"
send 0 "docker service ls"
send 1 "docker network ls"
send 1 "docker service ls"

sleep 3
send 0 "exit"
send 1 "exit"