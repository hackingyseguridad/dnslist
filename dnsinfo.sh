#!/bin/bash

Negro='\033[0;30m'
Rojo='\033[0;31m'
Verde='\033[0;32m'
Amarillo='\033[0;33m'
Azul='\033[0;34m'
Purpura='\033[0;35m'
Cyan='\033[0;36m'
Blanco='\033[0;37m'
Normal='\033[0m'

cat << "INFO"
  _____  _   _  _____ _        __
 |  __ \| \ | |/ ____(_)      / _|
 | |  | |  \| | (___  _ _ __ | |_ ___
 | |  | | . ` |\___ \| | '_ \|  _/ _ \
 | |__| | |\  |____) | | | | | || (_) |
 |_____/|_| \_|_____/|_|_| |_|_| \___/
                     hackingyseguridad.con
INFO

if [ -z "$1" ]; then
        printf "${Amarillo}" ; echo
        echo "Consulta tipo any, los registros del dominio en sus dns autoritativos"
        echo "Uso: $0 <dominio.com>"; printf "${Normal}\n"
        exit 0
fi

NS="$(dig $1 ns | egrep '[[:space:]]NS[[:space:]]' | awk '{print $5}')"
echo
echo "==========================================="
echo "Servidores DNS autoritativos del dominio:" $1
echo $NS
echo "==========================================="
echo

for NSERVER in $NS
do
        printf "${Amarillo}"; host $NSERVER; printf "${Normal}\n"
        dig @$NSERVER $1 any
done
