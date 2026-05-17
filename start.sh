#!/bin/bash
set -e

echo "🚀 Iniciando..."

git clone https://github.com/davserv/Decom-IA.git

cd Decom-IA

chmod +x chat.sh && ./chat.sh