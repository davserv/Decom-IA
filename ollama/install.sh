#!/bin/bash
set -e

echo "Instalando..."

git clone https://github.com/davserv/Decom-IA.git

sleep 1

cd Decom-IA/ollama

curl -fsSL https://ollama.com/install.sh | sh

ollama serve

clear

cat << "EOF"

████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █

            ISTALLER DECOM IA

EOF

echo "INSTALANDO O MODELO QWEN3:1.7B..."
echo ""
echo "'ollama run qwen3:1.7b'"
echo ""
echo "ENTRANDO NA PASTA DO PROJETO..."
echo ""
echo "'cd Decom-IA/ollama'"
echo ""
echo "EDITAR O ARQUIVO chat.sh PARA CONFIGURAR SUA API KEY, URL E MODELO"
echo ""
echo "EXECUTE O COMANDO ABAIXO PARA INICIAR O CHAT"
echo ""
echo "chmod +x chat.sh && ./chat.sh"
echo ""
echo "OU STALE O DECOM-IA WEB"
echo ""
echo "ENTRANDO NA PASTA DO PROJETO WEB..."
echo ""
echo "'cd app'"
echo ""
echo "EXECUTE O COMANDO ABAIXO PARA INICIAR O SERVIDOR WEB"
echo ""
echo "pip install -r requirements.txt"
echo ""
echo "python app.py"
echo ""