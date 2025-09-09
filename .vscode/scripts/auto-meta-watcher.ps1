param(
    [string]$WorkspaceFolder
)

$ErrorActionPreference = 'Continue'

$srcPath = Join-Path $WorkspaceFolder 'src'

if (-not (Test-Path $srcPath)) {
    Write-Host 'ERRO: Pasta src nao encontrada!' -ForegroundColor Red
    Read-Host 'Press Enter'
    return
}

Write-Host 'AUTO META WATCHER' -ForegroundColor Cyan
Write-Host ('Monitorando: ' + $srcPath) -ForegroundColor Green

$content = '{"ignoreUnknownInstances": true}'

# Varredura inicial - criar meta para pastas existentes
Get-ChildItem -Path $srcPath -Directory -Recurse | ForEach-Object {
    $meta = Join-Path $_.FullName 'init.meta.json'
    if (-not (Test-Path $meta)) {
        [System.IO.File]::WriteAllText($meta, $content, [System.Text.UTF8Encoding]::new($false))
        Write-Host ('CRIADO: ' + $meta.Replace($env:USERPROFILE, '~')) -ForegroundColor Green
    }
}

# Criar watcher para novas pastas
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $srcPath
$watcher.IncludeSubdirectories = $true
$watcher.Filter = '*'
$watcher.NotifyFilter = [IO.NotifyFilters]'DirectoryName'
$watcher.EnableRaisingEvents = $true

$action = {
    try {
        $eventArgs = $Event.SourceEventArgs
        $path = $eventArgs.FullPath
        
        if (Test-Path $path -PathType Container) {
            Start-Sleep -Milliseconds 300
            $metaFile = Join-Path $path 'init.meta.json'
            
            if (-not (Test-Path $metaFile)) {
                $contentLocal = '{"ignoreUnknownInstances": true}'
                [System.IO.File]::WriteAllText($metaFile, $contentLocal, [System.Text.UTF8Encoding]::new($false))
                Write-Host ('CRIADO: ' + $metaFile.Replace($env:USERPROFILE, '~')) -ForegroundColor Green
            }
        }
    } catch {
        Write-Host ('ERRO watcher: ' + $_) -ForegroundColor Red
    }
}

$sub1 = Register-ObjectEvent -InputObject $watcher -EventName 'Created' -Action $action
$sub2 = Register-ObjectEvent -InputObject $watcher -EventName 'Renamed' -Action $action

Write-Host 'Watcher ativo. Ctrl+C para parar.' -ForegroundColor Yellow

try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    if ($sub1) { Unregister-Event -SourceIdentifier $sub1.Name }
    if ($sub2) { Unregister-Event -SourceIdentifier $sub2.Name }
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
}
