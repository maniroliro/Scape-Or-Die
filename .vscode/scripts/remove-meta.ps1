param(
    [string]$WorkspaceFolder
)

$srcPath = Join-Path $WorkspaceFolder 'src'

if (Test-Path $srcPath) {
    Get-ChildItem -Path $srcPath -Recurse -Filter 'init.meta.json' | ForEach-Object {
        Write-Host ('Removendo: ' + $_.FullName) -ForegroundColor Yellow
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
    }
    Write-Host 'Todos removidos!' -ForegroundColor Green
} else {
    Write-Host 'Pasta src nao encontrada!' -ForegroundColor Red
}
