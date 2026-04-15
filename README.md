# MCP Salesforce — RGS Partners

Servidor MCP que conecta o Claude Code ao Salesforce da RGS. Permite consultar dados, criar e atualizar registros usando linguagem natural.

## O que faz

Depois do setup, você pode perguntar ao Claude coisas como:

- "Quais são meus projetos ativos pós-NBO?"
- "Quantas QMs minha célula fez esse semestre?"
- "Qual o fee estimado do projeto Aurora?"
- "Cria uma oportunidade para a empresa X, serviço M&A, tipo Inbound"

O Claude gera as queries automaticamente — você não precisa saber SOQL.

## Pré-requisitos

- **Claude Code** instalado ([download](https://claude.ai/download))
- **Python 3.10+** instalado e no PATH ([download](https://www.python.org/downloads/))
- **Node.js 18+** instalado e no PATH ([download](https://nodejs.org/))
- **Credenciais do Salesforce**: username, password e security token

## Setup (3 minutos)

### Windows

```
git clone https://github.com/andrelevyw/mcp-salesforce.git
cd mcp-salesforce
setup.bat
```

O script vai:
1. Verificar que Python e Claude Code estão instalados
2. Instalar as dependências Python
3. Pedir suas credenciais do Salesforce
4. Registrar o MCP server no Claude Code

Depois, **reinicie o Claude Code** e pronto.

### Manual (se o script não funcionar)

1. Instalar dependências:
   ```
   pip install -r requirements.txt
   ```

2. Registrar no Claude Code:
   ```
   claude mcp add salesforce -s user -- node "C:\caminho\para\mcp-salesforce\proxy.js" -e SALESFORCE_USERNAME="seu@email.com" -e SALESFORCE_PASSWORD="suasenha" -e SALESFORCE_SECURITY_TOKEN="seutoken" -e SALESFORCE_INSTANCE_URL="https://d1h000000oliluag.my.salesforce.com"
   ```

3. Reiniciar o Claude Code.

## Como obter o Security Token do Salesforce

1. Faça login no Salesforce
2. Clique no seu avatar (canto superior direito) → **Settings**
3. No menu lateral: **My Personal Information** → **Reset My Security Token**
4. Clique em **Reset Security Token**
5. O token será enviado para o seu e-mail

## Contexto opcional (melhora a experiência)

A pasta `claude-context/` contém o schema dos objetos do Salesforce da RGS. Se você copiar esse arquivo para o seu CLAUDE.md, o Claude já vai saber os campos e objetos sem precisar consultar o SF a cada pergunta.

Para usar, adicione ao seu `~/.claude/CLAUDE.md`:

```
@caminho/para/mcp-salesforce/claude-context/salesforce_schema.md
```

## Tools disponíveis

| Tool | O que faz |
|---|---|
| `salesforce_query` | Executa queries SOQL (SELECT) |
| `salesforce_aggregate` | Queries com COUNT, SUM, AVG |
| `salesforce_search` | Busca full-text via SOSL |
| `salesforce_describe` | Descreve campos de um objeto |
| `salesforce_create` | Cria um novo registro |
| `salesforce_update` | Atualiza um registro existente |

## Segurança

- Cada pessoa usa **suas próprias credenciais** — as permissões do SF são respeitadas
- Credenciais ficam no settings do Claude Code local, nunca no repositório
- O arquivo `credentials.json` está no `.gitignore` (nunca commitar credenciais)

## Troubleshooting

**"Python não encontrado"** — Instale Python e marque "Add to PATH" durante a instalação.

**"Erro de autenticação no Salesforce"** — Verifique username, password e security token. O token é resetado quando você muda de senha.

**"MCP server não aparece"** — Reinicie o Claude Code. Se não resolver, rode `claude mcp list` para verificar se o server está registrado.
