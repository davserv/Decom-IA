#!/bin/bash
set -e

clear

GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${GREEN}"
cat << "BANNER"

████  █████  ███   ███  █   █    ███  ███
█   █ █     █     █   █ ██ ██     █  █   █
█   █ ████  █     █   █ █ █ █     █  █████
█   █ █     █     █   █ █   █     █  █   █
████  █████  ███   ███  █   █    ███ █   █

          TERMINAL MULT.IA CHAT

BANNER

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

read -p "🔑 APIKEY : " apiskey
echo
read -p "🌐 SERV-URL: " servsurl
echo
read -p "🤖 MODELO: " modeloks

echo
echo "Gerando chat.sh..."

cat > chat.sh << EOF
#!/bin/bash

API_KEY="\${CLOD_API_KEY:-$apiskey}"
API_URL="$servsurl"
MODEL="$modeloks"

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

clear

echo -e "\${GREEN}"
cat << 'BANNER'

████  █████  ███   ███  █   █    ███  ███
█   █ █     █     █   █ ██ ██     █  █   █
█   █ ████  █     █   █ █ █ █     █  █████
█   █ █     █     █   █ █   █     █  █   █
████  █████  ███   ███  █   █    ███ █   █

          TERMINAL MULT.IA CHAT

BANNER

echo -e "\${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo -e "\${WHITE}🤖 Modelo:\${NC} \${YELLOW}\$MODEL\${NC}"
echo -e "\${WHITE}🌐 API:\${NC} \$API_URL"
echo -e "\${WHITE}💡 Comandos:\${NC} sair | clear"
echo -e "\${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
echo

while true; do

    echo -ne "\${GREEN}Você\${NC} > "
    read -r PERGUNTA

    [[ "\${PERGUNTA,,}" =~ ^(sair|exit)$ ]] && break
    [[ "\${PERGUNTA,,}" =~ ^(clear|limpar)$ ]] && clear && continue
    [ -z "\$PERGUNTA" ] && continue

    echo
    echo -e "\${CYAN}🤖 IA está pensando...\${NC}"
    echo

    JSON=\$(jq -n \
        --arg model "\$MODEL" \
        --arg pergunta "\$PERGUNTA" \
        '{
            model: \$model,
            messages: [
                {
                    role: "system",
                    content: "Você é um assistente inteligente."
                },
                {
                    role: "user",
                    content: \$pergunta
                }
            ],
            temperature: 0.7
        }')

    RESPONSE=\$(curl -s -X POST "\$API_URL" \
        -H "Authorization: Bearer \$API_KEY" \
        -H "Content-Type: application/json" \
        -d "\$JSON")

    RESPOSTA=\$(echo "\$RESPONSE" | jq -r '.choices[0].message.content // empty')

    if [ -z "\$RESPOSTA" ]; then
        echo -e "\${RED}Erro na API\${NC}"
        echo "\$RESPONSE"
        echo
        continue
    fi

    echo -e "\${BLUE}╭─────────────────╮\${NC}"
    echo -e "\${BLUE}│\${NC} Decom IA ---"
    echo -e "\${BLUE}╰─────────────────╯\${NC}"
    echo

    echo "\$RESPOSTA"
    echo
done
EOF

chmod +x chat.sh

echo
echo "✅ Arquivo chat.sh criado com sucesso."
echo

./chat.sh