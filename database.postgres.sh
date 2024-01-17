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


RUNNING_DB_CONTAINER=$(docker ps -f name=$PG_USERNAME --format "{{.Names}}")

stop_db() {
  if [ "$RUNNING_DB_CONTAINER" = "$PG_USERNAME" ]; then
    docker stop $PG_USERNAME
  else
    echo "DB($PG_USERNAME) is not running"
  fi
}

start_db() {
  if [ "$RUNNING_DB_CONTAINER" != "$PG_USERNAME" ]; then
    docker run --rm --name $PG_USERNAME -d \
      -v ${PWD}/schema:/docker-entrypoint-initdb.d \
      -p $PG_PORT:$PG_PORT \
      -e POSTGRES_PASSWORD="$PG_PASSWORD" \
      -e POSTGRES_USER="$PG_USERNAME" \
      -e POSTGRES_DB="$PG_DATABASE" \
      postgres
  else
    echo "DB($PG_USERNAME) is already running."
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