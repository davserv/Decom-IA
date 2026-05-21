# ==========================================
# DECOM IA TERMINAL CHAT - POWERSHELL EDITION
# ==========================================

# =========================
# CONFIG API
# =========================
$API_KEY = $env:CLOD_API_KEY

if ([string]::IsNullOrEmpty($API_KEY)) {
    $API_KEY = "API_KEY_AQUI"
}

$API_URL = "https://API_URL_AQUI"
$MODEL   = "MODEL_AQUI"

# =========================
# UTF-8 / ACENTUAÇÃO
# =========================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

# =========================
# FUNÇÃO BANNER
# =========================
function Show-Banner {

    Clear-Host

    Write-Host ""
    Write-Host "████  █████  ███   ███  █   █    ███  ███  " -ForegroundColor Green
    Write-Host "█   █ █     █     █   █ ██ ██     █  █   █ " -ForegroundColor Green
    Write-Host "█   █ ████  █     █   █ █ █ █     █  █████ " -ForegroundColor Green
    Write-Host "█   █ █     █     █   █ █   █     █  █   █ " -ForegroundColor Green
    Write-Host "████  █████  ███   ███  █   █    ███ █   █" -ForegroundColor Green

    Write-Host ""
    Write-Host "             TERMINAL AI CHAT" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
    Write-Host "🤖 Modelo: " -NoNewline
    Write-Host "$MODEL" -ForegroundColor Yellow

    Write-Host "💡 Comandos: " -NoNewline
    Write-Host "sair | clear" -ForegroundColor White

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
    Write-Host ""
}

# =========================
# ANIMAÇÃO IA
# =========================
function Show-Thinking {

    $frames = @(
        "⠋ Pensando...",
        "⠙ Pensando...",
        "⠹ Pensando...",
        "⠸ Pensando...",
        "⠼ Pensando...",
        "⠴ Pensando...",
        "⠦ Pensando...",
        "⠧ Pensando..."
    )

    for ($i = 0; $i -lt 2; $i++) {
        foreach ($frame in $frames) {
            Write-Host "`r🤖 $frame " -ForegroundColor Cyan -NoNewline
            Start-Sleep -Milliseconds 80
        }
    }

    Write-Host "`r                            `r" -NoNewline
}

# =========================
# INICIAR
# =========================
Show-Banner

# =========================
# LOOP PRINCIPAL
# =========================
while ($true) {

    Write-Host ""
    Write-Host "Você " -ForegroundColor Green -NoNewline
    Write-Host "> " -ForegroundColor DarkGray -NoNewline

    $PERGUNTA = Read-Host

    # =========================
    # COMANDOS
    # =========================

    if ($PERGUNTA.ToLower() -match "^(sair|exit)$") {

        Write-Host ""
        Write-Host "✅ Chat encerrado." -ForegroundColor Green
        Write-Host ""
        break
    }

    if ($PERGUNTA.ToLower() -match "^(clear|limpar)$") {
        Show-Banner
        continue
    }

    if ([string]::IsNullOrWhiteSpace($PERGUNTA)) {
        continue
    }

    # =========================
    # IA THINKING
    # =========================
    Show-Thinking

    # =========================
    # BODY JSON
    # =========================
    $body = @{
        model = $MODEL

        messages = @(
            @{
                role    = "system"
                content = "Você é um assistente inteligente estilo Decom IA no terminal."
            },
            @{
                role    = "user"
                content = $PERGUNTA
            }
        )

        temperature = 0.7
        max_completion_tokens = 6096

    } | ConvertTo-Json -Depth 10

    # =========================
    # REQUEST API
    # =========================
    try {

        $response = Invoke-RestMethod `
            -Uri $API_URL `
            -Method POST `
            -Headers @{
                "Authorization" = "Bearer $API_KEY"
                "Content-Type"  = "application/json"
            } `
            -Body $body `
            -ErrorAction Stop

        $RESPOSTA = $response.choices[0].message.content

        if ([string]::IsNullOrWhiteSpace($RESPOSTA)) {

            Write-Host ""
            Write-Host "❌ Resposta vazia da API." -ForegroundColor Red
            continue
        }

        # =========================
        # RESPOSTA ESTILIZADA
        # =========================
        Write-Host ""
        Write-Host "╭───────────────────────────────╮" -ForegroundColor Blue
        Write-Host "│ Decom IA" -ForegroundColor Blue
        Write-Host "╰───────────────────────────────╯" -ForegroundColor Blue
        Write-Host ""

        Write-Host $RESPOSTA -ForegroundColor White
    }

    catch {

        Write-Host ""
        Write-Host "❌ Erro ao obter resposta da API." -ForegroundColor Red
        Write-Host ""

        if ($_.Exception.Response) {

            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorResponse = $reader.ReadToEnd()

            Write-Host $errorResponse -ForegroundColor DarkGray
        }
        else {

            Write-Host $_.Exception.Message -ForegroundColor DarkGray
        }
    }

    Write-Host ""
}