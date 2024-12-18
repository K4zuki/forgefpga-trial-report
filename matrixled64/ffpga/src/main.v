// The (*top*) attribute is needed on the topmost module for synthesis
(* top *) module main(
  (* iopad_external_pin, clkbuf_inhibit *) input    i_clk,
  (* iopad_external_pin, clkbuf_inhibit *) input    i_lac0,
  (* iopad_external_pin *) input                    i_nreset,

  (* iopad_external_pin *) output                   osc_en,

  (* iopad_external_pin *) output reg [7:0]         o_row,
  (* iopad_external_pin *) output [7:0]             o_row_oe,
  (* iopad_external_pin *) output reg [7:0]         o_col,
  (* iopad_external_pin *) output [7:0]             o_col_oe,

  (* iopad_external_pin *) output                   scan_clk_out,
  (* iopad_external_pin *) output                   scan_clk_oe,

  (* iopad_external_pin *) output [2:0]             testbus,
  (* iopad_external_pin *) output [2:0]             testbus_oe

);

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

  parameter FPS            = 1250;
  parameter BRIGHTNESS     = 80;

  parameter MAX_SCAN_COUNT = 1_000_000 / (FPS * 8);
  parameter SCAN_DUTY_INT  = BRIGHTNESS * MAX_SCAN_COUNT / 100;

  assign osc_en = 1'b1;

  reg [2:0] row_ptr;
  reg row_en;
  reg [15:0] scan_cnt;

  wire [7:0] rows[7:0];
  reg scan_clk;

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

  clk_divider #(
      .WIDTH  (8 ),
      .DIVISOR(50)
  	)scan_clk_gen(
      .i_clk(i_clk   ),
      .o_clk(scan_clk)
  );

  always @(posedge i_lac0) begin
    if (i_nreset == 1'b0) begin
      row_ptr <= 3'b000;
      o_row <= 8'b0;
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
      o_row <= ~(row_en << row_ptr);
      o_col <= rows[row_ptr];
    end
  end

  assign testbus_oe = 3'b111;
  assign testbus[0] = scan_clk;
  assign testbus[1] = row_en;
  assign testbus[2] = 1'b1;

  assign scan_clk_out = scan_clk;
  assign scan_clk_oe = 1'b1;

endmodule
