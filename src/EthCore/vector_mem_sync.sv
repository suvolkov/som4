module vector_mem_sync #(
    parameter int pWIDTH     = 18,
    parameter int pMEM_DEPTH = 4
) (
    input  logic              rst_n,
    input  logic              clock_in,
    input  logic              clock_out,
    input  logic [pWIDTH-1:0] ivector,
    output logic [pWIDTH-1:0] ovector,
    output logic              sync_err
);

  localparam int MEM_WIDTH = $clog2(pMEM_DEPTH);
  //==============================================================================
  logic [MEM_WIDTH - 1:0] addr_wr, cnt;

  ram2port #(
      .pWIDTH_DATA_A(pWIDTH),
      .pSIZE_A(pMEM_DEPTH),
      .pWIDTH_ADDR_A(MEM_WIDTH)
  ) sync_buf (
      .clock_a (clock_in),
      .clock_b (clock_out),
      .clkena_a(rst_n),
      .clkena_b(rst_n),
      .addr_a  (addr_wr),
      .addr_b  (addr_rd),
      .wrena_a (1'd1),
      .wrena_b ('d0),
      .idata_a (ivector),
      .idata_b ('d0),
      .odata_a (),
      .odata_b (ovector)
  );
  //==============================================================================
  always_ff @(posedge clock_in) begin
    cnt <= cnt + 1'd1;
    for (int i = 0; i < MEM_WIDTH - 1; i = i + 1) begin
      addr_wr[i] <= cnt[i + 1] ^ cnt[i];
    end
    addr_wr[MEM_WIDTH - 1] <= cnt[MEM_WIDTH - 1];
  end

  logic [MEM_WIDTH-1:0] addr_rd_sync1, addr_rd, addr_rd_del;
  always_ff @(posedge clock_out) begin
    addr_rd_sync1 <= addr_wr;
    addr_rd <= addr_rd_sync1;

    addr_rd_del <= addr_rd;
    sync_err <= addr_rd == addr_rd_del;
  end

endmodule
