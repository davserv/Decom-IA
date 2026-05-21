# ==========================================
# TERMINAL AI CLI - MANUS AI
# PowerShell Ultra Moderna
# ==========================================

# =========================
# CONFIG API
# =========================
$API_KEY = $env:MANUS_API_KEY

if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = "sk-SUA_API_KEY"
}

$API_URL = "https://api.manus.ai/v2/task.create"

# =========================
# UTF-8 + TERMINAL
# =========================
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

# =========================
# FUNÇÃO CORES
# =========================
function Write-Color {
    param(
        [string]$Text,
        [string]$Color = "White",
        [switch]$NoNewLine
    )

    if ($NoNewLine) {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    }
    else {
        Write-Host $Text -ForegroundColor $Color
    }
}

# =========================
# LIMPAR TELA
# =========================
Clear-Host

# =========================
# LOGO
# =========================
Write-Color @"

████  █████  ███   ███  █   █    ███  ███
█   █ █     █     █   █ ██ ██     █  █   █
█   █ ████  █     █   █ █ █ █     █  █████
█   █ █     █     █   █ █   █     █  █   █
████  █████  ███   ███  █   █    ███ █   █

             TERMINAL AI CLI

"@ "Green"

Write-Color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Color "🤖 Modelo: " "White" -NoNewLine
Write-Color "MANUS AI" "Green"

Write-Color "💡 Comandos: " "White" -NoNewLine
Write-Color "sair | clear" "Yellow"

Write-Color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Host ""

# =========================
# LOOP PRINCIPAL
# =========================
while ($true) {

    Write-Color "💬 Você: " "Cyan" -NoNewLine
    $MSG = Read-Host

    # =========================
    # COMANDOS
    # =========================
    switch ($MSG.ToLower()) {

        "sair" {
            Write-Color "`n👋 Encerrando Terminal AI..." "Red"
            break
        }

        "clear" {
            Clear-Host
            continue
        }
    }

    if ([string]::IsNullOrWhiteSpace($MSG)) {
        continue
    }

    Write-Host ""
    Write-Color "🤖 Manus AI pensando..." "Yellow"
    Write-Host ""

    # =========================
    # BODY JSON
    # =========================
    $Body = @{
        message = @{
            content = $MSG
        }
    } | ConvertTo-Json -Depth 5

    try {

        # =========================
        # REQUEST API
        # =========================
        $Response = Invoke-RestMethod `
            -Uri $API_URL `
            -Method POST `
            -Headers @{
                "x-manus-api-key" = $API_KEY
            } `
            -ContentType "application/json" `
            -Body $Body

        # =========================
        # RESPOSTA
        # =========================
        if ($Response.task_url) {

            Write-Color "🔗 Link da Task:" "Green"
            Write-Color $Response.task_url "Cyan"
        }
        else {

            Write-Color "❌ Erro ao obter link." "Red"
            $Response | ConvertTo-Json -Depth 10
        }

    }
    catch {

        Write-Color "❌ Erro na API:" "Red"
        Write-Color $_.Exception.Message "Yellow"

        if ($_.ErrorDetails.Message) {
            Write-Host ""
            Write-Color "📄 Resposta da API:" "Cyan"
            Write-Host $_.ErrorDetails.Message
        }
    }

    Write-Host ""
}