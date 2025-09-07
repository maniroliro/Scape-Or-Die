# Script para criar init.meta.json apenas em pastas SEM arquivos init (pastas reais do Roblox)

$srcPath = Join-Path $PSScriptRoot "src"

if (Test-Path $srcPath) {
    Write-Host "Procurando pastas SEM arquivos init em src..." -ForegroundColor Green
    
    $folders = Get-ChildItem -Path $srcPath -Directory -Recurse
    $created = 0
    $skipped = 0
    $existing = 0
    
    foreach ($folder in $folders) {
        $metaFile = Join-Path $folder.FullName "init.meta.json"
        
        # Verificar se a pasta tem arquivos init (init.luau, init.client.luau, init.server.luau)
        $hasInitFile = $false
        $initFiles = @("init.luau", "init.client.luau", "init.server.luau")
        
        foreach ($initFile in $initFiles) {
            $initPath = Join-Path $folder.FullName $initFile
            if (Test-Path $initPath) {
                $hasInitFile = $true
                break
            }
        }
        
        if ($hasInitFile) {
            # Pasta tem arquivo init - é um módulo, não deve ter init.meta.json
            Write-Host "PULADO (tem init): $($folder.Name)" -ForegroundColor Cyan
            $skipped++
            
            # Se existir init.meta.json, vamos remover pois não deveria estar lá
            if (Test-Path $metaFile) {
                Remove-Item $metaFile -Force
                Write-Host "REMOVIDO meta de: $($folder.Name)" -ForegroundColor Red
            }
        } else {
            # Pasta SEM arquivo init - é uma pasta real, deve ter init.meta.json
            if (-not (Test-Path $metaFile)) {
                $content = '{"ignoreUnknownInstances": true}'
                $content | Out-File -FilePath $metaFile -Encoding UTF8
                Write-Host "CRIADO: $($folder.Name)" -ForegroundColor Green
                $created++
            } else {
                Write-Host "JA EXISTE: $($folder.Name)" -ForegroundColor Yellow
                $existing++
            }
        }
    }
    
    Write-Host ""
    Write-Host "RELATORIO:" -ForegroundColor Cyan
    Write-Host "Criados: $created" -ForegroundColor Green
    Write-Host "Ja existiam: $existing" -ForegroundColor Yellow
    Write-Host "Pulados (tem init): $skipped" -ForegroundColor Cyan
    
} else {
    Write-Host "ERRO: Pasta src nao encontrada!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Pressione Enter para continuar..."
Read-Host
