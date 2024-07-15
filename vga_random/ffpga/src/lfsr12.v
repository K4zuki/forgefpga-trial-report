//  http://www.neko.ne.jp/~freewing/fpga/lfsr_verilog/

module lfsr12(
  input             i_nreset,
  input             i_clk,
  output reg [11:0] lfsr
);
  always @(posedge i_clk) begin
    if (i_nreset == 1'b0)
        lfsr <= 12'hFFF;
    else begin
        // 12 bit tap 12,6,4,1
        lfsr <= {lfsr[0], lfsr[11:7], lfsr[0]^lfsr[6], lfsr[5], lfsr[0]^lfsr[4], lfsr[3:2], lfsr[0]^lfsr[1]};
    end
  end

endmodule