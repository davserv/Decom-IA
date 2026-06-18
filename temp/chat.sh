#!/bin/bash

API_KEY="${CLOD_API_KEY:-API_KEY-AQUI}"
API_URL="https://API_URL-AQUI"

echo "
████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █ 
"

echo "🚀 Iniciando Chat..."
echo  "🌐 API: Multiplas IA "
echo "💡 Digite 'sair' para encerrar"
echo ""

while true; do
    echo -n ">> "
    read -r PERGUNTA
    
    # Sai se digitar 'sair'
    [[ "${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && echo "✅ Tudo pronto!" && break
    [ -z "$PERGUNTA" ] && continue
    
    RESPONSE=$(curl -s -X POST "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"MODEL-AQUI\",
        \"messages\": [
          {\"role\": \"system\", \"content\": \"Você é um assistente prestativo.\"},
          {\"role\": \"user\", \"content\": \"$PERGUNTA\"}
        ],
        \"temperature\": 0.7,
        \"max_completion_tokens\": 5048
      }")
    
    RESPOSTA=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // "❌ Erro"')
    echo ""
    echo "🤖 IA: $RESPOSTA"
    echo ""
done
