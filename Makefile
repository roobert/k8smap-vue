PATH  := ./node_modules/.bin:$(PATH)
SHELL := env PATH=$(PATH) /bin/bash

.DEFAULT_GOAL := serve

depends:
	npm install
	sudo npm install -g @vue/cli-service-global

serve:
	@cd src \
	&& vue serve

configure-dev:
	@cd conf \
	&& ./bin/generate-vue-config > tmp/config.mjs \
	&& ./bin/generate-nginx-config template/nginx.conf.header.node > tmp/nginx.conf.node \
	&& sudo cp nginx.conf.node /etc/nginx/sites.enable/k8smap \
	&& sudo service nginx reload

configure-prod:
	@cd conf \
	&& ./bin/generate-vue-config > tmp/config.mjs \
	&& ./bin/generate-nginx-config template/nginx.conf.header.docker > tmp/nginx.conf.docker

build-dev:
	docker build -f Dockerfile.dev -t k8smap .

run:
	docker run -i -t --rm -p=8888:80 --name=k8smap k8smap
