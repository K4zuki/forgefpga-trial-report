module clk_divider #(
     parameter WIDTH   = 14,
     parameter DIVISOR = 12500
  )(
    input      i_clk,
    output reg o_clk
);

  reg [WIDTH-1:0] counter = 0;

  always @(posedge i_clk) begin
      counter <= counter + 1;
      if (counter >= (DIVISOR - 1)) begin
        counter <= 0;
      end
      o_clk <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
  end

endmodule
