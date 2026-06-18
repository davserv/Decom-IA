#!/bin/bash

API_KEY="sk-SUA_API_KEY"
API_URL="https://api.manus.ai/v2/task.create"

clear

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

echo -e "${GREEN}"
cat << "EOF"

████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █

             TERMINAL AI CLI

EOF

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🤖 Modelo:${NC} MANUS AI${NC}"
echo -e "${WHITE}🌐 API:${NC} ${GRAY}MANUS${NC}"
echo -e "${WHITE}💡 Comandos:${NC} sair | clear"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

while true; do

    read -p "💬 Você: " MSG

    [ "$MSG" = "sair" ] && break

    echo
    echo "🤖 Manus AI pensando..."
    echo

    RESPONSE=$(curl -s -X POST "$API_URL" \
      -H "Content-Type: application/json" \
      -H "x-manus-api-key: $API_KEY" \
      -d "{
        \"message\": {
          \"content\": \"$MSG\"
        }
      }")

    LINK=$(echo "$RESPONSE" | jq -r '.task_url // empty')

    if [ -n "$LINK" ]; then
        echo "🔗 $LINK"
    else
        echo "❌ Erro ao obter link."
        echo
        echo "$RESPONSE" | jq .
    fi

    echo
done