
module eth_ip_core_export#
(
  parameter int pADDR_CNTRL_WIDTH = 8,
  parameter int pADDR_TIMEST_WIDTH = 8,
  parameter int pDATA_WIDTH = 32
)
(
  // -- Associated clock and reset signals
  input logic avl_clock,
  input logic avl_rst_n,

  // -- Slave interface (exported)
  input logic [31 : 0] s_dma_avl_addr,
  input logic s_dma_avl_rdena,
  input logic s_dma_avl_wrena,
  output logic [64 - 1 : 0] s_dma_avl_rddata,
  input logic [64 - 1 : 0] s_dma_avl_wrdata,
  output wire s_dma_avl_wrq,
  output logic s_dma_avl_rddataval,
  input logic [7 : 0] s_dma_avl_burst_cnt,

  // -- DMA Master interface (connected to the avalon bus)
  output logic [31 : 0] m_dma_avl_addr,
  output logic m_dma_avl_rdena,
  input logic [64 - 1 : 0] m_dma_avl_rddata,
  output logic m_dma_avl_wrena,
  output logic [64 - 1 : 0] m_dma_avl_wrdata,
  input logic m_dma_avl_wrq,
  input logic m_dma_avl_rddataval,
  output logic [7 : 0] m_dma_avl_burst_cnt,

  // -- Slave control interface
  input logic [pADDR_CNTRL_WIDTH - 1 : 0] s_cntrl_avl_addr,
  input logic s_cntrl_avl_wrena,
  input logic [pDATA_WIDTH-1:0] s_cntrl_avl_wrdata,
  input logic s_cntrl_avl_rdena,
  output logic [pDATA_WIDTH-1:0] s_cntrl_avl_rddata,
  output logic s_cntrl_avl_irq,
  output wire s_cntrl_avl_wrq,

  // -- Master control interface
  output logic m_cntrl_avl_clk,
  output logic m_cntrl_avl_rstn,
  output logic [pADDR_CNTRL_WIDTH-1:0] m_cntrl_avl_addr,
  output logic m_cntrl_avl_wrena,
  output logic [pDATA_WIDTH-1:0] m_cntrl_avl_wrdata,
  output logic m_cntrl_avl_rdena,
  input logic [pDATA_WIDTH-1:0] m_cntrl_avl_rddata,
  input logic m_cntrl_avl_irq,
  input logic m_cntrl_avl_wrq
);

assign m_dma_avl_addr = s_dma_avl_addr;
assign m_dma_avl_rdena = s_dma_avl_rdena;
assign s_dma_avl_rddata = m_dma_avl_rddata;
assign s_dma_avl_wrq = m_dma_avl_wrq;
assign s_dma_avl_rddataval = m_dma_avl_rddataval;
assign m_dma_avl_burst_cnt = s_dma_avl_burst_cnt;
assign m_dma_avl_wrena = s_dma_avl_wrena;
assign m_dma_avl_wrdata = s_dma_avl_wrdata;

assign m_cntrl_avl_clk = avl_clock;
assign m_cntrl_avl_rstn = avl_rst_n;
assign m_cntrl_avl_addr = s_cntrl_avl_addr;
assign m_cntrl_avl_wrena = s_cntrl_avl_wrena;
assign m_cntrl_avl_wrdata = s_cntrl_avl_wrdata;
assign m_cntrl_avl_rdena = s_cntrl_avl_rdena;
assign s_cntrl_avl_rddata = m_cntrl_avl_rddata;
assign s_cntrl_avl_irq = m_cntrl_avl_irq;
assign s_cntrl_avl_wrq = m_cntrl_avl_wrq;

endmodule
