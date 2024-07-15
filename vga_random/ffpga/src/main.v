(* top *) module simple_counter(
  (* iopad_external_pin, clkbuf_inhibit *) input  i_clk,
  (* iopad_external_pin, clkbuf_inhibit *) input  bitclock,
  (* iopad_external_pin *) output                 osc_en,
  (* iopad_external_pin *) input                  i_nreset,
  (* iopad_external_pin *) output  [3:0]          red,
  (* iopad_external_pin *) output  [3:0]          red_oe,
  (* iopad_external_pin *) output  [3:0]          green,
  (* iopad_external_pin *) output  [3:0]          green_oe,
  (* iopad_external_pin *) output  [3:0]          blue,
  (* iopad_external_pin *) output  [3:0]          blue_oe,

  (* iopad_external_pin *) output                 HSYNC,
  (* iopad_external_pin *) output                 VSYNC,

  (* iopad_external_pin *) output                 HSYNC_OE,
  (* iopad_external_pin *) output                 VSYNC_OE,

  (* iopad_external_pin *) output reg             osc_out,
  (* iopad_external_pin *) output                 osc_out_en
);
/*
|IO8  : R0  |IO12 : B0  |
|IO9  : R1  |IO13 : B1  |
|IO10 : R2  |IO14 : B2  |
|IO11 : R3  |IO15 : B3  |

|IO0 : G0   |IO4 : HSY  |
|IO1 : G1   |IO5 : VSY  |
|IO2 : G2   |IO6 : NC   |
|IO3 : G3   |IO7 : NC   |
*/

  reg [11:0] lfsr;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  assign red_oe = 4'hF;
  assign green_oe = 4'hF;
  assign blue_oe = 4'hF;
  assign osc_en = 1'b1;
  assign osc_out_en = 1'b1;
  assign HSYNC_OE = 1'b1;
  assign VSYNC_OE = 1'b1;

  always @(posedge i_clk) begin
    osc_out = ~osc_out;
  end

  lfsr12 lfsr_gen(
    .i_nreset (i_nreset),
    .i_clk    (bitclock),
    .lfsr     (lfsr    )
  );

  vga_syncgen hvsync_gen(
    .clk       (bitclock  ),
    .reset     (i_nreset  ),
    .hsync     (HSYNC     ),
    .vsync     (VSYNC     ),
    .display_on(display_on),
    .hpos      (hpos      ),
    .vpos      (vpos      )
  );

  assign red = {lfsr[11] && display_on, lfsr[10] && display_on, lfsr[9] && display_on, lfsr[8] && display_on};
  assign green = {lfsr[7] && display_on, lfsr[6] && display_on, lfsr[5] && display_on, lfsr[4] && display_on};
  assign blue = {lfsr[3] && display_on, lfsr[2] && display_on, lfsr[1] && display_on, lfsr[0] && display_on};

endmodule
