/****************************************************************************
 * avl_export.sv
 ****************************************************************************/

module avl_export#
(
  parameter int pADDR_WIDTH = 8,
  parameter int pDATA_WIDTH = 32
)(
  // -- Associated clock and reset signals
  input logic avl_clock,
  input logic avl_rst_n,

  // -- Slave interface
  input logic [pADDR_WIDTH-1:0] s_avl_addr,
  input logic s_avl_wrena,
  input logic [pDATA_WIDTH-1:0] s_avl_wrdata,
  input logic s_avl_rdena,
  output logic [pDATA_WIDTH-1:0] s_avl_rddata,
  output logic s_avl_irq,
  output wire s_avl_wrq,

  // -- Master interface
  output logic m_avl_clk,
  output logic m_avl_rstn,
  output logic [pADDR_WIDTH-1:0] m_avl_addr,
  output logic m_avl_wrena,
  output logic [pDATA_WIDTH-1:0] m_avl_wrdata,
  output logic m_avl_rdena,
  input logic [pDATA_WIDTH-1:0] m_avl_rddata,
  input logic m_avl_irq,
  input logic m_avl_wrq
);

assign m_avl_clk = avl_clock;
assign m_avl_rstn = avl_rst_n;
assign m_avl_addr = s_avl_addr;
assign m_avl_wrena = s_avl_wrena;
assign m_avl_wrdata = s_avl_wrdata;
assign m_avl_rdena = s_avl_rdena;
assign s_avl_rddata = m_avl_rddata;
assign s_avl_irq = m_avl_irq;
assign s_avl_wrq = m_avl_wrq;

endmodule
