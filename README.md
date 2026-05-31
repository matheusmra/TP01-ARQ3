# TP01 — Controlador de Cache (SystemVerilog)

Trabalho Prático 1 da disciplina de Arquitetura de Computadores III.

Implementação de um **controlador de cache** em SystemVerilog, baseado na Seção 5.12 do livro *Computer Organization and Design: The Hardware/Software Interface — RISC-V Edition*.

## Estrutura do Repositório

```
├── rtl/        # Código-fonte SystemVerilog (módulos RTL)
├── tb/         # Testbenches para validação funcional
├── sim/        # Scripts de simulação (Makefile, shell scripts)
├── docs/       # Documentação e relatório (PDF)
```

## Especificações da Cache

- **Tipo**: Associativa por Conjuntos (Set-Associative) — 4 conjuntos, 2 vias
- **Política de escrita**: Write-Back
- **Política de alocação**: Write-Allocate
- **Política de substituição**: LRU (Least Recently Used)

## Dependências

- Simulador SystemVerilog (uma das opções abaixo):
  - [Verilator](https://www.veripool.org/verilator/)
  - [Icarus Verilog](http://iverilog.icarus.com/)
  - Xilinx XSIM (via Vivado)
  - ModelSim / Questa (Intel/Siemens)
- GNU Make (para scripts de simulação)

## Como Compilar e Simular (Linux)

Dependências mínimas:
- GNU Make
- Verilog simulator compatível com `iverilog` ou `xsim`
- GTKWave (opcional, para abrir waveforms)

No Linux, use os scripts em `sim/`:

```bash
# Clone o repositório
git clone https://github.com/matheusmra/TP01-ARQ3.git
cd TP01-ARQ3

# Compilar todos os módulos RTL e testbenches
cd sim
make compile

# Executar a simulação principal
make run

# Executar todos os testbenches sequencialmente
make run_all

# Limpar os artefatos gerados
make clean
```

Também é possível usar o script auxiliar:

```bash
./run_sim.sh --testbench tb_cache_controller
./run_sim.sh --run-all
./run_sim.sh --waves
./run_sim.sh --clean
```

Variáveis configuráveis:
- `SIM`  — simulador (`iverilog` por padrão)
- `BUILD_DIR` — diretório de saída (padrão `build`)
- `RUN_TB` — nome do testbench a executar

## Integrantes

- Andriel Mark da Silva Pinto
- Beatriz Miranda
- Felipe Henrique Oliveira Diniz
- Matheus de Almeida Moreira
- Otoniel Goulart


