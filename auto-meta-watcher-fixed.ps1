# ===== ROJO AUTO META WATCHER - VERSAO CORRIGIDA =====
# Monitora criacao de pastas e cria init.meta.json automaticamente
# APENAS em pastas SEM arquivos init (init.luau, init.client.luau, init.server.luau)

Clear-Host
Write-Host "ROJO AUTO META WATCHER - VERSAO CORRIGIDA" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Monitorando criacao de pastas SEM arquivos init..." -ForegroundColor Green
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

# Funcao para criar init.meta.json em TODAS as pastas com encoding correto
function Create-InitMeta {
    param($FolderPath)
    
    # Aguardar um pouco para pasta ser criada completamente
    Start-Sleep -Milliseconds 500
    
    # Criar init.meta.json sempre (sem verificar arquivos init)
    $metaFile = Join-Path $FolderPath "init.meta.json"
    
    if (-not (Test-Path $metaFile)) {
        $content = '{"ignoreUnknownInstances": true}'
        
        try {
            # Usar encoding UTF8 sem BOM para evitar problemas no Rojo
            [System.IO.File]::WriteAllText($metaFile, $content, [System.Text.UTF8Encoding]::new($false))
            $relativePath = $metaFile.Replace($projectPath, "").TrimStart("\")
            Write-Host "CRIADO: $relativePath" -ForegroundColor Green
        } catch {
            Write-Host "ERRO ao criar: $metaFile" -ForegroundColor Red
        }
    }
}

# Event handler para quando uma pasta é criada
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    
    if ($changeType -eq "Created" -and (Test-Path $path -PathType Container)) {
        Create-InitMeta -FolderPath $path
    }
}

# Registrar evento
$job = Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action

Write-Host "Monitoramento ativo!" -ForegroundColor Green
Write-Host "Crie uma pasta nova para testar..." -ForegroundColor Yellow
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
