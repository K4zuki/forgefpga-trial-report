module clk_divider #(
     parameter DIVISOR = 12500
  )(
    input      i_clk,
    output reg o_clk
);
/*
o_clk = i_clk / DIVISOR
about 50% duty cycle
*/

  reg [$clog2(DIVISOR + 1) - 1 : 0] counter = 0;

  always @(posedge i_clk) begin
      counter <= counter + 1;
      if (counter >= (DIVISOR - 1)) begin
        counter <= 0;
      end
      o_clk <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
  end

endmodule
