
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
╬═╬    DNS List V.1.1
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
subfinder -d $1 --silent -o subdominios.txt
