#!/bin/bash

# =========================
# CONFIGURAÇÃO DA API OLLAMA CLOUD
# =========================
API_KEY="${OLLAMA_API_KEY:-API_KEY-AQUI}"
API_URL="https://ollama.com/api/chat"
MODEL="glm-4.7:cloud"

clear

echo "
████  █████  ███   ███  █   █    ███  ███
█   █ █     █     █   █ ██ ██     █  █   █
█   █ ████  █     █   █ █ █ █     █  █████
█   █ █     █     █   █ █   █     █  █   █
████  █████  ███   ███  █   █    ███ █   █
"

echo "🚀 Iniciando Chat Ollama..."
echo "💡 Digite 'sair' para encerrar"
echo ""

while true; do
    echo -n ">> "
    read -r PERGUNTA

    # Sair
    [[ "${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && echo "✅ Tudo pronto!" && break

    # Ignora vazio
    [ -z "$PERGUNTA" ] && continue

    RESPONSE=$(curl -s "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
          {
            \"role\": \"user\",
            \"content\": \"$PERGUNTA\"
          }
        ],
        \"stream\": false
      }")

    # Captura resposta
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.message.content // "❌ Erro na resposta da API"')

    echo ""
    echo "🤖 IA: $RESPOSTA"
    echo ""
done