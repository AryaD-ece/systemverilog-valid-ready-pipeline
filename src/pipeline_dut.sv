// ─────────────────────────────────────────────────────────────
// File: pipeline_dut.sv
// Description: 1-stage pipeline with valid/ready handshake
//              Supports backpressure and transaction counting
// ─────────────────────────────────────────────────────────────

`timescale 1ns/1ps

module pipeline_dut (

  // ── Inputs ──
  input  logic       clk,
  input  logic       rst,
  input  logic       prod_valid,
  input  logic [7:0] prod_data,
  input  logic       cons_ready,

  // ── Outputs ──
  output logic [7:0] cons_data,
  output logic       cons_valid_out,
  output logic [7:0] txn_count
);

  // ── Internal Registers ──
  logic [7:0] data_reg;        // Holds current data
  logic       slot_full;       // Indicates valid data present
  logic [7:0] txn_count_reg;   // Transaction counter

  // ── Sequential Logic ──
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      data_reg      <= 8'h00;
      slot_full     <= 1'b0;
      txn_count_reg <= 8'h00;

    end else begin

      // ── CASE 1: Consume (valid & ready) ──
      if (slot_full && cons_ready) begin
        txn_count_reg <= txn_count_reg + 1;

        // Back-to-back transfer
        if (prod_valid) begin
          data_reg  <= prod_data;
          slot_full <= 1'b1;
        end else begin
          slot_full <= 1'b0;
        end

      // ── CASE 2: Load new data into empty slot ──
      end else if (!slot_full && prod_valid) begin
        data_reg  <= prod_data;
        slot_full <= 1'b1;
      end

      // ── CASE 3: Hold (backpressure) ──
      // slot_full = 1 and cons_ready = 0 → no change

    end
  end

  // ── Output Assignments ──
  assign cons_data      = data_reg;
  assign cons_valid_out = slot_full;
  assign txn_count      = txn_count_reg;

endmodule