#!/bin/bash

# =========================
# CONFIG GEMINI API
# =========================
API_KEY="${GEMINI_API_KEY:-SUA_API_KEY_AQUI}"

API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

MODEL="gemini-flash-latest"

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

# =========================
# LIMPAR TELA
# =========================
clear

# =========================
# BANNER
# =========================
echo -e "${GREEN}"
cat << "EOF"

████  █████  ███   ███  █   █    ███  ███
█   █ █     █     █   █ ██ ██     █  █   █
█   █ ████  █     █   █ █ █ █     █  █████
█   █ █     █     █   █ █   █     █  █   █
████  █████  ███   ███  █   █    ███ █   █

            GEMINI TERMINAL CHAT

EOF

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🤖 Modelo:${NC} ${YELLOW}$MODEL${NC}"
echo -e "${WHITE}💡 Comandos:${NC} sair | clear"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =========================
# LOOP CHAT
# =========================
while true; do

    # Prompt
    echo -ne "${GREEN}Você${NC} ${GRAY}> ${NC}"
    read -r PERGUNTA

    # SAIR
    [[ "${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && \
    echo -e "\n${GREEN}✅ Chat encerrado.${NC}\n" && break

    # CLEAR
    [[ "${PERGUNTA,,}" =~ ^(clear|limpar)$ ]] && clear && continue

    # IGNORA VAZIO
    [ -z "$PERGUNTA" ] && continue

    echo ""
    echo -e "${CYAN}🤖 Gemini está pensando...${NC}"
    echo ""

    # =========================
    # REQUISIÇÃO GEMINI API
    # =========================
    RESPONSE=$(curl -s "$API_URL" \
      -H "Content-Type: application/json" \
      -H "X-goog-api-key: $API_KEY" \
      -X POST \
      -d "{
        \"contents\": [
          {
            \"parts\": [
              {
                \"text\": \"$PERGUNTA\"
              }
            ]
          }
        ]
      }")

    # =========================
    # CAPTURA RESPOSTA
    # =========================
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // empty')

    # =========================
    # ERRO
    # =========================
    if [ -z "$RESPOSTA" ]; then
        echo -e "${RED}❌ Erro ao obter resposta.${NC}"
        echo -e "${GRAY}$RESPONSE${NC}"
        echo ""
        continue
    fi

    # =========================
    # MOSTRAR RESPOSTA
    # =========================
    echo -e "${BLUE}╭───────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC} ${WHITE}Gemini AI${NC}"
    echo -e "${BLUE}╰───────────────────────────────╯${NC}"

    echo -e "${WHITE}$RESPOSTA${NC}"
    echo ""

done