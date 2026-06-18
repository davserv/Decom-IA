Clear-Host

$items = @(
    "MultIA",
    "Manus",
    "GitHub",
    "Ollama",
    "Cline",
    "GGuf",
    "LMstudio",
    "Gemini",
    "Funcionalidade",
    "Sair"
)

$index = 0
$selected = $null

while ($null -eq $selected) {

    Clear-Host

    Write-Host ""
    Write-Host "████  █████  ███   ███  █   █    ███  ███  " -ForegroundColor Green
    Write-Host "█   █ █     █     █   █ ██ ██     █  █   █ " -ForegroundColor Green
    Write-Host "█   █ ████  █     █   █ █ █ █     █  █████ " -ForegroundColor Green
    Write-Host "█   █ █     █     █   █ █   █     █  █   █ " -ForegroundColor Green
    Write-Host "████  █████  ███   ███  █   █    ███ █   █" -ForegroundColor Green

    Write-Host ""
    Write-Host "          MENU PRINCIPAL AI CHAT" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan

    Write-Host "   ANTES DE SELECIONAR EDITA (chat.ps1)" -ForegroundColor Green
    Write-Host ""

    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($i -eq $index) {
            Write-Host "➜ $($items[$i])" -ForegroundColor Cyan
        }
        else {
            Write-Host "  $($items[$i])"
        }
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan

    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    switch ($key.VirtualKeyCode) {

        38 { # ↑
            if ($index -gt 0) {
                $index--
            }
        }

        40 { # ↓
            if ($index -lt ($items.Count - 1)) {
                $index++
            }
        }

        13 { # Enter
            $selected = $items[$index]
        }
    }
}

Clear-Host
Write-Host "Selecionado: $selected" -ForegroundColor Green

switch ($selected) {

    "MultIA" {
        & ".\wind\chat.ps1"
    }

    "Manus" {
        & ".\manus\wind\chat.ps1"
    }

    "GitHub" {
        & ".\github\wind\chat.ps1"
    }

    "Ollama" {
        & ".\ollama\wind\chat.ps1"
    }

    "Cline" {
        & ".\cline\wind\chat.ps1"
    }

    "GGuf" {
        & ".\gguf\wind\chat.ps1"
    }

    "LMstudio" {
        & ".\lmstudio\wind\chat.ps1"
    }

    "Gemini" {
        & ".\gemini\wind\chat.ps1"
    }

    "Funcionalidade" {
        Start-Process "https://davserv.github.io/Decom-IA/"
        exit
    }

    "Sair" {
        exit
    }
}

Read-Host "Pressione ENTER para sair"
Funcionalidade