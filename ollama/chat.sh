#!/bin/bash

API_KEY="${OLLAMA_API_KEY:-API_KEY-AQUI}"
API_URL="https://ollama.com/api/chat"
MODEL="glm-4.7:cloud"

clear

# CORES
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m'

# BANNER
echo -e "${CYAN}"

echo "
████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █ 
"

echo -e "${NC}"

echo -e "${GREEN}✅ Conectado ao modelo:${NC} ${YELLOW}$MODEL${NC}"
echo -e "${GRAY}Digite 'sair' para encerrar${NC}"
echo ""

# HISTÓRICO
MESSAGES='[]'

while true; do

    echo -ne "${BLUE}Você:${NC} "
    read -r PERGUNTA

    # SAIR
    [[ "${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && {
        echo ""
        echo -e "${GREEN}👋 Encerrando chat...${NC}"
        break
    }

    # IGNORA VAZIO
    [ -z "$PERGUNTA" ] && continue

    # ANIMAÇÃO
    echo ""
    echo -ne "${CYAN}🤖 IA está pensando"

    for i in {1..3}; do
        sleep 0.4
        echo -ne "."
    done

    echo -e "${NC}"
    echo ""

    # ENVIA PARA API
    RESPONSE=$(curl -s "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
          {
            \"role\": \"system\",
            \"content\": \"Você é um assistente inteligente estilo Decom IA.\"
          },
          {
            \"role\": \"user\",
            \"content\": \"$PERGUNTA\"
          }
        ],
        \"stream\": false
      }")

    # RESPOSTA
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.message.content // .choices[0].message.content // "❌ Erro na API"')

    # LINHA
    echo -e "${GRAY}──────────────────────────────────────${NC}"

    # EXIBE RESPOSTA
    echo -e "${GREEN}🤖 Decom IA:${NC}"
    echo ""

    # EFEITO DIGITAÇÃO
    for ((i=0; i<${#RESPOSTA}; i++)); do
        printf "%s" "${RESPOSTA:$i:1}"
        sleep 0.005
    done

    echo ""
    echo ""

    echo -e "${GRAY}──────────────────────────────────────${NC}"
    echo ""

done