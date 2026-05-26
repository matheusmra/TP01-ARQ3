# Regras para Agentes de IA

Este documento define regras obrigatórias para qualquer agente de IA que atue neste repositório.

---

## Regra 1 — Documentação Obrigatória de Prompts

**Toda interação com IA utilizada no desenvolvimento deste projeto DEVE ser registrada.**

Ao receber um prompt e gerar uma resposta, o agente **deve obrigatoriamente** atualizar o arquivo
[`docs/prompts_ia.md`](docs/prompts_ia.md), adicionando ao final:

### Formato obrigatório

```markdown
## Prompt N — [Título descritivo do que foi solicitado]

**Objetivo:** [Descrição breve do objetivo do prompt]

### Prompt

> [Prompt recebido — melhorar a redação se necessário, mantendo o sentido original]

### Resposta (resumo)

[Resumo claro e objetivo das ações realizadas e dos resultados produzidos]

---
```

### Regras do registro

1. **Numerar sequencialmente** — O número do prompt (`N`) deve seguir a sequência do último prompt registrado no arquivo.
2. **Incluir o prompt recebido** — Transcrever o prompt do usuário, podendo melhorar a redação para maior clareza, sem alterar o sentido.
3. **Resumir a resposta** — Documentar de forma objetiva o que foi feito, quais arquivos foram criados/modificados e quais decisões foram tomadas.
4. **Não omitir interações** — Toda interação que resulte em alteração de código, criação de arquivos ou decisão de projeto deve ser registrada. Interações triviais (como "ok", "aprovado", "prossiga") que não geram conteúdo novo podem ser omitidas.
5. **Atualizar antes de encerrar** — O registro deve ser feito na mesma sessão em que o prompt foi processado, antes de concluir a resposta ao usuário.

---

## Regra 2 — Contexto do Projeto

Este é um projeto acadêmico de **Arquitetura de Computadores III** que implementa um **controlador de cache em SystemVerilog**. O agente deve:

- Seguir a estrutura de diretórios existente (`rtl/`, `tb/`, `sim/`, `docs/`)
- Respeitar as decisões de projeto do grupo (não impor escolhas como políticas de cache)
- Gerar código em **SystemVerilog**
- Seguir a metodologia **Spec-Driven Development (SDD)** conforme exigido pelo enunciado
