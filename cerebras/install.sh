#!/bin/bash
set -e

echo "Instalando..."

git clone https://github.com/davserv/Decom-IA.git

sleep 1

cd Decom-IA/cerebras

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
echo ""
echo "'cd Decom-IA/cerebras'"
echo ""

echo "EDITAR O ARQUIVO chat.sh PARA CONFIGURAR SUA API KEY, URL E MODELO"

echo "EXECUTE O COMANDO ABAIXO PARA INICIAR O CHAT"
echo ""
echo "chmod +x chat.sh && ./chat.sh"
echo ""