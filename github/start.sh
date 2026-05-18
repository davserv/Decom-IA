#!/bin/bash
set -e

echo "Instalando..."

git clone https://github.com/davserv/Decom-IA.git

sleep 2

cd Decom-IA/github

sleep 1
clear

cat << "EOF"

████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █

            ISTALLER DECOM IA

EOF

echo "ENTRANDO NA PASTA DO PROJETO..."
echo "'cd Decom-IA/github'"

echo "EDITAR O ARQUIVO chat.sh PARA CONFIGURAR SUA API KEY, URL E MODELO"

echo "EXECUTE O COMANDO ABAIXO PARA INICIAR O CHAT"
echo ""
echo "chmod +x chat.sh && ./chat.sh"
echo ""