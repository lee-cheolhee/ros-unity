#!/bin/bash

REPO_NAME="ghcr.io/lee-cheolhee"
PROJECT_NAME="ros-unity"

# 인자가 있으면 그 값을 TAG로 사용, 없으면 git head를 검사하여 TAG를 설정
if [ -n "$1" ]; then
    TAG="$1"
    echo "Using TAG from argument: $TAG"
else
    remote_url=$(git config --get remote.origin.url)
    git_head=$(git rev-parse --abbrev-ref HEAD)
    if [ "$git_head" == "main" ]; then
        TAG=$(git describe --tags --exact-match 2>/dev/null)
    elif [ "$git_head" == "HEAD" ]; then
        TAG=$(git describe --tags --exact-match 2>/dev/null)
    else
        TAG="develop"
    fi
fi

echo "Using TAG: $TAG"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # 기본 색상 (No Color)
echo -e "${BLUE}Branch: ${NC}$git_head"
echo -e "${GREEN}Tag: ${RED}$TAG${NC}"

src_dir=$(pwd)
workspace=$src_dir/..

# cd $workspace || true
# docker build --build-arg BUILD_TYPE=$TAG -t $REPO_NAME/$PROJECT_NAME:$TAG -f $src_dir/Dockerfile .
# docker build --build-arg BUILD_TYPE=$TAG -t $REPO_NAME/$PROJECT_NAME:$TAG -f Dockerfile .
docker build --build-arg BUILD_TYPE=$TAG --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg HOME=$HOME --build-arg USER=$USER -t $REPO_NAME/$PROJECT_NAME:latest -f $src_dir/Dockerfile .
