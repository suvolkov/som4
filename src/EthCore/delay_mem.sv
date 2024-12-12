`timescale 1 ns / 1 ns

module delay_mem #(
  parameter int width = 1,
  parameter int depth = 4
)(
  input logic        clk,
  input logic        rst_n,
  input logic [width-1:0] d,
  output logic [width-1:0] q
);
localparam int depth_mem = depth - 2 + 1;
//==========================================================================================
localparam int addr_width = $clog2(depth_mem);
logic [addr_width-1:0] buf_mem_rx_addr_wr;
logic [addr_width-1:0] buf_mem_rx_addr_rd;

wire [addr_width-1:0] buf_mem_rx_addr_a = buf_mem_rx_addr_wr;
wire [addr_width-1:0] buf_mem_rx_addr_b = buf_mem_rx_addr_rd;
wire buf_mem_rx_wrena_a = 1'b1;
wire buf_mem_rx_wrena_b = 1'b0;
wire [width-1:0] buf_mem_rx_idata_a = d;
wire [width-1:0] buf_mem_rx_idata_b = 'd0;
wire [width-1:0] buf_mem_rx_odata_a;
wire [width-1:0] buf_mem_rx_odata_b;

ram2port #(.pWIDTH_DATA_A(width), .pSIZE_A(depth_mem), .pWIDTH_ADDR_A(addr_width)) del_mem
(
  .clock_a(clk),
  .clock_b(clk),
  .clkena_a(rst_n),
  .clkena_b(rst_n),
  .addr_a(buf_mem_rx_addr_a),
  .addr_b(buf_mem_rx_addr_b),
  .wrena_a(buf_mem_rx_wrena_a),
  .wrena_b(buf_mem_rx_wrena_b),
  .idata_a(buf_mem_rx_idata_a),
  .idata_b(buf_mem_rx_idata_b),
  .odata_a(buf_mem_rx_odata_a),
  .odata_b(buf_mem_rx_odata_b)
);
//==========================================================================================
assign q = buf_mem_rx_odata_b;
always_ff @(posedge clk) begin
  if(~rst_n) begin
    buf_mem_rx_addr_rd <= 'd0;
    buf_mem_rx_addr_wr <= depth_mem-1;
  end
  else begin
    if(buf_mem_rx_addr_rd == depth_mem - 1)
    buf_mem_rx_addr_rd <= 'd0;
  else
    buf_mem_rx_addr_rd <= buf_mem_rx_addr_rd + 1'd1;

    if(buf_mem_rx_addr_wr == depth_mem - 1)
    buf_mem_rx_addr_wr <= 'd0;
  else
    buf_mem_rx_addr_wr <= buf_mem_rx_addr_wr + 1'd1;
  end
end
endmodule
