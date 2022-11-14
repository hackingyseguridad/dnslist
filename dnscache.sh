#!/bin/bash
# Version Beta 
# Test respuesta de los dns cache
# hacking y seguridad 2022
# Uso.: #sh dnscache.sh
#
while : ; do  dig  @80.58.0.33 +short porttest.dns-oarc.net TXT ; done
