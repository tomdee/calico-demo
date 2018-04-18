.PHONY: create-hosts run-etcd run-consul resize create-tmux clean-hosts attach

LOCAL_IP_ENV?=$(shell ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)
CALICO1=docker exec -ti calico-01
CALICO2=docker exec -ti calico-02

busybox.tar:
	docker pull busybox:latest
	docker save --output busybox.tar busybox:latest

calico-node-v0.5.3.tar:
	docker pull calico/node:v0.5.3
	docker save --output $@ calico/node:v0.5.3

calico-node-v0.4.9.tar:
	docker pull calico/node:v0.4.9
	docker save --output $@ calico/node:v0.4.9

calicoctl:
	wget https://github.com/Metaswitch/calico-docker/releases/download/v0.5.3/calicoctl
	chmod +x calicoctl

calicoctl.v0.4.9:
	wget -O calicoctl.v0.4.9 https://github.com/Metaswitch/calico-docker/releases/download/v0.4.9/calicoctl
	chmod +x calicoctl.v0.4.9

run-etcd:
	@-docker rm -f calico-etcd
	docker run --detach \
	--net=host \
	--name calico-etcd quay.io/coreos/etcd:v2.0.11 \
	--advertise-client-urls "http://$(LOCAL_IP_ENV):2379,http://127.0.0.1:4001" \
	--listen-client-urls "http://0.0.0.0:2379,http://0.0.0.0:4001"

run-consul:
	@-docker rm -f calico-consul
	docker run --detach \
	--net=host \
	--name calico-consul progrium/consul \
	-server -bootstrap-expect 1 -client $(LOCAL_IP_ENV)

create-hosts-libnetwork: clean-hosts calicoctl calico-node-v0.5.3.tar busybox.tar run-consul run-etcd
	for NAME in calico-01 calico-02 ; do \
    docker run --name $$NAME -h $$NAME --privileged -v `pwd`:/code \
		-e LOG=file -e DOCKER_DAEMON_ARGS=--kv-store=consul:$(LOCAL_IP_ENV):8500 -e ETCD_AUTHORITY=$(LOCAL_IP_ENV):2379 \
		-tid calico/dind:dockerrestarter ; \
  done

	for TARGET in "$(CALICO1)" "$(CALICO2)" ; do \
		$$TARGET docker load --input /code/busybox.tar ; \
		$$TARGET docker load --input /code/calico-node-v0.5.3.tar ; \
		$$TARGET ln -s /code/calicoctl /usr/local/bin ; \
	done

create-hosts: clean-hosts calicoctl calico-node-v0.5.3.tar busybox.tar run-etcd
	for NAME in calico-01 calico-02 ; do \
    docker run --name $$NAME -h $$NAME --privileged -v `pwd`:/code \
		-e LOG=file -e ETCD_AUTHORITY=$(LOCAL_IP_ENV):2379 \
		-tid calico/dind:dockerrestarter ; \
  done

	for TARGET in "$(CALICO1)" "$(CALICO2)" ; do \
		$$TARGET docker load --input /code/busybox.tar ; \
		$$TARGET docker load --input /code/calico-node.tar ; \
		$$TARGET ln -s /code/calicoctl /usr/local/bin ; \
	done

create-hosts-powerstrip: clean-hosts calicoctl calico-node-v0.4.9.tar busybox.tar run-etcd
	for NAME in calico-01 calico-02 ; do \
    docker run --name $$NAME -h $$NAME --privileged -v `pwd`:/code \
		-e LOG=file -e ETCD_AUTHORITY=$(LOCAL_IP_ENV):2379 \
		-tid calico/dind:dockerrestarter ; \
  done

	for TARGET in "$(CALICO1)" "$(CALICO2)" ; do \
		$$TARGET docker load --input /code/busybox.tar ; \
		$$TARGET docker load --input /code/calico-node-v0.4.9.tar ; \
		$$TARGET ln -s /code/calicoctl.v0.4.9 /usr/local/bin/calicoctl ; \
	done

clean-hosts:
	-docker rm -f calico-01 calico-02

resize:
	# Ensure the terminal is a good size
	resize -s 40 80

create-tmux:
	# Start a tmux session, split the window in two and login to the server demo servers
	tmux -f tmux-demo.conf new -d -s CalicoDemo -n Window "$(CALICO1) bash"
	tmux split-window -d -v "$(CALICO2) bash"
	tmux select-p  -t 0
	tmux set -g window-status-current-format ""

attach: resize
	tmux a

reset-hosts-libnetwork:
	# Ideally cleaning would be able to just remove the workloads and libnetwork would remove all the data.
	# Unfortunately this doesn't work, so we jump through hoops to destroy all the datastores and restart docker.
	-$(CALICO1) docker rm -f workload-A
	-$(CALICO1) docker rm -f workload-B
	-$(CALICO1) docker rm -f workload-C
	-$(CALICO2) docker rm -f workload-D
	-$(CALICO2) docker rm -f workload-E

	-$(CALICO1) pkill docker
	-$(CALICO2) pkill docker
	make run-etcd run-consul
	sleep 5

reset-hosts:
	-$(CALICO1) docker rm -f workload-A
	-$(CALICO2) docker rm -f workload-B

	make run-etcd
