#  SystemVerilog Valid-Ready Pipeline Verification

<p align="center">
  <img src="https://img.shields.io/badge/SystemVerilog-Design%20%2B%20Verification-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/Protocol-Valid--Ready-green?style=for-the-badge">
  <img src="https://img.shields.io/badge/Simulation-XSim-red?style=for-the-badge">
  <img src="https://img.shields.io/badge/Status-PASS%2020%2F20-brightgreen?style=for-the-badge">
</p>

<p align="center">
  <b>Backpressure-aware, lossless 1-stage streaming pipeline (elastic buffer / register slice)</b><br>
  Verified using a <b>self-checking constrained-random testbench</b> with assertion-driven validation.
</p>

---

## ⚡ Quick Overview

| Aspect     | Detail                                    |
| ---------- | ----------------------------------------- |
| Problem    | Reliable data transfer under backpressure |
| Solution   | Valid-Ready 1-stage pipeline              |
| Guarantee  | No loss, no overwrite, ordered delivery   |
| Latency    | 1 cycle                                   |
| Throughput | 1 txn / cycle (no stalls)                 |
| Result     | PASS 20 / 20                              |

---

## 🧩 Problem

Independent modules in synchronous systems operate at different rates. Without proper flow control:

* ❌ Data loss under stalls
* ❌ Overwrite of unconsumed data
* ❌ Ordering violations
* ❌ Unstable throughput

---

## 🎯 Objective

Design a pipeline stage that:

* ✔ Ensures **lossless transfer**
* ✔ Handles **arbitrary backpressure**
* ✔ Preserves **strict ordering**
* ✔ Provides **deterministic behavior**

---

## 🔗 Protocol

Transfer occurs **iff**:

```systemverilog
valid && ready
```

---

## 🧠 Architecture

<p align="center">
  <img src="https://dummyimage.com/700x120/0f172a/ffffff&text=Producer+--(valid,data)--%3E+%5B+Pipeline+Stage+%5D+--%3E+Consumer" />
</p>

> Equivalent to a **1-depth elastic buffer / AXI-Stream register slice**

| Property     | Value         |
| ------------ | ------------- |
| Latency      | 1 cycle       |
| Throughput   | 1 txn / cycle |
| Storage      | Single-entry  |
| Backpressure | Lossless      |

---

## 🏗️ Design Summary

* `data_reg` → holds data
* `slot_full` → valid flag
* `txn_count` → increments on handshake

| Condition     | Action  |
| ------------- | ------- |
| full + ready  | consume |
| empty + valid | load    |
| full + !ready | stall   |

---

## 🧪 Verification

### Architecture

* Generator
* Driver
* Monitor
* Scoreboard

### Stimulus

* Random data
* Random delays (1–5 cycles)
* Random stalls (0–8 cycles)

---

## 🧷 Assertions

```systemverilog
// handshake correctness
assert property (@(posedge clk) valid && ready);

// stability under stall
assert property (@(posedge clk) valid && !ready |-> $stable(data));

// no overwrite
assert property (@(posedge clk) slot_full && !ready |-> $stable(data_reg));
```

---

## 📊 Coverage (Intent)

```systemverilog
covergroup cg;
  coverpoint valid;
  coverpoint ready;
  cross valid, ready;
endgroup
```

---

## 📈 Waveform

<p align="center">
  <img src="waveform.png" width="850">
</p>

✔ Correct handshake
✔ Stable under backpressure
✔ No data loss
✔ Accurate sequencing

---

## ⚙️ Performance

| Metric     | Value       |
| ---------- | ----------- |
| Latency    | 1 cycle     |
| Throughput | 1 txn/cycle |
| Integrity  | Guaranteed  |

---

## ▶️ Run

```bash
xvlog src/pipeline_dut.sv sim/transaction.sv sim/tb_pipeline.sv
xelab tb_pipeline -s tb_pipeline_sim
xsim tb_pipeline_sim -run all
```

---

## 📁 Structure

```
src/
sim/
waveform.png
README.md
```

---

## ✅ Results

PASS: **20 / 20**
FAIL: **0**

---

## 🏭 Relevance

* AXI-Stream pipelines
* NoC routers
* DSP streaming chains
* FIFO front-end buffering

---

## 🔮 Extensions

* FIFO (multi-stage)
* Skid buffer
* UVM testbench
* Coverage metrics
* Performance analysis

---

## Author

**Arya Dinesh**  
*B.Tech Electronics & Communication Engineering*
