import params::*;
import typesPkg::*;

module packets_rx_queue (
    output rx_queue_status_t  status,
    input ethipcore_control   cntrl,

    input logic               valid_rx, // rx data valid signal
    input logic [7 : 0]       data_rx,  // rx_data
    input mii_rx_status_t     rx_stat,  // struct for discarding bad packets

    /* forwarding interface */
    input  pack_q_frw_rx_from_sw_t rx_str_inp, // from ARM DMA
    output pack_q_frw_rx_to_sw_t   rx_str_out, // to ARM DMA

    /* Filter results */
    input filter_status_t          f_stat,

    /* Common interface */
    interSw                        ethSw
);
//==========================================================================================
localparam int MEM_FRW_LN_RX = PCKT_Q_BUF_LN_BYTES_RX / (PCKT_Q_INTF_W / 8); /* 4096 / (64 / 8) = 512 */
localparam int MEM_FRW_ADDR_W_RX = $clog2(MEM_FRW_LN_RX); /* 9, 2^9 = 512 */
localparam int MEM_ETH_ADDR_W_RX = $clog2(PCKT_Q_BUF_LN_BYTES_RX); /* 12, 2^12 = 4096 */

typedef struct packed {
  logic [MEM_FRW_ADDR_W_RX - 1 : 0] buf_addr; /* 9 bit, addres of the packet in rx_q_buf */
  logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] sz_pack_bytes; /* 11 bits, length of the packet in rx_q_buf */
} pack_desc_rx_t;
//==========================================================================================
// Status counters
logic [31:0] packets_received_cnt;
logic [15:0] crc_error_cnt;
logic [7:0] rx_desc_ovf_cnt, rx_queue_ovf_cnt, line_error_cnt, frm_size_err_cnt;

assign status.packets_received_cnt = packets_received_cnt;
assign status.frm_size_err_cnt = frm_size_err_cnt;
assign status.crc_error_cnt = crc_error_cnt;
assign status.line_error_cnt = line_error_cnt;
assign status.rx_queue_ovf_cnt = rx_queue_ovf_cnt;
assign status.rx_desc_ovf_cnt = rx_desc_ovf_cnt;
//==========================================================================================
logic [$clog2(N_DESC_RECORDS_RX) - 1 : 0] pos_desc_wr, pos_desc_rd;
pack_desc_rx_t rx_desc_wr, rx_desc_rd;
logic desc_wr;

/* RX descriptors */
ram2port # (
  .pWIDTH_DATA_A($bits(pack_desc_rx_t)),
  .pSIZE_A(N_DESC_RECORDS_RX),
  .pWIDTH_ADDR_A($clog2(N_DESC_RECORDS_RX))
) rx_desc_mem (
  .clock_a (ethSw.clk),
  .clock_b (ethSw.clk),
  .clkena_a(ethSw.main_rst_n),
  .clkena_b(ethSw.main_rst_n),
  .addr_a  (pos_desc_wr),
  .addr_b  (pos_desc_rd),
  .wrena_a (desc_wrena),
  .wrena_b (1'd0),
  .idata_a (rx_desc_wr),
  .idata_b (pack_desc_rx_t'(0)),
  .odata_a (),
  .odata_b (rx_desc_rd)
);

//==========================================================================================
logic [MEM_ETH_ADDR_W_RX - 1 : 0] buf_mem_rx_addr_wr, buf_mem_rx_addr_wr_del;
logic [MEM_FRW_ADDR_W_RX - 1 : 0] buf_mem_rx_addr_rd;
logic [PCKT_Q_INTF_W - 1 : 0] buf_mem_rx_odata_b;

/* RX buffer */
ram2port #(
  .pWIDTH_DATA_A(8),                  /* 8 */
  .pSIZE_A(PCKT_Q_BUF_LN_BYTES_RX),   /* 4096 */
  .pWIDTH_ADDR_A(MEM_ETH_ADDR_W_RX),  /* 12 */
  .pWIDTH_DATA_B(PCKT_Q_INTF_W),      /* 64 */
  .pSIZE_B(MEM_FRW_LN_RX),            /* 512 */
  .pWIDTH_ADDR_B(MEM_FRW_ADDR_W_RX)   /* 9 */
) rx_q_buf (
  .clock_a (ethSw.clk),
  .clock_b (ethSw.clk),
  .clkena_a(ethSw.main_rst_n),
  .clkena_b(ethSw.main_rst_n),
  .addr_a  (buf_mem_rx_addr_wr_del),
  .addr_b  (buf_mem_rx_addr_rd),
  .wrena_a (pack_wrena),
  .wrena_b (1'b0),
  .idata_a (data_in),
  .idata_b ({PCKT_Q_INTF_W{1'b0}}),
  .odata_a (),
  .odata_b (buf_mem_rx_odata_b)
);
//==========================================================================================
logic rx_reset;
logic rx_reset_strb;
logic [2:0] reset_cnt;
always_ff @(posedge ethSw.clk) begin : RESET_FROM_DMA
  if (~ethSw.main_rst_n || rx_str_inp.reset_rx) begin
    reset_cnt <= 3'h7;
    rx_reset_strb <= 1'd1;
  end
  else if (|reset_cnt)
    reset_cnt <= reset_cnt - 1'd1;
  else if (~valid_rx && (link_cnt == 'd0))
    rx_reset_strb <= 'd0;
end
assign rx_reset = rx_reset_strb || rx_str_inp.reset_rx;
//==========================================================================================
logic desc_wrena, pack_wrena;
logic valid_in;
logic [7 : 0] data_in;
logic q_ovf_flg, size_ovrlm_flg;
logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] rx_byte_cnt;
logic rx_desc_ovf_flg;
logic [7 : 0] link_cnt;

assign desc_wrena = desc_wr & ~rx_desc_ovf_flg;
assign pack_wrena = valid_in & ~size_ovrlm_flg & ~q_ovf_flg;

always_ff @(posedge ethSw.clk) begin : RX_QUEUE_ETH_CONTROL
  if (rx_reset) begin
    buf_mem_rx_addr_wr <= 'd0;
    q_ovf_flg <= 'd0;
    pos_desc_wr <= 'd0;
    rx_byte_cnt <= 'd0;
    size_ovrlm_flg <= 'd0;
    packets_received_cnt <= 'd0;
    rx_desc_wr <= pack_desc_rx_t'(0);
    desc_wr <= 'd0;
    frm_size_err_cnt <= 'd0;
    rx_queue_ovf_cnt <= 'd0;
    crc_error_cnt <= 'd0;
    line_error_cnt <= 'd0;
    rx_desc_ovf_cnt <= 'd0;
    rx_desc_ovf_flg <= 'd0;
    rx_desc_wr.buf_addr <= 'd0;
    valid_in <= 'd0;
    data_in <= 'd0;
    buf_mem_rx_addr_wr_del <= 'd0;
    link_cnt <= 'd0;
  end
  else begin
    valid_in <= valid_rx;
    data_in <= data_rx;
    buf_mem_rx_addr_wr_del <= buf_mem_rx_addr_wr;

    if (rx_stat.line_err)
      line_error_cnt <= line_error_cnt + 1'd1;

    if (ethSw.link_speed == LINK_1000)
      link_cnt <= 'd0;
    else if (valid_rx) begin
      if (ethSw.link_speed == LINK_100)
        link_cnt <= 'd15;
      else
        link_cnt <= 'd150;
    end
    else if (|link_cnt)
      link_cnt <= link_cnt - 1'd1;

    if (valid_rx) begin
      if (~valid_in && (link_cnt == 'd0)) begin
        /* Save packet address offset in the buffer */
        rx_desc_wr.buf_addr <= buf_mem_rx_addr_wr[MEM_ETH_ADDR_W_RX - 1 : BITS_PAD];
      end

      desc_wr <= 'd0;

      if (rx_byte_cnt == (MAX_ETH_FRAME_CNT + 4/*CRC*/)) begin
        size_ovrlm_flg <= 1'd1;
        if (~size_ovrlm_flg)
          frm_size_err_cnt <= frm_size_err_cnt + 1'd1;
      end
      else
        rx_byte_cnt <= rx_byte_cnt + 1'd1; /* Count packet length */

      buf_mem_rx_addr_wr <= buf_mem_rx_addr_wr + 1'd1;

      if ((buf_mem_rx_addr_wr[MEM_ETH_ADDR_W_RX - 1 : BITS_PAD] + 'd1 == buf_mem_rx_addr_rd) &&
              ~q_ovf_flg) begin
        q_ovf_flg <= 1'd1;
        rx_queue_ovf_cnt <= rx_queue_ovf_cnt + 1'd1;
      end
    end
    else if (rx_stat.rx_fl) begin
      /* Packet fully received */
      if (rx_stat.crc_val)
        packets_received_cnt <= packets_received_cnt + 1'd1;
      else
        crc_error_cnt <= crc_error_cnt + 1'd1;

      /* Accept the packet in the buffer */
      rx_desc_wr.sz_pack_bytes <= rx_byte_cnt - 3'd4; /* -4 byetes to cut CRC */

      if (rx_stat.crc_val && ~rx_stat.line_err && ~q_ovf_flg && ~rx_desc_ovf_flg && ~size_ovrlm_flg && (rx_byte_cnt >= MIN_ETH_FRAME_CNT) &&
            (f_stat.our_accept_flag || f_stat.multicast_accept_flg || f_stat.vlan_accept_flg ||
            f_stat.brdcst_accept_flag || cntrl.promiscuous_mode)) begin
        desc_wr <= 1'd1;
        /* Align next addres for future packet to an 2^BITS_PAD byte */
        buf_mem_rx_addr_wr <= { buf_mem_rx_addr_wr[MEM_ETH_ADDR_W_RX - 1 : BITS_PAD] + 1'd1, {BITS_PAD{1'b0}} };
      end
      else begin
        /* If the packet has been discarded then return write pointer */
        buf_mem_rx_addr_wr <= {rx_desc_wr.buf_addr, {BITS_PAD{1'b0}}};
        if (rx_desc_ovf_flg)
          rx_desc_ovf_cnt <= rx_desc_ovf_cnt + 1'd1;
      end
      q_ovf_flg <= 'd0;
      size_ovrlm_flg <= 'd0;
      rx_byte_cnt <= 'd0;
      link_cnt <= 'd0;
    end
    else begin
      desc_wr  <= 'd0;
    end

    if (pos_desc_wr + 1'd1 == pos_desc_rd)
      rx_desc_ovf_flg <= 1'd1;
    else
      rx_desc_ovf_flg <= 1'd0;

    if (desc_wr) begin
      if (pos_desc_wr == N_DESC_RECORDS_RX - 1)
        pos_desc_wr <= 'd0;
      else
        pos_desc_wr <= pos_desc_wr + 1'd1;
    end
  end
end
//==========================================================================================
delay_chain #(
  .width(1), .depth(2)
) dc_valid_str (
  .clk(ethSw.clk),
  .d(rx_str_inp.strb_rx),
  .q(rx_str_out.frw_valid_rx)
);
assign rx_str_out.frw_data_rx = buf_mem_rx_odata_b;
/* Actual packet length for DMA */
assign rx_str_out.cur_pckt_lnb = rx_desc_rd.sz_pack_bytes;

localparam int PCKT_CNT_WIDTH = MAX_ETH_FRAME_CNT_WIDTH - BITS_PAD;

logic [PCKT_CNT_WIDTH - 1 : 0] cur_pack_cnt;
logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] cur_pack_ln;
logic process_rd;
logic packet_avlb;


always_ff @(posedge ethSw.clk) begin : RX_QUEUE_FRW_CONTROL
  if (rx_reset) begin
    packet_avlb <= 'd0;
    rx_str_out.packet_avlb <= 'd0;
    process_rd <= 'd0;
    pos_desc_rd <= 'd0;
    cur_pack_cnt <= 'd0;
    cur_pack_ln <= 'd0;
    buf_mem_rx_addr_rd <= 'd0;
  end
  else begin
    /* Inform DMA that queue contains a packet */
    packet_avlb <= (pos_desc_wr != pos_desc_rd);
    rx_str_out.packet_avlb <= packet_avlb; /* ! +1 extra clk delay, Mixed-port RDW: Old Data :< */

    if (process_rd) begin
      if (rx_str_inp.strb_rx) begin
        if (cur_pack_cnt == cur_pack_ln[MAX_ETH_FRAME_CNT_WIDTH - 1 : BITS_PAD])
          process_rd <= 'd0;
        else
          cur_pack_cnt <= cur_pack_cnt + 1'd1;

        buf_mem_rx_addr_rd <= buf_mem_rx_addr_rd + 1'd1;
      end
    end
    else if (rx_str_out.packet_avlb & rx_str_inp.sop_rx) begin
      /* DMA is ready to get packet */
      buf_mem_rx_addr_rd <= rx_desc_rd.buf_addr + 1'd1;
      cur_pack_ln <= rx_desc_rd.sz_pack_bytes - 1'd1;
      cur_pack_cnt <= 'd1;
      process_rd <= 1'd1;

      if (pos_desc_rd == N_DESC_RECORDS_RX - 1)
        pos_desc_rd <= 'd0;
      else
        pos_desc_rd <= pos_desc_rd + 1'd1;
    end
    else begin
      if(rx_str_out.packet_avlb)
        buf_mem_rx_addr_rd <= rx_desc_rd.buf_addr;
      cur_pack_cnt <= 'd0;
    end
  end
end
//==========================================================================================
endmodule
