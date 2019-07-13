URL := https://www.curseforge.com/minecraft/modpacks/omnifactory/download/2733486/file

SRCS := \
	Makefile \
	Dockerfile \
	server \
	start.sh

all: build run

run: /tmp/omnifactory $(SRCS) .build_timestamp
	docker run \
	    -ti \
		-p 25565:25565 \
		-v /tmp/omnifactory:/data \
		-e EULA=$$EULA \
		jtgans/omnifactory-server:latest

shell: $(VOLS) $(SRCS) .build_timestamp
	docker run \
		-ti \
		-p 25565:25565 \
		-v /tmp/omnifactory:/data \
		-e EULA=$$EULA \
		--entrypoint /bin/bash \
		jtgans/omnifactory-server:latest \

build: $(SRCS) .build_timestamp

push: .build_timestamp .push_timestamp

fetch: omnifactory-server.tar.gz

clean:
	rm -rf /tmp/omnifactory

mrclean: clean
	rm -f .push_timestamp .build_timestamp
	rm -f omnifactory-server.zip server

/tmp/omnifactory:
	mkdir -p $@

server:
	wget -qO omnifactory-server.zip $(URL)
	unzip -uq omnifactory-server.zip
	rm omnifactory-server.zip
	mv Omnifactory\ Server\ * server

.build_timestamp: $(SRCS)
	docker build . -t jtgans/omnifactory-server:latest
	touch .build_timestamp

.push_timestamp: .build_timestamp
	docker push jtgans/omnifactory-server:latest

.PHONY: build push run shell fetch clean mrclean
