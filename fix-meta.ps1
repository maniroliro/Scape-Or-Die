# Script para criar init.meta.json em TODAS AS PASTAS com encoding correto

Write-Host "=== CRIACAO DE INIT.META.JSON EM TODAS AS PASTAS ===" -ForegroundColor Yellow

$srcPath = "src"

if (Test-Path $srcPath) {
    # Primeiro, remover TODOS os arquivos existentes para evitar problemas de encoding
    Write-Host "Removendo todos os init.meta.json existentes..." -ForegroundColor Red
    Get-ChildItem -Path $srcPath -Recurse -Filter "init.meta.json" | Remove-Item -Force
    
    Write-Host "Criando init.meta.json em TODAS as pastas..." -ForegroundColor Green
    
    $folders = Get-ChildItem -Path $srcPath -Directory -Recurse
    $created = 0
    
    # Conteudo do arquivo (sem BOM, encoding correto)
    $content = '{"ignoreUnknownInstances": true}'
    
    foreach ($folder in $folders) {
        $metaPath = Join-Path $folder.FullName "init.meta.json"
        
        try {
            # Criar arquivo com encoding UTF8 sem BOM
            [System.IO.File]::WriteAllText($metaPath, $content, [System.Text.UTF8Encoding]::new($false))
            Write-Host "CRIADO: $($folder.Name)" -ForegroundColor Green
            $created++
        } catch {
            Write-Host "ERRO ao criar: $($folder.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "=== RESULTADO ===" -ForegroundColor Cyan
    Write-Host "Total criados: $created" -ForegroundColor Green
    Write-Host "Todas as pastas agora tem init.meta.json!" -ForegroundColor Green
    
} else {
    Write-Host "ERRO: Pasta src nao encontrada!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Concluido! Agora teste o rojo serve." -ForegroundColor Green
