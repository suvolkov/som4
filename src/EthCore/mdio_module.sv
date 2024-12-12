/* Before first use- set phy address for each port by address 33 */
module mdio_module #(
  parameter integer AVL_ADDR_WIDTH = 6,
  parameter integer N_PHY_PORTS = 2, /* # of physical ports connected to this module */
  parameter integer N_LOG_PORTS = 4 /* # of logical ports connected to one physical */
)(
  input logic clk,
  input logic rst_n,

  input  logic [AVL_ADDR_WIDTH - 1 : 0] mdio_addr,   //  avalon_slave.address
  output logic [31 : 0]                 mdio_rdata,  //              .readdata
  input  logic                          mdio_rd,     //              .read
  input  logic                          mdio_wr,     //              .write
  input  logic [31 : 0]                 mdio_wdata,  //              .writedata
  output logic                          mdio_wrq,

  output logic [N_PHY_PORTS - 1 : 0] eth_mdclk,
  inout  logic [N_PHY_PORTS - 1 : 0] eth_mdio
);
//==========================================================================================
localparam int WIDTH_DATA_NP_PHY = ($clog2(N_PHY_PORTS) <= 0) ? 1 : $clog2(N_PHY_PORTS);
localparam int WIDTH_DATA_NP_LOG = ($clog2(N_LOG_PORTS) <= 0) ? 1 : $clog2(N_LOG_PORTS);
logic [WIDTH_DATA_NP_PHY - 1 : 0] eth_sel_phy;
logic [WIDTH_DATA_NP_LOG - 1 : 0] eth_sel_log;

always_comb begin
  for (int ii = 0; ii < N_PHY_PORTS; ii++) begin
    eth_mdclk[ii] = eth_mdc && (eth_sel_phy == ii) && mdio_busy; /* 2.5 MHz */
  end
end
//==========================================================================================
logic [5 : 0]   mdc_cnt, mdio_cnt;
logic           mdio_op_wr, mdio_busy;
logic [4 : 0]   mdio_save_addr;
logic [15 : 0]  mdio_save_wdata;
logic [4 : 0]   mdio_phy_addr[N_PHY_PORTS][N_LOG_PORTS];
logic           eth_mdc;
logic [3 : 0]   pos_cnt;

always_ff @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    mdc_cnt <= 'd0;
    eth_mdc <= 'd0;
    eth_mdio <= {N_PHY_PORTS{1'bz}};
    mdio_busy <= 'd0;
    mdio_wrq <= 'd1;
    mdio_rdata <= 'd0;
    for (int ii = 0; ii < N_PHY_PORTS; ii++) begin
      for (int jj = 0; jj < N_LOG_PORTS; jj++) begin
        mdio_phy_addr[ii][jj] <= 'd0;
      end
    end
  end
  else begin
    if (~mdio_busy) begin
      if (mdio_rd | mdio_wr) begin
        if (mdio_wr & mdio_addr[AVL_ADDR_WIDTH - 1] & ~mdio_addr[0]) begin  /* addr = 32 */
          eth_sel_phy <= mdio_wdata[WIDTH_DATA_NP_PHY - 1 : 0];
          eth_sel_log <= mdio_wdata[WIDTH_DATA_NP_PHY + WIDTH_DATA_NP_LOG - 1 : WIDTH_DATA_NP_PHY];
          mdio_wrq <= 'd0;
        end
        else if (mdio_wr & mdio_addr[AVL_ADDR_WIDTH - 1] & mdio_addr[0]) begin  /* addr = 33 */
          mdio_phy_addr[eth_sel_phy][eth_sel_log] <= mdio_wdata[4 : 0];
          mdio_wrq <= 'd0;
        end
        else begin
          mdio_busy <= 1'd1;
          mdio_cnt <= 6'b111111;
          mdio_op_wr <= mdio_wr;
          mdio_save_addr <= mdio_addr[4 : 0];
          mdc_cnt <= 'd0;
          if (mdio_wr)
            mdio_save_wdata <= mdio_wdata[15 : 0];
        end
      end
      else if (~mdio_wrq & ~mdio_wr & ~mdio_rd) begin
        mdio_wrq <= 'd1;
      end
    end
    else begin
      if (mdc_cnt == 'd23) begin : MDC_CLOCK_GEN
        eth_mdc <= 'd0;
        mdc_cnt <= 'd0;
      end else begin
        mdc_cnt <= mdc_cnt + 1'd1;
        if (mdc_cnt == 'd11)
          eth_mdc <= 1'd1;    // 5.21 MHz
      end

      if (mdc_cnt == 0 && mdio_wrq)
        mdio_cnt <= mdio_cnt + 1'd1;

      if (mdc_cnt == 'd1) begin
        case (mdio_cnt)
          0: eth_mdio[eth_sel_phy] <= 'd0;
          1: eth_mdio[eth_sel_phy] <= 1'd1;
          2: eth_mdio[eth_sel_phy] <= ~mdio_op_wr;
          3: eth_mdio[eth_sel_phy] <= mdio_op_wr;

          4: eth_mdio[eth_sel_phy] <= mdio_phy_addr[eth_sel_phy][eth_sel_log][4];
          5: eth_mdio[eth_sel_phy] <= mdio_phy_addr[eth_sel_phy][eth_sel_log][3];
          6: eth_mdio[eth_sel_phy] <= mdio_phy_addr[eth_sel_phy][eth_sel_log][2];
          7: eth_mdio[eth_sel_phy] <= mdio_phy_addr[eth_sel_phy][eth_sel_log][1];
          8: eth_mdio[eth_sel_phy] <= mdio_phy_addr[eth_sel_phy][eth_sel_log][0];

          9:  eth_mdio[eth_sel_phy] <= mdio_save_addr[4];
          10: eth_mdio[eth_sel_phy] <= mdio_save_addr[3];
          11: eth_mdio[eth_sel_phy] <= mdio_save_addr[2];
          12: eth_mdio[eth_sel_phy] <= mdio_save_addr[1];
          13: eth_mdio[eth_sel_phy] <= mdio_save_addr[0];
          default:
          if (mdio_op_wr) begin
            if (mdio_cnt == 'd14)
              eth_mdio[eth_sel_phy] <= 1'b1;
            else if (mdio_cnt == 'd15) begin
              eth_mdio[eth_sel_phy] <= 'd0;
              pos_cnt <= 'd15;
            end
            else if (mdio_cnt >= 'd16 && mdio_cnt <= 'd31) begin
              eth_mdio[eth_sel_phy] <= mdio_save_wdata[pos_cnt];
              pos_cnt <= pos_cnt - 1'd1;
            end
            else  /*if(mdio_cnt == 'd32)*/
              eth_mdio[eth_sel_phy] <= 1'bz;
          end
        endcase
      end

      if (mdc_cnt == 'd14 & ~mdio_op_wr & mdio_cnt == 'd13)
        eth_mdio[eth_sel_phy] <= 1'bz;

      if (mdc_cnt == 'd21 & ~mdio_op_wr) begin
        if (mdio_cnt == 'd14) begin
          mdio_rdata <= 'd0;
          pos_cnt <= 'd15;
        end
        else if (mdio_cnt >= 'd15 && mdio_cnt <= 'd30) begin
          mdio_rdata[pos_cnt] <= eth_mdio[eth_sel_phy];
          pos_cnt <= pos_cnt - 1'd1;
        end
      end

      if (mdc_cnt == 'd22 & mdio_cnt == 'd33) begin
        mdio_wrq <= 'd0;
      end
      else if (~mdio_wrq & ~mdio_wr & ~mdio_rd) begin
        mdio_busy <= 'd0;
        mdio_wrq  <= 1'd1;
      end
    end
  end
end

endmodule
