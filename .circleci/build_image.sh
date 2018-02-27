#!/bin/sh
set -xe

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 DOCKERFILE IMAGE_NAME"
  exit 2
fi

DIR=`dirname $1`
DOCKERFILE=$1
IMAGE_NAME=$2

docker build -t $IMAGE_NAME -f $DOCKERFILE $DIR

if [[ -z $CIRCLE_PULL_REQUEST ]]; then
  # Log in to Docker Hub.
  docker login -u $DOCKER_USER -p $DOCKER_PASS
  # Decide whether Docker Hub images should be tagged ":branch-Y" or ":latest".
  if [[ $CIRCLE_BRANCH != "master" ]]; then
    DOCKERHUB_TAG="branch-$CIRCLE_BRANCH"
  else
    DOCKERHUB_TAG="latest"
  fi
  docker tag $IMAGE_NAME $IMAGE_NAME:$DOCKERHUB_TAG
  docker push $IMAGE_NAME:$DOCKERHUB_TAG
fi
