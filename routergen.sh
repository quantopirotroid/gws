#!/bin/bash

SCR=$0
VERSION="v0.94ba"

echo "Вас приветствует скрипт создания конфигурации маршрутизаторов ${SCR} ${VERSION}. By Quantum labs. 2016"
echo "Нажмитe любую клавишу, чтобы продолжить."
read -n1

echo "Пожалуйста, введите название ключа vpn."
read NAME

echo "а теперь, введите номер салона."
read NUM

echo "Какую внутреннюю адресацию сетей вы хотите использовать?"
echo '192.168.X.0/24 - введите цифру "1"'
echo '10.20.X.0/24 - введитe цефру "2"'
echo '10.50.X.0/24 - введитe цефру "3"'

read -n1 COMPARE

if [[ ${COMPARE} == 1 ]]; then
    echo 'Введите предпоследний октет сети (192.168."это нужно ввести 0-255".0/24)'
    read OKT
    NET_00="192.168.${OKT}."
    AREA=${NUM}
elif [[ ${COMPARE} == 2 ]]; then
    NET_00="10.20.${NUM}."
    AREA=${NUM}
elif [[ ${COMPARE} == 3 ]]; then
    NET_00="10.50.${NUM}."
    AREA=$((${NUM}+1000))
else
    echo "Вы допустили ошибку. Завершение работы скрипта"
    exit 1

fi

NET_20="172.20.${NUM}."
NET_21="172.21.${NUM}."
NET_22="172.22.${NUM}."
ROOT="/opt/scripts"
SRC="${ROOT}/var/src/routergen/default"
TMP="${ROOT}/tmp/routergen/"
DST="${ROOT}/var/export/routergen/"
DATE=$(date +%Y-%m-%d-%H-%M-%S)

if [ ! -d $DST ]; then
    mkdir -p $DST
fi

    ### Prepare ###
mkdir -p ${TMP}
cp -r ${SRC} ${TMP}${NAME}
  ### Rename previous versions ###
OLD="${DST}etc-mods.${NAME}"
if [ -f ${OLD}.tar.bz2 ]; then
    mv ${OLD}.tar.bz2 ${OLD}-${DATE}.tar.bz2
fi

  ### Proceed ###
cd ${TMP}${NAME}
  ### Edit nets ##
for i in $(find . -type f); do
    #echo $i
    sed -i "s/%HOSTNAME%/${NAME}/g;s/%NET_00%/${NET_00}/g;s/%NET_20%/${NET_20}/g;s/%NET_21%/${NET_21}/g;s/%NET_22%/${NET_22}/g;s/%NUMAREA%/${AREA}/g" $i
done
  ### Get keys ###
scp 192.168.98.172:/etc/openvpn/easy-rsa/2.0/keys/${NAME}.key etc-mods/openvpn
scp 192.168.98.172:/etc/openvpn/easy-rsa/2.0/keys/${NAME}.crt etc-mods/openvpn
  ### Pack up ###
tar -cjf ${DST}etc-mods.${NAME}.tar.bz2 * 

  ### Cleanup ###
rm -r ${TMP}

echo "Готовую и настроенную конфигурация вы можете забрать из ${DST}etc-mods.${NAME}.tar.bz2"
echo "Спасибо, что воспользовались скриптом. Удачного дня!"
