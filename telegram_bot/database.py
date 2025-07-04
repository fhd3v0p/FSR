import sqlite3
import asyncio
from datetime import datetime
from typing import Optional, List, Dict

class Database:
    def __init__(self, db_path: str = 'users.db'):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Инициализация базы данных и создание таблиц"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            
            # Таблица пользователей
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS users (
                    user_id INTEGER PRIMARY KEY,
                    username TEXT,
                    first_name TEXT,
                    last_name TEXT,
                    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    giveaway_completed BOOLEAN DEFAULT FALSE,
                    tasks_completed INTEGER DEFAULT 0
                )
            ''')
            
            # Таблица активности пользователей
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS user_activity (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER,
                    action TEXT,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users (user_id)
                )
            ''')
            
            conn.commit()
    
    async def add_user(self, user_id: int, username: Optional[str] = None, 
                      first_name: Optional[str] = None, last_name: Optional[str] = None) -> bool:
        """Добавление нового пользователя"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute('''
                    INSERT OR REPLACE INTO users (user_id, username, first_name, last_name, last_activity)
                    VALUES (?, ?, ?, ?, ?)
                ''', (user_id, username, first_name, last_name, datetime.now()))
                conn.commit()
                return True
        except Exception as e:
            print(f"Ошибка при добавлении пользователя: {e}")
            return False
    
    async def get_user(self, user_id: int) -> Optional[Dict]:
        """Получение информации о пользователе"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute('SELECT * FROM users WHERE user_id = ?', (user_id,))
                row = cursor.fetchone()
                
                if row:
                    columns = [description[0] for description in cursor.description]
                    return dict(zip(columns, row))
                return None
        except Exception as e:
            print(f"Ошибка при получении пользователя: {e}")
            return None
    
    async def update_user_activity(self, user_id: int, action: str) -> bool:
        """Обновление активности пользователя"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                
                # Обновляем время последней активности
                cursor.execute('''
                    UPDATE users SET last_activity = ? WHERE user_id = ?
                ''', (datetime.now(), user_id))
                
                # Записываем действие
                cursor.execute('''
                    INSERT INTO user_activity (user_id, action)
                    VALUES (?, ?)
                ''', (user_id, action))
                
                conn.commit()
                return True
        except Exception as e:
            print(f"Ошибка при обновлении активности: {e}")
            return False
    
    async def mark_giveaway_completed(self, user_id: int) -> bool:
        """Отметить завершение гивевея пользователем"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute('''
                    UPDATE users SET giveaway_completed = TRUE WHERE user_id = ?
                ''', (user_id,))
                conn.commit()
                return True
        except Exception as e:
            print(f"Ошибка при отметке гивевея: {e}")
            return False
    
    async def get_all_users(self) -> List[Dict]:
        """Получение всех пользователей"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute('SELECT * FROM users ORDER BY registered_at DESC')
                rows = cursor.fetchall()
                
                columns = [description[0] for description in cursor.description]
                return [dict(zip(columns, row)) for row in rows]
        except Exception as e:
            print(f"Ошибка при получении пользователей: {e}")
            return []
    
    async def get_user_stats(self) -> Dict:
        """Получение статистики пользователей"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                
                # Общее количество пользователей
                cursor.execute('SELECT COUNT(*) FROM users')
                total_users = cursor.fetchone()[0]
                
                # Пользователи, завершившие гивевей
                cursor.execute('SELECT COUNT(*) FROM users WHERE giveaway_completed = TRUE')
                completed_giveaway = cursor.fetchone()[0]
                
                # Активные пользователи за последние 7 дней
                cursor.execute('''
                    SELECT COUNT(*) FROM users 
                    WHERE last_activity > datetime('now', '-7 days')
                ''')
                active_users = cursor.fetchone()[0]
                
                return {
                    'total_users': total_users,
                    'completed_giveaway': completed_giveaway,
                    'active_users_7d': active_users
                }
        except Exception as e:
            print(f"Ошибка при получении статистики: {e}")
            return {'total_users': 0, 'completed_giveaway': 0, 'active_users_7d': 0} 