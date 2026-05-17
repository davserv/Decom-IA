#!/bin/bash
set -e

API_KEY="${CLOD_API_KEY:-API_KEY-AQUI}"
API_URL="https://API_URL-AQUI"

MODEL="MODEL-AQUI"

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
# BANNER ESTILO Decom IA
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
echo -e "${WHITE}💡 Comandos:${NC} sair | clear"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =========================
# LOOP CHAT
# =========================
while true; do

    # Prompt estilo ChatGPT
    echo -ne "${GREEN}Você${NC} ${GRAY}> ${NC}"
    read -r PERGUNTA

    # Sair
    [[ "${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && \
    echo -e "\n${GREEN}✅ Chat encerrado.${NC}\n" && break

    # Limpar tela
    [[ "${PERGUNTA,,}" =~ ^(clear|limpar)$ ]] && clear && continue

    # Ignora vazio
    [ -z "$PERGUNTA" ] && continue

    echo ""
    echo -e "${CYAN}🤖 IA está pensando...${NC}"
    echo ""

    # Requisição API
    RESPONSE=$(curl -s -X POST "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
          {
            \"role\": \"system\",
            \"content\": \"Você é um assistente inteligente estilo Decom IA no terminal.\"
          },
          {
            \"role\": \"user\",
            \"content\": \"$PERGUNTA\"
          }
        ],
        \"temperature\": 0.7,
        \"max_completion_tokens\": 6096
      }")

    # Captura resposta
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

    # Erro
    if [ -z "$RESPOSTA" ]; then
        echo -e "${RED}❌ Erro ao obter resposta.${NC}"
        echo -e "${GRAY}$RESPONSE${NC}"
        echo ""
        continue
    fi

    # Mostrar resposta
    echo -e "${BLUE}╭───────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC} ${WHITE}Decom IA${NC}"
    echo -e "${BLUE}╰───────────────────────────────╯${NC}"

    echo -e "${WHITE}$RESPOSTA${NC}"
    echo ""
done