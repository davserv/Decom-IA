$API_KEY = "API_KEY-AQUI"
$API_URL = "https://API_URL-AQUI"

$history = @()

function Show-User($msg) {
    Write-Host ""
    Write-Host "=) Voce:" -ForegroundColor Cyan
    Write-Host "$msg" -ForegroundColor White
}

function Show-Bot($msg) {
    Write-Host ""
    Write-Host ":) DECOM IA:" -ForegroundColor Green
    Write-Host "$msg" -ForegroundColor Gray
    Write-Host ""
}

Clear-Host

Write-Host "===========================================" -ForegroundColor DarkGray
Write-Host "
####  #####  ###   ###  #   #    ###  ###  
#   # #     #     #   # ## ##     #  #   # 
#   # ####  #     #   # # # #     #  ##### 
#   # #     #     #   # #   #     #  #   # 
####  #####  ###   ###  #   #    ### #   #    
" -ForegroundColor DarkYellow
Write-Host "===========================================" -ForegroundColor DarkGray
Write-Host "Digite 'sair' para encerrar" -ForegroundColor Yellow
Write-Host ""

while ($true) {
    $PERGUNTA = Read-Host ">>"

    if ($PERGUNTA -match "^(sair|exit)$") {
        Write-Host "? Encerrando..." -ForegroundColor Red
        break
    }

    if ([string]::IsNullOrWhiteSpace($PERGUNTA)) {
        continue
    }

    Show-User $PERGUNTA

    $history += @{ role = "user"; content = $PERGUNTA }

    $body = @{
        model = "--MODEL-AQUI--"
        messages = @(
            @{ role = "system"; content = "Você é um assistente estilo ChatGPT." }
        ) + $history
        temperature = 0.7
        max_completion_tokens = 2048
    } | ConvertTo-Json -Depth 10

    try {
        Write-Host "Pensando..." -ForegroundColor DarkYellow

        $response = Invoke-RestMethod -Uri $API_URL `
            -Method Post `
            -Headers @{
                Authorization = "Bearer $API_KEY"
                "Content-Type" = "application/json"
            } `
            -Body $body

        $resposta = $response.choices[0].message.content

        $history += @{ role = "assistant"; content = $resposta }

        Show-Bot $resposta
    }
    catch {
        Write-Host "? Erro na API" -ForegroundColor Red
    }
}
