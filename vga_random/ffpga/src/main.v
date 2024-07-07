(* top *) module simple_counter(
  (* iopad_external_pin, clkbuf_inhibit *) input  i_clk,
  (* iopad_external_pin *) input                  i_nreset,
  (* iopad_external_pin *) output [7:0]           o_lfsr,
  (* iopad_external_pin *) output                 oe,
  (* iopad_external_pin *) output                 osc_en

);

  assign oe = 1'b1;
  assign osc_en = 1'b1;

  lfsr uut(
    .CLK  (i_clk      ),
    .load (1'b0       ),
    .seed (8'd100     ),
    .out  (o_lfsr[7:0])
  );


endmodule

module lfsr (CLK, load, seed, out);

    // port
    input        CLK;
    input        load;
    input  [7:0] seed;

    output [7:0] out;

    // internal
    reg    [7:0] r;

    always @(posedge CLK) begin
        if (load)
            r <= seed;
        else begin
            // 8 bit tap 8,6,5,4
            r <= {r[0], r[7], r[0]^r[6], r[0]^r[5], r[0]^r[4], r[3], r[2], r[1]};
        end
    end

    assign out = r;

endmodule
