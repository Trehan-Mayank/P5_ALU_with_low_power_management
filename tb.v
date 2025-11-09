`timescale 1ns / 1ps

module tb_top;

  //==========================================================
  // Parameters
  //==========================================================
  localparam WIDTH = 32;

  //==========================================================
  // DUT I/O
  //==========================================================
  reg                    clk;
  reg                    rst;
  reg  [WIDTH-1:0]       A, B;
  reg  [3:0]             ALU_Sel;
  reg                    Cin;
  reg                    idle;

  wire [WIDTH-1:0]       Result;
  wire                   Zero, CarryOut, Overflow, Negative, Less;

  //==========================================================
  // DUT Instance
  //==========================================================
  top #(.WIDTH(WIDTH)) uut (
    .clk(clk),
    .rst(rst),
    .A(A),
    .B(B),
    .ALU_Sel(ALU_Sel),
    .Cin(Cin),
    .Result(Result),
    .Zero(Zero),
    .CarryOut(CarryOut),
    .Overflow(Overflow),
    .Negative(Negative),
    .Less(Less),
    .idle(idle)
  );

  //==========================================================
  // Clock Generation
  //==========================================================
  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz clock

  //==========================================================
  // Reset
  //==========================================================
  initial begin
    rst = 1'b1;
    #20;
    rst = 1'b0;
  end

  //==========================================================
  // Stimulus
  //==========================================================
  initial begin
    A = 0; B = 0; ALU_Sel = 0; Cin = 0; idle = 0;

    // Wait for reset
    @(negedge rst);
    #10;

    $display("\n===== Starting ALU + PMU Simulation =====\n");

    // Case 1: Normal ADD operation
    idle = 0;
    A = 32'h0000_000A;
    B = 32'h0000_0005;
    ALU_Sel = 4'b0000; // ADD
    Cin = 0;
    #30;
    $display("[%0t] ADD -> A=%0d, B=%0d, Result=%0d", $time, A, B, Result);

    // Case 2: Enter idle (PMU activates isolation and power switches)
    $display("[%0t] --- Entering IDLE mode ---", $time);
    idle = 1;
    #50;

    // Case 3: Exit idle (PMU releases isolation)
    $display("[%0t] --- Exiting IDLE mode ---", $time);
    idle = 0;
    #50;

    // Case 4: Another operation after wake-up
    A = 32'h0000_000F;
    B = 32'h0000_0002;
    ALU_Sel = 4'b0001; // SUB
    #30;
    $display("[%0t] SUB -> A=%0d, B=%0d, Result=%0d", $time, A, B, Result);

    // Case 5: Multiple idle toggles to stress-test PMU counters
    repeat (3) begin
      idle = 1; #40;
      idle = 0; #40;
    end

    #100;
    $display("\n===== Simulation Complete =====\n");
    $finish;
  end

  //==========================================================
  // Waveform Dump
  //==========================================================
  initial begin
    $dumpfile("top_pmu_alu.vcd");
    $dumpvars(0, tb_top);
  end

  //==========================================================
  // PMU Monitor
  //==========================================================
  always @(uut.inst_PMU.iso_ctrl or uut.inst_PMU.psw_ctrl) begin
    $display("[%0t] iso_ctrl=%b  psw_ctrl=%b", $time,
             uut.inst_PMU.iso_ctrl, uut.inst_PMU.psw_ctrl);
  end

endmodule
