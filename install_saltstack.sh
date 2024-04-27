#!/bin/bash

# Функция выводит [INFO] и [ERROR] разными цветами
print_msg() {
    if [ "$1" == "INFO" ]; then
        echo -e "\e[32m[$1]\e[0m $2"
    elif [ "$1" == "ERROR" ]; then
        echo -e "\e[91m[$1]\e[0m $2"
    else
        echo "$1 $2"
    fi
}

print_msg "INFO" "Загрузка пакетов SaltStack..."
wget --timestamping https://repo.saltproject.io/salt/py3/redhat/9/x86_64/latest/salt-3007.0-0.x86_64.rpm -P $HOME || { print_msg "ERROR" "Ошибка при загрузке пакета salt"; }
wget --timestamping https://repo.saltproject.io/salt/py3/redhat/9/x86_64/latest/salt-master-3007.0-0.x86_64.rpm -P $HOME || { print_msg "ERROR" "Ошибка при загрузке пакета salt-master"; }
wget --timestamping https://repo.saltproject.io/salt/py3/redhat/9/x86_64/latest/salt-minion-3007.0-0.x86_64.rpm -P $HOME || { print_msg "ERROR" "Ошибка при загрузке пакета salt-minion"; }
wget --timestamping https://repo.saltproject.io/salt/py3/redhat/9/x86_64/latest/salt-api-3007.0-0.x86_64.rpm -P $HOME || { print_msg "ERROR" "Ошибка при загрузке пакета salt-api"; }

print_msg "INFO" "Добавление репозитория..."
apt-repo add "rpm http://ftp.altlinux.org/pub distributions/ALTLinux/p10/branch/x86_64 classic"

print_msg "INFO" "Обновление пакетов..."
apt-repo update

print_msg "INFO" "Установка пакета dmidecode..."
apt-get install dmidecode -y

print_msg "INFO" "Установка загруженных пакетов..."
rpm -i $HOME/salt-3007.0-0.x86_64.rpm || { print_msg "ERROR" "Не удалось установить пакет salt"; }
rpm -i $HOME/salt-master-3007.0-0.x86_64.rpm || { print_msg "ERROR" "Не удалось установить пакет salt-master"; }
rpm -i $HOME/salt-minion-3007.0-0.x86_64.rpm || { print_msg "ERROR" "Не удалось установить пакет salt-minion"; }
rpm -i $HOME/salt-api-3007.0-0.x86_64.rpm || { print_msg "ERROR" "Не удалось установить пакет salt-api"; }

print_msg "INFO" "Запуск сервисов..."
systemctl enable salt-master.service && systemctl start salt-master.service || { print_msg "ERROR" "Не удалось запустить salt-master.service"; }
systemctl enable salt-minion.service && systemctl start salt-minion.service || { print_msg "ERROR" "Не удалось запустить salt-minion.service"; }
systemctl enable salt-api.service && systemctl start salt-api.service || { print_msg "ERROR" "Не удалось запустить salt-api.service"; }

print_msg "INFO" "Установка SaltStack завершена"
