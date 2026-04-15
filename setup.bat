@echo off
setlocal enabledelayedexpansion

echo.
echo  ==========================================
echo   MCP Salesforce - Setup RGS Partners
echo  ==========================================
echo.

:: Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Python nao encontrado no PATH.
    echo  Instale em https://www.python.org/downloads/ e marque "Add to PATH".
    pause
    exit /b 1
)
echo  [OK] Python encontrado.

:: Check Claude Code
claude --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Claude Code nao encontrado no PATH.
    echo  Instale em https://claude.ai/download
    pause
    exit /b 1
)
echo  [OK] Claude Code encontrado.

:: Install dependencies
echo.
echo  Instalando dependencias Python...
pip install -r "%~dp0requirements.txt" --quiet
if %errorlevel% neq 0 (
    echo  [ERRO] Falha ao instalar dependencias.
    pause
    exit /b 1
)
echo  [OK] Dependencias instaladas.

:: Collect credentials
echo.
echo  ------------------------------------------
echo   Credenciais do Salesforce
echo  ------------------------------------------
echo.
echo  Seu usuario do Salesforce (ex: nome@rgspartners.com.br)
set /p SF_USER="  Username: "

echo.
echo  Sua senha do Salesforce
set /p SF_PASS="  Password: "

echo.
echo  Seu Security Token do Salesforce
echo  (Setup ^> My Personal Information ^> Reset My Security Token)
set /p SF_TOKEN="  Security Token: "

echo.
set SF_INSTANCE=https://d1h000000oliluag.my.salesforce.com
echo  Instance URL [enter = %SF_INSTANCE%]:
set /p SF_INSTANCE_INPUT="  Instance URL: "
if not "!SF_INSTANCE_INPUT!"=="" set SF_INSTANCE=!SF_INSTANCE_INPUT!

:: Get absolute path to proxy.js
set PROXY_PATH=%~dp0proxy.js

:: Register MCP server in Claude Code
echo.
echo  Registrando MCP server no Claude Code...
claude mcp add salesforce -s user -- node "%PROXY_PATH%" -e SALESFORCE_USERNAME="%SF_USER%" -e SALESFORCE_PASSWORD="%SF_PASS%" -e SALESFORCE_SECURITY_TOKEN="%SF_TOKEN%" -e SALESFORCE_INSTANCE_URL="%SF_INSTANCE%"

if %errorlevel% neq 0 (
    echo  [ERRO] Falha ao registrar no Claude Code.
    echo  Tente manualmente: claude mcp add salesforce -- node "%PROXY_PATH%"
    pause
    exit /b 1
)

echo  [OK] MCP server registrado.

echo.
echo  ==========================================
echo   Setup concluido!
echo  ==========================================
echo.
echo  Proximo passo: reinicie o Claude Code.
echo  Depois, pergunte algo como:
echo    "Quais sao meus projetos ativos?"
echo.
pause
