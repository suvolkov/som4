/* This module controls TX packets fifo
 * Gets packets form DMA and places them in fifo,
 * then it transmits packets to the MII module
 */
import params::*;
import typesPkg::*;

module packets_tx_queue (
    // MII interface:
    input logic       clk_tx, /* Tx clk to the eth_phy 125MHz or 25MHz */
    output mii_tx_t   mii_tx, /* TX signals to MII	*/

    /* DMA interface */
    input pack_q_frw_tx_from_sw_t tx_str_inp,
    output pack_q_frw_tx_to_sw_t  tx_str_out,

    /* Common interface */
    interSw                       ethSw
);
//==========================================================================================
/* Set tx_mii_fifo size = (PCKT_Q_BUF_LN_BYTES_TX / 8) !! */
localparam int MEM_FRW_LN_TX = PCKT_Q_BUF_LN_BYTES_TX / (PCKT_Q_INTF_W / 8); /*4096 / (64 / 8) = 512*/
localparam int MEM_ETH_ADDR_W_TX = $clog2(PCKT_Q_BUF_LN_BYTES_TX); /*12*/
localparam int MEM_FRW_ADDR_W_TX = $clog2(MEM_FRW_LN_TX); /*9*/
/* Don't forget about preamble:8clk + CRC:4clk + ?HSR/PRP overhead */
localparam [49 : 0] MAGIC_SEQ = 50'h2DEAD3642BABE;
localparam int AUX_PAD = 14 - MAX_ETH_FRAME_CNT_WIDTH;
localparam int TX_PACKET_PAUSE_CYC = INT_PACK_GAP + 8/*PREAMB*/ + 4/*CRC*/ - 8/*AUX_WRD_RD*/;

/* Cut-through transmission. Accumulating data before reading it.
 * If TX-out queue cuts reading packet(run-out of data), increase FIFO_EMPTY_THRESHOLD.
 */
localparam int FIFO_EMPTY_THRESHOLD = 40; /* Bytes, must be divisible by 8 */
//==========================================================================================
logic rdreq, wrreq;
logic rdempty, wrfull;
logic [PCKT_Q_INTF_W - 1 : 0] wr_data;
logic [MEM_FRW_ADDR_W_TX - 1 : 0] wrusedw;
logic [7 : 0] fifo_q;
logic [MEM_ETH_ADDR_W_TX - 1 : 0] rdusedw;

tx_mii_fifo tx_q_buf (
  .aclr(~ethSw.main_rst_n),
  .wrclk(ethSw.clk),
  .wrreq(wrreq),
  .data(wr_data),
  .wrfull(wrfull),
  .wrusedw(wrusedw),
  .rdclk(clk_tx),
  .rdreq(rdreq),
  .q(fifo_q),
  .rdempty(rdempty),
  .rdusedw(rdusedw)
);
//==========================================================================================
logic tx_error, tx_error_sync;

always_ff @(posedge ethSw.clk) begin : TX_QUEUE_FRW_CONTROL
  /* Bytes available in TX buffer */
  tx_str_out.bytes_avlb <= {MEM_FRW_LN_TX - 8/*aux_start*/ - wrusedw, {BITS_PAD{1'b0}}};

  if (~ethSw.main_rst_n) begin
    tx_error <= 'd0;
    wrreq <= 'd0;
    ethSw.tx_cnt <= 'd0;
    ethSw.tx_errors_wr <= 'd0;
  end 
  else begin
    if (tx_str_inp.frw_sop_tx) begin
      wr_data <= {tx_str_inp.data_offs, tx_str_inp.pack_ln_b, MAGIC_SEQ};
      if (wrfull || wrreq) begin
        ethSw.tx_errors_wr <= ethSw.tx_errors_wr + 1'd1;
        wrreq <= 'd0;
        tx_error <= 'd1;
      end
      else begin
        wrreq <= 'd1;
        tx_error <= 'd0;
      end
    end
    else if (tx_str_inp.frw_valid_tx) begin
      wr_data <= tx_str_inp.frw_data_tx;
      if (wrfull) begin
        ethSw.tx_errors_wr <= ethSw.tx_errors_wr + 1'd1;
        wrreq <= 'd0;
        tx_error <= 'd1;
      end
      else
        wrreq <= 'd1;

      if (tx_str_inp.frw_eop_tx && ~tx_error)
        ethSw.tx_cnt <= ethSw.tx_cnt + 1'd1;
    end
    else begin
      wrreq <= 'd0;
      if (tx_str_inp.frw_eop_tx) begin
        ethSw.tx_errors_wr <= ethSw.tx_errors_wr + 1'd1;
        tx_error <= 1'd1; /* Packet transmission was canceled */
      end
    end
  end
end
//==========================================================================================
vector_reg_sync #(
  .pWIDTH(2)
) tx_wr_sync (
  .clock_in(ethSw.clk),
  .clock_out(clk_tx),
  .ivector({tx_error, ethSw.main_rst_n}),
  .ovector({tx_error_sync, main_rst_n})
);
//==========================================================================================
/* TX-out queue control */
logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] pck_byte_cnt;
logic main_rst_n;
logic [AUX_PAD - 1 : 0] data_offs_cnt;

logic [PCKT_Q_INTF_W - 1 : 0] frame_sync_reg;
logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] packet_ln, rdreq_lim;
logic [$clog2(TX_PACKET_PAUSE_CYC) - 1 : 0] pause_cnt;

wire fifo_not_empty = (rdusedw >= FIFO_EMPTY_THRESHOLD);

always_ff @(posedge clk_tx) begin : TX_QUEUE_ETH_CONTROL
  mii_tx.data_tx <= fifo_q;
  mii_tx.tx_error = tx_error_sync;

  if (~main_rst_n) begin
    frame_sync_reg <= 'd0;
    rdreq <= 'd0;
    pck_byte_cnt <= 'd0;
    mii_tx.valid_tx <= 'd0;
    pause_cnt <= 'd0;
    data_offs_cnt <= 'd0;
  end
  else begin
    frame_sync_reg <= {fifo_q, frame_sync_reg[PCKT_Q_INTF_W - 1 : 8]};

    if (|pause_cnt) begin
      pause_cnt <= pause_cnt - 1'd1; /* Inter packet gap */
    end
    else if (mii_tx.valid_tx) begin
      if (pck_byte_cnt >= rdreq_lim)
        rdreq <= 'd0;

      if (pck_byte_cnt >= packet_ln) begin
        mii_tx.valid_tx <= 'd0;
        pause_cnt <= TX_PACKET_PAUSE_CYC - 1;
      end
      else
        pck_byte_cnt <= pck_byte_cnt + 1'd1;
    end
    else if (|data_offs_cnt) begin
      data_offs_cnt <= data_offs_cnt - 1'd1;
      if (data_offs_cnt == 'd1) begin
        mii_tx.valid_tx <= 1'd1;
      end
    end
    else if (rdreq) begin
      if (frame_sync_reg[49 : 0] == MAGIC_SEQ) begin
        packet_ln <= frame_sync_reg[50 + MAX_ETH_FRAME_CNT_WIDTH - 1 : 50] - 'd1;
        rdreq_lim <= frame_sync_reg[50 + MAX_ETH_FRAME_CNT_WIDTH - 1 : 50] - 'd2;
        data_offs_cnt <= frame_sync_reg[PCKT_Q_INTF_W - 1 : PCKT_Q_INTF_W - AUX_PAD];
        pck_byte_cnt <= 'd0;
        mii_tx.valid_tx <= (frame_sync_reg[PCKT_Q_INTF_W - 1 : PCKT_Q_INTF_W - AUX_PAD] == 'd0);
      end
    end
    else if (fifo_not_empty) begin
      /* We have enougth data to start sending a packet to MII */
      rdreq <= 'd1;
    end
  end
end
endmodule
