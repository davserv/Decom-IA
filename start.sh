#!/bin/bash
set -e

echo "Iniciando..."

cat << "EOF"

████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █

             TERMINAL AI CHAT

EOF

git clone https://github.com/davserv/Decom-IA.git

cd Decom-IA

clear

echo "EDITAR O ARQUIVO chat.sh PARA CONFIGURAR SUA API KEY, URL E MODELO"

echo "EXECUTE O COMANDO ABAIXO PARA INICIAR O CHAT"

echo "chmod +x chat.sh && ./chat.sh"