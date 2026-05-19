

$API_KEY = "${env:OLLAMA_API_KEY}"
if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = "API_KEY-AQUI"
}

$API_URL = "https://ollama.com/api/chat"
$MODEL = "glm-4.7:cloud"

# LOCAL OLLAMA OFFLINE
# $API_URL = "http://localhost:11434/api/chat"
# $MODEL = "qwen3:1.7b"

# ==========================================
# CORES
# ==========================================
$RED    = "Red"
$GREEN  = "Green"
$BLUE   = "Cyan"
$CYAN   = "DarkCyan"
$YELLOW = "Yellow"
$GRAY   = "DarkGray"
$WHITE  = "White"

Clear-Host

# ==========================================
# BANNER
# ==========================================
Write-Host "
####  #####  ###   ###  #   #    ###  ###  
#   # #     #     #   # ## ##     #  #   # 
#   # ####  #     #   # # # #     #  ##### 
#   # #     #     #   # #   #     #  #   # 
####  #####  ###   ###  #   #    ### #   #    
" -ForegroundColor DarkYellow

Write-Host ""
Write-Host "✅ Conectado ao modelo: " -NoNewline -ForegroundColor Green
Write-Host "$MODEL" -ForegroundColor Yellow

Write-Host "Digite 'sair' para encerrar" -ForegroundColor DarkGray
Write-Host ""

# ==========================================
# HISTÓRICO
# ==========================================
$history = @()

while ($true) {

    Write-Host ""
    $PERGUNTA = Read-Host "Você"

    # ==========================================
    # SAIR
    # ==========================================
    if ($PERGUNTA -match "^(sair|exit)$") {
        Write-Host ""
        Write-Host "👋 Encerrando chat..." -ForegroundColor Green
        break
    }

    # IGNORA VAZIO
    if ([string]::IsNullOrWhiteSpace($PERGUNTA)) {
        continue
    }

    # ==========================================
    # ANIMAÇÃO
    # ==========================================
    Write-Host ""
    Write-Host "🤖 IA está pensando..." -ForegroundColor Cyan
    Start-Sleep -Milliseconds 800
    Write-Host ""

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
                content = "Você é um assistente inteligente estilo Decom IA."
            }
        ) + $history
        stream = $false
    } | ConvertTo-Json -Depth 10

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
        # RESPOSTA
        # ==========================================
        $RESPOSTA = $response.message.content

        if (-not $RESPOSTA) {
            $RESPOSTA = $response.choices[0].message.content
        }

        if (-not $RESPOSTA) {
            $RESPOSTA = "❌ Erro na API"
        }

        # SALVA HISTÓRICO
        $history += @{
            role    = "assistant"
            content = $RESPOSTA
        }

        # ==========================================
        # LINHA
        # ==========================================
        Write-Host "──────────────────────────────────────" -ForegroundColor DarkGray

        # ==========================================
        # EXIBE RESPOSTA
        # ==========================================
        Write-Host ""
        Write-Host "🤖 Decom IA:" -ForegroundColor Green
        Write-Host ""

        # ==========================================
        # EFEITO DIGITAÇÃO
        # ==========================================
        foreach ($char in $RESPOSTA.ToCharArray()) {
            Write-Host -NoNewline $char
            Start-Sleep -Milliseconds 5
        }

        Write-Host ""
        Write-Host ""

        Write-Host "──────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""

    }
    catch {

        Write-Host ""
        Write-Host "❌ Erro ao obter resposta." -ForegroundColor Red
        Write-Host ""

        if ($_.Exception.Message) {
            Write-Host $_.Exception.Message -ForegroundColor DarkGray
        }

        Write-Host ""
    }
}