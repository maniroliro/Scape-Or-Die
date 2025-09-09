param(
    [string]$WorkspaceFolder
)

$ErrorActionPreference = 'Continue'

$srcPath = Join-Path $WorkspaceFolder 'src'

if (-not (Test-Path $srcPath)) {
    Write-Host 'ERRO: Pasta src nao encontrada!' -ForegroundColor Red
    exit 1
}

Write-Host 'REMOVENDO todos init.meta.json...' -ForegroundColor Red
Get-ChildItem -Path $srcPath -Recurse -Filter 'init.meta.json' | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host 'CRIANDO novos init.meta.json...' -ForegroundColor Green
$folders = Get-ChildItem -Path $srcPath -Directory -Recurse
$created = 0
$content = '{"ignoreUnknownInstances": true}'

foreach ($folder in $folders) {
    $metaPath = Join-Path $folder.FullName 'init.meta.json'
    try {
        [System.IO.File]::WriteAllText($metaPath, $content, [System.Text.UTF8Encoding]::new($false))
        Write-Host ('CRIADO: ' + $folder.FullName.Replace($env:USERPROFILE, '~')) -ForegroundColor Green
        $created++
    } catch {
        Write-Host ('ERRO: ' + $folder.FullName) -ForegroundColor Red
    }
}

Write-Host ('Total criados: ' + $created) -ForegroundColor Cyan
