
$API_KEY = $env:CLOD_API_KEY

if ([string]::IsNullOrWhiteSpace($API_KEY)) {
    $API_KEY = 'API-KEY-AQUI'
}

$API_URL = 'URL-SERV-AQUI'
$MODEL   = 'MODELO-AQUI'

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

$Chats = @{}
$CurrentChat = 'principal'

$SystemPrompt = 'Você é um assistente inteligente estilo Decom IA no terminal.'

$Chats[$CurrentChat] = @(
    @{
        role    = 'system'
        content = $SystemPrompt
    }
)

function Show-Banner {
    Clear-Host

    Write-Host ""
    Write-Host "████  █████  ███   ███  █   █    ███  ███  " -ForegroundColor Green
    Write-Host "█   █ █     █     █   █ ██ ██     █  █   █ " -ForegroundColor Green
    Write-Host "█   █ ████  █     █   █ █ █ █     █  █████ " -ForegroundColor Green
    Write-Host "█   █ █     █     █   █ █   █     █  █   █ " -ForegroundColor Green
    Write-Host "████  █████  ███   ███  █   █    ███ █   █ " -ForegroundColor Green

    Write-Host ""
    Write-Host "     AI TERMINAL • STREAMING EDITION" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
    Write-Host "🤖 Modelo: MODELO-AQUI" -ForegroundColor Yellow
    Write-Host "💬 Chat Atual: $CurrentChat" -ForegroundColor Magenta
    Write-Host "" -ForegroundColor Magenta

    Write-Host "📌 Comando:" -ForegroundColor White
    Write-Host "  /exit          → sair"

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
    Write-Host ""
}

function Start-StreamingResponse {
    param([string]$Prompt)

    $Chats[$CurrentChat] += @{
        role    = 'user'
        content = $Prompt
    }

    $body = @{
        model = $MODEL
        messages = $Chats[$CurrentChat]
        temperature = 0.7
        stream = $true
        max_completion_tokens = 4096
    } | ConvertTo-Json -Depth 100

    $request = [System.Net.HttpWebRequest]::Create($API_URL)
    $request.Method = 'POST'
    $request.ContentType = 'application/json'
    $request.Headers.Add('Authorization', "Bearer $API_KEY")

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
    $request.ContentLength = $bytes.Length

    $streamReq = $request.GetRequestStream()
    $streamReq.Write($bytes, 0, $bytes.Length)
    $streamReq.Close()

    $response = $request.GetResponse()
    $reader = New-Object IO.StreamReader($response.GetResponseStream())

    $full = ""

    while (-not $reader.EndOfStream) {
        $line = $reader.ReadLine()

        if ($line -like "data:*") {
            $json = $line.Substring(6)

            if ($json -eq "[DONE]") { break }

            try {
                $obj = $json | ConvertFrom-Json
                $token = $obj.choices[0].delta.content

                if ($token) {
                    $full += $token
                    Write-Host $token -NoNewline
                }
            } catch {}
        }
    }

    Write-Host ""

    $Chats[$CurrentChat] += @{
        role    = 'assistant'
        content = $full
    }

    $reader.Close()
    $response.Close()
}

Show-Banner

while ($true) {

    Write-Host "
[$CurrentChat] Você > " -ForegroundColor Green -NoNewline
    $input = Read-Host

    if ($input -match '^/(exit|sair)$') { break }

    Start-StreamingResponse $input
}
