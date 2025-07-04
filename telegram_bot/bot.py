import asyncio
import logging
import gc
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton, BotCommand
from aiogram.utils.keyboard import InlineKeyboardBuilder

from config import BOT_TOKEN, WEBAPP_URL, GIVEAWAY_FOLDER_LINK
from database import Database
from logger import telegram_logger

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Инициализация бота и диспетчера
bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

# Инициализация базы данных
db = Database()

# Команды бота для меню
async def set_bot_commands():
    """Установка команд бота в меню"""
    commands = [
        BotCommand(command="start", description="🚀 Запустить FSR Mini App"),
        BotCommand(command="giveaway", description="🎁 Участвовать в гивевее"),
        BotCommand(command="stats", description="📊 Статистика"),
        BotCommand(command="help", description="❓ Помощь")
    ]
    await bot.set_my_commands(commands)

# Создание inline-кнопки для открытия Mini App
def get_webapp_keyboard() -> InlineKeyboardMarkup:
    """Создание inline-кнопки для открытия Mini App"""
    builder = InlineKeyboardBuilder()
    builder.add(
        InlineKeyboardButton(
            text="🌟 Open FSR",
            web_app=types.WebAppInfo(url=WEBAPP_URL)
        )
    )
    return builder.as_markup()

# Создание кнопки для гивевея
def get_giveaway_keyboard() -> InlineKeyboardMarkup:
    """Создание кнопки для гивевея"""
    builder = InlineKeyboardBuilder()
    builder.add(
        InlineKeyboardButton(
            text="📁 Подписаться на папку",
            url=GIVEAWAY_FOLDER_LINK
        )
    )
    builder.add(
        InlineKeyboardButton(
            text="🌟 Open FSR",
            web_app=types.WebAppInfo(url=WEBAPP_URL)
        )
    )
    return builder.as_markup()

@dp.message(Command("start"))
async def cmd_start(message: types.Message):
    """Обработка команды /start"""
    user_id = message.from_user.id
    username = message.from_user.username
    first_name = message.from_user.first_name
    last_name = message.from_user.last_name
    
    # Логируем действие пользователя
    await telegram_logger.log_user_action(
        user_id=user_id,
        username=username,
        first_name=first_name,
        action="Нажал кнопку /start",
        additional_info="🆕 Новый пользователь"
    )
    
    # Добавляем пользователя в базу данных
    db_success = await db.add_user(user_id, username, first_name, last_name)
    
    # Логируем результат добавления в БД
    await telegram_logger.log_database_action(
        user_id=user_id,
        action="Добавление пользователя в БД",
        success=db_success,
        details=f"Username: @{username}, Имя: {first_name}"
    )
    
    await db.update_user_activity(user_id, "start_command")
    
    # Приветственное сообщение с inline-кнопкой
    welcome_text = f"""
🌟 Добро пожаловать в **Fresh Style Russia**!

🎨 Найди своего идеального мастера для тату, маникюра, причесок и многого другого!

🚀 Нажми кнопку ниже, чтобы открыть наше приложение:
    """
    
    await message.answer(
        welcome_text,
        reply_markup=get_webapp_keyboard(),
        parse_mode="Markdown"
    )

@dp.message(Command("giveaway"))
async def cmd_giveaway(message: types.Message):
    """Обработка команды /giveaway"""
    user_id = message.from_user.id
    username = message.from_user.username
    first_name = message.from_user.first_name
    
    # Логируем действие пользователя
    await telegram_logger.log_user_action(
        user_id=user_id,
        username=username,
        first_name=first_name,
        action="Открыл гивевей",
        additional_info="🎁 Пользователь хочет участвовать в гивевее"
    )
    
    await db.update_user_activity(user_id, "giveaway_command")
    
    giveaway_text = """
🎁 **GIVEAWAY от Fresh Style Russia!**

📋 **Задания для участия:**
1️⃣ Подписаться на нашу Telegram-папку (10 каналов одним кликом)
2️⃣ Пригласить друзей

🎯 **Призы:**
• +1000 XP за подписку на папку
• +100 XP за каждого приглашенного друга

🌟 После выполнения заданий открой приложение!
    """
    
    await message.answer(
        giveaway_text,
        reply_markup=get_giveaway_keyboard(),
        parse_mode="Markdown"
    )

@dp.message(Command("stats"))
async def cmd_stats(message: types.Message):
    """Обработка команды /stats (только для админов)"""
    user_id = message.from_user.id
    username = message.from_user.username
    first_name = message.from_user.first_name
    
    # Проверяем, является ли пользователь админом (замените на ваши ID)
    admin_ids = [123456789]  # Замените на ваш ID
    
    if user_id not in admin_ids:
        await message.answer("❌ У вас нет доступа к этой команде.")
        return
    
    # Логируем действие админа
    await telegram_logger.log_user_action(
        user_id=user_id,
        username=username,
        first_name=first_name,
        action="Запросил статистику",
        additional_info="👑 Админ"
    )
    
    await db.update_user_activity(user_id, "stats_command")
    
    # Получаем статистику
    stats = await db.get_user_stats()
    
    # Логируем статистику
    await telegram_logger.log_statistics(stats)
    
    stats_text = f"""
📊 **Статистика FSR Bot:**

👥 **Всего пользователей:** {stats['total_users']}
✅ **Завершили гивевей:** {stats['completed_giveaway']}
🔥 **Активных за 7 дней:** {stats['active_users_7d']}
    """
    
    await message.answer(stats_text, parse_mode="Markdown")

@dp.message(Command("help"))
async def cmd_help(message: types.Message):
    """Обработка команды /help"""
    user_id = message.from_user.id
    username = message.from_user.username
    first_name = message.from_user.first_name
    
    # Логируем действие пользователя
    await telegram_logger.log_user_action(
        user_id=user_id,
        username=username,
        first_name=first_name,
        action="Запросил помощь",
        additional_info="❓ Пользователь нуждается в помощи"
    )
    
    await db.update_user_activity(user_id, "help_command")
    
    help_text = """
❓ **Помощь по командам:**

🚀 `/start` - Запустить FSR Mini App
🎁 `/giveaway` - Участвовать в гивевее
📊 `/stats` - Статистика (только для админов)
❓ `/help` - Показать эту справку

🌟 **Как использовать:**
1. Нажмите кнопку "Open FSR" для открытия приложения
2. Выберите свою роль (клиент или мастер)
3. Найдите идеального мастера или станьте мастером!

💬 **Поддержка:** @FSR_Adminka
    """
    
    await message.answer(help_text, parse_mode="Markdown")

@dp.message()
async def handle_all_messages(message: types.Message):
    """Обработка всех остальных сообщений"""
    user_id = message.from_user.id
    username = message.from_user.username
    first_name = message.from_user.first_name
    
    # Логируем действие пользователя
    await telegram_logger.log_user_action(
        user_id=user_id,
        username=username,
        first_name=first_name,
        action="Отправил сообщение",
        additional_info=f"💬 Текст: {message.text[:50]}{'...' if len(message.text) > 50 else ''}"
    )
    
    await db.update_user_activity(user_id, "message_sent")
    
    # Очистка памяти каждые 100 сообщений для оптимизации
    if message.message_id % 100 == 0:
        gc.collect()
        logger.info(f"🧹 Очистка памяти выполнена (сообщение #{message.message_id})")
    
    # Отправляем кнопку для открытия Mini App
    await message.answer(
        "🌟 Нажмите кнопку, чтобы открыть FSR Mini App:",
        reply_markup=get_webapp_keyboard()
    )

async def main():
    """Главная функция запуска бота"""
    logger.info("Запуск FSR Telegram Bot...")
    
    try:
        # Логируем запуск бота
        await telegram_logger.log_bot_start()
        
        # Устанавливаем команды бота
        await set_bot_commands()
        
        # Запускаем бота
        await dp.start_polling(bot)
        
    except Exception as e:
        # Логируем ошибку
        await telegram_logger.log_error(str(e), "Ошибка запуска бота")
        logger.error(f"Ошибка запуска бота: {e}")
        raise
    finally:
        # Закрываем логгер
        await telegram_logger.close()

if __name__ == "__main__":
    asyncio.run(main()) 