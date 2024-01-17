#!/bin/sh

# 스크립트와 .env 파일이 동일한 디렉토리에 있다고 가정합니다.
ENV_FILE=".env.local"

# .env 파일에서 설정 값 로드
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "$ENV_FILE not found."
  exit 1
fi

RUNNING_DB_CONTAINER=$(docker ps -f name=$MYSQL_USERNAME --format "{{.Names}}")

stop_db() {
  if [ "$RUNNING_DB_CONTAINER" = "$MYSQL_USERNAME" ]; then
    docker stop $MYSQL_USERNAME
  else
    echo "DB($MYSQL_USERNAME) is not running"
  fi
}

start_db() {
  if [ "$RUNNING_DB_CONTAINER" != "$MYSQL_USERNAME" ]; then
    docker run --name $MYSQL_USERNAME -d \
      -v ${PWD}/schema:/docker-entrypoint-initdb.d \
      -p $MYSQL_PORT:$MYSQL_PORT \
      -e MYSQL_ROOT_PASSWORD="$MYSQL_PASSWORD" \
      -e MYSQL_USER="$MYSQL_USERNAME" \
      -d mysql:latest
  else
    echo "DB($MYSQL_USERNAME) is already running."
  fi
}

# 실행할 작업 선택
if [ "$1" = "start-db" ]; then
  start_db
elif [ "$1" = "stop-db" ]; then
  stop_db
else
  echo "Usage: ./database.sh [start-db|stop-db]"
  exit 1
fi
