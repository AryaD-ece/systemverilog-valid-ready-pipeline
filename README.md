# SystemVerilog Valid-Ready Pipeline (1-Stage)

A fully verified **1-stage valid-ready pipeline** implemented in SystemVerilog with a constrained-random, self-checking testbench.

This project demonstrates correct **flow control, backpressure handling, and transaction integrity** using a minimal yet robust design.

---

## 📌 Overview

This design models a **synchronous streaming interface** using the standard:

- `valid` → asserted by producer  
- `ready` → asserted by consumer  
- Transfer occurs only when **both are high**

The DUT implements a **single-stage pipeline register** with:

- Backpressure support  
- No data loss  
- No data duplication  
- Deterministic transaction counting  

---

## 🧠 Design Behavior

| Condition | Action |
|----------|--------|
| `valid=1`, `ready=1` | Data is transferred |
| `valid=1`, `ready=0` | Data is held (backpressure) |
| `valid=0` | No transfer |
| Slot empty + `valid=1` | Load new data |

### Key Guarantees
- ✔ In-order delivery  
- ✔ Lossless buffering  
- ✔ Back-to-back transaction support  
- ✔ Correct handshake semantics  

---

## 🏗️ Architecture


Producer ──(valid,data)──▶ [ Pipeline Stage ] ──▶ Consumer
◀──── ready ────────


- Internal register stores one transaction (`data_reg`)
- `slot_full` tracks validity
- `txn_count` increments only on **successful transfers**

---

## 📁 Repository Structure


sv-pipeline-valid-ready/
│
├── src/
│ └── pipeline_dut.sv # RTL Design
│
├── sim/
│ ├── tb_pipeline.sv # Testbench (driver + monitor + scoreboard)
│ └── transaction.sv # Transaction class (constrained random)
│
├── docs/
│ └── waveform.png # Simulation waveform
│
├── .gitignore
└── README.md


---

## 🧪 Verification Strategy

The testbench uses a **self-checking, constrained-random approach**:

### Stimulus
- Random data values
- Random inter-transaction delays
- Random consumer backpressure (0–8 cycles)

### Checking
- Mailbox-based transaction tracking
- Scoreboard compares:
  - Expected vs actual data
  - Transaction ordering
- Automatic pass/fail reporting

### Coverage Intent
- Back-to-back transfers
- Stall conditions
- Edge timing alignment
- Handshake correctness

---

## 📊 Simulation Results


SIMULATION COMPLETE
PASS : 20 / 20
FAIL : 0 / 20
DUT COUNT: 20


✔ All transactions verified successfully  
✔ No mismatches detected  
✔ DUT behavior matches specification  

---

## 📉 Waveform

![Waveform](docs/waveform.png)

### What this shows:
- Proper `valid-ready` handshake
- Data stability during stalls
- Correct transaction progression
- Accurate `txn_count` updates

---

## 🚀 How to Run

### Using Vivado XSim

```bash
xvlog src/pipeline_dut.sv sim/transaction.sv sim/tb_pipeline.sv
xelab tb_pipeline -s tb_pipeline_sim
xsim tb_pipeline_sim -run all
⚙️ Key Design Decisions
1. Single-entry buffering
Simplifies control logic
Ensures deterministic timing
2. Registered outputs
Clean synchronous design
Avoids combinational hazards
3. Handshake-driven counting

txn_count increments only on:

valid && ready
4. Backpressure-safe logic
Data is never overwritten unless consumed
🧩 Possible Extensions
Multi-stage pipeline (N-depth FIFO)
AXI-Stream compatibility wrapper
Functional coverage metrics
UVM-based verification environment
Throughput/latency benchmarking
📌 Takeaways

This project demonstrates:

Correct implementation of flow-controlled data paths
Practical understanding of valid-ready protocol
Ability to build self-checking verification environments
Handling of real-world backpressure scenarios
👤 Author

Arya Dinesh
B.Tech Electronics & Communication Engineering

📄 License

This project is open-source and available for learning and academic use.
