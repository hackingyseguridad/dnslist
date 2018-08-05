#!/bin/bash

if [ -z "$1" ]; then
        echo "hackingyseguridad.com 2018"
        echo "Descubre subdominios.. "
        echo "Uso: $0 <dominio.com>"
        exit 0
fi

for n in `cat subdominios.txt`

do

if host $n"."$1 > /dev/null
then echo $n"."$1
fi

done
