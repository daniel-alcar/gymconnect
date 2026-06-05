# ============================================================
#  GymConnect - Subir o backend SEM Docker (Windows / PowerShell)
#  Uso:  .\run-backend-local.ps1   (na pasta backend)
#
#  Pre-requisitos: JDK 21 e MySQL 8 (banco 'teste_gymconnect').
#  A chave do Gemini e lida do arquivo .env (um nivel acima desta pasta).
# ============================================================

$ErrorActionPreference = 'Stop'

# Ajuste aqui se a senha do root do seu MySQL nao for 123456:
$MYSQL_ROOT_PASSWORD = '123456'

# Le a chave do Gemini: variavel de ambiente OU ..\.env (keigemini=...)
$keigemini = $env:keigemini
$envFile = Join-Path $PSScriptRoot '..\.env'
if (-not $keigemini -and (Test-Path $envFile)) {
    $linha = Select-String -Path $envFile -Pattern '^\s*keigemini\s*=' | Select-Object -First 1
    if ($linha) { $keigemini = ($linha.Line -split '=', 2)[1].Trim() }
}
if (-not $keigemini) {
    Write-Host "AVISO: 'keigemini' nao encontrada (.env). O Chat IA (GIA) pode retornar 502." -ForegroundColor Yellow
    $keigemini = 'COLOQUE_SUA_CHAVE_DO_GEMINI'
}

Write-Host "Verificando Java..." -ForegroundColor Cyan
try { java -version } catch {
    Write-Host "ERRO: JDK 21 nao encontrado no PATH." -ForegroundColor Red
    exit 1
}

# Perfil 'prod' usa estas variaveis para conectar ao MySQL local.
$env:SPRING_PROFILES_ACTIVE = 'prod'
$env:MYSQL_HOST = 'localhost'
$env:MYSQL_DATABASE = 'teste_gymconnect'
$env:MYSQL_USER = 'root'
$env:MYSQL_PASSWORD = $MYSQL_ROOT_PASSWORD
$env:JWT_SECRET = 'my-secret-key'
$env:keigemini = $keigemini

Write-Host "`nSubindo o backend em http://localhost:8080 (Ctrl+C para parar)...`n" -ForegroundColor Green
.\mvnw.cmd spring-boot:run
