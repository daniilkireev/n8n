#!/usr/bin/env bash
#
# n8n_export_prod.sh
# Экспорт workflows с тегом "prod" из n8n в локальную директорию
#
set -euo pipefail

# Директория скрипта (для относительных путей)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/n8n.prod.workflow"

# Загружаем .env СНАЧАЛА (до использования переменных)
if [ -f "$SCRIPT_DIR/.env" ]; then
  # shellcheck disable=SC1091
  set -a  # автоматически экспортировать все переменные
  source "$SCRIPT_DIR/.env"
  set +a
fi

### НАСТРОЙКИ (берём из .env или используем значения по умолчанию)
N8N_URL="${N8N_URL:-http://192.168.1.60:5678}"
N8N_API_KEY="${N8N_API_KEY:-}"
PROD_TAG_NAME="${PROD_TAG_NAME:-prod}"  # Тег для фильтрации (prod, dev, bak и т.п.)

### ПРОВЕРКИ

# Проверяем наличие API ключа
if [ -z "$N8N_API_KEY" ]; then
  echo "[ERROR] N8N_API_KEY не задан!" >&2
  echo "" >&2
  echo "Способы задать ключ:" >&2
  echo "  1. Добавить в .env: N8N_API_KEY=ваш-ключ" >&2
  echo "  2. Экспортировать: export N8N_API_KEY=ваш-ключ" >&2
  echo "  3. Передать при запуске: N8N_API_KEY=ваш-ключ ./n8n_export_prod.sh" >&2
  echo "" >&2
  echo "Создать API ключ: n8n → Settings → API → Create API Key" >&2
  exit 1
fi

# Проверяем наличие jq
if ! command -v jq &> /dev/null; then
  echo "[ERROR] jq не установлен. Установите: sudo apt install jq" >&2
  exit 1
fi

# Проверяем наличие curl
if ! command -v curl &> /dev/null; then
  echo "[ERROR] curl не установлен. Установите: sudo apt install curl" >&2
  exit 1
fi

### ФУНКЦИИ

api_call() {
  local endpoint="$1"
  curl -s -f -X GET "${N8N_URL}/api/v1${endpoint}" \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    -H "Accept: application/json"
}

sanitize_filename() {
  # Заменяем небезопасные символы на подчёркивание
  echo "$1" | sed 's/[^a-zA-Z0-9._-]/_/g'
}

### ОСНОВНОЙ КОД

echo "========================================"
echo "  n8n Workflow Export Script"
echo "========================================"
echo ""
echo "[INFO] n8n URL: $N8N_URL"
echo "[INFO] Целевая папка: $EXPORT_DIR"
echo "[INFO] Фильтр по тегу: $PROD_TAG_NAME"
echo ""

# Проверяем доступность n8n
echo "[INFO] Проверка подключения к n8n..."
if ! curl -s -f -o /dev/null "${N8N_URL}/healthz" 2>/dev/null; then
  # Пробуем альтернативный endpoint
  if ! api_call "/workflows?limit=1" > /dev/null 2>&1; then
    echo "[ERROR] Не удалось подключиться к n8n по адресу $N8N_URL" >&2
    echo "[ERROR] Проверьте URL и API ключ" >&2
    exit 1
  fi
fi
echo "[OK] Подключение успешно"
echo ""

# Создаём директорию если нет
mkdir -p "$EXPORT_DIR"

# 1. Получаем список всех тегов для информации
echo "[INFO] Доступные теги в n8n:"
TAGS_RESPONSE=$(api_call "/tags" 2>/dev/null || echo '{"data":[]}')
echo "$TAGS_RESPONSE" | jq -r '.data[] | "  - \(.name) (ID: \(.id))"' 2>/dev/null || echo "  - нет тегов -"
echo ""

# 2. Получаем список всех workflows
echo "[INFO] Получение списка workflows..."
WORKFLOWS_RESPONSE=$(api_call "/workflows")

# Фильтруем по тегу
FILTERED_WORKFLOWS=$(echo "$WORKFLOWS_RESPONSE" | jq --arg tag "$PROD_TAG_NAME" '[.data[] | select(.tags[]?.name == $tag)]')
WORKFLOW_COUNT=$(echo "$FILTERED_WORKFLOWS" | jq 'length')

echo "[OK] Найдено workflows с тегом '$PROD_TAG_NAME': $WORKFLOW_COUNT"
echo ""

if [ "$WORKFLOW_COUNT" -eq 0 ]; then
  echo "[WARN] Нет workflows с тегом '$PROD_TAG_NAME'"
  echo ""
  echo "[INFO] Все workflows в системе:"
  echo "$WORKFLOWS_RESPONSE" | jq -r '.data[] | "  - \(.name) [tags: \(.tags | map(.name) | join(", "))]"'
  exit 0
fi

# 3. Экспортируем каждый workflow
echo "[INFO] Начинаем экспорт..."
echo "----------------------------------------"

EXPORTED=0
FAILED=0

echo "$FILTERED_WORKFLOWS" | jq -c '.[]' | while read -r workflow; do
  WF_ID=$(echo "$workflow" | jq -r '.id')
  WF_NAME=$(echo "$workflow" | jq -r '.name')
  
  # Санитизируем имя файла и добавляем ID для уникальности
  SAFE_NAME=$(sanitize_filename "$WF_NAME")
  # Используем короткий ID (первые 8 символов) для уникальности имени файла
  SHORT_ID="${WF_ID:0:8}"
  OUTPUT_FILE="$EXPORT_DIR/${SAFE_NAME}.${SHORT_ID}.json"
  
  printf "  %-40s → " "$WF_NAME"
  
  # Получаем полный workflow и сохраняем
  if FULL_WORKFLOW=$(api_call "/workflows/$WF_ID" 2>/dev/null); then
    echo "$FULL_WORKFLOW" | jq '.' > "$OUTPUT_FILE"
    echo "✓ $(basename "$OUTPUT_FILE")"
    ((EXPORTED++)) || true
  else
    echo "✗ ОШИБКА"
    ((FAILED++)) || true
  fi
done

echo "----------------------------------------"
echo ""
echo "[INFO] Экспорт завершён!"
echo "[INFO] Директория: $EXPORT_DIR"
echo ""

# Показываем результат
ls -la "$EXPORT_DIR"/*.json 2>/dev/null || echo "[WARN] Нет экспортированных файлов"

echo ""
echo "========================================"
