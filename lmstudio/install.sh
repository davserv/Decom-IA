#!/bin/bash
set -e

echo "Instalando..."

git clone https://github.com/davserv/Decom-IA.git

sleep 1

cd Decom-IA/lmstudio

curl -fsSL https://lmstudio.ai/install.sh | bash

echo "REINICIE O SHELL OU EXECUTE O SEGUINTE COMANDO:
export PATH="/home/LOCAL/.lmstudio/bin:$PATH""

echo "EXECUTANDO O SERVIDOR LMSTUDIO..."

echo "'lms server start'"

echo "INSTALANDO O MODELO GEMMA-3-1B..."

echo "'lms chat google/gemma-3-1b'"

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