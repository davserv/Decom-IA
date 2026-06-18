#!/bin/bash

options=(
    "MultIA"
    "Ollama"
    "Gemini"
    "LMstudio"
    "Cline"
    "GitHub"
    "Cerebras"
    "Manus"
    "GGuf"
    "Funcionalidade"
    "Sair"
)

selected=0

# =========================
# CORES
# =========================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

draw_menu() {
clear
echo -e "${GREEN}"
cat << "EOF"

████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █

         MENU PRINCIPAL AI CHAT
EOF
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}      ANTES DE SELECIONAR EDITA SH ${NC} "
echo
    for i in "${!options[@]}"; do
        if [ "$i" -eq "$selected" ]; then
            echo "➜ ${options[$i]}"
        else
            echo "  ${options[$i]}"
        fi
    done
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

while true; do
    draw_menu

    read -rsn1 key

    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key

        case $key in
            "[A")
                ((selected--))
                [ $selected -lt 0 ] && selected=$((${#options[@]} - 1))
                ;;
            "[B")
                ((selected++))
                [ $selected -ge ${#options[@]} ] && selected=0
                ;;
        esac

    elif [[ $key == "" ]]; then
        break
    fi
done

clear

case "${options[$selected]}" in

    "MultIA")
        echo "Executando MultIA..."
        chmod +x ./multia/chat.sh && ./multia/chat.sh
        ;;

    "Ollama")
        echo "Executando Ollama..."
        chmod +x ./ollama/chat.sh && ./ollama/chat.sh
        ;;

    "Gemini")
        echo "Executando Gemini..."
        chmod +x ./gemini/chat.sh && ./gemini/chat.sh
        ;;

    "LMstudio")
        echo "Executando LMstudio..."
        chmod +x ./lmstudio/chat.sh && ./lmstudio/chat.sh
        ;;

    "Cline")
        echo "Executando Cline..."
        chmod +x ./cline/chat.sh && ./cline/chat.sh
        ;;

    "GitHub")
        echo "Executando GitHub..."
        chmod +x ./github/chat.sh && ./github/chat.sh
        ;;

    "Cerebras")
        echo "Executando Cerebras..."
        chmod +x ./cerebras/chat.sh && ./cerebras/chat.sh
        ;;

    "Manus")
        echo "Executando Manus..."
        chmod +x ./manus/chat.sh && ./manus/chat.sh
        ;;

    "GGuf")
        echo "Executando GGuf..."
        chmod +x ./gguf/chat.sh && ./gguf/chat.sh
        ;;

    "Funcionalidade")
        echo "Funcionalidade..."
        echo ""
        echo "https://github.com/davserv/Decom-IA"
        echo ""
        ;;

    "Sair")
        exit 0
        ;;
esac