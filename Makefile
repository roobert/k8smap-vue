PATH  := ./node_modules/.bin:$(PATH)
SHELL := env PATH=$(PATH) /bin/bash

.DEFAULT_GOAL := node-run

# aliases

configure-all: configure node-configure docker-configure

node: configure node-configure

docker: configure docker-configure docker-build

# quick start..
node-linux: node-depends node node-install-linux node-run
node-os:    node-depends node node-install-osx   node-run

# common build targets

configure:
	./bin/generate-common-config > conf/config.common.mjs

# node build targets

node-depends:
	npm install \
	  && sudo apt install -y nginx

node-configure:
	./bin/generate-vue-config > conf/config.vue.json \
		&& ./bin/generate-nginx-config conf/template/nginx.conf.header.node > conf/nginx.conf.node

node-install-linux:
	sudo cp conf/nginx.conf.node /etc/nginx/sites-enabled/k8smap \
		&& sudo service nginx reload

node-install-osx:
	sudo cp conf/nginx.conf.node /usr/local/nginx/servers/k8smap \
		&& nginx -s reload

node-run:
	npm run serve

# docker build targets

docker-configure:
	./bin/generate-vue-config > conf/config.vue.json \
		&& ./bin/generate-nginx-config conf/template/nginx.conf.header.docker > conf/nginx.conf.docker

docker-build:
	docker build -t k8smap .

docker-run:
	docker run -i -t \
		--volume ${PWD}/conf/config.vue.json:/usr/share/nginx/html/config.vue.json \
		--volume ${PWD}/conf/nginx.conf.docker:/etc/nginx/conf.d/k8smap.conf \
		--rm -p=8888:80 \
		--name=k8smap k8smap

docker-shell:
	docker exec -it k8smap /bin/sh
