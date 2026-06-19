# =========================
# CONFIG API
# =========================
$API_KEY = $env:CLOD_API_KEY

if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = "API_KEY_AQUI"
}

$API_URL = "https://API_URL_AQUI"
$MODEL   = "MODEL_AQUI"

# =========================
# UTF-8
# =========================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

# =========================
# MEMÓRIA DOS CHATS
# =========================
$Chats = @{}
$CurrentChat = "principal"

$SystemPrompt = "Você é um assistente inteligente estilo Decom IA no terminal."

$Chats[$CurrentChat] = @(
    @{
        role    = "system"
        content = $SystemPrompt
    }
)

# =========================
# BANNER
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
    Write-Host "     AI TERMINAL • STREAMING EDITION" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan

    Write-Host "🤖 Modelo: " -NoNewline
    Write-Host "$MODEL" -ForegroundColor Yellow

    Write-Host "💬 Chat Atual: " -NoNewline
    Write-Host "$CurrentChat" -ForegroundColor Magenta

    Write-Host ""
    Write-Host "📌 Comandos:" -ForegroundColor White

    Write-Host "  /new NOME      → novo chat"
    Write-Host "  /switch NOME   → trocar chat"
    Write-Host "  /list          → listar chats"
    Write-Host "  /delete NOME   → deletar chat"
    Write-Host "  /clear         → limpar"
    Write-Host "  /exit          → sair"

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
    Write-Host ""
}

# =========================
# STREAM RESPONSE
# =========================
function Start-StreamingResponse {

    param (
        [string]$Prompt
    )

    # ==========================================
    # SALVAR USER
    # ==========================================
    $Chats[$CurrentChat] += @{
        role    = "user"
        content = $Prompt
    }

    # ==========================================
    # BODY JSON
    # ==========================================
    $body = @{
        model = $MODEL

        messages = $Chats[$CurrentChat]

        temperature = 0.7
        stream = $true

        max_completion_tokens = 4096

    } | ConvertTo-Json -Depth 100

    try {

        # ==========================================
        # REQUEST STREAM
        # ==========================================
        $request = [System.Net.HttpWebRequest]::Create($API_URL)

        $request.Method = "POST"
        $request.ContentType = "application/json"
        $request.Headers.Add("Authorization", "Bearer $API_KEY")

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $request.ContentLength = $bytes.Length

        $requestStream = $request.GetRequestStream()
        $requestStream.Write($bytes, 0, $bytes.Length)
        $requestStream.Close()

        # ==========================================
        # RESPONSE STREAM
        # ==========================================
        $response = $request.GetResponse()
        $stream = $response.GetResponseStream()

        $reader = New-Object System.IO.StreamReader($stream)

        Write-Host ""
        Write-Host "╭───────────────────────────────╮" -ForegroundColor Blue
        Write-Host "│ 🤖 Decom IA" -ForegroundColor Blue
        Write-Host "╰───────────────────────────────╯" -ForegroundColor Blue
        Write-Host ""

        $fullResponse = ""

        while (-not $reader.EndOfStream) {

            $line = $reader.ReadLine()

            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            # ==========================================
            # OPENAI STREAM FORMAT
            # data: {...}
            # ==========================================
            if ($line.StartsWith("data: ")) {

                $jsonLine = $line.Substring(6)

                if ($jsonLine -eq "[DONE]") {
                    break
                }

                try {

                    $json = $jsonLine | ConvertFrom-Json

                    $token = $json.choices[0].delta.content

                    if ($token) {

                        $fullResponse += $token

                        Write-Host $token `
                            -ForegroundColor White `
                            -NoNewline
                    }

                } catch {}
            }
        }

        Write-Host ""
        Write-Host ""

        # ==========================================
        # SALVAR RESPOSTA
        # ==========================================
        $Chats[$CurrentChat] += @{
            role    = "assistant"
            content = $fullResponse
        }

        $reader.Close()
        $stream.Close()
        $response.Close()
    }

    catch {

        Write-Host ""
        Write-Host "❌ Erro ao obter resposta." -ForegroundColor Red
        Write-Host ""

        if ($_.Exception.Response) {

            $reader = New-Object System.IO.StreamReader(
                $_.Exception.Response.GetResponseStream()
            )

            $errorResponse = $reader.ReadToEnd()

            Write-Host $errorResponse -ForegroundColor DarkGray
        }
        else {

            Write-Host $_.Exception.Message -ForegroundColor DarkGray
        }
    }
}

# =========================
# START
# =========================
Show-Banner

# =========================
# LOOP
# =========================
while ($true) {

    Write-Host ""
    Write-Host "[$CurrentChat]" `
        -ForegroundColor Magenta `
        -NoNewline

    Write-Host " Você > " `
        -ForegroundColor Green `
        -NoNewline

    $PERGUNTA = Read-Host

    if ([string]::IsNullOrWhiteSpace($PERGUNTA)) {
        continue
    }

    # ==========================================
    # EXIT
    # ==========================================
    if ($PERGUNTA -match "^/(exit|sair)$") {

        Write-Host ""
        Write-Host "✅ Encerrando..." -ForegroundColor Green
        break
    }

    # ==========================================
    # CLEAR
    # ==========================================
    if ($PERGUNTA -match "^/(clear|limpar)$") {

        Show-Banner
        continue
    }

    # ==========================================
    # LIST
    # ==========================================
    if ($PERGUNTA -match "^/list$") {

        Write-Host ""
        Write-Host "💬 Chats disponíveis:" -ForegroundColor Cyan

        foreach ($chat in $Chats.Keys) {

            if ($chat -eq $CurrentChat) {

                Write-Host " • $chat (ATUAL)" `
                    -ForegroundColor Green
            }
            else {

                Write-Host " • $chat" `
                    -ForegroundColor White
            }
        }

        continue
    }

    # ==========================================
    # NEW CHAT
    # ==========================================
    if ($PERGUNTA -match "^/new\s+(.+)$") {

        $NovoChat = $Matches[1].Trim()

        if ($Chats.ContainsKey($NovoChat)) {

            Write-Host ""
            Write-Host "⚠️ Esse chat já existe." `
                -ForegroundColor Yellow

            continue
        }

        $Chats[$NovoChat] = @(
            @{
                role    = "system"
                content = $SystemPrompt
            }
        )

        $CurrentChat = $NovoChat

        Write-Host ""
        Write-Host "✅ Novo chat criado: $NovoChat" `
            -ForegroundColor Green

        continue
    }

    # ==========================================
    # SWITCH CHAT
    # ==========================================
    if ($PERGUNTA -match "^/switch\s+(.+)$") {

        $TrocarChat = $Matches[1].Trim()

        if (-not $Chats.ContainsKey($TrocarChat)) {

            Write-Host ""
            Write-Host "❌ Chat não encontrado." `
                -ForegroundColor Red

            continue
        }

        $CurrentChat = $TrocarChat

        Write-Host ""
        Write-Host "🔄 Mudado para: $CurrentChat" `
            -ForegroundColor Cyan

        continue
    }

    # ==========================================
    # DELETE CHAT
    # ==========================================
    if ($PERGUNTA -match "^/delete\s+(.+)$") {

        $DeleteChat = $Matches[1].Trim()

        if ($DeleteChat -eq "principal") {

            Write-Host ""
            Write-Host "❌ Não pode deletar principal." `
                -ForegroundColor Red

            continue
        }

        if (-not $Chats.ContainsKey($DeleteChat)) {

            Write-Host ""
            Write-Host "❌ Chat não existe." `
                -ForegroundColor Red

            continue
        }

        $Chats.Remove($DeleteChat)

        if ($CurrentChat -eq $DeleteChat) {
            $CurrentChat = "principal"
        }

        Write-Host ""
        Write-Host "🗑️ Chat deletado." `
            -ForegroundColor Yellow

        continue
    }

    # ==========================================
    # START STREAM
    # ==========================================
    Start-StreamingResponse $PERGUNTA
}