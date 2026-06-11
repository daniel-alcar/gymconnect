# ============================================================
#  GymConnect - Iniciar TUDO (backend + adb reverse + app Flutter)
#  Uso:  .\iniciar-tudo.ps1   (na raiz do repositorio)
#
#  Pre-requisitos: JDK 21, MySQL 8 (banco 'gymconnect', root/123456),
#  Flutter e um celular/emulador Android conectado (flutter devices).
#  Crie um arquivo .env (copie de .env.example) com a sua keigemini.
# ============================================================

$ErrorActionPreference = 'Stop'
$base = $PSScriptRoot

function Achar($candidatos) {
    foreach ($c in $candidatos) { if (Test-Path $c) { return $c } }
    return $null
}

# Detecta o layout (repositorio: backend/mobile  |  extraido: backend-docker/app-flutter)
$backend = Achar @("$base\backend", "$base\backend-docker\backend")
$app     = Achar @("$base\mobile", "$base\app-flutter")
$envFile = Achar @("$base\.env", "$base\backend-docker\.env")

if (-not $backend) { Write-Host "ERRO: pasta do backend nao encontrada." -ForegroundColor Red; exit 1 }
if (-not $app)     { Write-Host "ERRO: pasta do app Flutter nao encontrada." -ForegroundColor Red; exit 1 }

# Le a chave do Gemini do .env
$keigemini = ''
if ($envFile) {
    $linha = Select-String -Path $envFile -Pattern '^\s*keigemini\s*=' | Select-Object -First 1
    if ($linha) { $keigemini = ($linha.Line -split '=', 2)[1].Trim() }
}
if (-not $keigemini) { $keigemini = 'COLOQUE_SUA_CHAVE_DO_GEMINI' }

Write-Host "`n[1/4] Verificando Java..." -ForegroundColor Cyan
try { java -version } catch { Write-Host "ERRO: JDK 21 nao encontrado." -ForegroundColor Red; exit 1 }

Write-Host "`n[2/4] Iniciando o backend em uma nova janela..." -ForegroundColor Cyan
$inner = "Set-Location -LiteralPath '$backend'; `$env:keigemini='$keigemini'; " +
         "Write-Host 'GymConnect - Backend (nao feche esta janela)' -ForegroundColor Green; " +
         ".\mvnw.cmd spring-boot:run"
Start-Process powershell -ArgumentList '-NoExit', '-Command', $inner | Out-Null

Write-Host "`n[3/4] Aguardando a API subir (pode levar ~30-60s)..." -ForegroundColor Cyan
$pronto = $false
for ($i = 1; $i -le 60; $i++) {
    try {
        Invoke-WebRequest -Uri 'http://localhost:8080/auth/login' -Method POST `
            -Body '{}' -ContentType 'application/json' -TimeoutSec 3 -UseBasicParsing | Out-Null
        $pronto = $true; break
    } catch {
        if ($_.Exception.Response) { $pronto = $true; break }
        Start-Sleep -Seconds 3
        Write-Host "  ...aguardando ($i)" -ForegroundColor DarkGray
    }
}
if ($pronto) { Write-Host "  API no ar em http://localhost:8080" -ForegroundColor Green }
else { Write-Host "  AVISO: a API nao respondeu a tempo. Veja a janela do backend." -ForegroundColor Yellow }

Write-Host "`n[4/4] adb reverse + iniciando o app..." -ForegroundColor Cyan
$adb = (Get-Command adb -ErrorAction SilentlyContinue).Source
if (-not $adb) { $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" }
if (Test-Path $adb) { & $adb reverse tcp:8080 tcp:8080; Write-Host "  adb reverse OK (celular via USB)." -ForegroundColor Green }
else { Write-Host "  adb nao encontrado - se usar emulador, tudo bem." -ForegroundColor Yellow }

Set-Location -LiteralPath $app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080
