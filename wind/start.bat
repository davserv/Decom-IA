@echo off
title Chat Decom IA

echo Iniciando...

:: Executa PowerShell automaticamente
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0chat.ps1'"

pause