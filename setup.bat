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
python -m pip install -r "%~dp0requirements.txt" --quiet
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
claude mcp add salesforce -s user -e SALESFORCE_USERNAME="%SF_USER%" -e SALESFORCE_PASSWORD="%SF_PASS%" -e SALESFORCE_SECURITY_TOKEN="%SF_TOKEN%" -e SALESFORCE_INSTANCE_URL="%SF_INSTANCE%" -- node "%PROXY_PATH%"

if %errorlevel% neq 0 (
    echo  [ERRO] Falha ao registrar no Claude Code.
    echo  Tente manualmente: claude mcp add salesforce -- node "%PROXY_PATH%"
    pause
    exit /b 1
)

echo  [OK] MCP server registrado.

:: Configure CLAUDE.md with SF context
echo.
echo  Configurando contexto do Salesforce...
set CLAUDE_DIR=%USERPROFILE%\.claude
set CLAUDE_MD=%CLAUDE_DIR%\CLAUDE.md
set IMPORT_LINE=@~/mcp-salesforce/claude-context/salesforce_schema.md

if not exist "%CLAUDE_DIR%" mkdir "%CLAUDE_DIR%"

:: Check if line already exists in CLAUDE.md
set ALREADY_EXISTS=0
if exist "%CLAUDE_MD%" (
    findstr /C:"%IMPORT_LINE%" "%CLAUDE_MD%" >nul 2>&1
    if !errorlevel! equ 0 set ALREADY_EXISTS=1
)

if !ALREADY_EXISTS! equ 1 (
    echo  [OK] Contexto do Salesforce ja configurado.
) else (
    (echo(%IMPORT_LINE%)>>"%CLAUDE_MD%"
    echo  [OK] Contexto do Salesforce adicionado ao CLAUDE.md.
)

echo.
echo  ==========================================
echo   Setup concluido!
echo  ==========================================
echo.
echo  Proximo passo: reinicie o VS Code.
echo  Depois, abra o Claude Code e pergunte algo como:
echo    "Quais sao os projetos M^&A ativos?"
echo.
pause
