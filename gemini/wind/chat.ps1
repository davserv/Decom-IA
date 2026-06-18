$API_KEY = "API_KEY_AQUI"
$API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

$history = @()

function Show-User($msg) {
    Write-Host ""
    Write-Host "=) Voce:" -ForegroundColor Cyan
    Write-Host "$msg" -ForegroundColor White
}

function Show-Bot($msg) {
    Write-Host ""
    Write-Host ":) GEMINI IA:" -ForegroundColor Green
    Write-Host "$msg" -ForegroundColor Gray
    Write-Host ""
}

Clear-Host

Write-Host "===========================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "████  █████  ███   ███  █   █    ███  ███  " -ForegroundColor Green
Write-Host "█   █ █     █     █   █ ██ ██     █  █   █ " -ForegroundColor Green
Write-Host "█   █ ████  █     █   █ █ █ █     █  █████ " -ForegroundColor Green
Write-Host "█   █ █     █     █   █ █   █     █  █   █ " -ForegroundColor Green
Write-Host "████  █████  ███   ███  █   █    ███ █   █" -ForegroundColor Green

Write-Host ""
Write-Host "           GEMINI AI TERMINAL" -ForegroundColor Cyan
Write-Host ""
Write-Host "===========================================" -ForegroundColor DarkGray
Write-Host "Digite 'sair' para encerrar" -ForegroundColor Yellow
Write-Host ""

while ($true) {

    $PERGUNTA = Read-Host ">>"

    if ($PERGUNTA -match "^(sair|exit)$") {
        Write-Host "Encerrando..." -ForegroundColor Red
        break
    }

    if ([string]::IsNullOrWhiteSpace($PERGUNTA)) {
        continue
    }

    Show-User $PERGUNTA

    # Adiciona histórico
    $history += @{
        role = "user"
        parts = @(
            @{
                text = $PERGUNTA
            }
        )
    }

    $body = @{
        contents = $history
        generationConfig = @{
            temperature = 0.7
            maxOutputTokens = 2048
        }
    } | ConvertTo-Json -Depth 20

    try {

        Write-Host "Pensando..." -ForegroundColor DarkYellow

        $response = Invoke-RestMethod `
            -Uri "$API_URL?key=$API_KEY" `
            -Method POST `
            -ContentType "application/json" `
            -Body $body

        $resposta = $response.candidates[0].content.parts[0].text

        # Salva resposta no histórico
        $history += @{
            role = "model"
            parts = @(
                @{
                    text = $resposta
                }
            )
        }

        Show-Bot $resposta
    }
    catch {
        Write-Host ""
        Write-Host "Erro ao conectar com a API Gemini." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
        Write-Host ""
    }
}