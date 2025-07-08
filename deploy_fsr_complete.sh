#!/bin/bash

# === ПОЛНЫЙ ДЕПЛОЙ FSR ПРОЕКТА ===
# Включает сборку Flutter Web и загрузку на сервер

set -e  # Останавливаемся при ошибке

# === НАСТРОЙКИ ===
SERVER="root@46.203.233.218"
KEY="~/.ssh/id_rsa"
LOCAL_PROJECT_PATH="/Users/h0/flutter/myapp1"
REMOTE_PROJECT_PATH="/root/myapp1"
TELEGRAM_BOT_PATH="/root/telegram_bot"

echo "🚀 Начинаем полный деплой FSR проекта..."
echo "📅 Время: $(date)"
echo "=" * 50

# === ПРОВЕРЯЕМ FLUTTER ===
echo "🔍 Проверяем Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не установлен!"
    echo "📦 Установите Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi

flutter --version
echo "✅ Flutter готов"

# === СБИРАЕМ FLUTTER WEB ===
echo "🔨 Собираем Flutter Web приложение..."
cd /Users/h0/flutter/FSR

# Очищаем предыдущую сборку
rm -rf build/web

# Собираем для production
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Flutter Web приложение собрано успешно"
    echo "📁 Размер сборки: $(du -sh build/web | cut -f1)"
else
    echo "❌ Ошибка сборки Flutter Web"
    exit 1
fi

# === КОПИРУЕМ FLUTTER WEB НА СЕРВЕР ===
echo "📤 Копируем Flutter Web на сервер..."
ssh -i $KEY $SERVER "mkdir -p /var/www/html"

# Копируем все файлы из build/web в /var/www/html на сервере
rsync -avz -e "ssh -i $KEY" --delete build/web/ $SERVER:/var/www/html/

if [ $? -eq 0 ]; then
    echo "✅ Flutter Web скопирован на сервер"
else
    echo "❌ Ошибка копирования Flutter Web"
    exit 1
fi

# === КОПИРУЕМ TELEGRAM BOT НА СЕРВЕР ===
echo "📤 Копируем Telegram Bot на сервер..."
rsync -avz -e "ssh -i $KEY" --exclude '.git' --exclude '__pycache__' --exclude '*.pyc' telegram_bot/ $SERVER:$TELEGRAM_BOT_PATH/

if [ $? -eq 0 ]; then
    echo "✅ Telegram Bot скопирован на сервер"
else
    echo "❌ Ошибка копирования Telegram Bot"
    exit 1
fi

# === УСТАНАВЛИВАЕМ ЗАВИСИМОСТИ НА СЕРВЕРЕ ===
echo "📦 Устанавливаем Python зависимости на сервере..."
ssh -i $KEY $SERVER "cd $TELEGRAM_BOT_PATH && pip3 install -r requirements.txt"

if [ $? -eq 0 ]; then
    echo "✅ Зависимости установлены"
else
    echo "❌ Ошибка установки зависимостей"
    exit 1
fi

# === ПЕРЕЗАПУСКАЕМ СЕРВИСЫ ===
echo "🔄 Перезапускаем сервисы на сервере..."

# Останавливаем сервисы
ssh -i $KEY $SERVER "systemctl stop fsr-api fsr-bot 2>/dev/null || true"

# Ждем немного
sleep 2

# Запускаем сервисы
ssh -i $KEY $SERVER "systemctl start fsr-api fsr-bot"

# Проверяем статус
echo "📊 Статус сервисов:"
ssh -i $KEY $SERVER "systemctl status fsr-api fsr-bot --no-pager -l"

# === ПРОВЕРЯЕМ РАБОТУ API ===
echo "🔍 Проверяем работу API..."
sleep 5  # Ждем запуска сервисов

API_STATUS=$(ssh -i $KEY $SERVER "curl -s -o /dev/null -w '%{http_code}' http://localhost:5000/health || echo '000'")

if [ "$API_STATUS" = "200" ]; then
    echo "✅ API работает (статус: $API_STATUS)"
else
    echo "⚠️ API может не работать (статус: $API_STATUS)"
fi

# === ПРОВЕРЯЕМ NGINX ===
echo "🔍 Проверяем nginx..."
ssh -i $KEY $SERVER "nginx -t && systemctl reload nginx"

if [ $? -eq 0 ]; then
    echo "✅ Nginx работает корректно"
else
    echo "❌ Проблемы с nginx"
fi

# === ПОКАЗЫВАЕМ ЛОГИ ===
echo "📋 Последние строки логов:"
echo "--- API Server Logs ---"
ssh -i $KEY $SERVER "journalctl -u fsr-api -n 10 --no-pager"
echo ""
echo "--- Bot Logs ---"
ssh -i $KEY $SERVER "journalctl -u fsr-bot -n 10 --no-pager"

# === ФИНАЛЬНАЯ ПРОВЕРКА ===
echo "🎯 Финальная проверка доступности:"
echo "🌐 Web App: https://fsr.agency"
echo "🔗 API Health: https://fsr.agency/health"
echo "🤖 Bot: @FSRUBOT"

# Проверяем доступность через curl
WEB_STATUS=$(curl -s -o /dev/null -w '%{http_code}' https://fsr.agency || echo '000')
HEALTH_STATUS=$(curl -s -o /dev/null -w '%{http_code}' https://fsr.agency/health || echo '000')

echo "📊 Статусы:"
echo "  Web App: $WEB_STATUS"
echo "  Health Check: $HEALTH_STATUS"

# === ЗАВЕРШЕНИЕ ===
echo ""
echo "🎉 ДЕПЛОЙ ЗАВЕРШЕН!"
echo "📅 Время завершения: $(date)"
echo ""
echo "💡 Что было сделано:"
echo "  ✅ Собрано Flutter Web приложение"
echo "  ✅ Скопирован код на сервер"
echo "  ✅ Установлены зависимости"
echo "  ✅ Перезапущены сервисы"
echo "  ✅ Проверена работа API"
echo ""
echo "🔗 Ссылки для проверки:"
echo "  🌐 https://fsr.agency"
echo "  🔗 https://fsr.agency/health"
echo "  🤖 https://t.me/FSRUBOT"
echo ""
echo "📞 Если что-то не работает, проверьте логи:"
echo "  ssh -i $KEY $SERVER 'journalctl -u fsr-api -f'"
echo "  ssh -i $KEY $SERVER 'journalctl -u fsr-bot -f'" 