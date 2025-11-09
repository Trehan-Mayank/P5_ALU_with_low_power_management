`timescale 1ns / 1ps
// Parameterizable ALU with flags
// AUTHOR: ChatGPT (example)
// WIDTH default = 32

module ALU #
(
  parameter integer WIDTH = 32
)
(
  input  wire [WIDTH-1:0] A,
  input  wire [WIDTH-1:0] B,
  input  wire [3:0]       ALU_Sel,
  input  wire             Cin,         // optional carry-in (for ADC / SBC)
  output reg  [WIDTH-1:0] Result,
  output reg              Zero,
  output reg              CarryOut,
  output reg              Overflow,
  output reg              Negative,
  output reg              Less         // for SLT / comparator
  // Power Signals
  input [3:0]             iso_ctrl,
  input [3:0]             psw_ctrl
);

  // intermediate wide results with extra bit for carry
  wire [WIDTH:0] add_w;
  wire [WIDTH:0] sub_w; // using two's complement add: A + (~B) + 1

  assign add_w = {1'b0, A} + {1'b0, B} + { {WIDTH{1'b0}}, Cin } ; 
  // For subtraction: A - B  = A + (~B) + 1
  assign sub_w = {1'b0, A} + {1'b0, ~B} + {{WIDTH{1'b0}}, 1'b1};

  // signed views for overflow detection
  wire signed [WIDTH-1:0] A_signed = A;
  wire signed [WIDTH-1:0] B_signed = B;
  wire signed [WIDTH-1:0] res_signed;

  // default combinational logic
  always @(*) begin
    // default outputs
    Result    = {WIDTH{1'b0}};
    Zero      = 1'b0;
    CarryOut  = 1'b0;
    Overflow  = 1'b0;
    Negative  = 1'b0;
    Less      = 1'b0;

    case (ALU_Sel)
      4'b0000: begin // AND
        Result = A & B;
      end

      4'b0001: begin // OR
        Result = A | B;
      end

      4'b0010: begin // ADD (A + B), Cin ignored
        Result   = add_w[WIDTH-1:0];
        CarryOut = add_w[WIDTH];
        // Overflow for signed add
        Overflow = (A[WIDTH-1] & B[WIDTH-1] & ~Result[WIDTH-1]) |
                   (~A[WIDTH-1] & ~B[WIDTH-1] & Result[WIDTH-1]);
      end

      4'b0011: begin // ADC (add with carry-in)
        Result   = add_w[WIDTH-1:0];
        CarryOut = add_w[WIDTH];
        Overflow = (A[WIDTH-1] & B[WIDTH-1] & ~Result[WIDTH-1]) |
                   (~A[WIDTH-1] & ~B[WIDTH-1] & Result[WIDTH-1]);
      end

      4'b0100: begin // XOR
        Result = A ^ B;
      end

      4'b0101: begin // NOR
        Result = ~(A | B);
      end

      4'b0110: begin // SUB (A - B)
        Result   = sub_w[WIDTH-1:0];
        CarryOut = sub_w[WIDTH]; // carry-out indicates no-borrow when 1
        // Overflow for signed subtract: A - B
        Overflow = (A[WIDTH-1] & ~B[WIDTH-1] & ~Result[WIDTH-1]) |
                   (~A[WIDTH-1] & B[WIDTH-1] & Result[WIDTH-1]);
      end

      4'b0111: begin // SBC (A - B - Cin) -> implement as A + (~B) + (1 - Cin)
        // compute A - B - Cin = A + (~B) + 1 - Cin => add (~B) + (1 - Cin)
        // We'll compute with add_w_temp
        wire [WIDTH:0] sbc_w;
        assign sbc_w = {1'b0, A} + {1'b0, ~B} + {{WIDTH{1'b0}}, (1'b1 - Cin)};
        Result   = sbc_w[WIDTH-1:0];
        CarryOut = sbc_w[WIDTH];
        Overflow = (A[WIDTH-1] & ~B[WIDTH-1] & ~Result[WIDTH-1]) |
                   (~A[WIDTH-1] & B[WIDTH-1] & Result[WIDTH-1]);
      end

      4'b1000: begin // SLT (signed)
        Less = (A_signed < B_signed) ? 1'b1 : 1'b0;
        Result = { {WIDTH-1{1'b0}}, Less };
      end

      4'b1001: begin // SLTU (unsigned)
        Less = (A < B) ? 1'b1 : 1'b0;
        Result = { {WIDTH-1{1'b0}}, Less };
      end

      4'b1010: begin // SLL - logical left shift by amount in lower bits of B
        Result = A << B[ $clog2(WIDTH)-1 : 0 ];
      end

      4'b1011: begin // SRL - logical right shift
        Result = A >> B[ $clog2(WIDTH)-1 : 0 ];
      end

      4'b1100: begin // SRA - arithmetic right shift
        Result = $signed(A) >>> B[ $clog2(WIDTH)-1 : 0 ];
      end

      default: begin
        Result = {WIDTH{1'b0}};
      end
    endcase

    // flags common
    Zero     = (Result == {WIDTH{1'b0}});
    Negative = Result[WIDTH-1];

    // For ADD/SUB paths CarryOut & Overflow already set in cases
    // For logic ops CarryOut & Overflow cleared (already defaulted to 0)
  end

  // expose signed result wire for clarity (not used elsewhere)
  assign res_signed = Result;

endmodule
