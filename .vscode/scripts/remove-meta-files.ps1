param(
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceFolder
)

$srcPath = Join-Path $WorkspaceFolder "src"

Write-Host "🗑️ Removendo todos os arquivos init.meta.json..." -ForegroundColor Cyan
Write-Host "Pasta source: $srcPath" -ForegroundColor Gray

if (-not (Test-Path $srcPath)) {
    Write-Host "❌ Pasta src não encontrada em: $srcPath" -ForegroundColor Red
    exit 1
}

try {
    $metaFiles = Get-ChildItem -Path $srcPath -Recurse -Filter "init.meta.json" -ErrorAction Stop
    
    if ($metaFiles.Count -eq 0) {
        Write-Host "✅ Nenhum arquivo init.meta.json encontrado para remover." -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Encontrados $($metaFiles.Count) arquivo(s) init.meta.json" -ForegroundColor Yellow
    
    foreach ($file in $metaFiles) {
        $relativePath = $file.FullName.Replace($WorkspaceFolder, "").TrimStart('\', '/')
        Write-Host "🗑️ Removendo: $relativePath" -ForegroundColor Yellow
        
        try {
            Remove-Item $file.FullName -Force -ErrorAction Stop
            Write-Host "   ✅ Removido com sucesso" -ForegroundColor Green
        }
        catch {
            Write-Host "   ❌ Erro ao remover: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "" 
    Write-Host "🎉 Operação concluída! Todos os arquivos init.meta.json foram processados." -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro ao buscar arquivos: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}