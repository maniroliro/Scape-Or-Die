# Como aplicar as configurações de Luau globalmente no VS Code

## Passo a passo:

1. **Abra o settings.json global do VS Code:**
   - Pressione `Ctrl + Shift + P`
   - Digite "Preferences: Open Settings (JSON)"
   - Ou use o menu: File > Preferences > Settings > clique no ícone {} no canto superior direito

2. **Copie e cole as configurações abaixo no seu settings.json global:**

**IMPORTANTE:** Se você já tiver algumas dessas configurações no seu settings.json global, substitua ou adicione apenas as que não existem. O VS Code aceita comentários no settings.json (formato JSONC).

```jsonc
{
  // Suas outras configurações existentes...
  
  // === CONFIGURAÇÕES GLOBAIS PARA LUAU ===
  
  "[lua]": {
    "editor.defaultFormatter": "JohnnyMorganz.stylua",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "always"
    }
  },
  "[luau]": {
    "editor.defaultFormatter": "JohnnyMorganz.stylua",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "always"
    }
  },
  
  "workbench.editor.customLabels.patterns": {
    "**/init.lua": "${dirname} (${filename}.${extname})",
    "**/init.luau": "${dirname} (${filename}.${extname})",
    "**/init.client.luau": "${dirname} (${filename}.${extname})",
    "**/init.server.luau": "${dirname} (${filename}.${extname})"
  },
  
  "luau-lsp.platform.type": "roblox",
  "luau-lsp.diagnostics.workspace": true,
  
  "editor.semanticHighlighting.enabled": false,
  
  "workbench.colorCustomizations": {
    "editor.background": "#252525",
    "editor.foreground": "#CCCCCC",
    "editor.selectionBackground": "#0B5AAF",
    "editor.selectionForeground": "#FFFFFF",
    "editor.lineHighlightBackground": "#2D3241",
    "editor.findMatchBackground": "#8D7600",
    "editor.wordHighlightBackground": "#55555566",
    "editor.rulers": ["#666666"],
    "editorWhitespace.foreground": "#555555",
    "editorBracketHighlight.foreground1": "#CCCCCC",
    "editorBracketHighlight.foreground2": "#CCCCCC",
    "editorBracketHighlight.foreground3": "#CCCCCC",
    "editorBracketHighlight.foreground4": "#CCCCCC",
    "editorBracketHighlight.foreground5": "#CCCCCC",
    "editorBracketHighlight.foreground6": "#CCCCCC"
  },
  
  "editor.tokenColorCustomizations": {
    "textMateRules": [
      {
        "scope": ["variable.property.luau"],
        "settings": {
          "foreground": "#CCCCCC"
        }
      },
      {
        "scope": ["keyword.operator.typeof.luau"],
        "settings": {
          "foreground": "#F86D7C",
          "fontStyle": "bold"
        }
      },
      {
        "scope": [
          "keyword",
          "keyword.control",
          "storage.type",
          "storage.modifier"
        ],
        "settings": {
          "foreground": "#F86D7C",
          "fontStyle": "bold"
        }
      },
      {
        "scope": [
          "variable.language.special.self",
          "variable.language.self",
          "variable.language.self.luau",
          "variable.language.super",
          "variable.language.this"
        ],
        "settings": {
          "foreground": "#F86D7C"
        }
      },
      {
        "scope": ["support.function"],
        "settings": {
          "foreground": "#84D6F7"
        }
      },
      {
        "scope": [
          "variable.parameter",
          "variable.other.readwrite",
          "variable.other.luau"
        ],
        "settings": {
          "foreground": "#CCCCCC"
        }
      },
      {
        "scope": [
          "punctuation.separator",
          "punctuation.terminator",
          "punctuation.accessor",
          "punctuation.section.brackets",
          "punctuation.section.braces",
          "punctuation.section.parens",
          "punctuation.definition.table",
          "meta.brace"
        ],
        "settings": {
          "foreground": "#CCCCCC"
        }
      },
      {
        "scope": [
          "meta.table.key",
          "entity.name.tag",
          "string.unquoted",
          "constant.other.key"
        ],
        "settings": {
          "foreground": "#CCCCCC"
        }
      },
      {
        "scope": [
          "comment",
          "punctuation.definition.comment"
        ],
        "settings": {
          "foreground": "#666666",
          "fontStyle": "italic"
        }
      },
      {
        "scope": [
          "constant.language.boolean.true",
          "constant.language.boolean.false",
          "constant.language.nil"
        ],
        "settings": {
          "foreground": "#FFC600",
          "fontStyle": "bold"
        }
      },
      {
        "scope": [
          "string.quoted.single",
          "string.quoted.double",
          "string",
          "punctuation.definition.string"
        ],
        "settings": {
          "foreground": "#ADF195"
        }
      },
      {
        "scope": [
          "entity.name.function",
          "entity.name.function.method"
        ],
        "settings": {
          "foreground": "#FDFBAC"
        }
      },
      {
        "scope": [
          "constant.numeric",
          "variable.other.constant.luau"
        ],
        "settings": {
          "foreground": "#FFC600"
        }
      },
      {
        "scope": [
          "keyword.operator",
          "meta.template.expression.ts"
        ],
        "settings": {
          "foreground": "#cccccc"
        }
      },
      {
        "scope": [
          "entity.other.attribute",
          "variable.language.metamethod",
          "variable.other.property",
          "meta.attribute",
          "meta.member.access"
        ],
        "settings": {
          "foreground": "#61A1F1"
        }
      },
      {
        "scope": [
          "entity.name.type",
          "support.type",
          "support.constant.luau"
        ],
        "settings": {
          "foreground": "#00FFFF"
        }
      }
    ]
  }
  
  // Suas outras configurações existentes continuam aqui...
}
```

3. **Salve o arquivo** (Ctrl + S)

4. **Reinicie o VS Code** para garantir que todas as configurações sejam aplicadas

## O que essas configurações fazem:

- **Formatação automática** com StyLua para arquivos .lua e .luau
- **Labels customizados** para arquivos init (mostra o nome da pasta)
- **Configurações do Luau LSP** para Roblox
- **Tema de cores** baseado no Roblox Studio Next Gen
- **Syntax highlighting personalizado** para Luau com cores específicas:
  - Keywords: Rosa (#F86D7C)
  - Functions (require, setmetatable): Azul claro (#84D6F7)
  - Strings: Verde claro (#ADF195)
  - Numbers: Amarelo (#FFC600)
  - Comments: Cinza (#666666)
  - E muito mais...

## Após aplicar:

Todos os projetos de Luau/Lua que você abrir no VS Code terão automaticamente essas configurações de cores e formatação aplicadas!
