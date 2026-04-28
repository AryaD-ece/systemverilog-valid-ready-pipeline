# 🚀 SystemVerilog Valid-Ready Pipeline Verification

<p align="center">
  <img alt="SystemVerilog" src="https://img.shields.io/badge/SystemVerilog-Design%20%2B%20Verification-blue">
  <img alt="Protocol" src="https://img.shields.io/badge/Protocol-Valid--Ready-green">
  <img alt="Verification" src="https://img.shields.io/badge/Verification-Constrained%20Random%20%2B%20SVA-orange">
  <img alt="Simulator" src="https://img.shields.io/badge/Simulator-Vivado%20XSim-red">
  <img alt="Status" src="https://img.shields.io/badge/Status-PASS%2020%2F20-brightgreen">
</p>

<p align="center">
  A <b>backpressure-aware, lossless 1-stage streaming pipeline</b> (elastic buffer / register slice) in SystemVerilog,
  verified with a <b>self-checking, constrained-random environment</b>.
</p>

---

## ⚡ TL;DR

* **Problem:** Reliable, ordered, lossless data transfer under backpressure
* **Solution:** 1-depth **valid-ready pipeline (elastic buffer)**
* **Guarantees:** No data loss, no overwrite, in-order delivery
* **Latency / Throughput:** **1 cycle** / **1 txn per cycle** (no stalls)
* **Result:** ✅ **PASS 20/20** with randomized delays & stalls

---

## 🧩 Problem Statement

In synchronous datapaths, modules often operate at **different rates**. Without proper flow control:

* ❌ Data can be **lost** during backpressure
* ❌ New data may **overwrite** unconsumed data
* ❌ **Ordering violations** can occur
* ❌ Throughput becomes **non-deterministic**

---

## 🎯 Objective

Design and verify a pipeline stage that:

* ✔ Guarantees **lossless transfer**
* ✔ Handles **arbitrary backpressure**
* ✔ Preserves **strict ordering**
* ✔ Ensures **cycle-accurate, deterministic behavior**

---

## 🔗 Protocol Overview

**Valid-Ready Handshake**

* `valid` → Producer asserts data availability
* `ready` → Consumer signals acceptance

**Transfer occurs iff:**

```sv
valid && ready
```

---

## 🧠 Architectural Positioning

> **Equivalent to a 1-depth elastic buffer / AXI-Stream register slice**

| Property     | Value                     |
| ------------ | ------------------------- |
| Latency      | 1 cycle                   |
| Throughput   | 1 txn / cycle (no stalls) |
| Backpressure | Fully supported           |
| Storage      | Single-entry buffer       |

---

## 🏗️ Design Summary

The DUT is a **single-entry pipeline register**:

* `data_reg` → holds current transaction
* `slot_full` → indicates valid data present
* `txn_count` → increments on successful transfers

### Operational Rules

| Condition             | Action               |
| --------------------- | -------------------- |
| `slot_full && ready`  | Consume transaction  |
| `!slot_full && valid` | Load new transaction |
| `slot_full && !ready` | Hold (stall)         |

---

## 🧪 Verification Strategy

**Self-checking, constrained-random environment**

### Architecture

* **Generator** → randomized transactions
* **Driver (Producer)** → applies stimulus
* **Monitor (Consumer)** → observes DUT
* **Scoreboard** → validates correctness

### Stimulus

* Random data (8-bit)
* Random inter-transaction delay (1–5 cycles)
* Random backpressure (0–8 cycles)

---

## 🧷 Assertions (SVA)

Core properties enforced:

```sv
// Transfer correctness
assert property (@(posedge clk) (valid && ready));

// Data stability under stall
assert property (@(posedge clk) (valid && !ready) |-> $stable(data));

// No overwrite before consumption
assert property (@(posedge clk) (slot_full && !ready) |-> $stable(data_reg));
```

---

## 📊 Functional Coverage (Intent)

* All `valid/ready` combinations
* Backpressure durations
* Burst transfers
* Edge timing cases

```sv
covergroup handshake_cg;
  coverpoint valid;
  coverpoint ready;
  cross valid, ready;
endgroup
```

---

## 📈 Waveform (Proof of Correctness)

<p align="center">
  <img src="waveform.png" alt="Waveform" width="800">
</p>

**Observations:**

* ✔ Correct handshake synchronization
* ✔ Data stable during stalls
* ✔ No overwrite or corruption
* ✔ Accurate transaction progression

---

## ⚙️ Performance

| Metric         | Value                     |
| -------------- | ------------------------- |
| Latency        | 1 cycle                   |
| Throughput     | 1 txn / cycle (no stalls) |
| Backpressure   | Lossless                  |
| Data Integrity | Guaranteed                |

---

## 🛠️ How to Run

```bash
xvlog src/pipeline_dut.sv sim/transaction.sv sim/tb_pipeline.sv
xelab tb_pipeline -s tb_pipeline_sim
xsim tb_pipeline_sim -run all
```

---

## 📁 Repository Structure

```
sv-pipeline-valid-ready/
├── src/
│   └── pipeline_dut.sv
├── sim/
│   ├── tb_pipeline.sv
│   └── transaction.sv
├── waveform.png
├── README.md
└── .gitignore
```

---

## ✅ Results

* Transactions: **20**
* PASS: **20**
* FAIL: **0**

✔ Deterministic behavior
✔ No data loss
✔ No ordering violations

---

## 🏭 Industry Relevance

Directly applicable to:

* AXI-Stream register slices
* Streaming DSP pipelines
* Network-on-Chip routing stages
* FIFO front-end buffering

---

## 🔮 Extensions

* Multi-stage pipeline (FIFO)
* Skid buffer design
* AXI-Stream wrapper
* UVM-based verification
* Coverage closure & metrics
* Throughput / latency analysis

---

## 🧠 Key Takeaways

* Flow-controlled datapath design
* Correct valid-ready semantics
* Backpressure-resilient architecture
* Self-checking verification methodology
* Assertion-driven validation mindset

---

## Author

**Arya Dinesh**  
*B.Tech Electronics & Communication Engineering*
