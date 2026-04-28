# SystemVerilog Valid-Ready Pipeline Verification

A rigorously verified implementation of a **1-stage valid-ready pipeline** in SystemVerilog, supported by a constrained-random, self-checking testbench, **SystemVerilog Assertions (SVA)**, and functional coverage.

---

## Problem Statement

In synchronous digital systems, **data transfer between producer and consumer modules must be reliable under varying rates of data generation and consumption**.

A common solution is the **valid-ready handshake protocol**, where:

* Producer asserts `valid`
* Consumer asserts `ready`
* Transfer occurs only when both are high

However, incorrect implementations can lead to:

* Data loss
* Data duplication
* Incorrect transaction ordering
* Failure under backpressure conditions

---

## Objective

Design and verify a **backpressure-aware pipeline stage** that guarantees:

* Correct data transfer under all timing conditions
* No loss or duplication of transactions
* Deterministic and accurate transaction counting
* Robust handling of random stalls and backpressure

---

## Why SystemVerilog?

SystemVerilog is used because it provides:

* **Assertions (SVA)** → formal correctness checks
* **Constrained randomization** → realistic stimulus generation
* **Coverage-driven verification** → ensures completeness
* **OOP-based testbench design** → scalable verification architecture

This makes it suitable for **industry-grade verification workflows**.

---

## Design Overview

The DUT implements a **single-entry pipeline register**:

```
Producer ──(valid,data)──▶ [ Pipeline Stage ] ──▶ Consumer
                          ◀──── ready ────────
```

### Key Behavior

| Condition         | Action                   |
| ----------------- | ------------------------ |
| valid=1 & ready=1 | Transfer occurs          |
| valid=1 & ready=0 | Data held (backpressure) |
| valid=0           | No transfer              |
| Empty + valid=1   | Load new data            |

---

## Key Design Guarantees

* In-order data delivery
* No overwriting of unconsumed data
* Stable data during stalls
* Transaction count increments only on valid transfers

---

## Repository Structure

```
sv-pipeline-valid-ready/
│
├── src/
│   └── pipeline_dut.sv
│
├── sim/
│   ├── tb_pipeline.sv
│   └── transaction.sv
│
├── waveform.png
├── .gitignore
└── README.md
```

---

## Verification Methodology

### 1. Constrained Random Stimulus

* Random data generation
* Random inter-transaction delays
* Random consumer backpressure

### 2. Self-Checking Scoreboard

* Mailbox-based transaction tracking
* Expected vs actual comparison
* Automatic pass/fail detection

### 3. SystemVerilog Assertions (SVA)

The following assertions validate protocol correctness:

```systemverilog
// Transfer must only occur when valid && ready
property p_handshake;
  @(posedge clk)
  cons_valid_out && cons_ready |-> ##0 cons_valid_out;
endproperty
assert property (p_handshake);

// Transaction count must increment on valid transfer
property p_txn_count;
  @(posedge clk)
  (cons_valid_out && cons_ready) |-> 
    (txn_count == $past(txn_count) + 1);
endproperty
assert property (p_txn_count);

// Data must remain stable when stalled
property p_stable_data;
  @(posedge clk)
  cons_valid_out && !cons_ready |-> 
    $stable(cons_data);
endproperty
assert property (p_stable_data);
```

---

### 4. Functional Coverage

Ensures all key scenarios are exercised:

```systemverilog
covergroup pipeline_cg @(posedge clk);

  coverpoint prod_valid;
  coverpoint cons_ready;

  // Cross coverage: handshake combinations
  cross prod_valid, cons_ready;

  // Backpressure scenarios
  coverpoint cons_ready {
    bins stall[] = {0};
    bins ready[] = {1};
  }

endgroup

pipeline_cg cg = new();
```

---

## Simulation Results

```
SIMULATION COMPLETE
PASS     : 20 / 20
FAIL     : 0 / 20
DUT COUNT: 20
```

✔ All randomized transactions passed
✔ No protocol violations detected
✔ Assertions satisfied

---

## Waveform

![Waveform](waveform.png)

### Observations

* Correct valid-ready handshake
* Data stability during backpressure
* No data corruption or misalignment
* Accurate transaction counting

---

## How to Run

### Using Vivado XSim

```bash
xvlog src/pipeline_dut.sv sim/transaction.sv sim/tb_pipeline.sv
xelab tb_pipeline -s tb_pipeline_sim
xsim tb_pipeline_sim -run all
```

---

## Design Trade-offs

| Aspect       | Choice          | Reason                 |
| ------------ | --------------- | ---------------------- |
| Buffer Depth | 1-stage         | Minimal latency        |
| Control      | Valid-ready     | Industry standard      |
| Counting     | Handshake-based | Accurate measurement   |
| Storage      | Register        | Deterministic behavior |

---

## Extensions

* Multi-stage pipeline (FIFO design)
* AXI-Stream interface adaptation
* Formal verification
* UVM-based testbench
* Performance analysis (latency/throughput)

---

## Key Takeaways

* Correct implementation of flow-controlled pipelines
* Practical use of SystemVerilog verification features
* Understanding of backpressure and timing hazards
* Foundation for scalable hardware verification

---

## Author

**Arya Dinesh**  
*B.Tech Electronics & Communication Engineering*

---

## License

Open-source for academic and learning purposes.
