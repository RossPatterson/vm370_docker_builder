#!/bin/sh
# Script to update container repositories

TAG=2.0.0
REPO=rosspatterson

# Docker Tagging (builder, test and latest)
docker pull $REPO/vm370:$TAG

docker tag $REPO/vm370:$TAG $REPO/vm370:builder
docker push $REPO/vm370:builder

# docker tag $REPO/vm370:$TAG $REPO/vm370:test
# docker push $REPO/vm370:test

docker tag $REPO/vm370:$TAG $REPO/vm370:latest
docker push $REPO/vm370:latest
