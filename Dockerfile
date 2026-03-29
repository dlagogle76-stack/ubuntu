FROM ubuntu:22.04

# Настройки среды
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1

# 1. Установка графики, VNC, noVNC и фикса буфера
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    autocutsel \
    novnc websockify \
    python3 git curl wget \
    dbus-x11 x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

# 2. Настройка пароля (123456)
RUN mkdir -p ~/.vnc && \
    echo "123456" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# 3. Скрипт запуска
RUN echo "#!/bin/bash\n\
vncserver -kill :1 || echo 'Fresh'\n\
autocutsel -fork\n\
autocutsel -s CLIPBOARD -fork\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
# Порт 8080 — стандарт для контейнеров на многих хостингах\n\
websockify --web /usr/share/novnc/ 8080 localhost:5901" > /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]
