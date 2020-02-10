
#!/bin/bash
cat << "INFO"

▬▬▬.◙.▬▬▬
═▂▄▄▓▄▄▂ 
◢◤ █▀▀████▄▄▄▄◢◤ 
█▄ █ █▄ ███▀▀▀▀▀▀▀╬ 
◥█████◤
══╩══╩═
╬═╬
╬═╬
╬═╬
╬═╬
╬═╬    DNS List V.1.0
╬═╬    hackingyseguridad.com
╬═╬⛑/ 
╬═╬/▌ 
╬═╬/  \

INFO
if [ -z "$1" ]; then
        echo
        echo "Descubre subdominios.. "
        echo "Uso: $0 <dominio.com>"
        exit 0
fi
echo
echo "==========================================="
echo "| Subdominios de: " $1 " |"
echo "==========================================="
echo

for n in `cat subdominios.txt`

do
        fqdn=$n"."$1
if host $fqdn > /dev/null
then echo $fqdn && echo $fqdn >> resultado.txt
fi

done
