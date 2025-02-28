# Extended MIPS Single-Cycle Processor

Welcome to the **Extended MIPS Single-Cycle Processor** project! This repository showcases a Verilog-based single-cycle MIPS CPU with additional custom instructions beyond the traditional MIPS instruction set.

**Key Features:**
- Classic single-cycle MIPS datapath and control logic.
- Six extended instructions (balrv, jmxor, ori, bgezal, jsp, baln) with new opcodes/funct fields.
- A status register to track Zero, Negative, and Overflow flags.
- Comprehensive test environment for verifying standard and extended instructions.
- An **updated circuit diagram** (`circuit-after.png`) illustrating the changes made to the datapath.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Extended Instructions](#extended-instructions)
3. [Repository Structure](#repository-structure)
4. [Datapath Design](#datapath-design)
5. [Status Register](#status-register)
6. [Simulation & Testing](#simulation--testing)
7. [References](#references)

---

## 1. Project Overview
This project extends a basic single-cycle MIPS processor by adding new instructions that require modifications to both the **control unit** and the **datapath**. The additional instructions may perform new arithmetic or logical operations, conditional branches based on the status register, or special jumps with link registers.

### Goals
- Demonstrate how to integrate new instructions into a single-cycle MIPS design.
- Show how the processor’s control logic and datapath can be adapted for custom instruction sets.
- Highlight the role of a status register in enabling new types of conditional behaviors.

---

## 2. Extended Instructions
You can customize which instructions to add. This project implemented these six new instructions:

| Instr  | Type    | Code  | Syntax                  | Meaning                                                                                                           |
|--------|---------|-------|-------------------------|-------------------------------------------------------------------------------------------------------------------|
| balrv  | R-type  | 22    | `balrv $rs, $rd`          | If Status [V] = 1, branches to address found in register `$rs`, link address is stored in `$rd` (which defaults to 31) |
| jmxor  | R-type  | 34    | `jmxor $rs, $rt`          | Jumps to address found in memory [`$rs XOR $rt`], link address is stored in $31                                    |
| ori    | I-type  | 13    | `ori $rt, $rs, Label`     | Put the logical OR of register `$rs` and the zero-extended immediate into register `$rt`                              |
| bgezal | I-type  | 35    | `bgezal $rs, Label`       | If R[rs] >= 0, branch to PC-relative address (formed as beq & bne do), link address is stored in register 25      |
| jsp    | I-type  | 18    | `jsp`                     | Jumps to address found in memory where the memory address is written in register 29 (`$sp`)                         |
| baln   | J-type  | 27    | `baln Target`             | If Status [N] = 1, branches to pseudo-direct address (formed as jal does), link address is stored in register 31  |
---

## 3. Repository Structure
Below is a brief overview of the main files in this project.

```
.
├── alu32.v                // 32-bit ALU logic and status-bit generation
├── alucont.v              // ALU control logic for selecting ALU operations
├── control.v              // Main control unit for opcode/funct decoding
├── mult2_to_1_5.v         // 2-to-1 multiplexer (5-bit output) for register selection
├── processor.v            // Top-level module instantiating CPU components
├── Circuit.png            // Updated datapath diagram with custom instructions
├── Project_2_Instructions.pdf
└── ...
```

- **alu32.v**  
  The core arithmetic logic unit that computes results and sets `Zero`, `Negative`, and `Overflow` bits.
- **alucont.v**  
  Decodes the ALU operation based on the `funct` field (R-type) or opcode (I-type/J-type).
- **control.v**  
  Translates the 6-bit opcode (and possibly the 6-bit `funct`) into control signals that drive multiplexers, memory, registers, etc.
- **mult2_to_1_5.v**  
  Multiplexer used to select the destination register for write operations.
- **processor.v**  
  The single-cycle CPU that connects instruction memory, registers, ALU, data memory, and control logic.
- **Circuit.png**  
  **Updated** datapath diagram showing how new multiplexers, signals, and the status register are integrated for the extended instructions.
---

## 4. Datapath Design
In the **single-cycle** approach, each instruction completes in one clock cycle. The CPU typically contains:

1. **Instruction Memory**: Provides the instruction bits based on the current `PC`.
2. **Register File**: Allows reading and writing of registers in one cycle.
3. **ALU & ALU Control**: Performs arithmetic/logic operations, sets condition flags (`Z`, `N`, `V`).
4. **Data Memory**: Handles load/store instructions (if included).
5. **Control Unit**: Decodes opcode/funct to generate the appropriate control signals (`RegDst`, `Branch`, `MemRead`, etc.).
6. **Status Register**: Stores the `Z`, `N`, `V` flags, used by branch/jump instructions.

### Updated Circuit Diagram

Below, you can see **two** diagrams:
1. **Circuit (Before)** – the original single-cycle MIPS datapath.
2. **Circuit (After)** – the enhanced datapath that supports new instructions, branching, and link registers.

### Circuit (Before)
The **base** single-cycle MIPS design includes:
- **Instruction Memory** connected to the **PC**.
- A **Register File** with read/write ports.
- An **ALU** and **ALU Control** for arithmetic/logic operations.
- **Data Memory** for load/store instructions.
- A set of **multiplexers** to handle register destinations, immediate values, and ALU inputs.
- **Control Logic** that decodes the instruction’s opcode to generate the correct signals.

![`circuit-before.png`](circuit-before.png)

### Circuit (After)
The **updated** design incorporates **additional muxes, signals, and control paths** required by new instructions. Key changes include:

1. **Status Register (Z, N, V)**
    - Outputs from the ALU feed into a 3-bit register for Zero, Negative, and Overflow.
    - Certain instructions (e.g., `balrv`, `bgezal`, `baln`) now check these bits to decide whether to branch/jump.

2. **Extended Control Logic**
    - The `control.v` and `alucont.v` modules handle new opcodes/funct values and condition-based jumps.
    - New or modified control signals may include `pcSrc`, `memToReg`, and custom link signals for storing `PC+4` into `$25` or `$31`.

3. **Additional Multiplexers**
    - Extra MUX inputs for selecting jump addresses generated by specialized logic (e.g., XOR, NOR).
    - MUXes for writing link registers (e.g., `$25`, `$31`) based on the instruction type.

4. **New Paths for Jump/Branch**
    - Instructions like `jsp`, `balrv`, or `jmxor` require special address calculations or memory lookups.
    - PC is updated from the newly introduced MUX if the extended control logic signals a jump/branch.

![`circuit-after.png`](circuit-after.png)
---

## 5. Status Register
The processor includes a 3-bit **status register**:
- **Z** (Zero) — set if ALU result is 0
- **N** (Negative) — set if ALU result is negative
- **V** (Overflow) — set if the operation overflows (for signed arithmetic)

Many extended instructions (e.g., `balrv`, `bgezal`, `baln`) rely on these bits to determine whether to branch or jump.

---

## 6. Simulation & Testing
1. **Testbench Setup**
    - Create a Verilog testbench (e.g., `processor_tb.v`) that instantiates `processor.v`.
    - Initialize the instruction memory with test programs that cover both standard MIPS instructions and your extended instructions.

2. **ModelSim or Another Simulator**
    - Add all `.v` source files and your testbench to a ModelSim project (or equivalent).
    - Compile all `.v` and testbench files.

3. **Observing Signals**
    - During simulation, you can monitor `PC`, `Instruction`, `ALUResult`, `Z`, `N`, `V`, etc.
    - Verify that each instruction behaves correctly and that new instructions do not break any existing functionality.

4. **Examples**
    - **Conditional Branch**: Check `PC` changes only if `Status[V] == 1` for `brv`.
    - **Link Registers**: Verify `$31` or `$25` is written with the correct link address.
    - **New ALU Logic**: For instructions like `xori`, confirm that the ALU performs an XOR with an immediate value.

---

## 7. References
- **MIPS Architecture**: For baseline instructions, see Patterson & Hennessy, *Computer Organization and Design*.
- **Intel ModelSim**: [Official Website](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-sim.html)
- **Project_2_Instructions.pdf**: Detailed explanation of each new instruction format and usage.
