#!/bin/bash

API_URL="http://localhost:1234/api/v1/chat"
MODEL="google/gemma-3-270m"

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
# VERIFICA JQ
# =========================
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq não instalado.${NC}"
    echo ""
    echo "Instale com:"
    echo "sudo apt install jq"
    exit 1
fi

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
echo -e "${WHITE}💡 Comandos:${NC} sair | clear"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =========================
# LOOP CHAT
# =========================
while true; do

    # PROMPT USUÁRIO
    echo -ne "${GREEN}Você${NC} ${GRAY}> ${NC}"
    read -r PERGUNTA

    # SAIR
    [[ "${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && \
    echo -e "\n${GREEN}✅ Chat encerrado.${NC}\n" && break

    # LIMPAR
    [[ "${PERGUNTA,,}" =~ ^(clear|limpar)$ ]] && clear && continue

    # IGNORA VAZIO
    [ -z "$PERGUNTA" ] && continue

    echo ""
    echo -e "${CYAN}🤖 IA está pensando...${NC}"
    echo ""

    # =========================
    # REQUISIÇÃO API
    # =========================
    RESPONSE=$(curl -sS "$API_URL" \
    -H "Authorization: Bearer $LM_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
    \"model\": \"$MODEL\",
    \"input\": \"$PERGUNTA\"
    }")

    # =========================
    # CAPTURA RESPOSTA
    # =========================

    # FORMATO ARRAY JSON
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.[0].content')

    # Se vier null
    if [ "$RESPOSTA" = "null" ] || [ -z "$RESPOSTA" ]; then
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')
    fi

    # FORMATO RESPONSE
    if [ -z "$RESPOSTA" ] || [ "$RESPOSTA" = "null" ]; then
        RESPOSTA=$(echo "$RESPONSE" | jq -r '.response // empty')
    fi

    # FORMATO OUTPUT
    if [ -z "$RESPOSTA" ] || [ "$RESPOSTA" = "null" ]; then
        RESPOSTA=$(echo "$RESPONSE" | jq -r '.output // empty')
    fi

    # REMOVE ASPAS EXTRAS
    RESPOSTA=$(echo "$RESPOSTA" | sed 's/\\"/"/g')

    # =========================
    # ERRO
    # =========================
    if [ -z "$RESPOSTA" ] || [ "$RESPOSTA" = "null" ]; then
        echo -e "${RED}❌ Erro ao obter resposta.${NC}"
        echo ""
        echo -e "${YELLOW}Resposta da API:${NC}"
        echo -e "${GRAY}$RESPONSE${NC}"
        echo ""
        continue
    fi

    # =========================
    # MOSTRAR RESPOSTA
    # =========================
    echo -e "${BLUE}╭───────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC} ${WHITE}Decom IA${NC}"
    echo -e "${BLUE}╰───────────────────────────────╯${NC}"

    echo -e "${WHITE}$RESPOSTA${NC}"
    echo ""

done