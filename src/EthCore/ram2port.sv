/****************************************************************************
 * ram2port.sv
 ****************************************************************************/
module ram2port#
(
  parameter int   pWIDTH_DATA_A = 18,
  parameter int   pWIDTH_DATA_B = pWIDTH_DATA_A,
  parameter int   pSIZE_A = 1024,
  parameter int   pSIZE_B = pSIZE_A,
  parameter int   pWIDTH_ADDR_A = 10,
  parameter int   pWIDTH_ADDR_B = pWIDTH_ADDR_A,
  parameter       init_file = "UNUSED"
)
(
  input                             clock_a,
  input                             clock_b,
  input                             clkena_a,
  input                             clkena_b,
  input [pWIDTH_ADDR_A-1:0]         addr_a,
  input [pWIDTH_ADDR_B-1:0]         addr_b,
  input                             wrena_a,
  input                             wrena_b,
  input [pWIDTH_DATA_A-1:0]         idata_a,
  input [pWIDTH_DATA_B-1:0]         idata_b,
  output logic [pWIDTH_DATA_A-1:0]  odata_a,
  output logic [pWIDTH_DATA_B-1:0]  odata_b
);

wire [pWIDTH_ADDR_A-1:0] mem__address_a;
wire [pWIDTH_ADDR_B-1:0] mem__address_b;
wire mem__clock_a;
wire mem__clock_b;
wire mem__enable_a;
wire mem__enable_b;
wire [pWIDTH_DATA_A-1:0] mem__data_a;
wire [pWIDTH_DATA_B-1:0] mem__data_b;
wire mem__wren_a;
wire mem__wren_b;
wire [pWIDTH_DATA_A-1:0] mem__q_a;
wire [pWIDTH_DATA_B-1:0] mem__q_b;

assign mem__address_a = addr_a;
assign mem__address_b = addr_b;
assign mem__clock_a = clock_a;
assign mem__clock_b = clock_b;
assign mem__enable_a = clkena_a;
assign mem__enable_b = clkena_b;
assign mem__data_a = idata_a;
assign mem__data_b = idata_b;
assign mem__wren_a = wrena_a;
assign mem__wren_b = wrena_b;
assign odata_a = mem__q_a;
assign odata_b = mem__q_b;

altsyncram#
(
  .address_reg_b              ("CLOCK1"),
  .clock_enable_input_a       ("BYPASS"),
  .clock_enable_input_b       ("BYPASS"),
  .clock_enable_output_a      ("BYPASS"),
  .clock_enable_output_b      ("BYPASS"),
  .indata_reg_b               ("CLOCK1"),
  .intended_device_family     ("Cyclone V"),
  .lpm_type                   ("altsyncram"),
  .numwords_a                 (pSIZE_A),
  .numwords_b                 (pSIZE_B),
  .operation_mode             ("BIDIR_DUAL_PORT"),
  .outdata_aclr_a             ("NONE"),
  .outdata_aclr_b             ("NONE"),
  .outdata_reg_a              ("CLOCK0"),
  .outdata_reg_b              ("CLOCK1"),
  .power_up_uninitialized     ("FALSE"),
  // .ram_block_type             ("M10K"),
  .read_during_write_mode_port_a("DONT_CARE"),  //DONT_CARE NEW_DATA
  .read_during_write_mode_port_b("DONT_CARE"),  //DONT_CARE NEW_DATA
  .read_during_write_mode_mixed_ports("OLD_DATA"), //DONT_CARE OLD_DATA
  .widthad_a                  (pWIDTH_ADDR_A),
  .widthad_b                  (pWIDTH_ADDR_B),
  .width_a                    (pWIDTH_DATA_A),
  .width_b                    (pWIDTH_DATA_B),
  .width_byteena_a            (1),
  .width_byteena_b            (1),
  .wrcontrol_wraddress_reg_b  ("CLOCK1"),
  .init_file                  (init_file)
) mem__ (
  .address_a(mem__address_a),
  .address_b(mem__address_b),
  .clock0(mem__clock_a),
  .clock1(mem__clock_b),
  .clocken0(mem__enable_a),
  .clocken1(mem__enable_b),
  .data_a(mem__data_a),
  .data_b(mem__data_b),
  .wren_a(mem__wren_a),
  .wren_b(mem__wren_b),
  .q_a(mem__q_a),
  .q_b(mem__q_b),
  .aclr0(1'b0),
  .aclr1(1'b0),
  .addressstall_a(1'b0),
  .addressstall_b(1'b0),
  .byteena_a(1'b1),
  .byteena_b(1'b1),
  .clocken2(1'b1),
  .clocken3(1'b1),
  .eccstatus(),
  .rden_a(1'b1),
  .rden_b(1'b1)
);

endmodule
