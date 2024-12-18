// The (*top*) attribute is needed on the topmost module for synthesis
(* top *) module main(
  (* iopad_external_pin, clkbuf_inhibit *) input    i_clk,
  (* iopad_external_pin, clkbuf_inhibit *) input    i_clk_lac0,
  (* iopad_external_pin *) input                    i_nreset,

  (* iopad_external_pin *) output                   osc_en,

  (* iopad_external_pin *) output reg [7:0]         o_row,
  (* iopad_external_pin *) output [7:0]             o_row_oe,
  (* iopad_external_pin *) output reg [7:0]         o_col,
  (* iopad_external_pin *) output [7:0]             o_col_oe,

  (* iopad_external_pin *) output                   scan_clk_4k_out,
  (* iopad_external_pin *) output                   scan_clk_4k_oe,

  (* iopad_external_pin *) output [2:0]             testbus,
  (* iopad_external_pin *) output [2:0]             testbus_oe

);

  assign osc_en = 1'b1;

  reg [2:0] row_ptr;
  reg row_en;
  reg [4:0] cnt_4k;
  parameter cnt_4k_max  = 25;
  parameter cnt_4k_duty = 20;

  wire [7:0] rows[7:0];
  reg [15:0] scan_counter;
  reg scan_clk_4k;

  assign o_row_oe = 8'hFF;
  assign o_col_oe = 8'hFF;

  assign rows[0] = 8'b0000_0001;
  assign rows[1] = 8'b0000_0011;
  assign rows[2] = 8'b0000_0111;
  assign rows[3] = 8'b0000_1111;
  assign rows[4] = 8'b0001_1111;
  assign rows[5] = 8'b0011_1111;
  assign rows[6] = 8'b0111_1111;
  assign rows[7] = 8'b1111_1111;

  assign testbus_oe = 3'b111;
  assign testbus[0] = scan_clk_4k;
  assign testbus[1] = row_en;
  assign testbus[2] = 1'b1;

  assign scan_clk_4k_out = scan_clk_4k;
  assign scan_clk_4k_oe = 1'b1;
/*
refresh rate = 20Hz = 50ms
50 / 8 = 6.25ms per row
6.25 = 0.25ms * 25
0.25mx = 250us = 4kHz
50M / 4k = 12500
*/
  clk_divider #(
  	.WIDTH  (16  ),
  	.DIVISOR(2500)
  	)scan_clk(
    .i_clk(i_clk      ),
    .o_clk(scan_clk_4k)
  );

  always @(posedge i_clk_lac0) begin
    if (i_nreset == 1'b0) begin
      row_ptr <= 3'b000;
      o_row <= 8'b0;
      cnt_4k <= 5'b0;
      row_en <= 1'b0;
    end else begin
      cnt_4k <= cnt_4k + 1;
      if (cnt_4k > (cnt_4k_max - 1)) begin
        cnt_4k <= 5'b0;
        row_ptr <= row_ptr + 1;
      end else begin
        row_en <= (cnt_4k < cnt_4k_duty) ? 1'b1 : 1'b0;
      end
      o_row <= ~(row_en << row_ptr);
      o_col <= rows[row_ptr];
    end
  end

endmodule
