.PHONEY: create-hosts run-etcd run-consul resize create-tmux clean-hosts attach

LOCAL_IP_ENV?=$(shell ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)
CALICO1=docker exec -ti calico-01
CALICO2=docker exec -ti calico-02

docker:
	wget https://test.docker.com/builds/Linux/x86_64/docker-1.9.0-rc1 -O docker
	chmod +x docker

calico-node-libnetwork.tar:
	docker pull calico/node-libnetwork:v0.5.0
	docker save --output $@ calico/node-libnetwork:v0.5.0

busybox.tar:
	docker pull busybox:latest
	docker save --output busybox.tar busybox:latest

calico-node-latest.tar:
#	docker pull calico/node:v0.8.0
	docker save --output $@ calico/node:v0.8.0
#	docker pull tomdee/calico-node:small
#	docker save --output $@ tomdee/calico-node:small

calico-node-v0.4.9.tar:
	docker pull calico/node:v0.4.9
	docker save --output $@ calico/node:v0.4.9

calicoctl:
	wget https://github.com/Metaswitch/calico-docker/releases/download/v0.8.0/calicoctl
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

create-hosts-libnetwork: clean-hosts calicoctl calico-node-latest.tar calico-node-libnetwork.tar busybox.tar run-etcd docker
	for NAME in calico-01 calico-02 ; do \
    docker run --name $$NAME -h $$NAME --privileged -v `pwd`:/code -v `pwd`/docker:/usr/local/bin/docker \
		-e ETCD_AUTHORITY=$(LOCAL_IP_ENV):2379 \
		-tid calico/dind:libnetwork docker daemon --storage-driver=aufs --cluster-store=etcd://$(LOCAL_IP_ENV):2379 ; \
  done

	for TARGET in "$(CALICO1)" "$(CALICO2)" ; do \
		$$TARGET docker load --input /code/busybox.tar ; \
		$$TARGET docker load --input /code/calico-node-latest.tar ; \
		$$TARGET docker load --input /code/calico-node-libnetwork.tar ; \
		$$TARGET ln -s /code/calicoctl /usr/local/bin ; \
		$$TARGET apk add toilet --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/; \
		$$TARGET sh -c "echo 'toilet -F border -f pagga $@' >/usr/local/bin/banner"; chmod +x /usr/local/bin/banner ; \
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
	tmux -f tmux-demo.conf new -d -s CalicoDemo -n Window "$(CALICO1) sh"
	tmux split-window -d -v "$(CALICO2) sh"
	tmux select-p  -t 0
	tmux set -g window-status-current-format ""

attach: resize
	tmux a

reset-hosts-libnetwork:
	-$(CALICO1) docker rm -f workload-A
	-$(CALICO2) docker rm -f workload-B
	-$(CALICO2) docker network rm calico_network

#	-$(CALICO1) pkill docker
#	-$(CALICO2) pkill docker
#	make run-etcd run-consul
#	sleep 5

reset-hosts:
	-$(CALICO1) docker rm -f conA conB conC conD conE
	-$(CALICO2) docker rm -f conA conB conC conD conE

	make run-etcd
