
module PMU (
  input  wire clk,
  input  wire rst,      // Active-high asynchronous reset
  input  wire idle,     // Idle input signal

  output reg [3:0] iso_ctrl,
  output reg [3:0] psw_ctrl,
);
  reg [3:0] counter_idle_high;
  reg [3:0] counter_idle_low;

  // sequential logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      iso_ctrl          <= 4'b0000;
      psw_ctrl          <= 4'b0000;
      counter_idle_high <= 4'd0;
      counter_idle_low  <= 4'd0;
    end else begin
      // if idle is HIGH: increment high counter, reset low counter
      if (idle) begin
        counter_idle_low  <= 4'd0;
        if (counter_idle_high < 4'd2)
          counter_idle_high <= counter_idle_high + 1;
        else
          counter_idle_high <= counter_idle_high; // hold at 2

        // control sequence when idle is high
        case (counter_idle_high)
          4'd0: begin
            // nothing yet
          end
          4'd1: begin
            iso_ctrl[1] <= 1'b1;
          end
          4'd2: begin
            iso_ctrl[0] <= 1'b1;
            psw_ctrl[1] <= 1'b1;
          end
          default: ;
        endcase

      end
      // if idle is LOW: increment low counter, reset high counter
      else begin
        counter_idle_high <= 4'd0;
        if (counter_idle_low < 4'd2)
          counter_idle_low <= counter_idle_low + 1;
        else
          counter_idle_low <= counter_idle_low; // hold at 2

        // control sequence when idle is low
        case (counter_idle_low)
          4'd0: begin
            // nothing yet
          end
          4'd1: begin
            iso_ctrl[0] <= 1'b0;
            psw_ctrl[1] <= 1'b0;
          end
          4'd2: begin
            iso_ctrl[1] <= 1'b0;
          end
          default: ;
        endcase
      end
    end
  end

endmodule
