/* параметризуемая задержка */
// width -- ширина, бит
// depth -- количество тактов
// depth_aux -- если нужно прочитать еще 1 выход из середины цепочки

module delay_chain #(
  parameter int width = 1,
  parameter int depth = 1,
  parameter int depth_aux = 1
)(
  input  wire             clk,
  input  wire [width-1:0] d,
  output wire [width-1:0] q,
  output wire [width-1:0] q_aux
);

wire [width-1:0] chain [depth+1];
assign chain[0] = d, q = chain[depth], q_aux = chain[depth_aux];

generate genvar i;
  for( i = 0; i < depth; i = i + 1 )
  begin : dc_gen
    lpm_ff #(.lpm_width( width )) dc(
      .clock(clk),
      .data(chain[i]),
      .q(chain[i+1]),
      .enable(1'd1),
      .aclr(1'b0),
      .aset(1'b0),
      .aload(1'b0),
      .sclr(1'b0),
      .sset(1'b0),
      .sload(1'b0));
  end
endgenerate

endmodule
