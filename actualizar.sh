#!/usr/bin/env bash
echo "##################################################################"
echo "... actualizando diccionarios ...  (R) 2026 hackingyseguridad.com "
echo "##################################################################"
echo
echo "...."
echo "....."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/subdominios.txt -q -O subdominios.txt  --inet4-only
wc -l subdominios.txt
echo ".."
echo "..."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/subdominios2.txt -q -O subdominios2.txt  --inet4-only
wc -l subdominios2.txt
echo "...."
echo "....."
wget https://raw.githubusercontent.com/hackingyseguridad/diccionarios/refs/heads/master/subdominios3.txt -q -O subdominios3.txt  --inet4-only
wc -l subdominios3.txt
echo "...."
echo "....."
echo

