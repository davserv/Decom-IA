
$API_URL = "http://localhost:8080/v1/chat/completions"
$MODEL   = "LFM2-350M-Q4_0.gguf"
$API_KEY = ""

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

try {
    chcp 65001 > $null
} catch {}

$ChatFolder = Join-Path $PSScriptRoot "chats"

if (-not (Test-Path $ChatFolder)) {
    New-Item -ItemType Directory -Path $ChatFolder | Out-Null
}

$SystemPrompt = "Você é um assistente inteligente estilo Decom IA."

$Chats = @{}
$CurrentChat = "principal"

function Save-Chat($Name) {

    $file = Join-Path $ChatFolder "$Name.json"

    $Chats[$Name] |
        ConvertTo-Json -Depth 100 |
        Set-Content $file -Encoding UTF8
}

function Load-Chats {

    $files = Get-ChildItem $ChatFolder -Filter *.json -ErrorAction SilentlyContinue

    foreach ($f in $files) {

        try {

            $data = Get-Content $f.FullName -Raw | ConvertFrom-Json

            $arr = @()

            foreach ($m in $data) {

                $arr += @{
                    role    = $m.role
                    content = $m.content
                }
            }

            $script:Chats[$f.BaseName] = $arr

        } catch {}
    }

    if ($script:Chats.Count -eq 0) {

        $script:Chats["principal"] = @(
            @{
                role    = "system"
                content = $SystemPrompt
            }
        )
    }
}

function Show-Banner {

    Clear-Host

    Write-Host ""
    Write-Host "████  █████  ███   ███  █   █    ███  ███" -ForegroundColor Green
    Write-Host "█   █ █     █     █   █ ██ ██     █  █   █" -ForegroundColor Green
    Write-Host "█   █ ████  █     █   █ █ █ █     █  █████" -ForegroundColor Green
    Write-Host "█   █ █     █     █   █ █   █     █  █   █" -ForegroundColor Green
    Write-Host "████  █████  ███   ███  █   █    ███ █   █" -ForegroundColor Green

    Write-Host ""
    Write-Host "     AI TERMINAL • STREAMING EDITION" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan

    Write-Host "Modelo: $MODEL" -ForegroundColor Yellow
    Write-Host "Chat Atual: $CurrentChat" -ForegroundColor Magenta

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

function Start-StreamingResponse([string]$Prompt) {

    $Chats[$CurrentChat] += @{
        role    = "user"
        content = $Prompt
    }

    $body = @{
        model    = $MODEL
        messages = $Chats[$CurrentChat]
        stream   = $true
    } | ConvertTo-Json -Depth 100

    try {

        $request = [System.Net.HttpWebRequest]::Create($API_URL)
        $request.Method = "POST"
        $request.ContentType = "application/json"

        if (-not [string]::IsNullOrWhiteSpace($API_KEY)) {
            $request.Headers.Add("Authorization", "Bearer $API_KEY")
        }

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)

        $request.ContentLength = $bytes.Length

        $reqStream = $request.GetRequestStream()
        $reqStream.Write($bytes, 0, $bytes.Length)
        $reqStream.Close()

        $response = $request.GetResponse()

        $reader = New-Object System.IO.StreamReader(
            $response.GetResponseStream()
        )

        $fullResponse = ""

        Write-Host ""
        Write-Host "🤖 IA:" -ForegroundColor Green
        Write-Host ""

        while (-not $reader.EndOfStream) {

            $line = $reader.ReadLine()

            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            if ($line.StartsWith("data: ")) {
                $line = $line.Substring(6)
            }

            if ($line -eq "[DONE]") {
                break
            }

            try {

                $json = $line | ConvertFrom-Json

                if ($json.choices[0].delta.content) {

                    $token = $json.choices[0].delta.content

                    $fullResponse += $token

                    Write-Host -NoNewline $token
                }
                elseif ($json.choices[0].message.content) {

                    $token = $json.choices[0].message.content

                    $fullResponse += $token

                    Write-Host -NoNewline $token
                }

            } catch {}
        }

        Write-Host ""
        Write-Host ""

        $Chats[$CurrentChat] += @{
            role    = "assistant"
            content = $fullResponse
        }

        Save-Chat $CurrentChat

        $reader.Close()
        $response.Close()

    } catch {

        Write-Host ""
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

Load-Chats
Show-Banner

while ($true) {

    Write-Host "[$CurrentChat]" -ForegroundColor Magenta -NoNewline
    Write-Host " Você > " -ForegroundColor Green -NoNewline

    $PERGUNTA = Read-Host

    if ([string]::IsNullOrWhiteSpace($PERGUNTA)) {
        continue
    }

    if ($PERGUNTA -match '^/(exit|sair)$') {
        break
    }

    if ($PERGUNTA -match '^/clear$') {
        Show-Banner
        continue
    }

    if ($PERGUNTA -match '^/list$') {

        $Chats.Keys |
            Sort-Object |
            ForEach-Object { Write-Host $_ }

        continue
    }

    if ($PERGUNTA -match '^/new\s+(.+)$') {

        $name = $Matches[1].Trim()

        $Chats[$name] = @(
            @{
                role    = "system"
                content = $SystemPrompt
            }
        )

        $CurrentChat = $name

        Save-Chat $name

        continue
    }

    if ($PERGUNTA -match '^/switch\s+(.+)$') {

        $name = $Matches[1].Trim()

        if ($Chats.ContainsKey($name)) {
            $CurrentChat = $name
        }

        continue
    }

    if ($PERGUNTA -match '^/delete\s+(.+)$') {

        $name = $Matches[1].Trim()

        if (
            $name -ne "principal" -and
            $Chats.ContainsKey($name)
        ) {

            $Chats.Remove($name)

            Remove-Item (
                Join-Path $ChatFolder "$name.json"
            ) -ErrorAction SilentlyContinue

            $CurrentChat = "principal"
        }

        continue
    }

    Start-StreamingResponse $PERGUNTA
}

Write-Host ""
Write-Host "Até logo!" -ForegroundColor Green
Write-Host ""