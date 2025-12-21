#!/bin/sh
# Script to update container repositories

TAG=$1
REPO=rosspatterson

if [ "$TAG" = "" ] ; then
	echo "Syntax: $0 tagname"
	exit 1
fi

set -x

# Docker Tagging (builder, test and latest)
docker pull $REPO/vm370:$TAG

docker tag $REPO/vm370:$TAG $REPO/vm370:builder
docker push $REPO/vm370:builder

docker tag $REPO/vm370:$TAG $REPO/vm370:test
docker push $REPO/vm370:test

docker tag $REPO/vm370:$TAG $REPO/vm370:latest
docker push $REPO/vm370:latest
