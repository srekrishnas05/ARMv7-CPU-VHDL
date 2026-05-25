# ARMv7 CPU Core - VHDL
My attempt at the classic five stage pipelined **ARMv7** core implemented in VHDL, with timing results and power/hardware usage reports. 

### Features
- **5-stage classic pipeline** — IF → ID → EX → MEM → WB
- **Full data hazard resolution** — MEM→EX and WB→EX forwarding bypass paths
- **Load-use hazard detection** — automatic stall insertion with NOP bubble injection
- **Control hazard handling** — pipeline flush on taken branches with flush signal propagation across all pipeline registers
- **ARMv7 base instruction support** — data processing, load/store, and branch instructions
- **L1 Cache has been implemennted** — more on it below

### Architecture Overview
<img width="549" height="129" alt="image" src="https://github.com/user-attachments/assets/b5647b79-bbad-439b-91bc-8968abc8cd66" />


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

### L1 Cache
**Type**  - 4 way SA
**Sets** - 4
**Ways** - 4
**Line Size** - 1 word (32 bits)
**Total Cap** - 64 bytes
**Replacement Policy** - Pseudo-LRU (round-robin counter)
**Write Policy** - Write-back
**Write Miss** - Write-allocate
**Miss Penalty** - idealized single cycle
**Tag** - 28 bits
**Index** - 2 bits
**Offset** - 2 bits
**Dirty Eviction** - Combinational Writeback to backing dmem

### Datapath
<img width="1029" height="603" alt="image" src="https://github.com/user-attachments/assets/358718f6-8f59-478f-b003-4e4a05a8fa6a" />
**Datapath without hazards**

<img width="976" height="577" alt="image" src="https://github.com/user-attachments/assets/aa213fe5-a2c0-4561-8c22-68440098795d" />
**Datapath with hazards**

I used a lot of class material from Microprocessors and Computer Architectures to make my CPU and I couldn't find a clean picture of the whole datapath without highlighting the Hazard so I just included both, lol.

### Synthesis Results
Will update after more stuff is added

