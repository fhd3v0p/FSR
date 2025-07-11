#!/bin/bash

SERVER=46.203.233.218
SERVER_PATH=/var/www/html
LOCAL_PATH=build/web

set -e

function check_file() {
  local f=$1
  echo "  Файл: $f"
  if [ ! -f $LOCAL_PATH/$f ]; then
    echo "    ❌ Локальный файл не найден!"
    return
  fi
  local_sum=$(md5 -q $LOCAL_PATH/$f 2>/dev/null)
  server_sum=$(ssh root@$SERVER "md5sum $SERVER_PATH/$f 2>/dev/null | awk '{print \$1}'")
  echo "    Локально: $local_sum"
  echo "    На сервере: $server_sum"
  if [ "$local_sum" != "$server_sum" ]; then
    echo "    ❌ Файлы отличаются!"
  else
    echo "    ✅ Совпадает"
  fi
}

echo "1. Проверка контрольных сумм ключевых файлов:"
for f in main.dart.js index.html flutter.js; do
  check_file $f
done

echo
echo "2. Проверка наличия ключевых строк в main.dart.js на сервере:"
ssh root@$SERVER "grep -E 'totalTickets|NauryzKeds|star|rating' $SERVER_PATH/main.dart.js | head -10"

echo
echo "3. Проверка отдачи актуального файла через curl:"
curl -s -H 'Cache-Control: no-cache' https://fsr.agency/main.dart.js | grep -E 'totalTickets|NauryzKeds|star|rating' | head -10

echo
echo "4. Проверка статуса сервисов:"
ssh root@$SERVER "systemctl status fsr-api.service fsr-bot.service --no-pager"

echo
echo "5. Проверка даты и размера файлов:"
for f in main.dart.js index.html flutter.js; do
  echo "  $f:"
  ls -lh $LOCAL_PATH/$f 2>/dev/null || echo "    ❌ Локальный файл не найден!"
  ssh root@$SERVER "ls -lh $SERVER_PATH/$f 2>/dev/null || echo '    ❌ Файл не найден на сервере!'"
done 