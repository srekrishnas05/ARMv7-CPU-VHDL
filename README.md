# ARMv7 CPU Core - VHDL
My attempt at the classic five stage pipelined **ARMv7** core implemented in VHDL, with timing results and power/hardware usage reports. 

### Features
- **5-stage classic pipeline** — IF → ID → EX → MEM → WB
- **Full data hazard resolution** — MEM→EX and WB→EX forwarding bypass paths
- **Load-use hazard detection** — automatic stall insertion with NOP bubble injection
- **Control hazard handling** — pipeline flush on taken branches with flush signal propagation across all pipeline registers
- **ARMv7 base instruction support** — data processing, load/store, and branch instructions

### Architecture Overview
          ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
  PC ───► │  IF  │──►│  ID  │──►│  EX  │──►│ MEM  │──►│  WB  │
          └──────┘   └──────┘   └──────┘   └──────┘   └──────┘
                        ▲           │           │
                        │           └─── FWD ───┘   (Forwarding Unit)
                        └────────────── HDU ──────── (Hazard Detection Unit)

### Pipeline Stages
**IF** - Instruction fetch; PC update and branch target mux
**ID** - Register file read, immediate decode, control signal generation
**EX** - ALU operation, branch condition evaluation, forwarding mux selection
**WB** - Data memory read/write
**MEM** - Write-back to register file from ALU result or memory load

### Pipeline Registers
**IF/ID** - Instruction word, PC+4
**ID/EX** - Control signals, RS1/RS2 data, immediate, dest register
**EX/WB** - ALU result, write data, control signals, dest register
**WB/MEM** - Load data or ALU result, dest register, WB control

### Hazard Handling
Data hazards resolved via forwarding from EX/MEM and MEM/WB registers back to EX-stage ALU inputs — no stall required for back-to-back ALU instructions
Load-use hazards (unavoidable 1-cycle penalty) handled by freezing IF/ID and ID/EX registers and injecting a NOP bubble into EX
Control hazards resolved by flushing IF/ID, ID/EX, and EX/MEM registers on a taken branch; branch resolution occurs in the EX stage

### Datapath
<img width="1029" height="603" alt="image" src="https://github.com/user-attachments/assets/358718f6-8f59-478f-b003-4e4a05a8fa6a" />
**Datapath without hazards**

<img width="976" height="577" alt="image" src="https://github.com/user-attachments/assets/aa213fe5-a2c0-4561-8c22-68440098795d" />
**Datapath with hazards**

I used a lot of class material from Microprocessors and Computer Architectures to make my CPU and I couldn't find a clean picture of the whole datapath without highlighting the Hazard so I just included both, lol.

### Synthesis Results
**Clock Frequency** - 100Mhz
**WNS** - +1.529
**WHS** - +0.081
**Total Power** - 0.141W (Around 93% was static power since it's all in Vivado for FPGA synthesis so it's really just leakage)
**LUTs** - 628
**FF** - 321
**No timing violations/failed routes ☺️**

### Future Contribution
I'm still really excited for this project and my next steps are adding branch prediction and integrating an L1 cache. Beyond that, I want to dive into the realm of tapeouts with Sky130. I also am adding more instruction set, multiply (wallace trees), barrel shifter, so on.
