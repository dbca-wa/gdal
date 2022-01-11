#!/bin/bash

BASE_IMAGE=tomcat:9.0-jdk11-openjdk-slim-buster

action="$1"
env="$2"
debug="False"

if [[ "$env" = "prod" ]]; then
    tag="$3"
	if [[ "$tag" = "" ]]; then
		echo "Version tag is missing"
    	exit 1
	fi
    disttype="release"
    debug="False"
elif [[ "$env" = "uat" ]]; then
	tag="latest"
    disttype="dev"
    debug="True"
elif [[ "$env" = "dev" ]]; then
	tag="dev"
    disttype="dev"
    debug="True"
elif [[ "$env" = "" ]]; then
    echo "Please choose the environment where the image will be running? release , uat or dev"
    exit 1
else
    echo "Only release, uat and dev environment are supported."
    exit 1
fi

echo "Begin to build geoserver with tag '${tag}' for '$env' environment"


if [[ "$action" = "all" ]] || [[ "$action" = "build"  ]]; then
  	#docker image build -t dbcawa/geoserver:${tag} -f Dockerfile .
    docker image build -t ghcr.io/dbca-wa/borgslave-sync:${tag} --build-arg CACHEBUST=$(date +%s) --build-arg BASE_IMAGE=tomcat:9.0-jdk11-openjdk-slim-buster --build-arg TARGET_ARCH=linux/arm -f Dockerfile .
    if [[ $? -ne 0 ]]; then
    	echo "Build docker image failed"
    	exit 1
    fi
fi

if [[ "$action" = "all" ]] || [[ "$action" = "push"  ]]; then
    pass show docker-credential-helpers/Z2hjci5pbw==/rockychen-dpaw | docker login ghcr.io -u rockychen-dpaw --password-stdin
    
    docker push ghcr.io/dbca-wa/borgslave-sync:${tag}
    if [[ $? -ne 0 ]]; then
    	echo "Failed to push imgage to github"
    	exit 1
    fi
    echo "Succeed to publish imgage to github"
    echo "Please logon to the docker runtime server to run the image "
fi

