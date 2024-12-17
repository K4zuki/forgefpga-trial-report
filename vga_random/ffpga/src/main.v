(* top *) module simple_counter(
  (* iopad_external_pin, clkbuf_inhibit *) input  i_clk,
  (* iopad_external_pin, clkbuf_inhibit *) input  pll_clk,
  (* iopad_external_pin *) output                 osc_en,
  (* iopad_external_pin *) input                  i_nreset,
  (* iopad_external_pin *) output reg [3:0]       red,
  (* iopad_external_pin *) output [3:0]           red_oe,
  (* iopad_external_pin *) output reg [3:0]       green,
  (* iopad_external_pin *) output [3:0]           green_oe,
  (* iopad_external_pin *) output reg [3:0]       blue,
  (* iopad_external_pin *) output [3:0]           blue_oe,

  (* iopad_external_pin *) output                 HSYNC,
  (* iopad_external_pin *) output                 VSYNC,

  (* iopad_external_pin *) output                 HSYNC_OE,
  (* iopad_external_pin *) output                 VSYNC_OE,

  // PLL Settings
  (* iopad_external_pin *) output                 pll_en,
  (* iopad_external_pin *) output [5:0]           pll_refdiv,
  (* iopad_external_pin *) output [11:0]          pll_fbdiv,
  (* iopad_external_pin *) output [2:0]           pll_postdiv1,
  (* iopad_external_pin *) output [2:0]           pll_postdiv2,
  (* iopad_external_pin *) output                 pll_bypass,
  (* iopad_external_pin *) output                 pll_clk_selection,

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

  assign pll_en = 1'b1;
  // config for 65MHz
  assign pll_refdiv = 6'd1;
  assign pll_fbdiv = 12'd26;
  assign pll_postdiv1 = 3'd5;
  assign pll_postdiv2 = 3'd4;
  assign pll_bypass = 1'b0;// 1 lets PLL_IN = PLL_OUT
  assign pll_clk_selection = 1'b0; // 1 uses GPIO2 for PLL input

  reg [11:0] lfsr;
  wire display_on;
  wire [10:0] hpos;
  wire [9:0] vpos;
  assign red_oe = 4'hF;
  assign green_oe = 4'hF;
  assign blue_oe = 4'hF;
  assign osc_en = 1'b1;
  assign osc_out_en = 1'b1;
  assign HSYNC_OE = 1'b1;
  assign VSYNC_OE = 1'b1;

  always @(posedge i_clk) begin
    osc_out <= ~osc_out;
  end

  lfsr12 lfsr_gen(
    .i_nreset (i_nreset),
    .i_clk    (pll_clk ),
    .lfsr     (lfsr    )
  );

  vga_syncgen hvsync_gen(
    .clk       (pll_clk   ),
    .reset     (i_nreset  ),
    .hsync     (HSYNC     ),
    .vsync     (VSYNC     ),
    .display_on(display_on),
    .hpos      (hpos      ),
    .vpos      (vpos      )
  );

  always @(posedge pll_clk) begin
    red <= {lfsr[11] && display_on, lfsr[10] && display_on, lfsr[9] && display_on, lfsr[8] && display_on};
    green <= {lfsr[7] && display_on, lfsr[6] && display_on, lfsr[5] && display_on, lfsr[4] && display_on};
    blue <= {lfsr[3] && display_on, lfsr[2] && display_on, lfsr[1] && display_on, lfsr[0] && display_on};
  end


endmodule
