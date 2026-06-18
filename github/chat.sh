#!/bin/bash

# =========================
# CONFIG API GITHUB MODELS
# =========================
API_KEY="${GITHUB_TOKEN:-ghp_SUA_API_KEY_AQUI}"
API_URL="https://models.github.ai/inference/chat/completions"

MODEL="openai/gpt-4.1-mini"

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

             TERMINAL AI CHAT

EOF

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🤖 Modelo:${NC} ${YELLOW}$MODEL${NC}"
echo -e "${WHITE}🌐 API:${NC} ${GRAY}GitHub${NC}"
echo -e "${WHITE}💡 Comandos:${NC} sair | clear"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =========================
# LOOP CHAT
# =========================
while true; do

    echo -ne "${GREEN}Você${NC} ${GRAY}> ${NC}"
    read -r PERGUNTA

    # Sair
    [[ "${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && \
    echo -e "\n${GREEN}✅ Chat encerrado.${NC}\n" && break

    # Limpar
    [[ "${PERGUNTA,,}" =~ ^(clear|limpar)$ ]] && clear && continue

    # Ignora vazio
    [ -z "$PERGUNTA" ] && continue

    echo ""
    echo -e "${CYAN}🤖 IA está pensando...${NC}"
    echo ""

    # =========================
    # REQUISIÇÃO API
    # =========================
    RESPONSE=$(curl -s -X POST "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
          {
            \"role\": \"system\",
            \"content\": \"Você é um assistente inteligente DECOM IA no terminal.\"
          },
          {
            \"role\": \"user\",
            \"content\": \"$PERGUNTA\"
          }
        ],
        \"temperature\": 1,
        \"top_p\": 1
      }")

    # =========================
    # CAPTURA RESPOSTA
    # =========================
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

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
    echo -e "${BLUE}│${NC} ${WHITE}DECOM IA${NC}"
    echo -e "${BLUE}╰───────────────────────────────╯${NC}"

    echo -e "${WHITE}$RESPOSTA${NC}"
    echo ""

done