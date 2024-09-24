# 🚀 FastBukkitSetup

Скрипт для быстрого развёртывания **Bukkit-подобного сервера (Spigot, Paper, Purpur, ...)**, **Bungeecord** или **Velocity**

# 💽 Что делает:
- **Обновляет пакеты** (а куда без этого?)
- Устанавливает **необходимые пакеты**
- Настраивает **файрволл** (**ufw** для Ubuntu/Debian, **firewalld** для CentOS/Rocky/Fedora):
  - Открывает 22 и 25565 порт по TCP
  - По желанию: открывает 25565 и/или 19132 по UDP
- Создаёт **нового пользователя** без ROOT доступа
- **Устанавливает Java** (версии на выбор: 8, 11, 16, 17, 21) от [Adoptium](https://adoptium.net/temurin/releases/)

# 🖥 Поддерживаемые Linux-дистрибутивы:
- **Debian-подобные:** Debian 10+, Ubuntu 20.04+
- **RedHat-подобные:** CentOS 8+, Rocky Linux, Fedora

# [💫 Мой сайт](https://drakoshaslv.ru)
