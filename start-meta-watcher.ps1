# ===== ROJO AUTO META WATCHER =====
# Script que monitora criacao de pastas e cria init.meta.json automaticamente
# Uso: .\start-meta-watcher.ps1

Clear-Host
Write-Host "ROJO AUTO META WATCHER" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Monitorando criacao de pastas..." -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow
Write-Host ""

$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcPath = Join-Path $projectPath "src"

if (-not (Test-Path $srcPath)) {
    Write-Host "ERRO: Pasta 'src' nao encontrada!" -ForegroundColor Red
    Write-Host "Certifique-se de executar na raiz do projeto Rojo" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit
}

Write-Host "Monitorando: $srcPath" -ForegroundColor Cyan

# Configurar FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $srcPath
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Funcao para criar init.meta.json (apenas em pastas SEM arquivos init)
function Create-InitMeta {
    param($FolderPath)
    
    # Verificar se a pasta tem arquivos init
    $initFiles = @("init.luau", "init.client.luau", "init.server.luau")
    $hasInitFile = $false
    
    foreach ($initFile in $initFiles) {
        $initPath = Join-Path $FolderPath $initFile
        if (Test-Path $initPath) {
            $hasInitFile = $true
            break
        }
    }
    
    if ($hasInitFile) {
        # Pasta tem arquivo init - é um módulo, não deve ter init.meta.json
        $folderName = Split-Path $FolderPath -Leaf
        Write-Host "PULADO (tem init): $folderName" -ForegroundColor Cyan
        return
    }
    
    # Pasta SEM arquivo init - pode ter init.meta.json
    $metaFile = Join-Path $FolderPath "init.meta.json"
    
    if (-not (Test-Path $metaFile)) {
        $content = @'
{
    "ignoreUnknownInstances": true
}
'@
        try {
            $content | Out-File -FilePath $metaFile -Encoding UTF8
            $relativePath = $metaFile.Replace($projectPath, "").TrimStart("\")
            Write-Host "CRIADO: $relativePath" -ForegroundColor Green
        } catch {
            Write-Host "ERRO ao criar: $metaFile" -ForegroundColor Red
        }
    }
}

# Event handler
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    
    if ($changeType -eq "Created" -and (Test-Path $path -PathType Container)) {
        Start-Sleep -Milliseconds 200
        Create-InitMeta -FolderPath $path
    }
}

# Registrar evento
$job = Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action

Write-Host "Monitoramento ativo!" -ForegroundColor Green
Write-Host ""

try {
    # Loop infinito
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Limpeza
    Unregister-Event -SourceIdentifier $job.Name
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-Host ""
    Write-Host "Monitoramento parado." -ForegroundColor Red
}
