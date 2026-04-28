// ─────────────────────────────────────────────────────────────
// File: transaction.sv
// Description: Transaction object used by producer and consumer
// ─────────────────────────────────────────────────────────────

class transaction;

  // ── Randomized Fields ──
  rand bit [7:0] data;    // 8-bit payload
  rand bit [2:0] delay;   // Inter-transaction delay (cycles)

  // ── Metadata ──
  int txn_id;             // Transaction ID

  // ── Constraints ──
  constraint c_delay { delay inside {[1:5]}; } // Avoid zero delay
  constraint c_data  { data > 0; }             // Avoid zero data

  // ── Display Utility ──
  function void display(input string tag);
    $display("%s txn_id=0x%0h data=0x%02h delay=0x%0h",
             tag, txn_id, data, delay);
  endfunction

endclass