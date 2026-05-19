# ==========================================
# CONFIG API DECOM IA
# ==========================================
$API_KEY = $env:CLOD_API_KEY
if (-not $API_KEY) {
    $API_KEY = "API_KEY-AQUI"
}

$API_URL = "https://api.cline.bot/api/v1/chat/completions"
$MODEL   = "minimax/minimax-m2.5"

# ==========================================
# CORES
# ==========================================
$RED    = "Red"
$GREEN  = "Green"
$YELLOW = "Yellow"
$BLUE   = "Cyan"
$WHITE  = "White"
$GRAY   = "DarkGray"

# ==========================================
# LIMPAR TELA
# ==========================================
Clear-Host

# ==========================================
# BANNER
# ==========================================
Write-Host "" -ForegroundColor $GREEN

Write-Host @"

████  █████  ███   ███  █   █    ███  ███
█   █ █     █     █   █ ██ ██     █  █   █
█   █ ████  █     █   █ █ █ █     █  █████
█   █ █     █     █   █ █   █     █  █   █
████  █████  ███   ███  █   █    ███ █   █

             TERMINAL AI CHAT

"@ -ForegroundColor $GREEN

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🤖 Modelo: $MODEL" -ForegroundColor Yellow
Write-Host "🌐 API: cline.bot" -ForegroundColor Gray
Write-Host "💡 Comandos: sair | clear" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# ==========================================
# HISTÓRICO
# ==========================================
$history = @(
    @{
        role = "system"
        content = "Você é um assistente inteligente estilo Chat no terminal Windows PowerShell."
    }
)

# ==========================================
# LOOP CHAT
# ==========================================
while ($true) {

    # Prompt usuário
    Write-Host -NoNewline "Você > " -ForegroundColor Green
    $PERGUNTA = Read-Host

    # SAIR
    if ($PERGUNTA.ToLower() -match "^(sair|exit)$") {
        Write-Host ""
        Write-Host "✅ Chat encerrado." -ForegroundColor Green
        Write-Host ""
        break
    }

    # CLEAR
    if ($PERGUNTA.ToLower() -match "^(clear|limpar)$") {
        Clear-Host
        continue
    }

    # Ignora vazio
    if ([string]::IsNullOrWhiteSpace($PERGUNTA)) {
        continue
    }

    Write-Host ""
    Write-Host "🤖 IA está pensando..." -ForegroundColor Cyan
    Write-Host ""

    # Adiciona pergunta
    $history += @{
        role = "user"
        content = $PERGUNTA
    }

    # ==========================================
    # BODY REQUEST
    # ==========================================
    $body = @{
        model = $MODEL
        messages = $history
        stream = $false
    } | ConvertTo-Json -Depth 20

    try {

        # ==========================================
        # REQUISIÇÃO API
        # ==========================================
        $response = Invoke-RestMethod `
            -Uri $API_URL `
            -Method Post `
            -Headers @{
                Authorization = "Bearer $API_KEY"
                "Content-Type" = "application/json"
            } `
            -Body $body

        # ==========================================
        # CAPTURA RESPOSTA
        # ==========================================
        $RESPOSTA = $response.data.choices[0].message.content

        if (-not $RESPOSTA) {
            Write-Host "❌ Erro ao obter resposta." -ForegroundColor Red
            Write-Host ""
            $response | ConvertTo-Json -Depth 10
            Write-Host ""
            continue
        }

        # Salva resposta
        $history += @{
            role = "assistant"
            content = $RESPOSTA
        }

        # ==========================================
        # MOSTRAR RESPOSTA
        # ==========================================
        Write-Host "╭───────────────────────────────╮" -ForegroundColor Cyan
        Write-Host "│ Decom IA" -ForegroundColor White
        Write-Host "╰───────────────────────────────╯" -ForegroundColor Cyan

        Write-Host $RESPOSTA -ForegroundColor White
        Write-Host ""

    }
    catch {

        Write-Host "❌ Erro na API." -ForegroundColor Red
        Write-Host ""

        if ($_.Exception.Message) {
            Write-Host $_.Exception.Message -ForegroundColor DarkGray
        }

        Write-Host ""
    }
}