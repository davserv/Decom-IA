#!/bin/bash

# ==========================================
# CONFIG API CEREBRAS
# ==========================================
API_KEY="${CEREBRAS_API_KEY:-csk-COLOQUE_SUA_KEY_AQUI}"
API_URL="https://api.cerebras.ai/v1/chat/completions"

MODEL="llama3.1-8b"

# ==========================================
# CORES
# ==========================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ==========================================
# VERIFICA JQ
# ==========================================
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ O jq não está instalado.${NC}"
    echo ""
    echo -e "${YELLOW}Instale com:${NC}"
    echo "sudo apt install jq"
    echo ""
    exit 1
fi

# ==========================================
# LIMPAR TELA
# ==========================================
clear

# ==========================================
# BANNER
# ==========================================
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
echo -e "${WHITE}🌐 API:${NC} ${GRAY}Cerebras${NC}"
echo -e "${WHITE}💡 Comandos:${NC} sair | clear"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ==========================================
# LOOP CHAT
# ==========================================
while true; do

    # Prompt usuário
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

    # ==========================================
    # REQUISIÇÃO API CEREBRAS
    # ==========================================
    RESPONSE=$(curl -s --location "$API_URL" \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer $API_KEY" \
      --data "{
        \"model\": \"$MODEL\",
        \"max_completion_tokens\": 1024,
        \"temperature\": 0.2,
        \"top_p\": 1,
        \"stream\": false,
        \"messages\": [
          {
            \"role\": \"user\",
            \"content\": \"$PERGUNTA\"
          }
        ]
      }")

    # ==========================================
    # CAPTURA RESPOSTA
    # ==========================================
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

    # ==========================================
    # ERRO
    # ==========================================
    if [ -z "$RESPOSTA" ]; then
        echo -e "${RED}❌ Erro ao obter resposta.${NC}"
        echo ""
        echo -e "${GRAY}$RESPONSE${NC}"
        echo ""
        continue
    fi

    # ==========================================
    # MOSTRAR RESPOSTA
    # ==========================================
    echo -e "${BLUE}╭───────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC} ${WHITE}Decom IA${NC}"
    echo -e "${BLUE}╰───────────────────────────────╯${NC}"

    echo -e "${WHITE}$RESPOSTA${NC}"
    echo ""
done