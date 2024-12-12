import params::*;
import typesPkg::*;

module eth_ip_core #(
  parameter int cntrl_addr_width = 6
)(
  input logic tx_clkA,
  input logic tx_phy_clkA,

  /* eth port A */
  input  logic       eth_rxclk_a,
  input  logic       eth_rxdv_a,
  input  logic [3:0] eth_rxd_a,
  output logic       eth_txclk_a,
  output logic       eth_txdv_a,
  output logic [3:0] eth_txd_a,

  output logic       phy_reset,

  /* HPS DMA */
  output logic [31 : 0]                   dma_addres,
  output logic                            dma_read,
  output logic                            dma_write,
  input  logic [ARM_INTF_WIDTH - 1 : 0]   dma_readdata,
  output logic [ARM_INTF_WIDTH - 1 : 0]   dma_writedata,
  input  logic                            dma_waitrequest,
  input  logic                            dma_readdatavalid,
  output logic [BURST_CNT_WIDTH - 1 : 0]  dma_burstcount,

  /* HPS control */
  input  logic [cntrl_addr_width - 1 : 0] cntrl_adr,
  input  logic                            cntrl_wrena,
  input  logic [31 : 0]                   cntrl_wdata,
  input  logic                            cntrl_rdena,
  output logic [31 : 0]                   cntrl_rdata,
  output logic                            cntrl_irq,
  output logic                            cntrl_wrq,

  /* Common interface */
  interSw                                 ethSw
);
//==========================================================================================
ethipcore_control cntrl, cntrl_reg;
//==========================================================================================
assign ethSw.main_rst_n = ethSw.rst_n & cntrl.work_ena;
//==========================================================================================
assign phy_reset = cntrl.eth_hard_reset;
//==========================================================================================
mii_rx_status_t mii_status_a;
logic valid_rx_a;
logic [7 : 0] data_rx_a;

mii_tx_t mii_txA;

mii_module mii_port_a (
  .clk(ethSw.clk),
  .eth_txck_in(tx_clkA),
  .eth_txclk_phy(tx_phy_clkA),
  .rst_n(ethSw.main_rst_n),
  .eth_rxclk(eth_rxclk_a),
  .eth_rxdv(eth_rxdv_a),
  .eth_rxd(eth_rxd_a),
  .eth_txclk(eth_txclk_a),
  .eth_txdv(eth_txdv_a),
  .eth_txd(eth_txd_a),
  .valid_rx(valid_rx_a),
  .data_rx(data_rx_a),
  .mii_tx(mii_txA),
  .rx_stat(mii_status_a),
  .link_speed(ethSw.link_speed)
);

//==========================================================================================
/* Filter of received packets */
vlan_setup_t vlan_set;
filter_status_t f_statA;

assign vlan_set.wr_val = cntrl_wrena & (cntrl_adr[5:4] == 2'd1);
assign vlan_set.addr = cntrl_adr[$clog2(MAX_VLAN_NETS) - 1 : 0];
assign vlan_set.vid = cntrl_wdata[11 : 0];

rx_filter rxfilt (
  .valid_rxA(valid_rx_a),
  .data_rxA(data_rx_a),
  .f_statA(f_statA),
  .vlan_setup(vlan_set),
  .cntrl(cntrl),
  .ethSw(ethSw)
);
//==========================================================================================
/* RX and TX fifo modules */
pack_q_frw_rx_from_sw_t rx_strA_sw;
pack_q_frw_rx_to_sw_t rx_strA_q;
rx_queue_status_t rx_stA;

packets_rx_queue rxq_pA (
  .status(rx_stA),
  .cntrl(cntrl),
  .valid_rx(valid_rx_a),
  .data_rx(data_rx_a),
  .rx_stat(mii_status_a),
  .rx_str_inp(rx_strA_sw),
  .rx_str_out(rx_strA_q),
  .f_stat(f_statA),
  .ethSw(ethSw)
);

pack_q_frw_tx_from_sw_t tx_strA_sw;
pack_q_frw_tx_to_sw_t   tx_strA_q;

packets_tx_queue txq_pA (
  .clk_tx(tx_clkA),
  .mii_tx(mii_txA),
  .tx_str_inp(tx_strA_sw),
  .tx_str_out(tx_strA_q),
  .ethSw(ethSw)
);
//==========================================================================================
/* ARM DMA */
arm_dma dma (
  .dma_addres(dma_addres),
  .dma_read(dma_read),
  .dma_write(dma_write),
  .dma_readdata(dma_readdata),
  .dma_writedata(dma_writedata),
  .dma_waitrequest(dma_waitrequest),
  .dma_readdatavalid(dma_readdatavalid),
  .dma_burstcount(dma_burstcount),
  .dma_cntrl(cntrl),
  .ethSw(ethSw),
  .dma_rx_inp(rx_strA_q),
  .dma_rx_out(rx_strA_sw),
  .dma_tx_inp(tx_strA_q),
  .dma_tx_out(tx_strA_sw)
);
//==========================================================================================
/* Periodic IRQ generator */
logic [6 : 0] tick_cnt;
logic [19 : 0] us_cnt, us_irq_cnt_set;
logic us_tmr_event, us_tmr_event_d;

always_ff @(posedge ethSw.clk) begin : IRQ_GEN
  if (~ethSw.rst_n) begin
    tick_cnt <= 'd0;
    us_cnt <= 'd0;
    us_tmr_event <= 'd0;
  end
  else if (|us_irq_cnt_set) begin
    us_tmr_event_d <= us_tmr_event;

    if (tick_cnt == 'd124) begin
      tick_cnt <= 'd0;
      us_cnt <= us_cnt + 1'd1;
    end
    else begin
      tick_cnt <= tick_cnt + 1'd1;

      if (us_cnt >= us_irq_cnt_set) begin
        us_tmr_event <= ~us_tmr_event;
        us_cnt <= 'd0;
      end
    end
  end
  else begin
    tick_cnt <= 'd0;
    us_cnt <= 'd0;
  end
end
//==========================================================================================
/* HPS control */
logic cntrl_rdena_del;
logic dma_rx_irq, dma_tx_irq, dma_rx_err_irq, dma_tx_err_irq;
logic dma_rx_irq_d, dma_tx_irq_d, dma_rx_err_irq_d, dma_tx_err_irq_d;
ethipcore_irq_status irq_status;

assign cntrl_wrq = cntrl_rdena & ~cntrl_rdena_del;

wire dma_rx_irq_r = dma_rx_irq ^ dma_rx_irq_d;
wire dma_tx_irq_r = dma_tx_irq ^ dma_tx_irq_d;
wire dma_rx_err_irq_r = dma_rx_err_irq ^ dma_rx_err_irq_d;
wire dma_tx_err_irq_r = dma_tx_err_irq ^ dma_tx_err_irq_d;
wire us_tmr_event_r = us_tmr_event ^ us_tmr_event_d;

logic cntrl_irq_level;
wire cntrl_irq_edge = cntrl_reg.work_ena ?	( dma_rx_irq_r | dma_tx_irq_r |
          dma_rx_err_irq_r | dma_tx_err_irq_r | us_tmr_event_r) : 1'd0;

//assign cntrl_irq = cntrl_irq_edge;
assign cntrl_irq = cntrl_irq_level;


always_ff @(posedge ethSw.clk) begin : HPS_CONTROL
  if (cntrl_rdena & cntrl_wrq)
    cntrl_rdena_del <= cntrl_rdena;
  else
    cntrl_rdena_del <= 'd0;

  cntrl <= cntrl_reg;
  ethSw.link_speed <= cntrl.link_speed;
  ethSw.vlan_filter_ena = cntrl.vlan_filter_ena;
  ethSw.multicast_filter_ena <= cntrl.multicast_filter_ena;

  dma_rx_irq <= cntrl_reg.irq_rx_mask ? ethSw.dma_rx_irq : dma_rx_irq;
  dma_tx_irq <= cntrl_reg.irq_tx_mask ? ethSw.dma_tx_irq : dma_tx_irq;
  dma_rx_err_irq <= cntrl_reg.irq_err_mask ? ethSw.dma_rx_err_irq : dma_rx_err_irq;
  dma_tx_err_irq <= cntrl_reg.irq_err_mask ? ethSw.dma_tx_err_irq : dma_tx_err_irq;
  dma_rx_irq_d <= dma_rx_irq;
  dma_tx_irq_d <= dma_tx_irq;
  dma_rx_err_irq_d <= dma_rx_err_irq;
  dma_tx_err_irq_d <= dma_tx_err_irq;

  if (~ethSw.rst_n) begin
    cntrl_reg <= ethipcore_control'('d0);
    ethSw.dma_par <= dma_params_t'('d0);
    cntrl_irq_level <= 1'd0;
  end
  else if (cntrl_wrena) begin
    if (cntrl_adr == 4'd0)
      cntrl_reg <= ethipcore_control'(cntrl_wdata);
    else if (cntrl_adr == 4'd2)
      ethSw.dma_par.ddr_rcv_pckts_addr <= cntrl_wdata;
    else if (cntrl_adr == 4'd3) 
      ethSw.dma_par.ddr_trm_pckts_addr <= cntrl_wdata;
    else if (cntrl_adr == 4'd4)
      ethSw.dma_par.cur_pckt_tx_pos <= cntrl_wdata[PACKETS_DEPTH_WIDTH - 1 : 0];
    else if(cntrl_adr == 4'd5) begin
      ethSw.port_mac[0] <= cntrl_wdata[7 : 0];
      ethSw.port_mac[1] <= cntrl_wdata[15 : 8];
      ethSw.port_mac[2] <= cntrl_wdata[23 : 16];
      ethSw.port_mac[3] <= cntrl_wdata[31 : 24];
    end else if(cntrl_adr == 4'd6) begin
      ethSw.port_mac[4] <= cntrl_wdata[7 : 0];
      ethSw.port_mac[5] <= cntrl_wdata[15 : 8];
    end else if (cntrl_adr == 4'd7)
      ethSw.dma_par.cur_pckt_rx_pos <= cntrl_wdata[PACKETS_DEPTH_WIDTH - 1 : 0];
    else if (cntrl_adr == 4'd8)
      us_irq_cnt_set <= cntrl_wdata[19 : 0];
    else if (cntrl_adr == 4'd9)
      ethSw.dma_control_select <= cntrl_wdata;
    else begin
    end
  end
  else if (cntrl_rdena) begin
    if (cntrl_adr == 4'd0)
      cntrl_rdata <= cntrl_reg;
    else if (cntrl_adr == 4'd1)
      cntrl_rdata <= ethSw.ddr_rx_pckt_wr;
    else if (cntrl_adr == 4'd2)
      cntrl_rdata <= ethSw.ddr_tx_pckt_rd;
    else if (cntrl_adr == 4'd3)
      cntrl_rdata[27:0]  <= {4'd0, ETHIPCORE_VER};
    else if (cntrl_adr == 4'd4)
      cntrl_rdata <= rx_stA.packets_received_cnt;
    else if (cntrl_adr == 4'd6)
      cntrl_rdata <= rx_stA.crc_error_cnt;
    else if (cntrl_adr == 4'd9)
      cntrl_rdata <= ethSw.dma_control_reg;
    else if (cntrl_adr == 4'd10)
      cntrl_rdata <= {rx_stA.line_error_cnt, rx_stA.rx_desc_ovf_cnt,
            rx_stA.rx_queue_ovf_cnt, rx_stA.frm_size_err_cnt};
    else if (cntrl_adr == 4'd14)
      cntrl_rdata <= ethSw.tx_cnt;
    else if (cntrl_adr == 4'd15) begin
      cntrl_rdata <= irq_status;
      if (~cntrl_wrq) begin
        cntrl_irq_level <= 'd0;
        irq_status.irq_rx_flg <= 'd0;
        irq_status.irq_tx_flg <= 'd0;
        irq_status.irq_rx_err <= 'd0;
        irq_status.irq_tx_err <= 'd0;
        irq_status.irq_from_tmr <= 'd0;
      end
    end
    else begin
      cntrl_rdata <= 'd0;
    end
  end

  if (cntrl_irq_edge)
    cntrl_irq_level <= 1'd1;
  if (dma_rx_irq_r)
    irq_status.irq_rx_flg <=  1'd1;
  if (dma_tx_irq_r)
    irq_status.irq_tx_flg <= 1'd1;
  if (dma_rx_err_irq_r)
    irq_status.irq_rx_err <= 1'd1;
  if (dma_tx_err_irq_r)
    irq_status.irq_tx_err <= 1'd1;
  if (us_tmr_event_r)
    irq_status.irq_from_tmr <= 1'd1;

end

endmodule
