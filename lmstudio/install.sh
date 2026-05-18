#!/bin/bash
set -e

echo "Instalando..."

curl -fsSL https://lmstudio.ai/install.sh | bash

echo "lmstudio instalado com sucesso!"

lms server start

echo "lmstudio servidor iniciado com sucesso!"

lms chat google/gemma-3-1b

echo "lmstudio gemma-3-1b instalado com sucesso!"

git clone https://github.com/davserv/Decom-IA.git

sleep 1

cd Decom-IA/lmstudio

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
echo "'cd Decom-IA/lmstudio'"
echo ""

echo "EDITAR O ARQUIVO chat.sh PARA CONFIGURAR SUA URL E MODELO"

echo "EXECUTE O COMANDO ABAIXO PARA INICIAR O CHAT"
echo ""
echo "chmod +x chat.sh && ./chat.sh"
echo ""
echo "OU STALE O DECOM-IA WEB"
echo "ENTRANDO NA PASTA DO PROJETO WEB..."
echo ""
echo "'cd Decom-IA/app'"
echo ""
echo "EXECUTE O COMANDO ABAIXO PARA INICIAR O SERVIDOR WEB"
echo ""
echo "pip install flask requests"
echo "python app.py"
echo ""