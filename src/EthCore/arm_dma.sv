/* Sending packets to ARM and receiving packets from ARM using direct memory accesss
 * ARM controls receive and transmite state
 */
import params::*;
import typesPkg::*;

module arm_dma (
  /* DMA HPS interface */
  output logic [31 : 0]                  dma_addres,
  output logic                           dma_read,
  output logic                           dma_write,
  input logic [ARM_INTF_WIDTH - 1 : 0]   dma_readdata,
  output logic [ARM_INTF_WIDTH - 1 : 0]  dma_writedata,
  input logic                            dma_waitrequest,
  input logic                            dma_readdatavalid,
  output logic [BURST_CNT_WIDTH - 1 : 0] dma_burstcount,
  /* Module control */
  input ethipcore_control        dma_cntrl,
  /* AVS control, inter ethipcore communications */
  interSw                        ethSw,
  /* RXQA */
  input pack_q_frw_rx_to_sw_t    dma_rx_inp, /* Data from RXQA */
  output pack_q_frw_rx_from_sw_t dma_rx_out, /* Data to RXQA */
  /* TXQA */
  input pack_q_frw_tx_to_sw_t    dma_tx_inp, /* Data from TXQA */
  output pack_q_frw_tx_from_sw_t dma_tx_out  /* Data to TXQA */
);
//==========================================================================================
/* One packet ARM DMA addr increment */
localparam int ARM_DMA_BUFFER_INC = ARM_DMA_NUMBER_OF_AUX_WORDS * ARM_INTF_WIDTH / 8 / 8;
//==========================================================================================
typedef enum logic [3:0] {
  DMA_TX_PACK_AVLB =  4'd0, /* Do we have packets to transmite from ARM? */
  DMA_TX_RD_AUX =     4'd1, /* Reading AUX word with TX packet details */
  DMA_TX_AUX_CHECK =  4'd2, /* Cheacking TX AUX word, get TX packet location and size */
  DMA_TX_PACK_RD =    4'd3, /* Reading TX packet from DDR and send it to TXQA */
  DMA_TX_END_RD =     4'd4, /* Completion of the TX stage */
  DMA_TX_WR_AUX =     4'd5, /* Writing TX AUX word back to DDR */
  DMA_RX_PACK_AVLB =  4'd6, /* Does RXQA have received packets */
  DMA_RX_RD_AUX =     4'd7, /* Reading AUX word with details for receiving packet */
  DMA_RX_AUX_CHECK =  4'd8, /* Cheacking RX AUX word, get RX packet location */
  DMA_RX_PACK_WR =    4'd9, /* Reading packet from RXQA and writing it to DDR */
  DMA_RX_WR_AUX =     4'd10, /* Writing RX AUX word */
  DMA_RX_END_WR =     4'd11  /* Completion of the RX stage */
} dma_state_t;
dma_state_t dma_state;
//==========================================================================================
typedef struct packed {
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_tx_rd_aux_timeout; /* Failed to read TX AUX word, timeout */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_tx_owner_error; /* DMA doesn't own TX packet */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_tx_packet_size_error; /* TX Packet length is out of bound */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_tx_rd_data_timeout; /* TX packet reading from DDR timeout, tx packet was dropped, hps bus is busy */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_tx_wr_aux_timeout; /* Failed to write TX AUX word, timeout */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_tx_postponed; /* Packet transmission was postponed due to transmission queue was full, not the error */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_rx_rd_aux_timeout; /* Failed to read RX AUX word, timeout */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_rx_owner_error; /* DMA doesn't own RX packet */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_rx_buffer_size_error; /* RX Packet length buffer is out of bound */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_rx_wr_data_timeout; /* RX packet writing to DDR timeout, rx packet was dropped, hps bus is busy */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_rx_wr_aux_timeout; /* Failed to write RX AUX word, timeout */
  logic [ERROR_COUNTERS_W - 1 : 0] arm_dma_rx_ddr_buff_owerflow; /* RX failed because DDR buffer oferflowed */
  logic [31 : 0] arm_dma_rx_pack_successfull;
} dma_errors_t;
dma_errors_t dma_errors;

typedef enum logic [3:0] {
  DMA_INDERECT_CTRL_TX_RX_NO_ERROR =     4'd0,
  DMA_INDERECT_CTRL_TX_RD_AUX_TIMEOUT =  4'd1,
  DMA_INDERECT_CTRL_TX_OWNER_ERR =       4'd2,
  DMA_INDERECT_CTRL_TX_PACK_SIZE_ERR =   4'd3,
  DMA_INDERECT_CTRL_TX_RD_DATA_TIMEOUT = 4'd4,
  DMA_INDERECT_CTRL_TX_WR_AUX_TIMEOUT =  4'd5,
  DMA_INDERECT_CTRL_TX_POSTPONED =       4'd6,
  DMA_INDERECT_CTRL_RX_RD_AUX_TIMEOUT =  4'd7,
  DMA_INDERECT_CTRL_RX_OWNER_ERR =       4'd8,
  DMA_INDERECT_CTRL_RX_BUFFER_SIZE_ERR = 4'd9,
  DMA_INDERECT_CTRL_RX_WR_DATA_TIMEOUT = 4'd10,
  DMA_INDERECT_CTRL_RX_WR_AUX_TIMEOUT =  4'd11,
  DMA_INDERECT_CTRL_RX_PACK_SUCCESS   =  4'd12,
  DMA_INDERECT_CTRL_RX_DDR_BUFF_OWF   =  4'd13
} dma_inderect_select_t;
dma_inderect_select_t dma_ind_select;

assign dma_ind_select = dma_inderect_select_t'(ethSw.dma_control_select);
//==========================================================================================
/* Receive and transmite description */
typedef struct packed {
  logic [31 : 0] dma_addrX; /* 32bits. Address to read from or write to */
  logic [5 : 0] pad_0; /* 31..26 */
  logic [BURST_CNT_WIDTH - 1 : 0] dma_burstcount; /* 25..18 */
  /* Field 'error' can contain:
   * DMA_INDERECT_CTRL_TX_PACK_SIZE_ERR - This packet was not transmitted because its size out of bound
   * DMA_INDERECT_CTRL_TX_RD_DATA_TIMEOUT - Bus is stall(slow), should make an attempt to send packet again
   * DMA_INDERECT_CTRL_RX_BUFFER_SIZE_ERR - This buffer is empty because of its insufficient size to store a packet
   * DMA_INDERECT_CTRL_RX_WR_DATA_TIMEOUT - Failed to write data, RX packet is lost and nothing to do anymore
   */
  dma_inderect_select_t error; /* 17..14 */
  logic dma_owner; /* 13 0 - Host owns packet, 1 - DMA owns packet */
  logic dst_src_port_B; /* 12 Пакет принимается/отправляется через порт B */
  logic dst_src_port_A; /* 11 Пакет принимается/отправляется через порт A */
  logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] pack_sz; /* 10..0 Packet size */
} ddr_aux_word_t;
ddr_aux_word_t aux_w_tx, aux_w_rx;

typedef struct packed {
  bit [ARM_INTF_WIDTH - 1 : 0] dbits;
} bits_aux_word_t;
bits_aux_word_t aux_b_tx, aux_b_rx;

assign aux_b_tx = bits_aux_word_t'(aux_w_tx);
assign aux_b_rx = bits_aux_word_t'(aux_w_rx);
//==========================================================================================
logic [31 : 0] ddr_tx_buf_addr, ddr_cur_tx_buf_addr; /* ToDo: Align with $ line size and reduce bits */
logic [31 : 0] ddr_rx_buf_addr, ddr_cur_rx_buf_addr; /* ToDo: Align with $ line size and reduce bits */
logic [9 : 0] brake_op_cnt; /* 1024 * 8ns = 8ms */
logic ddr_process_rd, rdy_for_rd;
(* ramstyle = "MLAB" *) logic [ARM_INTF_WIDTH - 1 : 0] rd_words[3 : 0]; /* 4 words each 64 bits */
logic [1 : 0] rd_answ_cnt;
logic [2 : 0] wr_wrd_cnt;
logic [MAX_ETH_FRAME_CNT_WIDTH - BITS_PAD_ARM - 1 : 0] pack_cnt_rd, pack_eop_cnt, pack_cnt_ddr_wr;
logic rd_done_str, buf_rdy;
logic [MAX_ETH_FRAME_CNT_WIDTH - BITS_PAD_ARM - 1 : 0] rd_brst_cnt;
logic [2 : 0] rx_dest_ddr;
logic irq_request_rx, irq_request_tx;
logic irq_request_rx_err, irq_request_tx_err;
logic rx_error;

wire tx_cond_flg = (ethSw.ddr_tx_pckt_rd != ethSw.dma_par.cur_pckt_tx_pos);
wire brake_op_cnt_timeout = &brake_op_cnt;
assign ddr_tx_buf_addr = ethSw.dma_par.ddr_trm_pckts_addr;
assign ddr_rx_buf_addr = ethSw.dma_par.ddr_rcv_pckts_addr;
assign ethSw.dma_rx_irq = irq_request_rx;
assign ethSw.dma_tx_irq = irq_request_tx;
assign ethSw.dma_rx_err_irq = irq_request_rx_err;
assign ethSw.dma_tx_err_irq = irq_request_tx_err;

wire [PACKETS_DEPTH_WIDTH - 1 : 0] buff_owerflow_val = ethSw.ddr_rx_pckt_wr + 'd1;

always_ff @(posedge ethSw.clk) begin: RXQA_PROCESS
  if (~ethSw.rst_n) begin
    dma_read <= 'd0;
    dma_write <= 'd0;
    irq_request_rx <= 'd0;
    irq_request_tx <= 'd0;
    irq_request_rx_err <= 'd0;
    irq_request_tx_err <= 'd0;
    dma_state <= DMA_RX_PACK_AVLB;
    rx_error <= 'd0;
  end
  else if (dma_cntrl.work_ena) begin
    irq_request_rx_err <= dma_errors.arm_dma_rx_rd_aux_timeout[0] ^ dma_errors.arm_dma_rx_owner_error[0] ^
    dma_errors.arm_dma_rx_buffer_size_error[0] ^ dma_errors.arm_dma_rx_wr_data_timeout[0] ^
    dma_errors.arm_dma_rx_wr_aux_timeout[0] ^ dma_errors.arm_dma_rx_ddr_buff_owerflow[0];

    irq_request_tx_err <= dma_errors.arm_dma_tx_rd_aux_timeout[0] ^ dma_errors.arm_dma_tx_owner_error[0] ^
    dma_errors.arm_dma_tx_packet_size_error[0] ^ dma_errors.arm_dma_tx_rd_data_timeout[0] ^
    dma_errors.arm_dma_tx_wr_aux_timeout[0] /*^ dma_errors.arm_dma_tx_postponed[0]*/;

    case (dma_state)
    //------------------------------------------------------------------------------
    DMA_TX_PACK_AVLB: begin
      dma_rx_out.reset_rx <= 1'd0;
      if (tx_cond_flg) begin
        dma_state <= DMA_TX_RD_AUX;
        dma_addres <= ddr_cur_tx_buf_addr;
        dma_read <= 1'd1;
        dma_burstcount <= 1'd1; /* One AUX word to read */
        brake_op_cnt <= 'd0;
      end
      else
        dma_state <= DMA_RX_PACK_AVLB;
    end
    DMA_TX_RD_AUX: begin
      if (~dma_waitrequest || dma_readdatavalid || brake_op_cnt_timeout)
        dma_read <= 'd0;

      if (dma_readdatavalid) begin
        aux_w_tx <= ddr_aux_word_t'(dma_readdata);
        dma_state <= DMA_TX_AUX_CHECK;
        ddr_process_rd <= 'd0;
        rdy_for_rd <= 'd0;
      end
      else if (brake_op_cnt_timeout) begin
        dma_state <= DMA_RX_PACK_AVLB;
        dma_errors.arm_dma_tx_rd_aux_timeout <= dma_errors.arm_dma_tx_rd_aux_timeout + 1'd1;
        dma_read <= 'd0;
      end
      else
        brake_op_cnt <= brake_op_cnt + 1'd1;
    end
    DMA_TX_AUX_CHECK: begin
      if(aux_w_tx.dma_owner == 0) begin
        dma_errors.arm_dma_tx_owner_error <= dma_errors.arm_dma_tx_owner_error + 1'd1;
        ethSw.ddr_tx_pckt_rd <= ethSw.ddr_tx_pckt_rd + 1'd1;
        if (&ethSw.ddr_tx_pckt_rd)
          ddr_cur_tx_buf_addr <= ddr_tx_buf_addr;
        else
          ddr_cur_tx_buf_addr <= ddr_cur_tx_buf_addr + ARM_DMA_BUFFER_INC;

        dma_state <= DMA_RX_PACK_AVLB;
      end
      else if(aux_w_tx.pack_sz < MIN_ETH_FRAME_CNT || aux_w_tx.pack_sz > MAX_ETH_FRAME_CNT) begin
        dma_errors.arm_dma_tx_packet_size_error <= dma_errors.arm_dma_tx_packet_size_error + 1'd1;
        dma_state <= DMA_TX_END_RD;
        aux_w_tx.error <= DMA_INDERECT_CTRL_TX_PACK_SIZE_ERR;
      end
      else begin
        dma_state <= DMA_TX_PACK_RD;
      end
      aux_w_tx.dma_owner <= 'd0;
    end
    DMA_TX_PACK_RD: begin
      if (ddr_process_rd) begin
        if (~dma_waitrequest)
          dma_read <= 'd0;

        dma_tx_out.frw_data_tx <= dma_readdata;

        dma_tx_out.frw_sop_tx <= 1'd0;
        if (dma_readdatavalid) begin
          brake_op_cnt <= 'd0;
          dma_tx_out.frw_valid_tx <= 1'd1;
          rd_brst_cnt <= rd_brst_cnt - 1'd1;
          if (rd_brst_cnt == 'd0) begin
            dma_state <= DMA_TX_END_RD;
            dma_tx_out.frw_eop_tx <= 1'd1;
            dma_read <= 'd0;
          end
        end
        else if (brake_op_cnt_timeout) begin
          dma_errors.arm_dma_tx_rd_data_timeout <= dma_errors.arm_dma_tx_rd_data_timeout + 1'd1;
          dma_state <= DMA_TX_END_RD; /* Cut-through TXQA must be prepared for this error! */
          aux_w_tx.error <= DMA_INDERECT_CTRL_TX_RD_DATA_TIMEOUT;
          dma_tx_out.frw_eop_tx <= 1'd1;
          dma_read <= 'd0;
        end else
        begin
          brake_op_cnt <= brake_op_cnt + 1'd1;
          dma_tx_out.frw_valid_tx <= 'd0;
        end
      end
      else begin
        if (rdy_for_rd) begin
          rdy_for_rd <= 'd0;
          ddr_process_rd <= 1'd1;
          brake_op_cnt <= 'd0;
          dma_addres <= aux_w_tx.dma_addrX >> BITS_PAD;
          dma_read <= 1'd1;
          rd_brst_cnt <= dma_burstcount - 1'd1;
          dma_tx_out.frw_sop_tx <= 1'd1;
        end
        else if (dma_tx_inp.bytes_avlb >= (aux_w_tx.pack_sz + (2*PCKT_Q_INTF_W/8))) begin
          /* TXQA has enough space to receive packet for transmission */
          //dma_burstcount <= aux_w_tx.pack_sz[MAX_ETH_FRAME_CNT_WIDTH - 1 : BITS_PAD_ARM] +
                //|aux_w_tx.pack_sz[BITS_PAD_ARM - 1 : 0];
          dma_burstcount <= aux_w_tx.dma_burstcount;

          dma_tx_out.pack_ln_b <= aux_w_tx.pack_sz; /* Inform TXQA about the packet length */
          dma_tx_out.data_offs <= aux_w_tx.dma_addrX[BITS_PAD - 1 : 0];
          rdy_for_rd <= 1'd1;
        end
        else begin
          /* TXQA is not ready yet */
          dma_errors.arm_dma_tx_postponed <= dma_errors.arm_dma_tx_postponed + 1'd1;
          dma_state <= DMA_RX_PACK_AVLB;
          dma_read <= 'd0;
        end
      end
    end
    DMA_TX_END_RD: begin
      /* Packet was placed(or not) to the TXQA */
      dma_state <= DMA_TX_WR_AUX;
      dma_tx_out.frw_valid_tx <= 'd0;
      dma_tx_out.frw_eop_tx <= 'd0;
      brake_op_cnt <= 'd0;
      ddr_process_rd <= 'd0;
      dma_addres <= ddr_cur_tx_buf_addr;
      dma_burstcount <= 1'd1; /* One AUX word to write */
      dma_write <= 1'd1;
      dma_writedata <= aux_b_tx.dbits[ARM_INTF_WIDTH - 1 : 0];
    end
    DMA_TX_WR_AUX: begin
      if ((dma_write & ~dma_waitrequest) || brake_op_cnt_timeout) begin
        dma_state <= DMA_RX_PACK_AVLB;
        irq_request_tx <= ~irq_request_tx; /* Successful transmite IRQ */
        dma_write <= 'd0;
        if (brake_op_cnt_timeout)
          dma_errors.arm_dma_tx_wr_aux_timeout <= dma_errors.arm_dma_tx_wr_aux_timeout + 1'd1;

        ethSw.ddr_tx_pckt_rd <= ethSw.ddr_tx_pckt_rd + 1'd1;
        if (&ethSw.ddr_tx_pckt_rd)
          ddr_cur_tx_buf_addr <= ddr_tx_buf_addr;
        else
          ddr_cur_tx_buf_addr <= ddr_cur_tx_buf_addr + ARM_DMA_BUFFER_INC;
      end
      else
        brake_op_cnt <= brake_op_cnt + 1'd1;
    end
    //------------------------------------------------------------------------------
    DMA_RX_PACK_AVLB: begin
      /* Check if we have RX packets */
      if (dma_rx_inp.packet_avlb) begin
        if (buff_owerflow_val == ethSw.dma_par.cur_pckt_rx_pos) begin
          dma_errors.arm_dma_rx_ddr_buff_owerflow <= dma_errors.arm_dma_rx_ddr_buff_owerflow + 1'd1;
          dma_state <= DMA_TX_PACK_AVLB;
          dma_rx_out.reset_rx <= 1'd1;
        end
        else begin
          dma_addres <= ddr_cur_rx_buf_addr;
          dma_burstcount <= 1'd1; /* One AUX word to read */
          brake_op_cnt <= 'd0;
          dma_state <= DMA_RX_RD_AUX;
          dma_read <= 1'd1;
        end
      end
      else
        dma_state <= DMA_TX_PACK_AVLB;
    end
    DMA_RX_RD_AUX: begin
      if (~dma_waitrequest || dma_readdatavalid || brake_op_cnt_timeout)
        dma_read <= 'd0;

      if (dma_readdatavalid) begin
        aux_w_rx <= ddr_aux_word_t'(dma_readdata);
        dma_state <= DMA_RX_AUX_CHECK;
      end
      else if (brake_op_cnt_timeout) begin
        dma_state <= DMA_TX_PACK_AVLB;
        dma_errors.arm_dma_rx_rd_aux_timeout <= dma_errors.arm_dma_rx_rd_aux_timeout + 1'd1;
      end
      else begin
        brake_op_cnt <= brake_op_cnt + 1'd1;
      end
    end
    DMA_RX_AUX_CHECK: begin
      if(aux_w_rx.dma_owner == 0) begin
        dma_errors.arm_dma_rx_owner_error <= dma_errors.arm_dma_rx_owner_error + 1'd1;
        ethSw.ddr_rx_pckt_wr <= ethSw.ddr_rx_pckt_wr + 1'd1;
        if (&ethSw.ddr_rx_pckt_wr)
          ddr_cur_rx_buf_addr <= ddr_rx_buf_addr;
        else
          ddr_cur_rx_buf_addr <= ddr_cur_rx_buf_addr + ARM_DMA_BUFFER_INC;

        dma_state <= DMA_TX_PACK_AVLB;
        dma_rx_out.reset_rx <= 1'd1;
      end
      else if(aux_w_rx.pack_sz < MIN_ETH_FRAME_CNT || aux_w_rx.pack_sz > MAX_ETH_FRAME_CNT) begin
        dma_errors.arm_dma_rx_buffer_size_error <= dma_errors.arm_dma_rx_buffer_size_error + 1'd1;
        dma_state <= DMA_RX_WR_AUX;
        aux_w_rx.dst_src_port_A <= 1'd1; /* Receive from port A now */
        aux_w_rx.dma_owner <= 'd0; /* Host owns this buffer */
        aux_w_rx.error <= DMA_INDERECT_CTRL_RX_BUFFER_SIZE_ERR;
        brake_op_cnt <= 'd0;
      end
      else begin
        dma_state <= DMA_RX_PACK_WR;
        aux_w_rx.pack_sz <= dma_rx_inp.cur_pckt_lnb;
        aux_w_rx.dst_src_port_A <= 1'd1; /* Receive from port A now */
        aux_w_rx.dma_owner <= 'd0; /* Host owns this packet */
        rd_done_str <= 'd0;
        dma_rx_out.strb_rx <= 1'd1;
        dma_rx_out.sop_rx <= 1'd1;
        pack_cnt_rd <= 'd0;
        pack_eop_cnt <= dma_rx_inp.cur_pckt_lnb[MAX_ETH_FRAME_CNT_WIDTH - 1 : BITS_PAD_ARM] +
                |dma_rx_inp.cur_pckt_lnb[BITS_PAD_ARM - 1 : 0] - 1'd1;
        rd_answ_cnt <= 'd0;
        buf_rdy <= 'd0;
        wr_wrd_cnt <= 'd0;
        pack_cnt_ddr_wr <= 'd0;
        dma_write <= 'd0;
        dma_addres <= aux_w_rx.dma_addrX >> BITS_PAD;
        dma_burstcount <= dma_rx_inp.cur_pckt_lnb[MAX_ETH_FRAME_CNT_WIDTH - 1 : BITS_PAD_ARM] +
                |dma_rx_inp.cur_pckt_lnb[BITS_PAD_ARM - 1 : 0];
        brake_op_cnt <= 'd0;
        rx_error <= 'd0;
      end
    end
    DMA_RX_PACK_WR: begin
      dma_rx_out.sop_rx <= 1'd0;
      /* Data request to RXQA */
      if (rx_error) begin
        pack_cnt_rd <= pack_cnt_rd + 1'd1;
        if (pack_cnt_rd == pack_eop_cnt) begin
          dma_rx_out.strb_rx <= 'd0; /* ToDo: Check that this is correct moment to remove the signal */
          dma_state <= DMA_RX_WR_AUX;
          dma_write <= 'd0;
        end
      end
      else if ((dma_rx_out.strb_rx && ~rd_done_str)) begin
        pack_cnt_rd <= pack_cnt_rd + 1'd1;
        if (pack_cnt_rd == pack_eop_cnt) begin
          rd_done_str <= 1'd1;
          dma_rx_out.strb_rx <= 'd0;
        end
        else if (&pack_cnt_rd[1:0])
          dma_rx_out.strb_rx <= 'd0;
      end

      /* Gets data from RXQA */
      if (dma_rx_inp.frw_valid_rx) begin
        rd_answ_cnt <= rd_answ_cnt + 1'd1;
        rd_words[rd_answ_cnt] <= dma_rx_inp.frw_data_rx;
        buf_rdy <= 1'd1;
      end

      /* Store received data in DDR */
      if (~rx_error) begin
        if (buf_rdy & ~dma_waitrequest) begin
          brake_op_cnt <= 'd0;
          if (wr_wrd_cnt == 'd4) begin
            buf_rdy <= 'd0;
            dma_write <= 'd0;
            wr_wrd_cnt <= 'd0;
            dma_rx_out.strb_rx <= 1'd1;
          end
          else begin
            dma_write <= 1'd1;
            wr_wrd_cnt <= wr_wrd_cnt + 1'd1;
          end
        end
        else if (brake_op_cnt_timeout) begin
          dma_errors.arm_dma_rx_wr_data_timeout <= dma_errors.arm_dma_rx_wr_data_timeout + 1'd1;
          brake_op_cnt <= 'd0;
          aux_w_rx.pack_sz <= 'd0; /* Corrupted RX packet */
          aux_w_rx.error <= DMA_INDERECT_CTRL_RX_WR_DATA_TIMEOUT;
          rx_error <= 'd1;
          dma_write <= 'd0;
          dma_rx_out.strb_rx <= 1'd1; /* Drain RX queue */
        end
        else if (buf_rdy)
          brake_op_cnt <= brake_op_cnt + 1'd1;
      end

      if (~dma_waitrequest) begin
        dma_writedata <= rd_words[wr_wrd_cnt[1:0]];
        if (dma_write) begin
          if (pack_cnt_ddr_wr == pack_eop_cnt) begin
              buf_rdy <= 'd0;
              dma_write <= 0;
              dma_state <= DMA_RX_WR_AUX;
              dma_rx_out.strb_rx <= 1'd0;
              dma_errors.arm_dma_rx_pack_successfull <= dma_errors.arm_dma_rx_pack_successfull + 1'd1;
          end
          else
            pack_cnt_ddr_wr <= pack_cnt_ddr_wr + 1'd1;
        end
      end
    end
    DMA_RX_WR_AUX: begin
      if (dma_write & ~dma_waitrequest) begin
        dma_write <= 'd0;
        dma_state <= DMA_RX_END_WR;
      end
      else if (~dma_waitrequest) begin
        dma_addres <= ddr_cur_rx_buf_addr; // sending to ARM
        dma_burstcount <= 'd1;
        dma_write <= 1'd1;
        dma_writedata <= aux_b_rx.dbits[ARM_INTF_WIDTH - 1 : 0];
      end
      else if (brake_op_cnt_timeout) begin
        dma_errors.arm_dma_rx_wr_aux_timeout <= dma_errors.arm_dma_rx_wr_aux_timeout + 1'd1;
        dma_state <= DMA_RX_END_WR;
        dma_write <= 'd0;
      end
      else
        brake_op_cnt <= brake_op_cnt + 1'd1;
    end
    DMA_RX_END_WR: begin
      dma_write <= 'd0;
      /* The packet has been written to the DDR, go to next */
      dma_state <= DMA_RX_PACK_AVLB;
      irq_request_rx <= ~irq_request_rx; /* Successful receive(or not) IRQ */

      ethSw.ddr_rx_pckt_wr <= ethSw.ddr_rx_pckt_wr + 1'd1;
      if (&ethSw.ddr_rx_pckt_wr)
        ddr_cur_rx_buf_addr <= ddr_rx_buf_addr;
      else
        ddr_cur_rx_buf_addr <= ddr_cur_rx_buf_addr + ARM_DMA_BUFFER_INC;
    end
    endcase
  end
  else begin
    ddr_cur_tx_buf_addr <= ddr_tx_buf_addr;
    ddr_cur_rx_buf_addr <= ddr_rx_buf_addr;
    ethSw.ddr_rx_pckt_wr <= 'd0;
    ethSw.ddr_tx_pckt_rd <= 'd0;
    dma_errors <= dma_errors_t'(0);
    dma_state <= DMA_RX_PACK_AVLB;
    dma_read <= 'd0;
    dma_write <= 'd0;
    dma_tx_out <= pack_q_frw_tx_from_sw_t'(0);
    dma_rx_out <= pack_q_frw_rx_from_sw_t'(0);
    irq_request_rx <= 'd0;
    irq_request_tx <= 'd0;
    irq_request_rx_err <= 'd0;
    irq_request_tx_err <= 'd0;
  end
end


always_ff @(posedge ethSw.clk) begin: DMA_IND_CONTROL
  if (~ethSw.rst_n) begin
    ethSw.dma_control_reg <= 'd0;
  end
  else if (dma_cntrl.work_ena) begin
    case (dma_ind_select)
    DMA_INDERECT_CTRL_TX_POSTPONED: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_tx_postponed;
    end
    DMA_INDERECT_CTRL_TX_RD_AUX_TIMEOUT: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_tx_rd_aux_timeout;
    end
    DMA_INDERECT_CTRL_TX_OWNER_ERR: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_tx_owner_error;
    end
    DMA_INDERECT_CTRL_TX_PACK_SIZE_ERR: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_tx_packet_size_error;
    end
    DMA_INDERECT_CTRL_TX_RD_DATA_TIMEOUT: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_tx_rd_data_timeout;
    end
    DMA_INDERECT_CTRL_TX_WR_AUX_TIMEOUT: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_tx_wr_aux_timeout;
    end
    DMA_INDERECT_CTRL_RX_RD_AUX_TIMEOUT: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_rx_rd_aux_timeout;
    end
    DMA_INDERECT_CTRL_RX_OWNER_ERR: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_rx_owner_error;
    end
    DMA_INDERECT_CTRL_RX_BUFFER_SIZE_ERR: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_rx_buffer_size_error;
    end
    DMA_INDERECT_CTRL_RX_WR_DATA_TIMEOUT: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_rx_wr_data_timeout;
    end
    DMA_INDERECT_CTRL_RX_WR_AUX_TIMEOUT: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_rx_wr_aux_timeout;
    end
    DMA_INDERECT_CTRL_RX_PACK_SUCCESS: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_rx_pack_successfull;
    end
    DMA_INDERECT_CTRL_RX_DDR_BUFF_OWF: begin
      ethSw.dma_control_reg <= dma_errors.arm_dma_rx_ddr_buff_owerflow;
    end
    default: begin
      ethSw.dma_control_reg <= 'd0;
    end
    endcase
  end
  else begin
    ethSw.dma_control_reg <= 'd0;
  end
end

endmodule
