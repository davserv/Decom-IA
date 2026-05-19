# ==========================================
# CONFIG API GITHUB MODELS
# ==========================================
$API_KEY = $env:GITHUB_TOKEN

if (-not $API_KEY) {
    $API_KEY = "ghp_SUA_API_KEY_AQUI"
}

$API_URL = "https://models.github.ai/inference/chat/completions"
$MODEL = "openai/gpt-4.1-mini"

# ==========================================
# HISTÓRICO CHAT
# ==========================================
$history = @()

# ==========================================
# FUNÇÃO USUÁRIO
# ==========================================
function Show-User($msg) {
    Write-Host ""
    Write-Host "╭───────────────────────────────╮" -ForegroundColor Green
    Write-Host "│ Você" -ForegroundColor Green
    Write-Host "╰───────────────────────────────╯" -ForegroundColor Green
    Write-Host "$msg" -ForegroundColor White
}

# ==========================================
# FUNÇÃO IA
# ==========================================
function Show-Bot($msg) {
    Write-Host ""
    Write-Host "╭───────────────────────────────╮" -ForegroundColor Cyan
    Write-Host "│ DECOM IA" -ForegroundColor Cyan
    Write-Host "╰───────────────────────────────╯" -ForegroundColor Cyan
    Write-Host "$msg" -ForegroundColor Gray
    Write-Host ""
}

# ==========================================
# LIMPAR TELA
# ==========================================
Clear-Host

# ==========================================
# BANNER
# ==========================================
Write-Host "" -ForegroundColor Green
Write-Host "
████  █████  ███   ███  █   █    ███  ███  
█   █ █     █     █   █ ██ ██     █  █   █ 
█   █ ████  █     █   █ █ █ █     █  █████ 
█   █ █     █     █   █ █   █     █  █   █ 
████  █████  ███   ███  █   █    ███ █   █

             TERMINAL AI CHAT
" -ForegroundColor Green

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🤖 Modelo: $MODEL" -ForegroundColor Yellow
Write-Host "💡 Comandos: sair | clear" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# ==========================================
# LOOP CHAT
# ==========================================
while ($true) {

    $PERGUNTA = Read-Host "Você >"

    # ==========================================
    # SAIR
    # ==========================================
    if ($PERGUNTA -match "^(sair|exit)$") {
        Write-Host ""
        Write-Host "✅ Chat encerrado." -ForegroundColor Green
        Write-Host ""
        break
    }

    # ==========================================
    # LIMPAR
    # ==========================================
    if ($PERGUNTA -match "^(clear|limpar)$") {
        Clear-Host
        continue
    }

    # ==========================================
    # IGNORA VAZIO
    # ==========================================
    if ([string]::IsNullOrWhiteSpace($PERGUNTA)) {
        continue
    }

    Show-User $PERGUNTA

    # ==========================================
    # HISTÓRICO
    # ==========================================
    $history += @{
        role    = "user"
        content = $PERGUNTA
    }

    # ==========================================
    # BODY JSON
    # ==========================================
    $body = @{
        model = $MODEL
        messages = @(
            @{
                role    = "system"
                content = "Você é um assistente inteligente DECOM IA no terminal."
            }
        ) + $history
        temperature = 1
        top_p = 1
        max_completion_tokens = 2048
    } | ConvertTo-Json -Depth 20

    try {

        Write-Host ""
        Write-Host "🤖 IA está pensando..." -ForegroundColor Cyan
        Write-Host ""

        # ==========================================
        # REQUISIÇÃO API
        # ==========================================
        $response = Invoke-RestMethod `
            -Uri $API_URL `
            -Method POST `
            -Headers @{
                Authorization = "Bearer $API_KEY"
                "Content-Type" = "application/json"
            } `
            -Body $body

        # ==========================================
        # RESPOSTA
        # ==========================================
        $RESPOSTA = $response.choices[0].message.content

        if ([string]::IsNullOrWhiteSpace($RESPOSTA)) {
            Write-Host "❌ Não foi possível obter resposta." -ForegroundColor Red
            continue
        }

        # ==========================================
        # SALVAR HISTÓRICO IA
        # ==========================================
        $history += @{
            role    = "assistant"
            content = $RESPOSTA
        }

        # ==========================================
        # MOSTRAR RESPOSTA
        # ==========================================
        Show-Bot $RESPOSTA
    }
    catch {

        Write-Host "❌ Erro ao obter resposta da API." -ForegroundColor Red
        Write-Host ""

        if ($_.Exception.Response) {
            $_.Exception.Response
        }
    }
}