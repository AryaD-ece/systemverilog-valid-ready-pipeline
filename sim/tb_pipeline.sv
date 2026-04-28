// ─────────────────────────────────────────────────────────────
// File: tb_pipeline.sv
// Description: Testbench for pipeline_dut
//              Includes randomized stimulus and scoreboard
// ─────────────────────────────────────────────────────────────

`include "transaction.sv"

module tb_pipeline;

  timeunit 1ns;
  timeprecision 1ps;

  // ── DUT Interface Signals ──
  logic        clk;
  logic        rst;
  logic        prod_valid;
  logic [7:0]  prod_data;
  logic        cons_ready;
  logic [7:0]  cons_data;
  logic        cons_valid_out;
  logic [7:0]  txn_count;

  // ── Verification Infrastructure ──
  mailbox #(transaction) pipe_mb;
  int pass_count = 0;
  int fail_count = 0;

  // ── DUT Instance ──
  pipeline_dut dut (
    .clk            (clk),
    .rst            (rst),
    .prod_valid     (prod_valid),
    .prod_data      (prod_data),
    .cons_ready     (cons_ready),
    .cons_data      (cons_data),
    .cons_valid_out (cons_valid_out),
    .txn_count      (txn_count)
  );

  // ── Clock Generation (10ns period) ──
  initial clk = 1'b0;
  always  #5 clk = ~clk;

  // ── Waveform Dump ──
  initial begin
    $dumpfile("tb_pipeline.vcd");
    $dumpvars(0, tb_pipeline);
  end

  // ══════════════════════════════════════════════════════════
  // PRODUCER TASK
  // Generates transactions and feeds DUT
  // ══════════════════════════════════════════════════════════
  task automatic producer(input int num_txns);
    transaction tr;

    for (int i = 0; i < num_txns; i++) begin

      tr = new();
      assert(tr.randomize());

      tr.txn_id = i;
      tr.display("PROD");

      // Wait until DUT is ready to accept new data
      @(posedge clk);
      while (cons_valid_out) @(posedge clk);

      // Drive data for one cycle
      prod_data  <= tr.data;
      prod_valid <= 1'b1;
      @(posedge clk);
      prod_valid <= 1'b0;

      // Send to mailbox for verification
      pipe_mb.put(tr);

      // Random delay
      repeat (tr.delay) @(posedge clk);
    end
  endtask

  // ══════════════════════════════════════════════════════════
  // CONSUMER TASK
  // Applies backpressure and verifies DUT output
  // ══════════════════════════════════════════════════════════
  task automatic consumer(input int num_txns);
    transaction  expected;
    int          stall_time;
    logic [7:0]  captured_data;

    repeat (num_txns) begin

      // Apply random backpressure
      stall_time  = $urandom_range(0, 8);
      cons_ready <= 1'b0;
      repeat (stall_time) @(posedge clk);

      // Wait for valid data
      while (!cons_valid_out) @(posedge clk);

      // Trigger consume
      cons_ready <= 1'b1;
      @(posedge clk);

      // Capture data before it is cleared
      captured_data = cons_data;

      cons_ready <= 1'b0;

      // Wait for count update (registered output)
      @(posedge clk);

      // Scoreboard comparison
      pipe_mb.get(expected);

      if (captured_data === expected.data) begin
        pass_count++;
        $display("PASS txn_id=0x%0h  exp=0x%02h  got=0x%02h  count=%0d",
                 expected.txn_id, expected.data,
                 captured_data,   txn_count);
      end else begin
        fail_count++;
        $error("FAIL txn_id=0x%0h  exp=0x%02h  got=0x%02h",
               expected.txn_id, expected.data, captured_data);
      end

      @(posedge clk); // Idle cycle

    end
  endtask

  // ══════════════════════════════════════════════════════════
  // MAIN TEST SEQUENCE
  // ══════════════════════════════════════════════════════════
  initial begin

    pipe_mb    = new();
    prod_valid = 1'b0;
    prod_data  = 8'h00;
    cons_ready = 1'b0;

    // Reset sequence
    rst = 1'b1;
    repeat (3) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    // Run producer and consumer in parallel
    fork
      producer(20);
      consumer(20);
    join

    // Final summary
    $display("================================================");
    $display("         SIMULATION COMPLETE");
    $display("  PASS     : %0d / 20", pass_count);
    $display("  FAIL     : %0d / 20", fail_count);
    $display("  DUT COUNT: %0d",      txn_count);
    $display("================================================");

    #20 $finish;

  end

endmodule