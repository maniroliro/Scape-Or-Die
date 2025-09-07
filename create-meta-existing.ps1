# ===== CRIAR META PARA PASTAS EXISTENTES =====
# Script que cria init.meta.json para todas as pastas existentes no projeto
# Uso: .\create-meta-existing.ps1

Clear-Host
Write-Host "CRIAR META PARA PASTAS EXISTENTES" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcPath = Join-Path $projectPath "src"

if (-not (Test-Path $srcPath)) {
    Write-Host "ERRO: Pasta 'src' nao encontrada!" -ForegroundColor Red
    Write-Host "Certifique-se de executar na raiz do projeto Rojo" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit
}

Write-Host "Procurando pastas em: $srcPath" -ForegroundColor Green
Write-Host ""

# Contar pastas
$allFolders = Get-ChildItem -Path $srcPath -Directory -Recurse
$totalFolders = $allFolders.Count
$createdCount = 0
$existingCount = 0

Write-Host "Encontradas $totalFolders pastas para processar..." -ForegroundColor Yellow
Write-Host ""

# Processar cada pasta
foreach ($folder in $allFolders) {
    $metaFile = Join-Path $folder.FullName "init.meta.json"
    $relativePath = $folder.FullName.Replace($projectPath, "").TrimStart("\")
    
    if (-not (Test-Path $metaFile)) {
        # Criar arquivo
        $content = @'
{
    "ignoreUnknownInstances": true
}
'@
        try {
            $content | Out-File -FilePath $metaFile -Encoding UTF8
            Write-Host "CRIADO: $relativePath\init.meta.json" -ForegroundColor Green
            $createdCount++
        } catch {
            Write-Host "ERRO ao criar: $relativePath\init.meta.json" -ForegroundColor Red
        }
    } else {
        Write-Host "JA EXISTE: $relativePath\init.meta.json" -ForegroundColor Yellow
        $existingCount++
    }
}

Write-Host ""
Write-Host "===== RELATORIO FINAL =====" -ForegroundColor Cyan
Write-Host "Total de pastas: $totalFolders" -ForegroundColor White
Write-Host "Arquivos criados: $createdCount" -ForegroundColor Green
Write-Host "Ja existiam: $existingCount" -ForegroundColor Yellow
Write-Host ""

if ($createdCount -gt 0) {
    Write-Host "SUCESSO! $createdCount arquivos init.meta.json foram criados!" -ForegroundColor Green
} else {
    Write-Host "Todos os arquivos ja existiam!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pressione Enter para sair..." -ForegroundColor Gray
Read-Host
