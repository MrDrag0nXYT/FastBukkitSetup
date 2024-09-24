#!/bin/bash

check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "Скрипт должен быть запущен с правами ROOT!"
        exit 1
    fi
}

install_dependencies() {
    if command -v apt-get &> /dev/null; then
        apt update -y && apt upgrade -y
        apt install tmux nano ufw wget -y

        ufw allow 22/tcp

        ufw allow 25565/tcp
        
        read -p "Открыть порт 25565 для UDP? Это полезно для плагинов на голосовой чат, таких как PlasmoVoice. (y/n): " IS_VOICE_PLUGINS_USED
        case $IS_VOICE_PLUGINS_USED in
            [Yy]* )
                ufw allow 25565/udp
                echo "Порт 25565 для UDP открыт"
                ;;
            * )
                ;;
        esac

        read -p "Открыть порт 19132 для UDP? Это полезно для использования Geyser, чтобы игроки с Bedrock могли играть на сервере. (y/n): " IS_BEDROCK_NEED
        case $IS_BEDROCK_NEED in
            [Yy]* )
                ufw allow 19132/udp
                echo "Порт 19132 для UDP открыт"
                ;;
            * )
                ;;
        esac

        ufw enable

    elif command -v dnf &> /dev/null; then
        dnf update -y && dnf install epel-release -y
        dnf install firewalld -y
        dnf install tmux nano wget -y
        
        systemctl enable firewalld
        systemctl start firewalld

        firewall-cmd --zone=public --add-port=22/tcp --permanent
        firewall-cmd --zone=public --add-port=25565/tcp --permanent
        
        read -p "Открыть порт 25565 для UDP? Это полезно для плагинов на голосовой чат, таких как PlasmoVoice. (y/n): " IS_VOICE_PLUGINS_USED
        case $IS_VOICE_PLUGINS_USED in
            [Yy]* )
                firewall-cmd --zone=public --add-port=25565/udp --permanent
                echo "Порт 25565 для UDP открыт"
                ;;
            * )
                ;;
        esac

        read -p "Открыть порт 19132 для UDP? Это полезно для использования Geyser, чтобы игроки с Bedrock могли играть на сервере. (y/n): " IS_BEDROCK_NEED
        case $IS_BEDROCK_NEED in
            [Yy]* )
                firewall-cmd --zone=public --add-port=19132/udp --permanent
                echo "Порт 19132 для UDP открыт"
                echo "Порт открыт!"
                ;;
            * )
                ;;
        esac
        
        firewall-cmd --reload

    else
        echo "Пакетный менеджер не определен, ваш дистрибутив не поддерживается"
        exit 1
    fi
}

echo ""

check_root
install_dependencies

echo "Зависимости загружены!"

###

while true; do
    read -p "Выберите имя для нового пользователя, от которого и будет запускаться сервер: " SERVER_USER
    if [[ -n "$SERVER_USER" ]]; then
        break
    else
        echo "Имя пользователя не может быть пустым!"
    fi
done

echo "Создание пользователя $SERVER_USER"
useradd -m -s /bin/bash $SERVER_USER

mkdir /home/$SERVER_USER
chmod 700 /home/$SERVER_USER
chmod -R 700 /home/$SERVER_USER
chown -R $SERVER_USER:$SERVER_USER /home/$SERVER_USER

echo "Пользователь $SERVER_USER создан! Не забудьте установить ему пароль командой: passwd $SERVER_USER"

###

read -p "Выберите версию JAVA ( 8 / 11 / 16 / 17 / 21; ENTER - 21): " JAVA_RELEASE

cd ~

FULL_ARCHITECTURE=$(uname -m)

if [[ "$FULL_ARCHITECTURE" == "x86_64" ]]; then
    ARCH="x64"
elif [[ "$FULL_ARCHITECTURE" == "aarch64" ]]; then
    ARCH="aarch64"
else
    echo "Неизвестная архитектура: $FULL_ARCHITECTURE"
    exit 1
fi

case $JAVA_RELEASE in
    [17]* )
        URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.12%2B7/OpenJDK17U-jre_${ARCH}_linux_hotspot_17.0.12_7.tar.gz"
        FILE="OpenJDK17U-jre_${ARCH}_linux_hotspot_17.0.12_7.tar.gz"
        JRE_FOLDER_NAME="jdk-17.0.12+7-jre"
        ;;
    [16]* )
        URL="https://github.com/adoptium/temurin16-binaries/releases/download/jdk-16.0.2%2B7/OpenJDK16U-jdk_${ARCH}_linux_hotspot_16.0.2_7.tar.gz"
        FILE="OpenJDK16U-jdk_${ARCH}_linux_hotspot_16.0.2_7.tar.gz"
        JRE_FOLDER_NAME="jdk-16.0.2+7"
        ;;
    [11]* )
        URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.24%2B8/OpenJDK11U-jre_${ARCH}_linux_hotspot_11.0.24_8.tar.gz"
        FILE="OpenJDK11U-jre_${ARCH}_linux_hotspot_11.0.24_8.tar.gz"
        JRE_FOLDER_NAME="jdk-11.0.24+8-jre"
        ;;
    [8]* )
        URL="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u422-b05/OpenJDK8U-jre_${ARCH}_linux_hotspot_8u422b05.tar.gz"
        FILE="OpenJDK8U-jre_${ARCH}_linux_hotspot_8u422b05.tar.gz"
        JRE_FOLDER_NAME="jdk8u422-b05-jre"
        ;;
    * )
        URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jre_${ARCH}_linux_hotspot_21.0.4_7.tar.gz"
        FILE=OpenJDK21U-jre_${ARCH}_linux_hotspot_21.0.4_7.tar.gz""
        JRE_FOLDER_NAME="jdk-21.0.4+7-jre"
        JAVA_RELEASE=21
        ;;
esac

echo "Скачивание $FILE с URL: $URL"
wget "$URL"

echo "Распаковка $FILE..."
tar xf $FILE

rm $FILE -rf

mv $JRE_FOLDER_NAME /opt/
ln -svf /opt/$JRE_FOLDER_NAME/bin/java /usr/bin/java

echo "Проверка JAVA:"
if command -v java &> /dev/null; then
    echo "Java $JAVA_RELEASE установлена!"
    java -version
else
    echo "Java не установлена"
fi

###

echo ""
echo "Готово! Спасибо за использование скрипта."
echo " - Автор скрипта: @MrDrag0nXYT"
echo " - Мой сайт: https://drakoshaslv.ru"
echo "Сервер можно запустить командой: tmux new -s srv java -jar server.jar"
echo ""
