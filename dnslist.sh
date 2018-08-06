#!/bin/bash
cat << "INFO"
________    _______     _________.____     .___   ____________________
\______ \   \      \   /   _____/|    |    |   | /   _____/\__    ___/
 |    |  \  /   |   \  \_____  \ |    |    |   | \_____  \   |    |
 |    `   \/    |    \ /        \|    |___ |   | /        \  |    |
/_______  /\____|__  //_______  /|_______ \|___|/_______  /  |____|
        \/         \/         \/         \/             \/
                                                hackingyseguridad.con
INFO
if [ -z "$1" ]; then
        echo
        echo "Descubre subdominios.. "
        echo "Uso: $0 <dominio.com>"
        exit 0
fi
echo
echo "========================================="
echo "| Subdominios de " $1 " |"
echo "========================================="
echo

for n in `cat subdominios.txt`

do

if host $n"."$1 > /dev/null
then echo $n"."$1
fi

done
