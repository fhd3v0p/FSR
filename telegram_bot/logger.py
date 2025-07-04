import asyncio
from datetime import datetime
from typing import Optional
from aiogram import Bot
from config import BOT_TOKEN

class TelegramLogger:
    def __init__(self, chat_id: int = -4948669471):
        self.chat_id = chat_id
        self.bot = Bot(token=BOT_TOKEN)
    
    async def log_user_action(self, user_id: int, username: Optional[str], 
                            first_name: Optional[str], action: str, 
                            additional_info: str = "") -> None:
        """Логирование действий пользователя"""
        try:
            timestamp = datetime.now().strftime("%d.%m.%Y %H:%M:%S")
            
            # Форматируем сообщение
            message = f"""
🆔 **Лог действия пользователя**

👤 **Пользователь:**
• ID: `{user_id}`
• Username: @{username or 'Не указан'}
• Имя: {first_name or 'Не указано'}

⚡ **Действие:** {action}
🕐 **Время:** {timestamp}

{additional_info}
            """.strip()
            
            await self.bot.send_message(
                chat_id=self.chat_id,
                text=message,
                parse_mode="Markdown"
            )
        except Exception as e:
            print(f"Ошибка логирования: {e}")
    
    async def log_bot_start(self) -> None:
        """Логирование запуска бота"""
        try:
            timestamp = datetime.now().strftime("%d.%m.%Y %H:%M:%S")
            message = f"""
🚀 **Бот запущен!**

🆔 **Bot ID:** 8164568741
📝 **Название:** FRESH STYLE RUSSIA
🕐 **Время запуска:** {timestamp}
🌐 **WebApp URL:** https://FSR.agensy/

✅ **Бот готов к работе!**
            """.strip()
            
            await self.bot.send_message(
                chat_id=self.chat_id,
                text=message,
                parse_mode="Markdown"
            )
        except Exception as e:
            print(f"Ошибка логирования запуска: {e}")
    
    async def log_database_action(self, user_id: int, action: str, 
                                success: bool, details: str = "") -> None:
        """Логирование действий с базой данных"""
        try:
            timestamp = datetime.now().strftime("%d.%m.%Y %H:%M:%S")
            status = "✅ Успешно" if success else "❌ Ошибка"
            
            message = f"""
🗄️ **Действие с базой данных**

👤 **Пользователь ID:** `{user_id}`
⚡ **Действие:** {action}
📊 **Статус:** {status}
🕐 **Время:** {timestamp}

📝 **Детали:** {details}
            """.strip()
            
            await self.bot.send_message(
                chat_id=self.chat_id,
                text=message,
                parse_mode="Markdown"
            )
        except Exception as e:
            print(f"Ошибка логирования БД: {e}")
    
    async def log_error(self, error: str, context: str = "") -> None:
        """Логирование ошибок"""
        try:
            timestamp = datetime.now().strftime("%d.%m.%Y %H:%M:%S")
            
            message = f"""
⚠️ **Ошибка в боте**

❌ **Ошибка:** {error}
📋 **Контекст:** {context}
🕐 **Время:** {timestamp}
            """.strip()
            
            await self.bot.send_message(
                chat_id=self.chat_id,
                text=message,
                parse_mode="Markdown"
            )
        except Exception as e:
            print(f"Ошибка логирования ошибки: {e}")
    
    async def log_statistics(self, stats: dict) -> None:
        """Логирование статистики"""
        try:
            timestamp = datetime.now().strftime("%d.%m.%Y %H:%M:%S")
            
            message = f"""
📊 **Статистика FSR Bot**

👥 **Всего пользователей:** {stats.get('total_users', 0)}
✅ **Завершили гивевей:** {stats.get('completed_giveaway', 0)}
🔥 **Активных за 7 дней:** {stats.get('active_users_7d', 0)}
🕐 **Время:** {timestamp}
            """.strip()
            
            await self.bot.send_message(
                chat_id=self.chat_id,
                text=message,
                parse_mode="Markdown"
            )
        except Exception as e:
            print(f"Ошибка логирования статистики: {e}")
    
    async def close(self):
        """Закрытие соединения с ботом"""
        await self.bot.session.close()

# Создаем глобальный экземпляр логгера
telegram_logger = TelegramLogger() 