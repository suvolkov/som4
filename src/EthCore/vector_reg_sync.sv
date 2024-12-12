module vector_reg_sync #(
    parameter int pWIDTH     = 18,
    parameter int pREG_DEPTH = 3
) (
    //input  logic                rst_n,
    input  logic                clock_in,
    input  logic                clock_out,
    input  logic [pWIDTH - 1:0] ivector,
    output logic [pWIDTH - 1:0] ovector
);

  logic [pWIDTH-1:0] ivector_reg;
  always_ff @(posedge clock_in) begin
    ivector_reg <= ivector;
  end

  logic [pWIDTH - 1:0] chain[pREG_DEPTH + 1];
  assign chain[0] = ivector_reg;

  generate
    genvar i;
    for (i = 0; i < pREG_DEPTH; i = i + 1) begin : dc_gen
      lpm_ff #(
          .LPM_WIDTH(pWIDTH)
      ) dc (
          .clock(clock_out),
          .data(chain[i]),
          .q(chain[i+1])
      );
    end
  endgenerate

  assign ovector = chain[pREG_DEPTH];

endmodule
