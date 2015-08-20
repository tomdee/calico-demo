#!/usr/bin/env bash
source functions.sh
status "Start the Calico agents on the hosts"
send 0 'calicoctl node --ip=`ip route get 8.8.8.8 | head -1 | cut -d" " -f8`'
send 1 'calicoctl node --ip=`ip route get 8.8.8.8 | head -1 | cut -d" " -f8`'
sleep 3

status "Set DOCKER_HOST to route the Docker requests through Powerstrip"
sleep 2
send 0 "export DOCKER_HOST=localhost:2377"
send 1 "export DOCKER_HOST=localhost:2377"
sleep 2


status "Start a container on the first host - workload-A"
sleep 2
send 0 "docker run -e CALICO_IP=192.168.1.1 -e CALICO_PROFILE=WORKLOADS --name workload-A -tid busybox"
status "The container is given an IP and profile as it starts"
sleep 2

status "Start a container on the second host - workload-B"
sleep 2
send 1 "docker run -e CALICO_IP=192.168.1.2 -e CALICO_PROFILE=WORKLOADS --name workload-B -tid busybox"
status "The container is given an IP and profile as it starts"
sleep 2

status "And now the containers have interfaces"
sleep 2
send 0 "docker exec workload-A ifconfig"
send 1 "docker exec workload-B ifconfig"
sleep 3

status "And now we can ping"
sleep 1
send 0 "docker exec workload-A ping -c 5 192.168.1.2"
send 1 "docker exec workload-B ping -c 5 192.168.1.1"

sleep 8
send 0 "exit"
send 1 "exit"
