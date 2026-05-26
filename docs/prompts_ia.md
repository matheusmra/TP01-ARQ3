# Registro de Uso de Inteligência Artificial

Este documento registra todos os prompts utilizados durante o desenvolvimento do projeto,
conforme exigido pela **Seção 8** do enunciado do trabalho.

**Ferramenta utilizada:** Antigravity CLI — Modelo Claude Opus 4.6 (Thinking)
**Metodologia:** Spec-Driven Development (SDD)

---

## Prompt 1 — Estruturação do Repositório e Criação de Issues

**Objetivo:** Definir a estrutura de diretórios do projeto e criar as issues no GitHub para organizar o desenvolvimento.

### Prompt

> Analise o enunciado do trabalho (`Enunciado.md`) e, com base nele, me ajude a estruturar o repositório do projeto.
> Além disso, crie issues no GitHub para organizar o trabalho. Para cada issue, gere um body em Markdown e utilize o
> GitHub CLI (`gh`) para cadastrá-las no repositório.

### Resposta (resumo)

A IA analisou o enunciado e propôs:

- **Estrutura de diretórios:**
  - `rtl/` — Código-fonte SystemVerilog (módulos RTL)
  - `tb/` — Testbenches para validação funcional
  - `sim/` — Scripts de simulação (Makefile, shell scripts)
  - `docs/` — Documentação e relatório (PDF)

- **Arquivos base criados:** `.gitignore`, `README.md`

- **10 issues propostas inicialmente**, organizadas em: infraestrutura, implementação RTL, testes e documentação.

- **Labels criadas no repositório:** `rtl`, `implementação`, `teste`, `testbench`, `documentação`, `infra`, `simulação`

---

## Prompt 2 — Ajuste na Organização das Issues

**Objetivo:** Refinar a proposta de issues para melhor refletir o fluxo real de desenvolvimento.

### Prompt

> Não precisamos de uma issue separada para o setup inicial do repositório, pois isso já pode ser feito diretamente.
> Além disso, o script de simulação não deveria ser a última tarefa a ser realizada?
> O ideal é cadastrar as issues em ordem cronológica de execução.

### Resposta (resumo)

A IA concordou e ajustou o plano:

- **Removeu** a issue de setup inicial (a estruturação foi feita diretamente)
- **Reordenou** as 9 issues restantes em ordem cronológica:
  1. Implementação RTL (issues #1 a #4)
  2. Testbenches (issues #5 a #7)
  3. Documentação (issue #8)
  4. Scripts de simulação (issue #9 — última)
- **Executou** a criação das 9 issues no GitHub via `gh issue create`

---

## Prompt 3 — Correção sobre Políticas de Cache

**Objetivo:** Garantir que decisões de projeto do grupo não sejam pré-definidas pela IA.

### Prompt

> Na issue #3, a política de escrita foi definida como write-back, porém essa deveria ser uma decisão do grupo.
> Corrija a issue para apresentar as opções disponíveis sem impor uma escolha.

### Resposta (resumo)

A IA corrigiu a issue #3 (`Implementar FSM do controlador de cache`):

- **Antes:** A issue especificava implementar write-back e write-allocate como requisitos fixos.
- **Depois:** A seção de políticas foi alterada para "Políticas (decisão do grupo)", listando as opções disponíveis:
  - Política de escrita: write-back **ou** write-through
  - Política de alocação: write-allocate **ou** no-write-allocate
- A issue foi atualizada tanto localmente (`.github/issues/issue_03.md`) quanto no GitHub via `gh issue edit`.

---
