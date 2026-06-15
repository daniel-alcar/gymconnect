$backendPath = Join-Path $PSScriptRoot "backend"
$m2Path     = Join-Path $env:USERPROFILE ".m2"

docker run --rm `
  --volume "${backendPath}:/app" `
  --volume "${m2Path}:/root/.m2" `
  --workdir /app `
  maven:3.9-eclipse-temurin-21 `
  mvn test --batch-mode
