#!/bin/bash

# ==========================================
# CONFIG API CLINE
# ==========================================
API_KEY="${CLOD_API_KEY:-API_KEY-AQUI}"
API_URL="https://api.cline.bot/api/v1/chat/completions"

MODEL="minimax/minimax-m2.5"

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
if ! command -v jq &> /dev/null
then
    echo -e "${RED}❌ jq não está instalado.${NC}"
    echo ""
    echo -e "${YELLOW}Ubuntu/Debian:${NC} sudo apt install jq"
    echo -e "${YELLOW}Arch:${NC} sudo pacman -S jq"
    echo -e "${YELLOW}Fedora:${NC} sudo dnf install jq"
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
echo -e "${WHITE}🌐 API:${NC} ${GRAY}cline.bot${NC}"
echo -e "${WHITE}💡 Comandos:${NC} sair | clear"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ==========================================
# HISTÓRICO CHAT
# ==========================================
MESSAGES='[
  {
    "role": "system",
    "content": "Você é um assistente inteligente estilo Chat no terminal Linux."
  }
]'

# ==========================================
# LOOP CHAT
# ==========================================
while true; do

    # Prompt usuário
    echo -ne "${GREEN}Você${NC} ${GRAY}> ${NC}"
    read -r PERGUNTA

    # SAIR
    [[ "${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && \
    echo -e "\n${GREEN}✅ Chat encerrado.${NC}\n" && break

    # LIMPAR
    [[ "${PERGUNTA,,}" =~ ^(clear|limpar)$ ]] && clear && continue

    # Ignora vazio
    [ -z "$PERGUNTA" ] && continue

    echo ""
    echo -e "${CYAN}🤖 IA está pensando...${NC}"
    echo ""

    # Adiciona pergunta ao histórico
    MESSAGES=$(echo "$MESSAGES" | jq --arg msg "$PERGUNTA" '. += [{"role":"user","content":$msg}]')

    # ==========================================
    # REQUISIÇÃO API
    # ==========================================
    RESPONSE=$(curl -s -X POST "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "$(jq -n \
        --arg model "$MODEL" \
        --argjson messages "$MESSAGES" \
        '{
          model: $model,
          messages: $messages,
          stream: false
        }'
      )")

    # ==========================================
    # CAPTURA RESPOSTA
    # ==========================================
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.data.choices[0].message.content // empty')

# Erro
if [ -z "$RESPOSTA" ]; then
    echo -e "${RED}❌ Erro ao obter resposta.${NC}"
    echo ""
    echo "$RESPONSE" | jq
    echo ""
    continue
fi

    # Salva resposta no histórico
    MESSAGES=$(echo "$MESSAGES" | jq --arg msg "$RESPOSTA" '. += [{"role":"assistant","content":$msg}]')

    # ==========================================
    # MOSTRAR RESPOSTA
    # ==========================================
    echo -e "${BLUE}╭───────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC} ${WHITE}Decom IA${NC}"
    echo -e "${BLUE}╰───────────────────────────────╯${NC}"

    echo -e "${WHITE}$RESPOSTA${NC}"
    echo ""

done