(* top *) module simple_counter(
  (* iopad_external_pin, clkbuf_inhibit *) input  i_clk,
  (* iopad_external_pin *) output                 osc_en,
  (* iopad_external_pin *) input                  i_nreset,
  (* iopad_external_pin *) output  [7:0]          o_lfsr,
  (* iopad_external_pin *) output  [7:0]          lfsr_oe,
  (* iopad_external_pin *) output reg             osc_out,
  (* iopad_external_pin *) output                 osc_out_en
);

  reg [7:0] lfsr;
  assign lfsr_oe = 8'b11111111;
  assign osc_en = 1'b1;
  assign osc_out_en = 1'b1;

  always @(posedge i_clk) begin
    osc_out = ~osc_out;
  end

  always @(posedge i_clk) begin
    //  http://www.neko.ne.jp/~freewing/fpga/lfsr_verilog/
    if (i_nreset==1'b0)
        lfsr <= 8'b11111111;
    else begin
        // 8 bit tap 8,6,5,4
        lfsr <= {lfsr[0], lfsr[7], lfsr[0]^lfsr[6], lfsr[0]^lfsr[5], lfsr[0]^lfsr[4], lfsr[3:1]};
    end
  end

  assign o_lfsr = lfsr;

endmodule
