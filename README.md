# Arithmetic logic unit (ALU) with Power Management Unit for low power (UPF based) strategies
This project implements a 32-bit Arithmetic Logic Unit (ALU) integrated with a Power Management Unit (PMU) for power-aware digital design. The PMU dynamically controls the ALU’s power domain using isolation and power switch control signals, mimicking how real SoCs save power when blocks go idle.

🧮 ALU

Parameterized 32-bit width
Supports arithmetic and logic operations (ADD, SUB, AND, OR, XOR, etc.)
Generates flags: Zero, CarryOut, Overflow, Negative, and Less
Designed to interface with PMU power signals

⚙️ PMU (Power Management Unit)

Inputs: clk, rst, idle
Outputs:
iso_ctrl[3:0] → controls isolation cells
psw_ctrl[3:0] → controls power switch signals
Uses simple counters to sequence isolation/power switch transitions
Emulates power-down and wake-up behavior based on ALU’s idle signal

🧠 Power Intent – Hierarchical UPF

This project uses two UPF files to define the power architecture:
top.upf  → defines global domains (e.g., PD_TOP, Power switches)
alu.upf  → defines local ALU domain rules (isolation)

This simulates dynamic power gating and state retention in low-power design flows.


▶️ Simulating in VCS

Run the hierarchical UPF simulation:

vcs -full64 -sverilog top.v ALU.v PMU.v tb.v -upf top.upf -debug_access+all
./simv

---------------------------------------------------------------------------
![673c22d5-ce82-46f1-9e40-6c97a2495c26](https://github.com/user-attachments/assets/3b76525a-6eda-49c6-a44a-c9878c997e06)

Block Diagram of Design with PMU (Power Management Unit) that controls the low power strategies according to idle signal. Causing ALU to shutdown during no usage and inputs and outputs will be isolated to prevent 'x' propagation.
