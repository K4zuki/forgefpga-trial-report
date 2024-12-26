// The (*top*) attribute is needed on the topmost module for synthesis
(* top *) module main(
  (* iopad_external_pin, clkbuf_inhibit *) input    i_clk, /* Receives integrated oscillator output */
  (* iopad_external_pin, clkbuf_inhibit *) input    i_lac0, /* Receives LaC output */
  (* iopad_external_pin *) input                    i_nreset, /* Receives nRST pin status */

  (* iopad_external_pin *) output                   osc_en, /* Enables integrated oscillator; const H */

  (* iopad_external_pin *) output reg [7:0]         row, /* ROW signal output */
  (* iopad_external_pin *) output [7:0]             o_row_oe, /* ROW pins output enable; const H */
  (* iopad_external_pin *) output reg [7:0]         col, /* COL signal output */
  (* iopad_external_pin *) output [7:0]             o_col_oe, /* COL pins output enable; const H */

  (* iopad_external_pin *) output                   scan_clk_out, /* Sends to LaC0 block; 1MHz */
  (* iopad_external_pin *) output                   scan_clk_oe, /* Enables LaC0 block; const H */

  (* iopad_external_pin *) output [2:0]             testbus, /* Internal signal monitoring output array */
  (* iopad_external_pin *) output [2:0]             testbus_oe /* Test signal pins output enable; const H */

);

  parameter FPS            = 1250; /* Frames Per Second */
  parameter BRIGHTNESS     = 80; /* Percentage */

  /*
  scan clock = 50M / 50 = 1MHz
  MAX_SCAN_COUNT = 1M / (FPS * 8)

  MAX_SCAN_COUNT [us/ROW] | FPS
  -----------------------------------
  100                     | 1250
  125                     | 1000
  250                     | 500
  2500                    | 50
  25000                   | 5
  125000                  | 1
  */

  parameter MAX_SCAN_COUNT = 1_000_000 / (FPS * 8); /* usec per row */
  parameter SCAN_DUTY_INT  = BRIGHTNESS * MAX_SCAN_COUNT / 100; /* Hi level duration in usec */

  /* Constant Hi signals */
  assign osc_en = 1'b1;
  assign o_row_oe = 8'hFF;
  assign o_col_oe = 8'hFF;
  assign testbus_oe = 3'b111;
  assign scan_clk_oe = 1'b1;

  reg [2:0] row_ptr; /* ROW focus pointer */
  reg row_en; /* ROW pulls cuurent when this is Hi */
  reg [15:0] scan_cnt; /* Timing generation counter */

  reg scan_clk; /* Receives clock divider output */

  /* Data */
  wire [7:0] rows[7:0];
  assign rows[0] = 8'b0000_0001;
  assign rows[1] = 8'b0000_0011;
  assign rows[2] = 8'b0000_0111;
  assign rows[3] = 8'b0000_1111;
  assign rows[4] = 8'b0001_1111;
  assign rows[5] = 8'b0011_1111;
  assign rows[6] = 8'b0111_1111;
  assign rows[7] = 8'b1111_1111;

  /* 50M to 1M clock divider */
  clk_divider #(
    .DIVISOR(50)
  )scan_clk_gen(
    .i_clk(i_clk   ),
    .o_clk(scan_clk)
  );

  always @(posedge i_lac0) begin
    if (i_nreset == 1'b0) begin
      row_ptr <= 3'b000;
      row <= 8'b0;
      scan_cnt <= 'd0;
      row_en <= 1'b0;
    end else begin
      scan_cnt <= scan_cnt + 1;
      if (scan_cnt > (MAX_SCAN_COUNT - 1)) begin
        scan_cnt <= 'd0;
        row_ptr <= row_ptr + 1;
      end else begin
        row_en <= (scan_cnt < (SCAN_DUTY_INT - 1)) ? 1'b1 : 1'b0;
      end
      row <= ~(row_en << row_ptr);
      col <= rows[row_ptr];
    end
  end

  assign testbus[0] = scan_clk;
  assign testbus[1] = row_en;
  assign testbus[2] = row[0];

  assign scan_clk_out = scan_clk;

endmodule
