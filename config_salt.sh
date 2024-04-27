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

read -p "Какой тип компьютера вы хотите сконфигурировать? master[1] / minion[2] >> " computer_type

if [ "$computer_type" == "1" ]; then
    read -p "Введите ip-адрес для interface (например, 127.0.0.1) >> " interface
    read -p "Введите значение для user (например, root) >> " user
    # Добавляем строки в файл /etc/salt/master.d/master.conf
    print_msg "INFO" "Конфигурация master..."
    echo "interface: $interface" | tee /etc/salt/master.d/master.conf
    echo "user: $user" | tee -a /etc/salt/master.d/master.conf
    echo "publish_port: 4505" | tee -a /etc/salt/master.d/master.conf
    echo "ret_port: 4506" | tee -a /etc/salt/master.d/master.conf
elif [ "$computer_type" == "2" ]; then
    read -p "Введите ip-адрес для master (например, localhost) >> " master
    read -p "Введите значение для user (например, root) >> " user
    read -p "Введите значение для id (например, minion-1) >> " minion_id
    # Добавляем строки в файл /etc/salt/minion.d/minion.conf
    print_msg "INFO" "Конфигурация minion..."
    echo "master: $master" | tee /etc/salt/minion.d/minion.conf
    echo "user: $user" | tee -a /etc/salt/minion.d/minion.conf
    echo "id: $minion_id" | tee -a /etc/salt/minion.d/minion.conf
else
    print_msg "ERROR" "Неверно указан тип компьютера. Допустимые значения: 1 или 2"
fi

print_msg "INFO" "Перезапуск сервисов..."
systemctl restart salt-master.service || { print_msg "ERROR" "Не удалось перезапустить salt-master.service"; }
systemctl restart salt-minion.service || { print_msg "ERROR" "Не удалось перезапустить salt-minion.service"; }
systemctl restart salt-api.service || { print_msg "ERROR" "Не удалось перезапустить salt-api.service"; }

print_msg "INFO" "Конфигурирование завершено..."
