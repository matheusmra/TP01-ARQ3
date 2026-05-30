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

## Prompt 4 — Entendendo a Decomposição do Endereço

**Objetivo:** Compreender como o endereço da CPU é decomposto para acessar a cache.

### Prompt

> Explique como funciona a decomposição do endereço em uma cache set-associative.
> Quero entender como os bits do endereço são divididos em tag, index e offset,
> e como isso se aplica ao nosso projeto com endereço de 8 bits.

### Resposta

A IA explicou a decomposição do endereço para a arquitetura do projeto:

- **Endereço de 8 bits** com endereçamento por byte
- **Byte Offset** (bits `[1:0]`): 2 bits — seleciona o byte dentro da palavra de 32 bits (4 bytes). Como a cache opera em palavras inteiras, esses bits não são usados diretamente pela lógica de controle.
- **Set Index** (bits `[3:2]`): 2 bits — seleciona 1 dos 4 conjuntos (`log2(4) = 2`).
- **Tag** (bits `[7:4]`): 4 bits — identifica unicamente o bloco dentro do conjunto, usada para comparação de hit/miss.

Representação visual:

```
 [7:4]     [3:2]     [1:0]
┌───────┬─────────┬──────────┐
│  TAG  │  INDEX  │  OFFSET  │
│ 4 bits│  2 bits │  2 bits  │
└───────┴─────────┴──────────┘
```

Também explicou que, com 4 conjuntos e 2 vias, a cache possui 8 linhas no total, cada uma armazenando 1 palavra de 32 bits.

---

## Prompt 5 — Entendendo a FSM do Controlador de Cache

**Objetivo:** Compreender o fluxo de estados da máquina de estados finitos (FSM) que controla as operações da cache.

### Prompt

> Explique o fluxo de estados da FSM do controlador de cache. Quais são os estados possíveis
> e em que situações ocorre a transição entre eles? Como funciona o fluxo em caso de hit e de miss?

### Resposta

A IA detalhou a FSM de 8 estados:

1. **IDLE** — Estado ocioso. Aguarda requisição da CPU (`cpu_read` ou `cpu_write`). Ao receber, latcha os sinais e transita para COMPARE_TAG.

2. **COMPARE_TAG** — Verifica hit/miss usando lógica combinacional. Três caminhos:
   - **Hit** → vai direto para RESPOND (dado já disponível)
   - **Miss sem dirty** → vai para ALLOCATE_REQ (pode sobrescrever direto)
   - **Miss com dirty** → vai para WRITE_BACK_REQ (precisa salvar bloco sujo antes)

3. **WRITE_BACK_REQ** — Envia requisição de escrita para a memória principal com o bloco sujo. Transita para WRITE_BACK_WAIT.

4. **WRITE_BACK_WAIT** — Aguarda `mem_ready` da memória principal. Quando pronto, transita para ALLOCATE_REQ.

5. **ALLOCATE_REQ** — Envia requisição de leitura para a memória principal para buscar o novo bloco. Transita para ALLOCATE_WAIT.

6. **ALLOCATE_WAIT** — Aguarda `mem_ready`. Quando o dado chega, transita para UPDATE_CACHE.

7. **UPDATE_CACHE** — Atualiza a cache com o novo bloco: escreve dados, tag, valid, dirty e LRU. Transita para RESPOND.

8. **RESPOND** — Sinaliza `cpu_ready = 1` e `cache_hit` para a CPU. Retorna para IDLE.

**Fluxo em caso de hit:** IDLE → COMPARE_TAG → RESPOND (2 ciclos de latência)
**Fluxo em caso de miss limpo:** IDLE → COMPARE_TAG → ALLOCATE_REQ → ALLOCATE_WAIT → UPDATE_CACHE → RESPOND
**Fluxo em caso de miss com write-back:** IDLE → COMPARE_TAG → WRITE_BACK_REQ → WRITE_BACK_WAIT → ALLOCATE_REQ → ALLOCATE_WAIT → UPDATE_CACHE → RESPOND

---

## Prompt 6 — Questionamento sobre Arquitetura Modular vs. Monolítica

**Objetivo:** Avaliar se a separação em módulos (`cache_data_mem.sv`, `cache_tag_mem.sv`) faz sentido para o escopo do projeto.

### Prompt

> As issues #1 e #2 propõem criar módulos separados para a memória de dados e a memória de tags.
> Mas isso não adiciona complexidade desnecessária? Não seria melhor adotar uma abordagem monolítica,
> com tudo em um único `cache_controller.sv`?

### Resposta

A IA concordou que a abordagem modular adiciona overhead de interface sem ganho real:

- **Overhead identificado:** Cada módulo separado exige ~30-35 linhas só de declaração de portas (rd_index, rd_way, wr_en, wr_index, wr_way, etc.) para expor a mesma funcionalidade que no monolítico são acessos diretos a arrays internos.
- **Quantificação:** O design modular resultaria em ~370+ linhas espalhadas em múltiplos arquivos, enquanto o monolítico fica em ~254 linhas em um único arquivo — com a mesma funcionalidade.
- **Justificativa:** A modularização faz sentido para sub-módulos reutilizáveis ou complexos. Numa cache didática de 8 linhas com bloco de 1 palavra, os arrays são triviais e separá-los só adiciona burocracia.

**Decisão do grupo:** Adotar a abordagem monolítica. As issues #1 e #2 serão fechadas junto com a #3, pois toda a lógica ficará dentro do `cache_controller.sv`.

---

## Prompt 7 — Implementação do Controlador de Cache Monolítico

**Objetivo:** Implementar o módulo `cache_controller.sv` com design monolítico, contendo toda a lógica de dados, tags, controle e FSM.

### Prompt

> Implemente o `cache_controller.sv` seguindo a abordagem monolítica que decidimos.
> Use o padrão que definimos: endereço de 8 bits, 4 conjuntos, 2 vias, bloco = 1 palavra de 32 bits.
> A FSM deve ser síncrona.
> Adote write-back com write-allocate e LRU com 1 bit por conjunto.

### Resposta

A IA implementou o módulo `rtl/cache_controller.sv` com as seguintes características:

- **Design monolítico:** Arrays `data`, `tags`, `valid`, `dirty` e `lru` internos ao módulo
- **Parâmetros:** `NUM_SETS=4`, `NUM_WAYS=2`, `DATA_WIDTH=32`, `TAG_BITS=4`, `INDEX_BITS=2`
- **Hit/miss combinacional:**
  ```systemverilog
  assign hit_way0 = valid[req_index][0] && (tags[req_index][0] == req_tag);
  assign hit_way1 = valid[req_index][1] && (tags[req_index][1] == req_tag);
  assign hit      = hit_way0 || hit_way1;
  ```
- **FSM de 8 estados:** IDLE, COMPARE_TAG, WRITE_BACK_REQ, WRITE_BACK_WAIT, ALLOCATE_REQ, ALLOCATE_WAIT, UPDATE_CACHE, RESPOND
- **Políticas:** Write-back + Write-allocate
- **LRU:** 1 bit por conjunto, atualizado em COMPARE_TAG (hit) e UPDATE_CACHE (miss)
- **Seleção de vítima:** Prioriza via inválida; se ambas válidas, usa LRU
- **Reset assíncrono:** Invalida toda a cache e zera registradores

---

## Prompt 8 — Estruturação e Automação do Testbench Integrado

**Objetivo:** Consolidar os cenários de teste (Seções 7.3, 7.4 e 7.5) em um único ambiente de verificação (`tb_cache_top.sv`) e implementar uma rotina automatizada para contagem de acertos/erros e geração de evidências visuais.

### Prompt

> Decisão de centralizar todos os testes em um único arquivo (tb_cache_top.sv).
> Organização e isolamento de cada cenário utilizando tasks do SystemVerilog.
> Como implementar um mecanismo elegante para automatizar os logs de PASS/FAIL (incluindo a contabilização de acertos e erros totais)?

### Resposta

A IA validou a estratégia do grupo de modularizar os cenários através de `tasks` e sugeriu a seguinte infraestrutura complementar de verificação:

- **Sistema de Asserção Customizado:** Recomendou a criação de uma task auxiliar chamada `check_assert`. Essa função recebe o nome do teste e a condição lógica esperada, imprimindo `[PASS]` ou `[FAIL]` diretamente no terminal, além de incrementar variaveis globais (`tests_passed` e `tests_failed`) para exibir um resumo final da execução.
- **Sincronismo de Sinais:** Lembrou a necessidade de incluir comandos de espera (`wait(cpu_ready == 1'b1)`) dentro das tasks de estímulo (`read_cache` e `write_cache`), garantindo que o testbench respeite os ciclos de latência da memória definidos na nossa FSM.
- **Geração de Waveforms:** Indicou o uso das diretivas nativas `$dumpfile("tb_cache_waveforms.vcd")` e `$dumpvars(0, tb_cache_top)` no bloco `initial`, o que força o simulador a registrar as transições de todos os barramentos automaticamente, facilitando a extração dos gráficos solicitados pelo enunciado.

---

## Prompt 9 — Validação da Estratégia de Teste para LRU e Write-Back

**Objetivo:** Validar a sequência lógica de estímulos para forçar a substituição (eviction) e o write-back em uma arquitetura associativa de 2 vias.

### Prompt

> Criação de ambiente único com logs automáticos de PASS/FAIL e exportação de waveforms (.vcd).
> Confirmação da sequência de estímulos criada pelo grupo para forçar o LRU e o write-back na cache de 2 vias.

### Resposta

A IA confirmou que a estratégia arquitetada pelo grupo está correta e descreveu o fluxo resultante na FSM:
- **Ocupação do Set:** Os endereços 0x00 e 0x10 mapeiam para o mesmo índice. A leitura preenche as duas vias.
- **Manipulação do LRU:** Escrever em 0x00 torna o bloco modificado (dirty). A leitura subsequente em 0x10 força a FSM a atualizar o estado do LRU, tornando a via 0 (que contém 0x00) a menos recentemente usada.
- **Write-Back Forçado:** Ao solicitar 0x20 (que também mapeia para o mesmo índice), ocorre um conflito. O controlador avalia o LRU e seleciona a via 0 para ejeção. Como o bloco está sujo, a FSM transita obrigatoriamente para os estados WRITE_BACK_REQ e WRITE_BACK_WAIT, garantindo que o dado chegue na memória principal antes do novo carregamento.

---

## Prompt 11 — Refatoração e Padronização dos Comentários do Testbench

**Objetivo:** Aplicar metodologias de Clean Code na documentação interna do testbench (tb_cache_top.sv), garantindo que os comentários expliquem a intenção dos testes e a estratégia arquitetural adotada.

### Prompt

> Testbench unificado pronto, mas os comentários literais poluem o código.
> Criar separações visuais claras para os diferentes blocos lógicos.
> Substituir traduções de sintaxe por explicações da estratégia de teste (ex: LRU).

### Resposta

A IA refatorou a documentação interna do código aplicando quatro princípios fundamentais:
- **Documentação Guiada por Intenção:** Removeu comentários que apenas traduziam o código (ex: "Lê o endereço X") e os substituiu por explicações estratégicas, documentando a lógica de engenharia por trás da ação (ex: // Lê a Via 1 para que a Via 0 vire a candidata a ser expulsa (LRU)).
- **Logs como Documentação:** Ajustou os textos de asserção da função check_assert para que o próprio log gerado no terminal sirva como um relatório descritivo autossuficiente (ex: "Conflito: Carregou 3a tag com sucesso (MISS)").

---

