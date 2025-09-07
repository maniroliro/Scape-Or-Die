# 🚀 ROJO AUTO META - GUIA RÁPIDO

## Como Usar

### Método 1: Monitoramento Automático (Recomendado)
1. **Ctrl + Shift + P** no VS Code
2. Digite: **"Tasks: Run Task"**
3. Escolha: **"🚀 Iniciar Auto Meta Watcher"**
4. Pronto! Agora toda pasta nova terá `init.meta.json` criado automaticamente

### Método 2: Criar para Pasta Específica
1. Abra qualquer arquivo na pasta que você quer
2. **Ctrl + Shift + P**
3. **"Tasks: Run Task"**
4. **"📁 Criar Meta para Pasta Atual"**

### Método 3: Criar para Todas as Pastas Existentes
1. **Ctrl + Shift + P**
2. **"Tasks: Run Task"**
3. **"🗂️ Criar Meta para Todas as Pastas"**

## O que faz o `init.meta.json`?
- Impede que o Rojo apague arquivos/instâncias criados no Roblox Studio
- Cada pasta precisa ter seu próprio arquivo
- Conteúdo: `{"ignoreUnknownInstances": true}`

## Dicas
- ✅ Deixe o Watcher rodando enquanto desenvolve
- ✅ Funciona para qualquer pasta dentro de `src/`
- ✅ Não duplica arquivos se já existirem
- ❌ Para parar o Watcher: Ctrl + C no terminal

---
*Criado automaticamente para facilitar seu workflow com Rojo* 🎯
