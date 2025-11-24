#!/usr/bin/env bash
set -euo pipefail

### НАСТРОЙКИ
PROJECT_DIR="/home/dkny/apps/n8n"
BACKUP_ROOT="/var/backups/n8n"
LOGICAL_VOLUMES=("db_storage" "n8n_storage")

### ФУНКЦИИ

compose() {
  docker compose "$@"
}

ensure_busybox() {
  if ! docker image inspect busybox >/dev/null 2>&1; then
    echo "[INFO] Образ busybox не найден, скачиваю..."
    docker pull busybox >/dev/null
  fi
}

### ПРОВЕРКА АРГУМЕНТОВ

if [ "$#" -ne 1 ]; then
  echo "Использование: $0 <путь_к_папке_бэкапа>" >&2
  echo "Например: $0 $BACKUP_ROOT/2025-11-22_20-45-10" >&2
  exit 1
fi

BACKUP_DIR="$1"

echo "=== n8n restore script ==="
echo "[INFO] Папка бэкапа: $BACKUP_DIR"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "[ERROR] Папка бэкапа не существует: $BACKUP_DIR" >&2
  exit 1
fi

BACKUP_PROJECT_DIR="$BACKUP_DIR/project"
BACKUP_VOLUMES_DIR="$BACKUP_DIR/volumes"

if [ ! -d "$BACKUP_PROJECT_DIR" ] || [ ! -d "$BACKUP_VOLUMES_DIR" ]; then
  echo "[ERROR] В бэкапе нет ожидаемых папок 'project' и/или 'volumes'." >&2
  exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
  echo "[ERROR] PROJECT_DIR не существует: $PROJECT_DIR" >&2
  exit 1
fi

cd "$PROJECT_DIR"

PROJECT_NAME="${COMPOSE_PROJECT_NAME:-$(basename "$PWD")}"
echo "[INFO] PROJECT_NAME: $PROJECT_NAME"

echo "[WARN] ВНИМАНИЕ: будет выполнен ПОЛНЫЙ откат к состоянию бэкапа!"
echo "       Все изменения БД и файлов проекта после момента бэкапа будут потеряны."
read -r -p "Продолжить? [yes/NO]: " answer
if [ "$answer" != "yes" ]; then
  echo "[INFO] Отменено пользователем."
  exit 0
fi

echo "[INFO] Останавливаю стек n8n (docker compose down)..."
compose down

echo "[INFO] Восстанавливаю файлы проекта из бэкапа..."

# docker-compose.yml обязателен
if [ -f "$BACKUP_PROJECT_DIR/docker-compose.yml" ]; then
  cp "$BACKUP_PROJECT_DIR/docker-compose.yml" "$PROJECT_DIR/docker-compose.yml"
else
  echo "[WARN] В бэкапе нет docker-compose.yml, пропускаю." >&2
fi

# .env, init-data.sh и вспомогательные папки
[ -f "$BACKUP_PROJECT_DIR/.env" ] && cp "$BACKUP_PROJECT_DIR/.env" "$PROJECT_DIR/.env"
[ -f "$BACKUP_PROJECT_DIR/init-data.sh" ] && cp "$BACKUP_PROJECT_DIR/init-data.sh" "$PROJECT_DIR/init-data.sh"

if [ -d "$BACKUP_PROJECT_DIR/ssh-tunnel" ]; then
  rm -rf "$PROJECT_DIR/ssh-tunnel"
  cp -a "$BACKUP_PROJECT_DIR/ssh-tunnel" "$PROJECT_DIR/"
fi

if [ -d "$BACKUP_PROJECT_DIR/ssh-n8n-tunnel" ]; then
  rm -rf "$PROJECT_DIR/ssh-n8n-tunnel"
  cp -a "$BACKUP_PROJECT_DIR/ssh-n8n-tunnel" "$PROJECT_DIR/"
fi

ensure_busybox

echo "[INFO] Восстанавливаю Docker-тома..."

for logical_name in "${LOGICAL_VOLUMES[@]}"; do
  docker_volume="${PROJECT_NAME}_${logical_name}"
  src_dir="$BACKUP_VOLUMES_DIR/$docker_volume"

  echo "  - Том $docker_volume из $src_dir"

  if [ ! -d "$src_dir" ]; then
    echo "    [WARN] В бэкапе нет папки для тома $docker_volume, пропускаю." >&2
    continue
  fi

  if docker volume inspect "$docker_volume" >/dev/null 2>&1; then
    echo "    [INFO] Удаляю существующий том $docker_volume..."
    docker volume rm "$docker_volume" >/dev/null
  fi

  echo "    [INFO] Создаю том $docker_volume..."
  docker volume create "$docker_volume" >/dev/null

  echo "    [INFO] Копирую данные в том $docker_volume..."
  docker run --rm \
    -v "${docker_volume}:/to" \
    -v "${src_dir}:/from:ro" \
    busybox sh -c "cd /from && cp -a . /to"
done

echo "[INFO] Поднимаю стек n8n (docker compose up -d)..."
compose up -d

echo "=== Восстановление завершено успешно. Текущее состояние n8n соответствует бэкапу: $BACKUP_DIR ==="
