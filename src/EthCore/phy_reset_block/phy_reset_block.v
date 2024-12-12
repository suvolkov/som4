
module phy_reset_block (
	clk,
	reset_n,
	phy_resetn
);

	input wire clk;
	input wire reset_n;

	output wire phy_resetn;
  
  //PHY power-on reset control
	parameter MSB = 20; // PHY interface: need minimum 10ms delay for POR
	reg [MSB:0] epcount;

	always @(posedge clk or negedge reset_n) begin
	  if (!reset_n)
		  epcount <= MSB + 1'b0;
	  else if (epcount[MSB] == 1'b0)
		  epcount <= epcount + 1;
	  else
		  epcount <= epcount;
	end

	assign phy_resetn    = !epcount[MSB-1];
  
endmodule
