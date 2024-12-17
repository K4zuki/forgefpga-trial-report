// Custom Module

module vga_syncgen(clk, reset, hsync, vsync, display_on, hpos, vpos);
  // https://yuji2yuji.hatenablog.com/entry/2019/08/21/144446
  input             clk;
  input             reset;
  output reg        hsync, vsync;
  output reg        display_on;
  output reg [10:0] hpos;
  output reg [9:0]  vpos;

  // declarations for TV-simulator sync parameters
  // horizontal constants
  parameter H_DISPLAY    = 1024; // horizontal display width
  parameter H_FRONT      = 24;  // horizontal right border (front porch)
  parameter H_SYNC       = 136;  // horizontal sync width
  parameter H_BACK       = 160; // horizontal left border (back porch)
  // vertical constants
  parameter V_DISPLAY    = 768; // vertical display height
  parameter V_BOTTOM     = 3;   // vertical bottom border
  parameter V_SYNC       = 6;   // vertical sync # lines
  parameter V_TOP        = 29;  // vertical top border
  // derived constants
  parameter H_SYNC_START = H_DISPLAY + H_FRONT;
  parameter H_SYNC_END   = H_DISPLAY + H_FRONT + H_SYNC - 1;
  parameter H_MAX        = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
  parameter V_SYNC_START = V_DISPLAY + V_BOTTOM;
  parameter V_SYNC_END   = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  parameter V_MAX        = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

  wire hmaxxed = (hpos == H_MAX) || !reset;  // set when hpos is maximum
  wire vmaxxed = (vpos == V_MAX) || !reset;  // set when vpos is maximum

  // horizontal position counter
  always @(posedge clk)
  begin
    hsync <= (hpos >= H_SYNC_START && hpos <= H_SYNC_END);
    if(hmaxxed)
      hpos <= 0;
    else
      hpos <= hpos + 1;
  end

  // vertical position counter
  always @(posedge clk)
  begin
    vsync <= (vpos >= V_SYNC_START && vpos <= V_SYNC_END);
    if(hmaxxed)
      if (vmaxxed)
        vpos <= 0;
      else
        vpos <= vpos + 1;
  end

  // display_on is set when beam is in "safe" visible frame
  always @(posedge clk)
  begin
    display_on <= (hpos < H_DISPLAY) && (vpos < V_DISPLAY);
  end

endmodule
