#!/bin/bash
set -e
echo "Create git mirror volume"

docker volume remove gitmirror_volume||true
docker plugin install ashald/docker-volume-loopback  --grant-all-permissions || true
docker volume create -d ashald/docker-volume-loopback gitmirror_volume \
-o sparse=true -o fs=ext4 -o size=512MiB \
-o uid=1000 -o gid=1000 

docker rm gitmirror||true

imageName="riccardoblb/gitmirror"
if [ "$BUILD_LOCAL" != "" ];
then
    docker build -t "gitmirror" .
    imageName="gitmirror"
else    
    docker pull $imageName
fi

echo "Create git mirror container for $imageName"
docker run -it --rm  \
--read-only \
--name="gitmirror" \
--mount source=gitmirror_volume,target=/wdir \
-e ACCESS_USER="$ACCESS_USER" \
-e ACCESS_TOKEN="$ACCESS_TOKEN" \
$imageName