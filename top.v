`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2025
// Design Name: ALU + PMU Top
// Module Name: top
// Description: 
//   Top-level integrating ALU and PMU with power management signals.
// 
//////////////////////////////////////////////////////////////////////////////////

module top #
(
  parameter integer WIDTH = 32
)(
    // Global signals
    input  wire                   clk,
    input  wire                   rst,

    // ALU input Signals
    input  wire [WIDTH-1:0]       A,
    input  wire [WIDTH-1:0]       B,
    input  wire [3:0]             ALU_Sel,
    input  wire                   Cin,

    // ALU output Signals
    output wire [WIDTH-1:0]       Result,
    output wire                   Zero,
    output wire                   CarryOut,
    output wire                   Overflow,
    output wire                   Negative,
    output wire                   Less,

    // Idle Signal for PMU to direct Power Signals
    input  wire                   idle
);

  // Power control signals from PMU
  wire [3:0] iso_ctrl;
  wire [3:0] psw_ctrl;

  //==========================================================
  // Instantiate PMU
  //==========================================================
  PMU inst_PMU (
      .clk(clk),
      .rst(rst),
      .idle(idle),
      .iso_ctrl(iso_ctrl),
      .psw_ctrl(psw_ctrl)
  );

  //==========================================================
  // Instantiate ALU
  //==========================================================
  ALU #(.WIDTH(WIDTH)) inst_ALU (
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
      .iso_ctrl(iso_ctrl),
      .psw_ctrl(psw_ctrl)
  );

endmodule
