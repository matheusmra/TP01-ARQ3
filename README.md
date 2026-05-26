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

> **TODO**: Preencher após definição das decisões de projeto.

- **Tipo**: *a definir*
- **Política de escrita**: *a definir (write-back / write-through)*
- **Política de alocação**: *a definir (write-allocate / no-write-allocate)*
- **Política de substituição**: *a definir (LRU / FIFO / outra)*

## Dependências

- Simulador SystemVerilog (uma das opções abaixo):
  - [Verilator](https://www.veripool.org/verilator/)
  - [Icarus Verilog](http://iverilog.icarus.com/)
  - Xilinx XSIM (via Vivado)
  - ModelSim / Questa (Intel/Siemens)
- GNU Make (para scripts de simulação)

## Como Compilar e Simular (Linux)

> **TODO**: Instruções detalhadas serão adicionadas após a configuração dos scripts de simulação.

```bash
# Clone o repositório
git clone https://github.com/matheusmra/TP01-ARQ3.git
cd TP01-ARQ3

# Execute a simulação
cd sim
make run
```

## Integrantes

- Andriel Mark da Silva Pinto
- Beatriz Miranda
- Felipe Henrique Oliveira Diniz
- Matheus de Almeida Moreira
- Otoniel Goulart


