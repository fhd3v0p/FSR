# FSR Telegram Bot

Telegram-бот для Fresh Style Russia с поддержкой Mini App, гивевеев и базы данных пользователей.

## 🚀 Возможности

- **Bot Menu Button** - кнопка "Open FSR" в меню бота
- **Inline-кнопки** - открытие Mini App прямо из чата
- **Команда /start** - приветствие с inline-кнопкой
- **Команда /giveaway** - участие в гивевее с ссылкой на папку
- **База данных** - отслеживание пользователей и их активности
- **Статистика** - для администраторов

## 📋 Требования

- Python 3.8+
- pip
- Telegram Bot Token (от @BotFather)

## 🔧 Установка

1. **Клонируйте репозиторий:**
```bash
git clone <your-repo>
cd telegram_bot
```

2. **Установите зависимости:**
```bash
pip install -r requirements.txt
```

3. **Создайте файл .env:**
```bash
cp config.py .env
```

4. **Настройте переменные в .env:**
```env
BOT_TOKEN=your_bot_token_here
WEBAPP_URL=https://FSR.agensy/
DATABASE_PATH=users.db
```

## 🤖 Получение Bot Token

1. Найдите @BotFather в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям для создания бота
4. Скопируйте полученный токен в .env файл

## 🚀 Запуск

```bash
python bot.py
```

## 📊 Команды бота

- `/start` - Запустить FSR Mini App
- `/giveaway` - Участвовать в гивевее  
- `/stats` - Статистика (только для админов)
- `/help` - Показать справку

## 🗄️ База данных

Бот автоматически создает SQLite базу данных с таблицами:

### users
- `user_id` - ID пользователя Telegram
- `username` - username пользователя
- `first_name` - имя пользователя
- `last_name` - фамилия пользователя
- `registered_at` - дата регистрации
- `last_activity` - последняя активность
- `giveaway_completed` - завершил ли гивевей
- `tasks_completed` - количество выполненных заданий

### user_activity
- `id` - уникальный ID записи
- `user_id` - ID пользователя
- `action` - действие пользователя
- `timestamp` - время действия

## 🔧 Настройка админов

В файле `bot.py` найдите строку:
```python
admin_ids = [123456789]  # Замените на ваш ID
```

Замените `123456789` на ваш Telegram ID.

## 📱 Mini App Integration

Бот интегрирован с Flutter Web App по адресу `https://FSR.agensy/`

### Inline-кнопки:
- "🌟 Open FSR" - открывает Mini App
- "📁 Подписаться на папку" - ссылка на гивевей

## 🎁 Giveaway Integration

Бот использует ссылку на Telegram-папку: `https://t.me/addlist/f3YaeLmoNsdkYjVl`

## 📈 Статистика

Команда `/stats` показывает:
- Общее количество пользователей
- Количество завершивших гивевей
- Активных пользователей за 7 дней

## 🛠️ Разработка

### Структура проекта:
```
telegram_bot/
├── bot.py          # Основной файл бота
├── config.py       # Конфигурация
├── database.py     # Работа с БД
├── requirements.txt # Зависимости
└── README.md       # Документация
```

### Добавление новых команд:

1. Создайте функцию-обработчик:
```python
@dp.message(Command("newcommand"))
async def cmd_newcommand(message: types.Message):
    # Ваш код
    pass
```

2. Добавьте команду в `set_bot_commands()`:
```python
BotCommand(command="newcommand", description="Описание команды")
```

## 🚨 Безопасность

- Храните токен бота в секрете
- Не публикуйте .env файл
- Регулярно обновляйте зависимости

## 📞 Поддержка

По вопросам обращайтесь: @FSR_Adminka 