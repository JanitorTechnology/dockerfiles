#!/bin/bash

# Log in to Docker Hub.
docker login -u $DOCKER_USER -p $DOCKER_PASS

# Decide whether Docker Hub images should be tagged ":pull-request-X", ":branch-Y" or ":latest".
if [ ! -z $CIRCLE_PR_NUMBER ]; then
  DOCKERHUB_TAG="pull-request-$CIRCLE_PR_NUMBER"
elif [ $CIRCLE_BRANCH != "master" ]; then
  DOCKERHUB_TAG="branch-$CIRCLE_BRANCH"
else
  DOCKERHUB_TAG="latest"
fi

# Pull the `ubuntu-dev` base image from Docker Hub.
if [ $CIRCLE_JOB = "ubuntu-dev" ] || [ $DOCKERHUB_TAG = "latest" ]; then
  docker pull janx/ubuntu-dev:latest
else
  docker pull janx/ubuntu-dev:$DOCKERHUB_TAG
  docker tag janx/ubuntu-dev:$DOCKERHUB_TAG janx/ubuntu-dev:latest
fi
