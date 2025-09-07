# Script para criar automaticamente init.meta.json em novas pastas
# Uso: .\auto-meta-watcher.ps1

$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcPath = Join-Path $projectPath "src"

Write-Host "Monitorando criação de pastas em: $srcPath" -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar o monitoramento" -ForegroundColor Yellow

# Criar FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $srcPath
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Função para criar init.meta.json
function Create-InitMeta {
    param($Path)
    
    $metaFile = Join-Path $Path "init.meta.json"
    
    # Verificar se já existe
    if (-not (Test-Path $metaFile)) {
        $content = @'
{
    "ignoreUnknownInstances": true
}
'@
        $content | Out-File -FilePath $metaFile -Encoding UTF8
        Write-Host "Criado: $metaFile" -ForegroundColor Cyan
    }
}

# Event handler para quando uma pasta é criada
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    
    # Verificar se é uma pasta e foi criada
    if ($changeType -eq "Created" -and (Test-Path $path -PathType Container)) {
        Start-Sleep -Milliseconds 100  # Pequena pausa para garantir que a pasta está totalmente criada
        Create-InitMeta -Path $path
    }
}

# Registrar o event handler
Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action

# Manter o script rodando
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Limpeza quando o script é interrompido
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-Host "`nMonitoramento parado." -ForegroundColor Red
}
