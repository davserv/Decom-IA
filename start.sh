#!/bin/bash
set -e

echo "Instalando..."

cat << "EOF"

████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █

            ISTALLER DECOM IA

EOF

git clone https://github.com/davserv/Decom-IA.git

cd Decom-IA

sleep 10
clear

echo "EDITAR O ARQUIVO chat.sh PARA CONFIGURAR SUA API KEY, URL E MODELO"

echo "EXECUTE O COMANDO ABAIXO PARA INICIAR O CHAT"
echo ""
echo "chmod +x chat.sh && ./chat.sh"
echo ""