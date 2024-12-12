/* Result latency = ? clocks from the begining of packet */
import params::*;
import typesPkg::*;

module rx_filter (
  input logic                 valid_rxA,
  input logic [7 : 0]         data_rxA,
  output filter_status_t      f_statA,
  input vlan_setup_t          vlan_setup,
  input ethipcore_control     cntrl,
  interSw                     ethSw
);
//==========================================================================================
logic [7 : 0] link_cnt;

always_ff @(posedge ethSw.clk) begin
  if (~ethSw.main_rst_n) begin
    link_cnt <= 'd0;
  end
  else begin
    if (ethSw.link_speed == LINK_1000)
      link_cnt <= 'd0;
    else if (valid_rxA) begin
      if (ethSw.link_speed == LINK_100)
        link_cnt <= 'd15;
      else
        link_cnt <= 'd150;
    end
    else if (|link_cnt)
      link_cnt <= link_cnt - 1'd1;
  end
end
//==========================================================================================
logic [$clog2(MAX_VLAN_NETS) - 1 : 0] vlan_addr;
logic [11 : 0] arr_vid;

ram2port #(.pWIDTH_DATA_A(12), .pSIZE_A(MAX_VLAN_NETS), .pWIDTH_ADDR_A($clog2(MAX_VLAN_NETS)) ) vlan_array
(
  .clock_a(ethSw.clk),
  .clock_b(ethSw.clk),
  .clkena_a(ethSw.main_rst_n),
  .clkena_b(ethSw.main_rst_n),
  .addr_a(vlan_setup.addr),
  .addr_b(vlan_addr),
  .wrena_a(vlan_setup.wr_val),
  .wrena_b(1'd0),
  .idata_a(vlan_setup.vid),
  .idata_b('d0),
  .odata_a(),
  .odata_b(arr_vid)
);
//==========================================================================================
logic [5 : 0] pack_cnt_v;
logic vlan_pack_flg, vlan_pack_flg_d1, vlan_pack_flg_d2;
logic alien_vlan_pack;
logic [15 : 0] prot;
logic [11 : 0] pack_vid;

assign f_statA.vlan_accept_flg = ethSw.vlan_filter_ena & ~alien_vlan_pack;

always_ff @(posedge ethSw.clk) begin : VLAN_RX_FILTER
  if (~ethSw.main_rst_n) begin
    vlan_addr <= 'd0;
    pack_cnt_v <= 'd0;
    vlan_pack_flg <= 'd0;
    alien_vlan_pack <= 'd1;
  end
  else if (ethSw.vlan_filter_ena) begin
    if (valid_rxA) begin
      if (~&pack_cnt_v)
        pack_cnt_v <= pack_cnt_v + 1'd1;

      if (pack_cnt_v == 'd12 || pack_cnt_v == 'd13)
        prot <= {prot[7 : 0], data_rxA};
      else if (pack_cnt_v == 'd14) begin
        pack_vid[11 : 8] <= data_rxA[3 : 0];
        alien_vlan_pack <= 'd1;
        if (prot == 16'h8100)
          vlan_pack_flg <= 'd1;
      end
      else if (pack_cnt_v == 'd15)
        pack_vid[7 : 0] <= data_rxA;

      if (vlan_pack_flg) begin
        if (vlan_addr == MAX_VLAN_NETS - 1)
          vlan_pack_flg <= 'd0;
        else
          vlan_addr <= vlan_addr + 1'd1;
      end
    end
    else if (link_cnt == 'd0) begin
      vlan_addr <= 'd0;
      pack_cnt_v <= 'd0;
      vlan_pack_flg <= 'd0;
    end

    vlan_pack_flg_d1 <= vlan_pack_flg;
    vlan_pack_flg_d2 <= vlan_pack_flg_d1;

    if(vlan_pack_flg_d2 && (arr_vid == pack_vid)) begin
        alien_vlan_pack <= 'd0;
    end
  end
end

//==========================================================================================
logic pack_multi_flg;

assign f_statA.multicast_accept_flg = ethSw.multicast_filter_ena & pack_multi_flg;

always_ff @(posedge ethSw.clk) begin : ALLMULTICAST_RX_FILTER
  if (~ethSw.main_rst_n) begin
    pack_multi_flg <= 'd0;
  end
  else if(ethSw.multicast_filter_ena) begin
    if (valid_rxA && (link_cnt == 'd0)) begin
      if (data_rxA[0])
        pack_multi_flg <= 'd1;
      else
        pack_multi_flg <= 'd0;
    end
  end
end

//==========================================================================================
logic pack_broadcast_flg;
logic [2 : 0] pack_cnt_br;

assign f_statA.brdcst_accept_flag = pack_broadcast_flg;

always_ff @(posedge ethSw.clk) begin : BROADCAST_RX_FILTER
  if (~ethSw.main_rst_n) begin
    pack_broadcast_flg <= 1'd1;
    pack_cnt_br <= 'd0;
  end
  else if (valid_rxA) begin
    if (pack_cnt_br < 'd6) begin
      pack_cnt_br <= pack_cnt_br + 1'd1;
      pack_broadcast_flg <= pack_broadcast_flg & &data_rxA;
    end
  end
  else if (link_cnt == 'd0) begin
    pack_broadcast_flg <= 1'd1;
    pack_cnt_br <= 'd0;
  end
end

//==========================================================================================
logic pack_our_flg;
logic [2 : 0] pack_cnt_our;

assign f_statA.our_accept_flag = pack_our_flg;

always_ff @(posedge ethSw.clk) begin : OURMAC_RX_FILTER
  if (~ethSw.main_rst_n) begin
    pack_our_flg <= 1'd1;
    pack_cnt_our <= 'd0;
  end
  else if (valid_rxA) begin
    if (pack_cnt_our < 'd6) begin
      pack_cnt_our <= pack_cnt_our + 1'd1;
      pack_our_flg <= pack_our_flg & ~|( data_rxA ^ ethSw.port_mac[pack_cnt_our] );
    end
  end
  else if (link_cnt == 'd0) begin
    pack_our_flg <= 1'd1;
    pack_cnt_our <= 'd0;
  end
end

//==========================================================================================

endmodule
