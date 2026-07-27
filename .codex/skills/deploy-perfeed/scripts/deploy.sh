#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-/Users/pavel/Dev/pets/perfeed}"
SERVER_HOST="${PERFEED_SERVER_HOST:-138.16.161.115}"
SERVER_USER="${PERFEED_SERVER_USER:-root}"
REMOTE_DIR="${PERFEED_REMOTE_DIR:-/var/www/perfeed}"
BACKUP_DIR="${PERFEED_BACKUP_DIR:-/var/www/perfeed-backups}"
NGINX_SITE="${PERFEED_NGINX_SITE:-perfeed}"
PORT="${PERFEED_PORT:-18081}"
SERVER_NAME="${PERFEED_SERVER_NAME:-138.16.161.115}"
SITE_URL="${PERFEED_SITE_URL:-http://138.16.161.115:18081}"
REQUIRE_HTTPS="${PERFEED_REQUIRE_HTTPS:-0}"
REPLACE_NGINX_CONFIG="${PERFEED_REPLACE_NGINX_CONFIG:-0}"
REMOTE="${SERVER_USER}@${SERVER_HOST}"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32mOK\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31mERROR\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<EOF
Деплой Perfeed на существующий nginx-сервер.

Использование:
  $0 [путь_к_проекту]

Необязательные переменные:
  PERFEED_PORT=18081        порт nginx и публичного URL
  PERFEED_SERVER_NAME       server_name nginx
  PERFEED_SITE_URL          URL для проверки
  PERFEED_REQUIRE_HTTPS=1  потребовать успешный HTTPS-ответ
  PERFEED_REPLACE_NGINX_CONFIG=1  перезаписать существующую nginx-конфигурацию
  PERFEED_SERVER_HOST      по умолчанию 138.16.161.115
  PERFEED_SERVER_USER      по умолчанию root
  PERFEED_REMOTE_DIR       по умолчанию /var/www/perfeed
EOF
}

need_command() { command -v "$1" >/dev/null 2>&1 || fail "Не найдена команда: $1"; }
remote_run() { ssh "$REMOTE" "$@"; }

validate_settings() {
  [[ "$SERVER_NAME" =~ ^[A-Za-z0-9.-]+$ ]] || fail 'PERFEED_SERVER_NAME содержит недопустимые символы.'
  [[ "$SITE_URL" =~ ^https?://[^[:space:]]+$ ]] || fail 'PERFEED_SITE_URL должен начинаться с http:// или https://.'
  [[ "$PORT" =~ ^[1-9][0-9]{0,4}$ && "$PORT" -le 65535 ]] || fail 'PERFEED_PORT должен быть числом от 1 до 65535.'
  [[ "$REMOTE_DIR" =~ ^/var/www/[A-Za-z0-9-]+$ ]] || fail 'PERFEED_REMOTE_DIR должен быть изолированным каталогом в /var/www/.'
  [[ "$BACKUP_DIR" =~ ^/var/www/[A-Za-z0-9-]+$ ]] || fail 'PERFEED_BACKUP_DIR должен быть каталогом в /var/www/.'
  [[ "$NGINX_SITE" =~ ^[A-Za-z0-9-]+$ ]] || fail 'PERFEED_NGINX_SITE содержит недопустимые символы.'
  [[ "$REQUIRE_HTTPS" == '0' || "$REQUIRE_HTTPS" == '1' ]] || fail 'PERFEED_REQUIRE_HTTPS должен быть 0 или 1.'
  [[ "$REPLACE_NGINX_CONFIG" == '0' || "$REPLACE_NGINX_CONFIG" == '1' ]] || fail 'PERFEED_REPLACE_NGINX_CONFIG должен быть 0 или 1.'
  if [[ "$REQUIRE_HTTPS" == '1' ]]; then
    [[ "$SITE_URL" == https://* ]] || fail 'При PERFEED_REQUIRE_HTTPS=1 URL должен начинаться с https://.'
  fi
}

check_project() {
  [[ -d "$PROJECT_DIR" ]] || fail "Каталог проекта не найден: $PROJECT_DIR"
  [[ -f "$PROJECT_DIR/package.json" ]] || fail "В каталоге проекта нет package.json: $PROJECT_DIR"
}

build_project() {
  info "Собираю проект: $PROJECT_DIR"
  (cd "$PROJECT_DIR" && npm run build)
  [[ -f "$PROJECT_DIR/dist/index.html" ]] || fail "После сборки не найден $PROJECT_DIR/dist/index.html"
  ok 'Локальная сборка готова'
}

prepare_server() {
  info "Проверяю сервер $REMOTE"
  remote_run "command -v nginx >/dev/null 2>&1 || { echo 'nginx не установлен'; exit 1; }"
  remote_run "systemctl is-active --quiet nginx || { echo 'nginx не активен; деплой не меняет состояние shared-сервиса'; exit 1; }"
  remote_run "nginx -t"
  remote_run "mkdir -p '$REMOTE_DIR' '$BACKUP_DIR'"
  ok 'Сервер готов к загрузке файлов'
}

backup_current_release() {
  info 'Создаю резервную копию текущей версии Perfeed'
  remote_run "if [ -f '$REMOTE_DIR/index.html' ]; then tar -C '$REMOTE_DIR' -czf '$BACKUP_DIR/release-'\"\$(date +%Y%m%d%H%M%S)\"'.tar.gz' .; fi"
  ok 'Предыдущая версия сохранена, если она существовала'
}

upload_dist() {
  info "Загружаю dist/ в $REMOTE:$REMOTE_DIR"
  rsync -az --delete "$PROJECT_DIR/dist/" "$REMOTE:$REMOTE_DIR/"
  remote_run "chown -R root:root '$REMOTE_DIR'"
  ok 'Файлы сайта загружены'
}

configure_nginx() {
  info 'Настраиваю отдельный nginx-сайт Perfeed'
  ssh "$REMOTE" bash -s -- "$REMOTE_DIR" "$NGINX_SITE" "$SERVER_NAME" "$PORT" "$REPLACE_NGINX_CONFIG" <<'REMOTE_SCRIPT'
set -euo pipefail
remote_dir="$1"
nginx_site="$2"
server_name="$3"
port="$4"
replace_nginx_config="$5"
config="/etc/nginx/sites-available/${nginx_site}"
temporary="${config}.new"
backup="${config}.backup-$(date +%Y%m%d%H%M%S)"

if [ -e "$config" ] && [ "$replace_nginx_config" != '1' ]; then
    nginx -t
    exit 0
fi

cat > "$temporary" <<NGINX
server {
    listen ${port};
    listen [::]:${port};
    server_name ${server_name};

    root ${remote_dir};
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX

if [ -e "$config" ]; then
    cp "$config" "$backup"
fi
mv "$temporary" "$config"
ln -sfn "$config" "/etc/nginx/sites-enabled/${nginx_site}"

if ! nginx -t; then
    if [ -e "$backup" ]; then
        mv "$backup" "$config"
    else
        rm -f "$config" "/etc/nginx/sites-enabled/${nginx_site}"
    fi
    nginx -t || true
    exit 1
fi

systemctl reload nginx
REMOTE_SCRIPT
  ok 'nginx проверен и перезагружен'
}

open_firewall() {
  info 'Проверяю firewall'
  if remote_run "command -v ufw >/dev/null 2>&1 && ufw status | grep -q '^Status: active'"; then
    remote_run "ufw allow ${PORT}/tcp >/dev/null"
    ok "ufw разрешает ${PORT}/tcp"
  else
    info 'ufw не установлен или не активен, настройка не требуется'
  fi
}

verify_site() {
  info "Проверяю сайт: $SITE_URL"
  local status
  status="$(curl -L --max-time 20 -o /dev/null -s -w '%{http_code}' "$SITE_URL" || true)"
  [[ "$status" == '200' ]] || fail "Сайт ответил HTTP ${status:-000}, ожидался 200"
  ok "Сайт доступен: $SITE_URL"
}

main() {
  if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then usage; exit 0; fi
  need_command npm; need_command ssh; need_command rsync; need_command curl
  validate_settings; check_project; build_project; prepare_server; backup_current_release
  upload_dist; configure_nginx; open_firewall; verify_site
  printf '\nГотово. Perfeed опубликован: %s\n' "$SITE_URL"
}

main "$@"
