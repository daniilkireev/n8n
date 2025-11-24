#!/usr/bin/env bash
set -euo pipefail

### НАСТРОЙКИ (можно подправить при необходимости)
PROJECT_DIR="/home/dkny/apps/n8n"
BACKUP_ROOT="/var/backups/n8n"

# Какие логические Docker-тома бэкапить из docker-compose.yml
LOGICAL_VOLUMES=("db_storage" "n8n_storage")

### ФУНКЦИИ

compose() {
  # Всегда используем docker compose (v2)
  docker compose "$@"
}

ensure_busybox() {
  if ! docker image inspect busybox >/dev/null 2>&1; then
    echo "[INFO] Образ busybox не найден, скачиваю..."
    docker pull busybox >/dev/null
  fi
}

### ОСНОВНОЙ КОД

echo "=== n8n backup script ==="

# Проверим, что проект существует
if [ ! -d "$PROJECT_DIR" ]; then
  echo "[ERROR] PROJECT_DIR не существует: $PROJECT_DIR" >&2
  exit 1
fi

# Создаём корневую папку для бэкапов
sudo mkdir -p "$BACKUP_ROOT"
sudo chown "$(id -u)":"$(id -g)" "$BACKUP_ROOT"

TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

echo "[INFO] Создаю папку бэкапа: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR/project" "$BACKUP_DIR/volumes"

cd "$PROJECT_DIR"

# Определяем имя проекта docker compose (по умолчанию = basename каталога)
PROJECT_NAME="${COMPOSE_PROJECT_NAME:-$(basename "$PWD")}"
echo "[INFO] PROJECT_NAME: $PROJECT_NAME"

# Чтобы при любом падении после down стек поднялся обратно:
restore_stack_on_exit() {
  echo "[INFO] Скрипт завершён (успешно или с ошибкой). Поднимаю стек n8n..."
  compose up -d >/dev/null 2>&1 || true
}
trap restore_stack_on_exit EXIT

echo "[INFO] Останавливаю стек n8n (docker compose down)..."
compose down

echo "[INFO] Копирую файлы проекта в бэкап..."

# Основные файлы проекта
cp docker-compose.yml "$BACKUP_DIR/project/" 2>/dev/null || true
cp .env "$BACKUP_DIR/project/" 2>/dev/null || true
cp init-data.sh "$BACKUP_DIR/project/" 2>/dev/null || true

# Вспомогательные каталоги (туннели и т.п.)
[ -d ssh-tunnel ] && cp -a ssh-tunnel "$BACKUP_DIR/project/"
[ -d ssh-n8n-tunnel ] && cp -a ssh-n8n-tunnel "$BACKUP_DIR/project/"

# Немного метаданных
compose config > "$BACKUP_DIR/project/docker-compose.config.yaml" 2>/dev/null || true
compose images > "$BACKUP_DIR/project/docker-images.txt" 2>/dev/null || true

ensure_busybox

echo "[INFO] Бэкаплю Docker-тома в $BACKUP_DIR/volumes ..."

for logical_name in "${LOGICAL_VOLUMES[@]}"; do
  docker_volume="${PROJECT_NAME}_${logical_name}"
  target_dir="$BACKUP_DIR/volumes/$docker_volume"

  echo "  - Том $docker_volume → $target_dir"

  if ! docker volume inspect "$docker_volume" >/dev/null 2>&1; then
    echo "    [WARN] Том $docker_volume не найден, пропускаю." >&2
    continue
  fi

  mkdir -p "$target_dir"

  docker run --rm \
    -v "${docker_volume}:/from:ro" \
    -v "${target_dir}:/to" \
    busybox sh -c "cd /from && cp -a . /to"
done

echo "[INFO] Бэкап томов завершён."

# Поднимаем стек (trap всё равно его дернёт ещё раз — это не страшно)
echo "[INFO] Поднимаю стек n8n (docker compose up -d)..."
compose up -d

echo "=== Бэкап завершён успешно. Путь к бэкапу: $BACKUP_DIR ==="
