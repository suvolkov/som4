module vector_fifo_sync #(
    parameter int pWIDTH = 10 // Change value according with cross_fifo
) (
    input link_select_t           link_speed,
    input logic                   clock_in,
    input logic                   ivalid,
    input logic [pWIDTH - 1 : 0]  ivector,

    input  logic                  clock_out,
    output logic                  ovalid,
    output logic [pWIDTH - 1 : 0] ovector
);

logic rdreq_1000, rdreq_100;
logic rdreq, _rdreq;
logic rdempty;

cross_fifo fifo (
  .wrclk(clock_in),
  .wrreq(ivalid),
  .data(ivector),
  .rdclk(clock_out),
  .rdreq(rdreq),
  .q(ovector),
  .rdempty(rdempty)
);

assign _rdreq = rdempty ? 1'd0 : 1'd1;

delay_chain #(
  .width(1),
  .depth_aux(2),
  .depth(4)
) dc_fifo (
  .clk(clock_out),
  .d(_rdreq),
  .q_aux(rdreq_100),
  .q(rdreq_1000)
);

assign rdreq = (link_speed == LINK_1000) ? rdreq_1000 : rdreq_100;

always_ff @(posedge clock_out) begin
  ovalid <= rdreq & ~rdempty;
end

endmodule
