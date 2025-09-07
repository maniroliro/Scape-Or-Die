const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

let fileWatcher;
let isEnabled = true;

function activate(context) {
    console.log('Rojo Auto Meta extension is now active!');

    // Carregar configuração
    const config = vscode.workspace.getConfiguration('rojoAutoMeta');
    isEnabled = config.get('enabled', true);

    // Comando para criar meta manualmente
    const createMetaCommand = vscode.commands.registerCommand('rojoAutoMeta.createMeta', async () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('Nenhum arquivo aberto');
            return;
        }

        const currentDir = path.dirname(editor.document.uri.fsPath);
        await createInitMeta(currentDir);
    });

    // Comando para alternar auto-criação
    const toggleCommand = vscode.commands.registerCommand('rojoAutoMeta.toggleAutoCreate', () => {
        isEnabled = !isEnabled;
        vscode.window.showInformationMessage(
            `Criação automática: ${isEnabled ? 'Habilitada' : 'Desabilitada'}`
        );
        
        if (isEnabled) {
            startWatching();
        } else {
            stopWatching();
        }
    });

    // Iniciar monitoramento se habilitado
    if (isEnabled) {
        startWatching();
    }

    context.subscriptions.push(createMetaCommand, toggleCommand);
}

function startWatching() {
    if (fileWatcher) {
        fileWatcher.dispose();
    }

    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (!workspaceFolders) return;

    // Procurar por projetos Rojo
    for (const folder of workspaceFolders) {
        const projectJsonPath = path.join(folder.uri.fsPath, 'default.project.json');
        if (fs.existsSync(projectJsonPath)) {
            // Monitorar apenas a pasta src
            const srcPath = path.join(folder.uri.fsPath, 'src');
            if (fs.existsSync(srcPath)) {
                watchDirectory(srcPath);
            }
        }
    }
}

function watchDirectory(dirPath) {
    const pattern = new vscode.RelativePattern(dirPath, '**');
    fileWatcher = vscode.workspace.createFileSystemWatcher(pattern);

    fileWatcher.onDidCreate(async (uri) => {
        if (!isEnabled) return;

        // Verificar se é uma pasta
        try {
            const stat = await vscode.workspace.fs.stat(uri);
            if (stat.type === vscode.FileType.Directory) {
                // Aguardar um pouco para garantir que a pasta foi totalmente criada
                setTimeout(() => {
                    createInitMeta(uri.fsPath);
                }, 100);
            }
        } catch (error) {
            // Ignorar erros de stat
        }
    });
}

async function createInitMeta(dirPath) {
    const metaPath = path.join(dirPath, 'init.meta.json');
    
    try {
        // Verificar se já existe
        await vscode.workspace.fs.stat(vscode.Uri.file(metaPath));
        return; // Já existe
    } catch {
        // Não existe, criar
    }

    const content = JSON.stringify({
        "ignoreUnknownInstances": true
    }, null, 4);

    try {
        await vscode.workspace.fs.writeFile(
            vscode.Uri.file(metaPath),
            Buffer.from(content, 'utf8')
        );
        
        vscode.window.showInformationMessage(
            `Criado: ${path.relative(vscode.workspace.rootPath || '', metaPath)}`
        );
    } catch (error) {
        vscode.window.showErrorMessage(`Erro ao criar init.meta.json: ${error.message}`);
    }
}

function stopWatching() {
    if (fileWatcher) {
        fileWatcher.dispose();
        fileWatcher = null;
    }
}

function deactivate() {
    stopWatching();
}

module.exports = {
    activate,
    deactivate
};
