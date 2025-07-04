#!/bin/bash

# Скрипт развертывания FSR API сервера
echo "🚀 Начинаем развертывание FSR API сервера..."

# Обновляем зависимости
echo "📦 Обновляем зависимости..."
pip install -r requirements.txt

# Создаем резервную копию текущей nginx конфигурации
echo "💾 Создаем резервную копию nginx конфигурации..."
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup.$(date +%Y%m%d_%H%M%S)

# Обновляем nginx конфигурацию
echo "⚙️ Обновляем nginx конфигурацию..."
cp nginx_fsr_agency.conf /tmp/nginx_fsr_agency.conf

# Заменяем секцию fsr.agency в default конфигурации
sed -i '/server_name www.fsr.agency fsr.agency/,/^}/c\
    server {\
        root /var/www/html;\
        index index.html index.htm index.nginx-debian.html;\
        server_name www.fsr.agency fsr.agency;\
        location /api/ {\
            proxy_pass http://127.0.0.1:5000;\
            proxy_set_header Host $host;\
            proxy_set_header X-Real-IP $remote_addr;\
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
            proxy_set_header X-Forwarded-Proto $scheme;\
            proxy_connect_timeout 60s;\
            proxy_send_timeout 60s;\
            proxy_read_timeout 60s;\
            proxy_request_buffering off;\
            client_max_body_size 10M;\
        }\
        location /health {\
            proxy_pass http://127.0.0.1:5000;\
            proxy_set_header Host $host;\
            proxy_set_header X-Real-IP $remote_addr;\
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
            proxy_set_header X-Forwarded-Proto $scheme;\
        }\
        location / {\
            try_files $uri $uri/ =404;\
        }\
        listen [::]:443 ssl;\
        listen 443 ssl;\
        ssl_certificate /etc/letsencrypt/live/fsr.agency/fullchain.pem;\
        ssl_certificate_key /etc/letsencrypt/live/fsr.agency/privkey.pem;\
        include /etc/letsencrypt/options-ssl-nginx.conf;\
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;\
    }' /etc/nginx/sites-available/default

# Проверяем конфигурацию nginx
echo "🔍 Проверяем конфигурацию nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Конфигурация nginx корректна"
    
    # Перезапускаем nginx
    echo "🔄 Перезапускаем nginx..."
    systemctl reload nginx
    
    # Копируем systemd сервис
    echo "📋 Копируем systemd сервис..."
    cp fsr-api.service /etc/systemd/system/
    
    # Перезагружаем systemd
    echo "🔄 Перезагружаем systemd..."
    systemctl daemon-reload
    
    # Останавливаем старый сервис если запущен
    echo "🛑 Останавливаем старый API сервис..."
    systemctl stop fsr-api 2>/dev/null || true
    
    # Запускаем новый сервис
    echo "🚀 Запускаем API сервис..."
    systemctl enable fsr-api
    systemctl start fsr-api
    
    # Проверяем статус
    echo "📊 Проверяем статус сервисов..."
    systemctl status fsr-api --no-pager -l
    systemctl status nginx --no-pager -l
    
    echo "🎉 Развертывание завершено!"
    echo "🌐 API доступен по адресу: https://fsr.agency/api/"
    echo "💚 Health check: https://fsr.agency/health"
    
else
    echo "❌ Ошибка в конфигурации nginx!"
    echo "Восстанавливаем резервную копию..."
    cp /etc/nginx/sites-available/default.backup.* /etc/nginx/sites-available/default
    exit 1
fi 