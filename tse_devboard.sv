/* Main module */

module tse_devboard
(
  //input logic         CLK_100,
  // HPS DDR
(* chip_pin = "F24, G23, C24, D24, B24, A24, F25, F26, B26, C26, J20, J21 D26, E26, B28, C28" *)	 
	output wire [15:0] hps_memory_mem_a,                           
(* chip_pin = "G25, H25, A27" *)	output wire [2:0]  hps_memory_mem_ba,                          
(* chip_pin = "N21" *)	output wire        hps_memory_mem_ck,                          
(* chip_pin = "N20" *)	output wire        hps_memory_mem_ck_n,                        
//(* chip_pin = "L28" *)	output wire        hps_memory_mem_cke0,                         
//(* chip_pin = "K28" *)	output wire        hps_memory_mem_cke1,                         
(* chip_pin = "K28, L28" *)	output wire    [1:0]hps_memory_mem_cke,                         
//(* chip_pin = "L21" *)	output wire        hps_memory_mem_cs0_n,                        
//(* chip_pin = "L20" *)	output wire        hps_memory_mem_cs1_n,                        
(* chip_pin = "L20, L21" *)	output wire    [1:0]hps_memory_mem_cs_n,                        
(* chip_pin = "A25" *)	output wire        hps_memory_mem_ras_n,                       
(* chip_pin = "A26" *)	output wire        hps_memory_mem_cas_n,                       
(* chip_pin = "E25" *)	output wire        hps_memory_mem_we_n,                        
(* chip_pin = "V28" *)	output wire        hps_memory_mem_reset_n,                     
//(* chip_pin = "N28, M28, M26, M27, J28, J27, L25, K25, F28, G27, K26, J26, D27, E28, J24, J25" *)
//	inout  wire [15:0] hps_memory_mem_dq,                          
(* chip_pin = "AA27, Y27, T24, R24, W26, AA28, R25, R26, V27, R27, N27, N26, U28, T28, N25, N24, N28, M28, M26, M27, J28, J27, L25, K25, F28, G27, K26, J26, D27, E28, J24, J25" *)
	inout  wire [31:0] hps_memory_mem_dq,                          
//(* chip_pin = "R19, R17" *)	inout  wire [1:0]  hps_memory_mem_dqs_p, //                        
//(* chip_pin = "R18, R16" *)	inout  wire [1:0]  hps_memory_mem_dqs_n, //                      
(* chip_pin = "U19, T19, R19, R17" *)	inout  wire [3:0]  hps_memory_mem_dqs_p, //                        
(* chip_pin = "T20, T18, R18, R16" *)	inout  wire [3:0]  hps_memory_mem_dqs_n, //                      
(* chip_pin = "G26, D28" *)	output wire [1:0]  hps_memory_mem_odt,   //                      
(* chip_pin = "AB28, w28, P28, G28" *)	output wire [3:0]  hps_memory_mem_dm,    //                      
//(* chip_pin = "P28, G28" *)	output wire [1:0]  hps_memory_mem_dm,    //                      
(* chip_pin = "D25" *)	input  wire        hps_memory_oct_rzqin,      /*???*/                 

(* chip_pin = "U11, T11, AE9, AD10 " *)	input wire	[3:0]	fpga_enet0_rx_d,
	//input wire			fpga_enet0_rx_error,
(* chip_pin = "AF4" *)	input wire			fpga_enet0_rx_dv,
(* chip_pin = "AE4" *) 	input wire			fpga_enet0_rx_clk,
(* chip_pin = "AE11, AD11, AF9, AE8" *)	output wire	[3:0]	fpga_enet0_tx_d,
(* chip_pin = "AF8" *)	output wire			fpga_enet0_tx_en,
(* chip_pin = "AE7" *)	input wire			fpga_enet0_tx_clk,
	//output wire			fpga_enet0_tx_error,
(* chip_pin = "AG5" *)	output wire			RGMII_0_1_RESETn,
(* chip_pin = "AH4" *)	inout wire			RGMII_0_1_MDIO0,
(* chip_pin = "AE12" *)	inout wire			RGMII_0_1_MDIO1,
	
//(* chip_pin = ??? *)	output wire			fpga_enet1_gtx_clk,
	//input wire			fpga_enet3_tx_clk_fb,
(* chip_pin = "AG6, AF7, AF6, AF5" *)	input wire	[3:0]	fpga_enet1_rx_d,
	//input wire			fpga_enet1_rx_error,
(* chip_pin = "W11" *)	input wire			fpga_enet1_rx_dv,
(* chip_pin = "V11" *)	input wire			fpga_enet1_rx_clk,
(* chip_pin = "AH2, AH3, T12, T13" *)	output wire	[3:0]	fpga_enet1_tx_d,
(* chip_pin = "AF10" *)	output reg			fpga_enet1_tx_en,
(* chip_pin = "AF11" *)	input wire			fpga_enet1_tx_clk,
	//output wire			fpga_enet1_tx_error,

	//(* chip_pin = ??? *)	output wire			fpga_enet2_gtx_clk,
	// PHY1 interface (uPD60620 P0 interface)
	//input wire			fpga_enet0_tx_clk_fb,
(* chip_pin = "U13, U14, AF13, AG13" *)	input wire	[3:0]	fpga_enet2_rx_d,
	//input wire			fpga_enet0_rx_error,
(* chip_pin = "AH7" *)	input wire			fpga_enet2_rx_dv,
(* chip_pin = "AG8" *) 	input wire			fpga_enet2_rx_clk,
(* chip_pin = "AE15, AF15, AH9, AG10" *)	output wire	[3:0]	fpga_enet2_tx_d,
(* chip_pin = "AH8" *)	output wire			fpga_enet2_tx_en,
(* chip_pin = "AG9" *)	input wire			fpga_enet2_tx_clk,
	//output wire			fpga_enet0_tx_error,
	
//(* chip_pin = ??? *)	output wire			fpga_enet3_gtx_clk,
	//input wire			fpga_enet3_tx_clk_fb,
(* chip_pin = "AF17, AH12, AH11, AG11" *)	input wire	[3:0]	fpga_enet3_rx_d,
	//input wire			fpga_enet1_rx_error,
(* chip_pin = "AA13" *)	input wire			fpga_enet3_rx_dv,
(* chip_pin = "Y13" *)	input wire			fpga_enet3_rx_clk,
(* chip_pin = "AG15, AH13, AG14, V13" *)	output wire	[3:0]	fpga_enet3_tx_d,
(* chip_pin = "W14" *)	output wire			fpga_enet3_tx_en,
(* chip_pin = "AG16" *)	input wire			fpga_enet3_tx_clk,
	//output wire			fpga_enet1_tx_error,

//(* chip_pin = ??? *)	output wire			fpga_enet4_gtx_clk,
	// PHY1 interface (uPD60620 P0 interface)
	//input wire			fpga_enet0_tx_clk_fb,
(* chip_pin = "AH17, AA15, Y15, AE17" *)	input wire	[3:0]	fpga_enet4_rx_d,
	//input wire			fpga_enet0_rx_error,
(* chip_pin = "AD17" *)	input wire			fpga_enet4_rx_dv,
(* chip_pin = "AH14" *)	input wire			fpga_enet4_rx_clk,
(* chip_pin = "AA18, AA19, AD19, AE19" *)	output wire	[3:0]	fpga_enet4_tx_d,
(* chip_pin = "AF18" *)	output wire			fpga_enet4_tx_en,
(* chip_pin = "AH16" *)	input wire			fpga_enet4_tx_clk,
	//output wire			fpga_enet0_tx_error,
	
//(* chip_pin = ??? *)	output wire			fpga_enet5_gtx_clk,
	//input wire			fpga_enet3_tx_clk_fb,
(* chip_pin = "AD20, AE20, AH19, AG19" *)	input wire	[3:0]	fpga_enet5_rx_d,
	//input wire			fpga_enet1_rx_error,
(* chip_pin = "AH18" *)	input wire			fpga_enet5_rx_dv,
(* chip_pin = "AG18" *)	input wire			fpga_enet5_rx_clk,
(* chip_pin = "AD23, AF21, AF22, AG21" *)	output wire	[3:0]	fpga_enet5_tx_d,
(* chip_pin = "AG20" *)	output wire			fpga_enet5_tx_en,
(* chip_pin = "AF20" *)	input wire			fpga_enet5_tx_clk,
	//output wire			fpga_enet1_tx_error,

//(* chip_pin = "AG18" *)	output wire			RGMII_2_5_RESETn,
//(* chip_pin = "AH18" *)	inout wire			RGMII_2_5_MDIO0,
//(* chip_pin = "AG19" *)	inout wire			RGMII_2_5_MDIO1,

(* chip_pin = "D12" *)	input wire			fpga_clk,
  /* HPS FLASH */
//(* chip_pin = "W8" *)	inout wire			fpga_sd_cmd,
//(* chip_pin = "Y8" *)	inout wire			fpga_sd_clk,
//(* chip_pin = "Y5" *)	inout wire			fpga_sd_data0,
//(* chip_pin = "Y4" *)	inout wire			fpga_sd_data1,
//(* chip_pin = "U9" *)	inout wire			fpga_sd_data2,
//(* chip_pin = "T8" *)	inout wire			fpga_sd_data3,
//

(* chip_pin = "AB23" *)	output wire 		fpga_spi_mosi,
(* chip_pin = "Y16" *)	input wire 			fpga_spi_miso,
(* chip_pin = "W15" *)	inout wire 			fpga_spi_cs,
(* chip_pin = "AC24" *)	output wire 		fpga_spi_clk,

//(* chip_pin = "AA24" *)	inout wire 			fpga_irig0,
//(* chip_pin = "AA23" *)	inout wire 			fpga_irig1,

(* chip_pin = "U10" *)	output wire 		hps_uart2_TX,
(* chip_pin = "AB4" *)	input wire 			hps_uart2_RX,
(* chip_pin = "AA4" *)	output wire 		hps_uart2_CTS,
(* chip_pin = "V10" *)	input wire 			hps_uart2_RTS,

//(* chip_pin = "AA4" *)	inout wire			fpga_uart_de,
//(* chip_pin = "AB4" *)	inout wire			fpga_uart_rx,
//(* chip_pin = "U10" *)	inout wire			fpga_uart_tx,
//(* chip_pin = "V10" *)	inout wire			fpga_uart_re,
//
//(* chip_pin = "AC4" *)	inout wire			fpga_1pps,
//
//(* chip_pin = "AC24" *)	inout wire			fpga_spi_clk,
//(* chip_pin = "AB23" *)	inout wire			fpga_spi_mosi,
//(* chip_pin = "Y16" *)	inout wire			fpga_spi_miso,
//(* chip_pin = "W15" *)	inout wire			fpga_spi_cs,
//(* chip_pin = "AA24" *)	inout wire			fpga_spi_iriq0,
//(* chip_pin = "AA23" *)	inout wire			fpga_spi_iriq1,
//
//(* chip_pin = "AF26" *)	inout wire			fpga_rf0,
//(* chip_pin = "AE26" *)	inout wire			fpga_rf1,
//(* chip_pin = "AA20" *)	inout wire			fpga_rf2,
//(* chip_pin = "Y19"  *)	inout wire			fpga_rf3,
//(* chip_pin = "AE25" *)	inout wire			fpga_rf4,
  /* HPS UART */

  /* HPS SD card*/

(* chip_pin = "E4" *)	inout  wire 		 hps_io_gpio_inst_GPIO00,	// GPIO0

  /* HPS USB */
(* chip_pin = "C10" *)	inout  wire        hps_usb1_D0,        //(1)USB DATA 0
(* chip_pin = "F5" *)	inout  wire        hps_usb1_D1,        //(2)USB DATA 1
(* chip_pin = "C9" *)	inout  wire        hps_usb1_D2,        //(3)USB DATA 2
(* chip_pin = "C4" *)	inout  wire        hps_usb1_D3,        //(4)USB DATA 3
(* chip_pin = "C8" *)	inout  wire        hps_usb1_D4,        //(5)USB DATA 4
(* chip_pin = "D4" *)	inout  wire        hps_usb1_D5,        //(6)USB DATA 5
(* chip_pin = "C7" *)	inout  wire        hps_usb1_D6,        //(7)USB DATA 6
(* chip_pin = "F4" *)	inout  wire        hps_usb1_D7,        //(8)USB DATA 7
(* chip_pin = "C6" *)	inout  wire        hps_usb1_RST,       //(9)USB RST 
(* chip_pin = "G4" *)	input  wire        hps_usb1_CLK,       //(10)USB CLK
(* chip_pin = "C5" *)	output  wire        hps_usb1_STP,       //(11)USB STP
(* chip_pin = "E5" *)	input  wire        hps_usb1_DIR,       //(12)USB DIR
(* chip_pin = "D5" *)	input  wire        hps_usb1_NXT,       //(13)USB NXT

//(* chip_pin = "J15" *)	inout  wire 		 hps_io_gpio_inst_GPIO14,	// GPIO14

//(* chip_pin = "A16" *)	inout  wire 		 hps_io_gpio_inst_GPIO15,	// GPIO15
//(* chip_pin = "J14" *)	inout  wire 		 hps_io_gpio_inst_GPIO16,	// GPIO16
//(* chip_pin = "A15" *)	inout  wire 		 hps_io_gpio_inst_GPIO17,	// GPIO17
//(* chip_pin = "D17" *)	inout  wire 		 hps_io_gpio_inst_GPIO18,	// GPIO18
//(* chip_pin = "A14" *)	inout  wire 		 hps_io_gpio_inst_GPIO19,	// GPIO19
//(* chip_pin = "E16" *)	inout  wire 		 hps_io_gpio_inst_GPIO20,	// GPIO20
//(* chip_pin = "A13" *)	inout  wire 		 hps_io_gpio_inst_GPIO21,	// GPIO21
//(* chip_pin = "J13" *)	inout  wire 		 hps_io_gpio_inst_GPIO22,	// GPIO22
//(* chip_pin = "A12" *)	inout  wire 		 hps_io_gpio_inst_GPIO23,	// GPIO23
//(* chip_pin = "J12" *)	inout  wire 		 hps_io_gpio_inst_GPIO24,	// GPIO24
//(* chip_pin = "A11" *)	inout  wire 		 hps_io_gpio_inst_GPIO25,	// GPIO25
//(* chip_pin = "C15" *)	inout  wire 		 hps_io_gpio_inst_GPIO26,	// GPIO26
//(* chip_pin = "A9" *) 	inout  wire 		 hps_io_gpio_inst_GPIO27	// GPIO27

(* chip_pin = "J15" *)		output  wire 		 hps_io_hps_io_nand_inst_ALE,	// GPIO14	
(* chip_pin = "A16" *)		output  wire 		 hps_io_hps_io_nand_inst_CE,	// GPIO15	
(* chip_pin = "J14" *)		output  wire 		 hps_io_hps_io_nand_inst_CLE,	// GPIO16	
(* chip_pin = "A15" *)		output  wire 		 hps_io_hps_io_nand_inst_RE,	// GPIO17	
(* chip_pin = "D17" *)		inout  wire 		 hps_io_hps_io_nand_inst_RB,	// GPIO18	
(* chip_pin = "A14" *)		inout  wire 		 hps_io_hps_io_nand_inst_DQ0,	// GPIO19	
(* chip_pin = "E16" *)		inout  wire 		 hps_io_hps_io_nand_inst_DQ1,	// GPIO20	
(* chip_pin = "A13" *)		inout  wire 		 hps_io_hps_io_nand_inst_DQ2,	// GPIO21	
(* chip_pin = "J13" *)		inout  wire 		 hps_io_hps_io_nand_inst_DQ3,	// GPIO22	
(* chip_pin = "A12" *)		inout  wire 		 hps_io_hps_io_nand_inst_DQ4,	// GPIO23	
(* chip_pin = "J12" *)		inout  wire 		 hps_io_hps_io_nand_inst_DQ5,	// GPIO24	
(* chip_pin = "A11" *)		inout  wire 		 hps_io_hps_io_nand_inst_DQ6,	// GPIO25	
(* chip_pin = "C15" *)		inout  wire 		 hps_io_hps_io_nand_inst_DQ7,	// GPIO26	
(* chip_pin = "A9" *)		output  wire 		 hps_io_hps_io_nand_inst_WP,	// GPIO27	
(* chip_pin = "D15" *)		output  wire 		 hps_io_hps_io_nand_inst_WE,	// GPIO28

//(* chip_pin = "D15" *)	inout  wire 		 hps_bootsel2,						// GPIO28

(* chip_pin = "A8" *)		inout  wire 		 hps_io_hps_io_qspi_inst_IO0,	// GPIO29	
(* chip_pin = "H16" *)		inout  wire 		 hps_io_hps_io_qspi_inst_IO1,	// GPIO30
(* chip_pin = "A7" *)		inout  wire 		 hps_io_hps_io_qspi_inst_IO2,	// GPIO31
(* chip_pin = "J16" *)		inout  wire 		 hps_io_hps_io_qspi_inst_IO3,	// GPIO32
(* chip_pin = "A6" *)		output  wire 		 hps_io_hps_io_qspi_inst_SS0,	// GPIO33
(* chip_pin = "C14" *)		output  wire 		 hps_io_hps_io_qspi_inst_CLK,	// GPIO34


//(* chip_pin = "A8" *)		inout  wire 		 hps_io_gpio_inst_GPIO29,	// GPIO29 QSPI IO0
//(* chip_pin = "H16" *)	inout  wire 		 hps_io_gpio_inst_GPIO30,	// GPIO30 QSPI IO1
//(* chip_pin = "A7" *)		inout  wire 		 hps_io_gpio_inst_GPIO31,	// GPIO31 QSPI IO2
//(* chip_pin = "J16" *)	inout  wire 		 hps_io_gpio_inst_GPIO32,	// GPIO32 QSPI IO3
	
//(* chip_pin = "A6" *)		inout  wire 		 hps_io_gpio_inst_GPIO33,	// GPIO33 QSPI SS0 flash_DC

//(* chip_pin = "C14" *)	inout  wire 		 hps_io_gpio_inst_GPIO34,	// GPIO34 QSPI CLK
//(* chip_pin = "B14" *)	inout  wire 		 hps_io_gpio_inst_GPIO35,	// GPIO35 QSPI SS1

(* chip_pin = "D14" *)	inout  wire        hps_sdio_CMD, 	// (36)eMMC CMD      

(* chip_pin = "A5" *)	inout  wire        hps_io_gpio_inst_GPIO37,	// GPIO37

(* chip_pin = "C13" *)	inout  wire        hps_sdio_D0,     // (38)eMMC D0
(* chip_pin = "B6" *)	inout  wire        hps_sdio_D1,     // (39)eMMC D1
(* chip_pin = "H13" *)	inout  wire 		 hps_sdio_D4,		// (40)eMMC D4
(* chip_pin = "A4" *)	inout  wire 		 hps_sdio_D5,		// (41)eMMC D5
(* chip_pin = "H12" *)	inout  wire 		 hps_sdio_D6,		// (42)eMMC D6
(* chip_pin = "B4" *)	inout  wire 		 hps_sdio_D7,		// (43)eMMC D7

(* chip_pin = "B12" *)	inout  wire 		 hps_io_gpio_inst_GPIO44,		// GPIO44

(* chip_pin = "B8" *)	output wire        hps_sdio_CLK,    // (45)eMMC CLK   
(* chip_pin = "B11" *)	inout  wire        hps_sdio_D2,     // (46)eMMC D2   
(* chip_pin = "B9" *)	inout  wire        hps_sdio_D3,     // (47)eMMC D3

(* chip_pin = "C21" *)	inout  wire 		 hps_io_gpio_inst_GPIO48,		// GPIO48

(* chip_pin = "A22" *)	input  wire        hps_uart0_RX,			// GPIO49       
(* chip_pin = "B21" *)	output wire        hps_uart0_TX,       // GPIO50

(* chip_pin = "A21" *)	inout  wire 		 hps_io_gpio_inst_GPIO51,		// GPIO51

(* chip_pin = "k18" *)	inout  wire 		 hps_rtc_RST,			// GPIO52
(* chip_pin = "A20" *)	inout  wire 		 hps_rtc_CLK,			// GPIO53
(* chip_pin = "J18" *)	inout  wire 		 hps_rtc_INT,			// GPIO54
(* chip_pin = "A19" *)	inout  wire 		 hps_rtc_SDA,			// GPIO55
(* chip_pin = "C18" *)	inout  wire 		 hps_rtc_SCL,			// GPIO56
  /* HPS I2C */
(* chip_pin = "A18" *)	inout  wire        hps_i2c1_SDA,       // GPIO57
(* chip_pin = "C17" *)	inout  wire        hps_i2c1_SCL,       // GPIO58

(* chip_pin = "B18" *)	input  wire        hps_uart1_CTS,      // GPIO59 
(* chip_pin = "J17" *)	output wire        hps_uart1_RTS,      // GPIO60 
(* chip_pin = "A17" *)	inout  wire        hps_io_gpio_inst_GPIO61,    // GPIO61
//(* chip_pin = "H17" *)	inout  wire        hps_clocksel1, 		// GPIO62       
(* chip_pin = "C19" *)	input  wire        hps_uart1_RX,       // GPIO63
(* chip_pin = "B16" *)	output wire        hps_uart1_TX,      	// GPIO64
(* chip_pin = "B19" *)	inout  wire        hps_io_gpio_inst_GPIO65    // GPIO65
//(* chip_pin = "C16" *)	inout  wire        hps_clocksel0, 		//GPIO66      

  /* HPS CAN */

  /* HPS LED */
);

logic fpga_spi_cs_out, fpga_spi_cs_oe;
assign fpga_spi_cs = fpga_spi_cs_oe ? 1'bz : fpga_spi_cs_out;

//==============================================================================================================
localparam int CNTRL_ADDR_WIDTH = 6; /* Coordinate with HPS! */
//==============================================================================================================
logic pll_cntrl_rstn;
logic [5:0]	pll_cntrl_adr;
logic [31:0] pll_cntrl_wdata;
logic pll_cntrl_rdena;
logic [31:0] pll_cntrl_rdata;
logic pll_cntrl_wrq;
logic pll_cntrl_wrena;

logic tx_clkA_0, tx_clkA_1;
logic tx_clkA_0_phy, tx_clkA_1_phy;

logic [63:0] reconfig_to_pll, reconfig_from_pll;
logic eth_pll_locked;

eth_pll epll(
  .refclk(main_clock_25),
  .rst(~pll_cntrl_rstn),
  .outclk_0(tx_clkA_0),
  .outclk_1(tx_clkA_0_phy),
  .outclk_2(tx_clkA_1),
  .outclk_3(tx_clkA_1_phy),
  .outclk_4(),
  .outclk_5(),
  .locked(eth_pll_locked),
  .reconfig_to_pll(reconfig_to_pll),
  .reconfig_from_pll(reconfig_from_pll)
);

eth_pll_reconf epll_recf(
  .mgmt_clk(main_clock_25),
  .mgmt_reset(~pll_cntrl_rstn),
  .mgmt_waitrequest(pll_cntrl_wrq),
  .mgmt_read(pll_cntrl_rdena),
  .mgmt_write(pll_cntrl_wrena),
  .mgmt_readdata(pll_cntrl_rdata),
  .mgmt_address(pll_cntrl_adr),
  .mgmt_writedata(pll_cntrl_wdata),
  .reconfig_to_pll(reconfig_to_pll),
  .reconfig_from_pll(reconfig_from_pll)
);

logic tx_clkC_0, tx_clkC_1;
logic tx_clkC_0_phy, tx_clkC_1_phy;

logic [63:0] reconfig1_to_pll, reconfig1_from_pll;
logic eth1_pll_locked;

eth_pll epll1(
  .refclk(main_clock_25),
  .rst(~pll_cntrl_rstn),
  .outclk_0(tx_clkC_0),
  .outclk_1(tx_clkC_0_phy),
  .outclk_2(tx_clkC_1),
  .outclk_3(tx_clkC_1_phy),
  .outclk_4(),
  .outclk_5(),
  .locked(eth1_pll_locked),
  .reconfig_to_pll(reconfig1_to_pll),
  .reconfig_from_pll(reconfig1_from_pll)
);

logic pll_cntrl_1_rstn;
logic [5:0]	pll_cntrl_1_adr;
logic [31:0] pll_cntrl_1_wdata;
logic pll_cntrl_1_rdena;
logic [31:0] pll_cntrl_1_rdata;
logic pll_cntrl_1_wrq;
logic pll_cntrl_1_wrena;

eth_pll_reconf epll_recf1(
  .mgmt_clk(main_clock_25),
  .mgmt_reset(~pll_cntrl_1_rstn),
  .mgmt_waitrequest(pll_cntrl_1_wrq),
  .mgmt_read(pll_cntrl_1_rdena),
  .mgmt_write(pll_cntrl_1_wrena),
  .mgmt_readdata(pll_cntrl_1_rdata),
  .mgmt_address(pll_cntrl_1_adr),
  .mgmt_writedata(pll_cntrl_1_wdata),
  .reconfig_to_pll(reconfig1_to_pll),
  .reconfig_from_pll(reconfig1_from_pll)
);

//logic pll_cntrl_2_rstn;
//logic [5:0]	pll_cntrl_2_adr;
//logic [31:0] pll_cntrl_2_wdata;
//logic pll_cntrl_2_rdena;
//logic [31:0] pll_cntrl_2_rdata;
//logic pll_cntrl_2_wrq;
//logic pll_cntrl_2_wrena;
//
//eth_pll_reconf epll_recf2(
//  .mgmt_clk(main_clock_25),
//  .mgmt_reset(~pll_cntrl_2_rstn),
//  .mgmt_waitrequest(pll_cntrl_2_wrq),
//  .mgmt_read(pll_cntrl_2_rdena),
//  .mgmt_write(pll_cntrl_2_wrena),
//  .mgmt_readdata(pll_cntrl_2_rdata),
//  .mgmt_address(pll_cntrl_2_adr),
//  .mgmt_writedata(pll_cntrl_2_wdata),
//  .reconfig_to_pll(reconfig2_to_pll),
//  .reconfig_from_pll(reconfig2_from_pll)
//);
//==============================================================================================================

logic pll_lock;
logic main_clock_25;
logic main_clock_125;

 wire [7:0]hps_emac1_phy_txd_o;
 wire hps_emac1_phy_txen_o;
 wire hps_emac1_phy_txer_o;
 wire hps_emac1_phy_rxdv_i;
 wire hps_emac1_phy_rxer_i;
 wire [7:0]hps_emac1_phy_rxd_i;
 wire hps_emac1_phy_col_i;
 wire hps_emac1_phy_crs_i;
 wire hps_emac1_gmii_mdo_o;
 wire hps_emac1_gmii_mdo_o_e;
 wire hps_emac1_ptp_pps_o;
 wire hps_emac1_ptp_aux_ts_trig_i = 1'b0;
 
 wire [7:0]hps_emac0_phy_txd_o;
 wire hps_emac0_phy_txen_o;
 wire hps_emac0_phy_txer_o;
 wire hps_emac0_phy_rxdv_i;
 wire hps_emac0_phy_rxer_i;
 wire [7:0]hps_emac0_phy_rxd_i;
 wire hps_emac0_phy_col_i;
 wire hps_emac0_phy_crs_i;
 
 wire hps_emac0_gmii_mdo_o;
 wire hps_emac0_gmii_mdo_o_e;
 wire hps_emac0_ptp_pps_o;
 wire hps_emac0_ptp_aux_ts_trig_i = 1'b0;

 wire	[1:0]	gmii0_phy_mac_speed_o;
 wire gmii0_phy_tx_clk_o;
 wire gmii1_phy_tx_clk_o;
// wire gmii0_phy_tx_clk_i;
// wire gmii0_phy_rx_clk_i;
wire hps_emac0_rx_reset_reset_n;
wire hps_emac1_rx_reset_reset_n;

 wire	[1:0]	gmii1_phy_mac_speed_o;
 //wire gmii1_phy_tx_clk_o;
// wire gmii1_phy_tx_clk_i;
// wire gmii1_phy_rx_clk_i;
 tse_devboard_hps hps (
  //.clk_100_clk                    (CLK_100),
  .pll_0_locked_export            (pll_lock), // HPS->FPGA
  .clock_25m_clk                  (main_clock_25),
  .main_clk_clk                   (main_clock_125),

  .hps_0_f2h_cold_reset_req_reset_n  (~hps_cold_reset_n),
  .hps_0_f2h_debug_reset_req_reset_n (~hps_debug_reset_n),
  .hps_0_f2h_warm_reset_req_reset_n  (~hps_warm_reset_n),

  .memory_mem_a                         (hps_memory_mem_a),                               
  .memory_mem_ba                        (hps_memory_mem_ba),                         
  .memory_mem_ck                        (hps_memory_mem_ck),                         
  .memory_mem_ck_n                      (hps_memory_mem_ck_n),                       
//  .memory_mem_cke0                       (hps_memory_mem_cke0),                        
//  .memory_mem_cke1                       (hps_memory_mem_cke1),                        
  .memory_mem_cke                       (hps_memory_mem_cke),                        
//  .memory_mem_cs0_n                      (hps_memory_mem_cs0_n),                       
//  .memory_mem_cs1_n                      (hps_memory_mem_cs1_n),                       
  .memory_mem_cs_n                      (hps_memory_mem_cs_n),                       
  .memory_mem_ras_n                     (hps_memory_mem_ras_n),                      
  .memory_mem_cas_n                     (hps_memory_mem_cas_n),                      
  .memory_mem_we_n                      (hps_memory_mem_we_n),                       
  .memory_mem_reset_n                   (hps_memory_mem_reset_n),                    
  .memory_mem_dq                        (hps_memory_mem_dq),                         
  .memory_mem_dqs                       (hps_memory_mem_dqs_p),                        
  .memory_mem_dqs_n                     (hps_memory_mem_dqs_n),                      
  .memory_mem_odt                       (hps_memory_mem_odt),                        
  .memory_mem_dm                        (hps_memory_mem_dm),                         
  .memory_oct_rzqin                     (hps_memory_oct_rzqin),                      

  
			.hps_io_hps_io_gpio_inst_GPIO00     (hps_io_gpio_inst_GPIO00),

			.hps_io_hps_io_usb1_inst_D0     (hps_usb1_D0),      
			.hps_io_hps_io_usb1_inst_D1     (hps_usb1_D1),      
			.hps_io_hps_io_usb1_inst_D2     (hps_usb1_D2),      
			.hps_io_hps_io_usb1_inst_D3     (hps_usb1_D3),      
			.hps_io_hps_io_usb1_inst_D4     (hps_usb1_D4),      
			.hps_io_hps_io_usb1_inst_D5     (hps_usb1_D5),      
			.hps_io_hps_io_usb1_inst_D6     (hps_usb1_D6),      
			.hps_io_hps_io_usb1_inst_D7     (hps_usb1_D7),      
  
			.hps_io_hps_io_gpio_inst_GPIO09 (hps_usb1_RST),
  
			.hps_io_hps_io_usb1_inst_CLK    (hps_usb1_CLK),     
			.hps_io_hps_io_usb1_inst_STP    (hps_usb1_STP),     
			.hps_io_hps_io_usb1_inst_DIR    (hps_usb1_DIR),     
			.hps_io_hps_io_usb1_inst_NXT    (hps_usb1_NXT),     

  
			.hps_io_hps_io_nand_inst_ALE		(hps_io_hps_io_nand_inst_ALE),// GPIO14
			.hps_io_hps_io_nand_inst_CE		(hps_io_hps_io_nand_inst_CE),	// GPIO15
			.hps_io_hps_io_nand_inst_CLE		(hps_io_hps_io_nand_inst_CLE),// GPIO16
			.hps_io_hps_io_nand_inst_RE		(hps_io_hps_io_nand_inst_RE),	// GPIO17
			.hps_io_hps_io_nand_inst_RB		(hps_io_hps_io_nand_inst_RB),	// GPIO18
			.hps_io_hps_io_nand_inst_DQ0		(hps_io_hps_io_nand_inst_DQ0),// GPIO19
			.hps_io_hps_io_nand_inst_DQ1		(hps_io_hps_io_nand_inst_DQ1),// GPIO20
			.hps_io_hps_io_nand_inst_DQ2		(hps_io_hps_io_nand_inst_DQ2),// GPIO21
			.hps_io_hps_io_nand_inst_DQ3		(hps_io_hps_io_nand_inst_DQ3),// GPIO22
			.hps_io_hps_io_nand_inst_DQ4		(hps_io_hps_io_nand_inst_DQ4),// GPIO23
			.hps_io_hps_io_nand_inst_DQ5		(hps_io_hps_io_nand_inst_DQ5),// GPIO24
			.hps_io_hps_io_nand_inst_DQ6		(hps_io_hps_io_nand_inst_DQ6),// GPIO25
			.hps_io_hps_io_nand_inst_DQ7		(hps_io_hps_io_nand_inst_DQ7),// GPIO26
			.hps_io_hps_io_nand_inst_WP		(hps_io_hps_io_nand_inst_WP),	// GPIO27
			.hps_io_hps_io_nand_inst_WE		(hps_io_hps_io_nand_inst_WE),	// GPIO28

			//.hps_io_hps_io_gpio_inst_GPIO28     (/*hps_bootsel2*/),
			
			.hps_io_hps_io_qspi_inst_IO0		(hps_io_hps_io_qspi_inst_IO0),// GPIO29	
			.hps_io_hps_io_qspi_inst_IO1		(hps_io_hps_io_qspi_inst_IO1),// GPIO30
			.hps_io_hps_io_qspi_inst_IO2		(hps_io_hps_io_qspi_inst_IO2),// GPIO31
			.hps_io_hps_io_qspi_inst_IO3		(hps_io_hps_io_qspi_inst_IO3),// GPIO32
			.hps_io_hps_io_qspi_inst_SS0		(hps_io_hps_io_qspi_inst_SS0),// GPIO33
			.hps_io_hps_io_qspi_inst_CLK		(hps_io_hps_io_qspi_inst_CLK),// GPIO34
	
			.hps_io_hps_io_sdio_inst_CMD    	(hps_sdio_CMD),     // GPIO36
			.hps_io_hps_io_gpio_inst_GPIO37 	(hps_io_gpio_inst_GPIO37), // hps_io_gpio_inst_GPIO37
			.hps_io_hps_io_sdio_inst_D0     	(hps_sdio_D0),      // GPIO38
			.hps_io_hps_io_sdio_inst_D1     	(hps_sdio_D1),      // GPIO39
			.hps_io_hps_io_sdio_inst_CLK    	(hps_sdio_CLK),	  // GPIO45     
			.hps_io_hps_io_sdio_inst_D2     	(hps_sdio_D2),      // GPIO46
			.hps_io_hps_io_sdio_inst_D3     	(hps_sdio_D3),      // GPIO47
			.hps_io_hps_io_sdio_inst_D4     	(hps_sdio_D4),      // GPIO40
			.hps_io_hps_io_sdio_inst_D5     	(hps_sdio_D5),      // GPIO41
			.hps_io_hps_io_sdio_inst_D6     	(hps_sdio_D6),      // GPIO42
			.hps_io_hps_io_sdio_inst_D7     	(hps_sdio_D7),      // GPIO43
			
			.hps_io_hps_io_gpio_inst_GPIO44    (hps_io_gpio_inst_GPIO44), // hps_io_gpio_inst_GPIO44
			
			.hps_io_hps_io_uart0_inst_RX    	  (hps_uart0_RX),				  // GPIO49
			.hps_io_hps_io_uart0_inst_TX    	  (hps_uart0_TX),     		  // GPIO50

			.hps_io_hps_io_gpio_inst_GPIO48    (hps_io_gpio_inst_GPIO48), // hps_io_gpio_inst_GPIO48
			.hps_io_hps_io_gpio_inst_GPIO51    (hps_io_gpio_inst_GPIO51), // hps_io_gpio_inst_GPIO51
			.hps_io_hps_io_gpio_inst_GPIO52    (hps_rtc_RST),				  // hps_io_gpio_inst_GPIO52
			.hps_io_hps_io_gpio_inst_GPIO53    (hps_rtc_CLK), 			  	  // hps_io_gpio_inst_GPIO53
			.hps_io_hps_io_gpio_inst_GPIO54    (hps_rtc_INT), 				  // hps_io_gpio_inst_GPIO54
			.hps_io_hps_io_i2c0_inst_SDA    	  (hps_rtc_SDA),				  // GPIO55     
			.hps_io_hps_io_i2c0_inst_SCL    	  (hps_rtc_SCL),				  // GPIO56     
			.hps_io_hps_io_i2c1_inst_SDA    	  (hps_i2c1_SDA),				  // GPIO57    
			.hps_io_hps_io_i2c1_inst_SCL    	  (hps_i2c1_SCL),				  // GPIO58     
			
			.hps_io_hps_io_uart1_inst_CTS    	(hps_uart1_CTS),    		  // GPIO59 
			.hps_io_hps_io_uart1_inst_RTS	   	(hps_uart1_RTS),    		  // GPIO60 
  
			.hps_io_hps_io_gpio_inst_GPIO61    	(hps_io_gpio_inst_GPIO61), // hps_io_gpio_inst_GPIO61
//			.hps_io_hps_io_gpio_inst_GPIO62    	(hps_clocksel1), 			  // hps_io_gpio_inst_GPIO62
			.hps_io_hps_io_uart1_inst_RX    	  	(hps_uart1_RX),     		  // GPIO63
			.hps_io_hps_io_uart1_inst_TX       	(hps_uart1_TX),       	  // GPIO64
			.hps_io_hps_io_gpio_inst_GPIO65    	(hps_io_gpio_inst_GPIO65), // hps_io_gpio_inst_GPIO65
//			.hps_io_hps_io_gpio_inst_GPIO66    	(hps_clocksel2), 			  // hps_io_gpio_inst_GPIO66

			.hps_spim0_txd								(fpga_spi_mosi),					// fpga
			.hps_spim0_rxd								(fpga_spi_miso),					// fpga
			.hps_spim0_ss_in_n						(fpga_spi_cs),						// fpga
			.hps_spim0_ssi_oe_n						(fpga_spi_cs_oe),					// fpga
			.hps_spim0_ss_0_n							(fpga_spi_cs_out),				// fpga
			.hps_spim0_ss_1_n							(),
			.hps_spim0_ss_2_n							(),				
			.hps_spim0_ss_3_n							(),
			.hps_spim0_sclk_out_clk					(fpga_spi_clk),					// fpga
	
			//.hps_can0_rxd(),
			//.hps_can0_txd(),
			.uart_0_external_connection_rxd		(hps_uart2_RX),
			.uart_0_external_connection_txd		(hps_uart2_TX),
			.uart_0_external_connection_cts_n	(hps_uart2_CTS),
			.uart_0_external_connection_rts_n	(hps_uart2_RTS),

//			.hps_qspi_mi0(hps_qspi_mi0),
//			.hps_qspi_mi1(hps_qspi_mi0),
//			.hps_qspi_mi2(hps_qspi_mi0),
//			.hps_qspi_mi3(hps_qspi_mi0),
//			.hps_qspi_mo0(hps_qspi_mo0),
//			.hps_qspi_mo1(hps_qspi_mo0),
//			.hps_qspi_mo2_wpn(hps_qspi_mo0),
//			.hps_qspi_mo3_hold(hps_qspi_mo0),
//			.hps_qspi_n_mo_en(hps_qspi_n_mo_en),	//4
//			.hps_qspi_n_ss_out(hps_qspi_n_mo_en),//4
			
  /* PLL control signals */
  .pll_cntrl_clk                  (),
  .pll_cntrl_rstn                 (pll_cntrl_rstn),
  .pll_cntrl_adr                  (pll_cntrl_adr),
  .pll_cntrl_wdata                (pll_cntrl_wdata),
  .pll_cntrl_rdena                (pll_cntrl_rdena),
  .pll_cntrl_rdata                (pll_cntrl_rdata),
  .pll_cntrl_wrq                  (pll_cntrl_wrq),
  .pll_cntrl_wrena                (pll_cntrl_wrena),

  .pll_cntrl_1_clk                  (),
  .pll_cntrl_1_rstn                 (pll_cntrl_1_rstn),
  .pll_cntrl_1_adr                  (pll_cntrl_1_adr),
  .pll_cntrl_1_wdata                (pll_cntrl_1_wdata),
  .pll_cntrl_1_rdena                (pll_cntrl_1_rdena),
  .pll_cntrl_1_rdata                (pll_cntrl_1_rdata),
  .pll_cntrl_1_wrq                  (pll_cntrl_1_wrq),
  .pll_cntrl_1_wrena                (pll_cntrl_1_wrena),

//  .pll_cntrl_2_clk                  (),
//  .pll_cntrl_2_rstn                 (pll_cntrl_2_rstn),
//  .pll_cntrl_2_adr                  (pll_cntrl_2_adr),
//  .pll_cntrl_2_wdata                (pll_cntrl_2_wdata),
//  .pll_cntrl_2_rdena                (pll_cntrl_2_rdena),
//  .pll_cntrl_2_rdata                (pll_cntrl_2_rdata),
//  .pll_cntrl_2_wrq                  (pll_cntrl_2_wrq),
//  .pll_cntrl_2_wrena                (pll_cntrl_2_wrena),


	.hps_emac1_phy_txd_o			(hps_emac1_phy_txd_o),
	.hps_emac1_phy_txen_o		(hps_emac1_phy_txen_o),
	.hps_emac1_phy_txer_o		(hps_emac1_phy_txer_o),
	.hps_emac1_phy_rxdv_i		(hps_emac1_phy_rxdv_i),
	.hps_emac1_phy_rxer_i		(hps_emac1_phy_rxer_i),
	.hps_emac1_phy_rxd_i			(hps_emac1_phy_rxd_i),
	.hps_emac1_phy_col_i			(hps_emac1_phy_col_i),
	.hps_emac1_phy_crs_i			(hps_emac1_phy_crs_i),
	.hps_emac1_gmii_mdo_o		(hps_emac1_gmii_mdo_o),
	.hps_emac1_gmii_mdo_o_e		(hps_emac1_gmii_mdo_o_e),
	.hps_emac1_gmii_mdi_i		(hps_emac1_gmii_mdo_o_e?hps_emac1_gmii_mdo_o:1'b1),
	.hps_emac1_ptp_pps_o			(hps_emac1_ptp_pps_o),
	.hps_emac1_ptp_aux_ts_trig_i(hps_emac1_ptp_aux_ts_trig_i),
	
	.hps_emac1_gtx_clk_clk		(gmii1_phy_rx_clk_o),
	.hps_emac1_rx_reset_reset_n(hps_emac1_rx_reset_reset_n),
	.hps_emac1_md_clk_clk		(),

	
 	.hps_emac0_phy_txd_o		(hps_emac0_phy_txd_o),
	.hps_emac0_phy_txen_o	(hps_emac0_phy_txen_o),
	.hps_emac0_phy_txer_o	(hps_emac0_phy_txer_o),
	.hps_emac0_phy_rxdv_i	(hps_emac0_phy_rxdv_i),
	.hps_emac0_phy_rxer_i	(hps_emac0_phy_rxer_i),
	.hps_emac0_phy_rxd_i		(hps_emac0_phy_rxd_i),
	.hps_emac0_phy_col_i		(hps_emac0_phy_col_i),
	.hps_emac0_phy_crs_i		(hps_emac0_phy_crs_i),
	.hps_emac0_gmii_mdo_o	(hps_emac0_gmii_mdo_o),
	.hps_emac0_gmii_mdo_o_e	(hps_emac0_gmii_mdo_o_e),
	.hps_emac0_gmii_mdi_i	(hps_emac0_gmii_mdo_o_e?hps_emac0_gmii_mdo_o:1'b1),
	.hps_emac0_ptp_pps_o		(hps_emac0_ptp_pps_o),
	.hps_emac0_ptp_aux_ts_trig_i(hps_emac0_ptp_aux_ts_trig_i),

	.hps_emac0_gtx_clk_clk		(gmii0_phy_rx_clk_o),
	.hps_emac0_rx_reset_reset_n(hps_emac0_rx_reset_reset_n),
	.hps_emac0_md_clk_clk		(),
	
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_tx_clk_o(gmii1_phy_tx_clk_o),
	.gmii_to_rgmii_adapter_1_hps_gmii_rst_tx_n	(hps_emac1_rx_reset_reset_n),
	.gmii_to_rgmii_adapter_1_hps_gmii_rst_rx_n	(hps_emac1_rx_reset_reset_n),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_txd_o	(hps_emac1_phy_txd_o),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_txen_o	(hps_emac1_phy_txen_o),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_txer_o	(hps_emac1_phy_txer_o),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_mac_speed_o(gmii1_phy_mac_speed_o),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_tx_clk_i(gmii1_phy_tx_clk_o),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_rx_clk_i(gmii1_phy_rx_clk_o),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_rxdv_i	(hps_emac1_phy_rxdv_i),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_rxer_i	(hps_emac1_phy_rxer_i),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_rxd_i	(hps_emac1_phy_rxd_i),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_col_i	(hps_emac1_phy_col_i),
	.gmii_to_rgmii_adapter_1_hps_gmii_phy_crs_i	(hps_emac1_phy_crs_i),

	.gmii_to_rgmii_adapter_1_phy_rgmii_rgmii_rx_clk	(fpga_enet1_rx_clk),
	.gmii_to_rgmii_adapter_1_phy_rgmii_rgmii_rxd		(fpga_enet1_rx_d),
	.gmii_to_rgmii_adapter_1_phy_rgmii_rgmii_rx_ctl	(fpga_enet1_rx_dv),
	.gmii_to_rgmii_adapter_1_phy_rgmii_rgmii_tx_clk	(fpga_enet1_tx_clk),
	.gmii_to_rgmii_adapter_1_phy_rgmii_rgmii_txd		(fpga_enet1_tx_d),
	.gmii_to_rgmii_adapter_1_phy_rgmii_rgmii_tx_ctl	(fpga_enet1_tx_en),

	.gmii_to_rgmii_adapter_0_hps_gmii_phy_tx_clk_o(gmii0_phy_tx_clk_o),
	.gmii_to_rgmii_adapter_0_hps_gmii_rst_tx_n	(hps_emac0_rx_reset_reset_n),
	.gmii_to_rgmii_adapter_0_hps_gmii_rst_rx_n	(hps_emac0_rx_reset_reset_n),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_txd_o	(hps_emac0_phy_txd_o),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_txen_o	(hps_emac0_phy_txen_o),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_txer_o	(hps_emac0_phy_txer_o),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_mac_speed_o(gmii0_phy_mac_speed_o),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_tx_clk_i(gmii0_phy_tx_clk_o),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_rx_clk_i(gmii0_phy_rx_clk_o),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_rxdv_i	(hps_emac0_phy_rxdv_i),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_rxer_i	(hps_emac0_phy_rxer_i),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_rxd_i	(hps_emac0_phy_rxd_i),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_col_i	(hps_emac0_phy_col_i),
	.gmii_to_rgmii_adapter_0_hps_gmii_phy_crs_i	(hps_emac0_phy_crs_i),	
	
	.gmii_to_rgmii_adapter_0_phy_rgmii_rgmii_rx_clk	(fpga_enet0_rx_clk),
	.gmii_to_rgmii_adapter_0_phy_rgmii_rgmii_rxd		(fpga_enet0_rx_d),
	.gmii_to_rgmii_adapter_0_phy_rgmii_rgmii_rx_ctl	(fpga_enet0_rx_dv),
	.gmii_to_rgmii_adapter_0_phy_rgmii_rgmii_tx_clk	(fpga_enet0_tx_clk),
	.gmii_to_rgmii_adapter_0_phy_rgmii_rgmii_txd		(fpga_enet0_tx_d),
	.gmii_to_rgmii_adapter_0_phy_rgmii_rgmii_tx_ctl	(fpga_enet0_tx_en),
	

  /* MDIO module */
  .mdio_module_cond_clk           (),
  .mdio_module_cond_rstn          (mdio_module_rstn),
  .mdio_module_cond_adr           (mdio_module_adr),
  .mdio_module_cond_wdata         (mdio_module_wdata),
  .mdio_module_cond_rdena         (mdio_module_rdena),
  .mdio_module_cond_rdata         (mdio_module_rdata),
  .mdio_module_cond_wrq           (mdio_module_wrq),
  .mdio_module_cond_wrena         (mdio_module_wrena),

 `ifdef USE6CH
 /* MDIO module */
  .mdio1_module_cond_clk           (),
  .mdio1_module_cond_rstn          (mdio1_module_rstn),
  .mdio1_module_cond_adr           (mdio1_module_adr),
  .mdio1_module_cond_wdata         (mdio1_module_wdata),
  .mdio1_module_cond_rdena         (mdio1_module_rdena),
  .mdio1_module_cond_rdata         (mdio1_module_rdata),
  .mdio1_module_cond_wrq           (mdio1_module_wrq),
  .mdio1_module_cond_wrena         (mdio1_module_wrena),
`endif	// USE6CH

  /* ETH0 */
  .arm_dma_addres                 (arm_dma_A_addres),
  .arm_dma_read                   (arm_dma_A_read),
  .arm_dma_write                  (arm_dma_A_write),
  .arm_dma_readdata               (arm_dma_A_readdata),
  .arm_dma_writedata              (arm_dma_A_writedata),
  .arm_dma_waitrequest            (arm_dma_A_waitrequest),
  .arm_dma_readdatavalid          (arm_dma_A_readdatavalid),
  .arm_dma_burstcount             (arm_dma_A_burstcount),

  .eth_cntrl_clk                  (),
  .eth_cntrl_rstn                 (eth_cntrl_A_rstn),
  .eth_cntrl_adr                  (eth_cntrl_A_adr),
  .eth_cntrl_wrena                (eth_cntrl_A_wrena),
  .eth_cntrl_wdata                (eth_cntrl_A_wdata),
  .eth_cntrl_rdena                (eth_cntrl_A_rdena),
  .eth_cntrl_rdata                (eth_cntrl_A_rdata),
  .eth_cntrl_irq                  (eth_cntrl_A_irq),
  .eth_cntrl_wrq                  (eth_cntrl_A_wrq),

  /* ETH1 */
  .arm_dma_1_addres               (arm_dma_B_addres),
  .arm_dma_1_read                 (arm_dma_B_read),
  .arm_dma_1_write                (arm_dma_B_write),
  .arm_dma_1_readdata             (arm_dma_B_readdata),
  .arm_dma_1_writedata            (arm_dma_B_writedata),
  .arm_dma_1_waitrequest          (arm_dma_B_waitrequest),
  .arm_dma_1_readdatavalid        (arm_dma_B_readdatavalid),
  .arm_dma_1_burstcount           (arm_dma_B_burstcount),

  .eth_cntrl_1_clk                (),
  .eth_cntrl_1_rstn               (eth_cntrl_B_rstn),
  .eth_cntrl_1_adr                (eth_cntrl_B_adr),
  .eth_cntrl_1_wrena              (eth_cntrl_B_wrena),
  .eth_cntrl_1_wdata              (eth_cntrl_B_wdata),
  .eth_cntrl_1_rdena              (eth_cntrl_B_rdena),
  .eth_cntrl_1_rdata              (eth_cntrl_B_rdata),
  .eth_cntrl_1_irq                (eth_cntrl_B_irq),
  .eth_cntrl_1_wrq                (eth_cntrl_B_wrq),

  /* ETH2 */
  .arm_dma_2_addres                 (arm_dma_C_addres),
  .arm_dma_2_read                   (arm_dma_C_read),
  .arm_dma_2_write                  (arm_dma_C_write),
  .arm_dma_2_readdata               (arm_dma_C_readdata),
  .arm_dma_2_writedata              (arm_dma_C_writedata),
  .arm_dma_2_waitrequest            (arm_dma_C_waitrequest),
  .arm_dma_2_readdatavalid          (arm_dma_C_readdatavalid),
  .arm_dma_2_burstcount             (arm_dma_C_burstcount),

  .eth_cntrl_2_clk                  (),
  .eth_cntrl_2_rstn                 (eth_cntrl_C_rstn),
  .eth_cntrl_2_adr                  (eth_cntrl_C_adr),
  .eth_cntrl_2_wrena                (eth_cntrl_C_wrena),
  .eth_cntrl_2_wdata                (eth_cntrl_C_wdata),
  .eth_cntrl_2_rdena                (eth_cntrl_C_rdena),
  .eth_cntrl_2_rdata                (eth_cntrl_C_rdata),
  .eth_cntrl_2_irq                  (eth_cntrl_C_irq),
  .eth_cntrl_2_wrq                  (eth_cntrl_C_wrq),

  /* ETH3 */
  .arm_dma_3_addres               (arm_dma_D_addres),
  .arm_dma_3_read                 (arm_dma_D_read),
  .arm_dma_3_write                (arm_dma_D_write),
  .arm_dma_3_readdata             (arm_dma_D_readdata),
  .arm_dma_3_writedata            (arm_dma_D_writedata),
  .arm_dma_3_waitrequest          (arm_dma_D_waitrequest),
  .arm_dma_3_readdatavalid        (arm_dma_D_readdatavalid),
  .arm_dma_3_burstcount           (arm_dma_D_burstcount),

  .eth_cntrl_3_clk                (),
  .eth_cntrl_3_rstn               (eth_cntrl_D_rstn),
  .eth_cntrl_3_adr                (eth_cntrl_D_adr),
  .eth_cntrl_3_wrena              (eth_cntrl_D_wrena),
  .eth_cntrl_3_wdata              (eth_cntrl_D_wdata),
  .eth_cntrl_3_rdena              (eth_cntrl_D_rdena),
  .eth_cntrl_3_rdata              (eth_cntrl_D_rdata),
  .eth_cntrl_3_irq                (eth_cntrl_D_irq),
  .eth_cntrl_3_wrq                (eth_cntrl_D_wrq)

`ifdef USE6CH
  
`endif	// USE6CH

  /* HPS GPIO */

  /* HPS CAN */
);

//==========================================================================================
/* MDIO MODULE */
logic           mdio_module_rstn;
logic [5 : 0]   mdio_module_adr;
logic [31 : 0]  mdio_module_wdata;
logic           mdio_module_rdena;
logic [31 : 0]  mdio_module_rdata;
logic           mdio_module_wrq;
logic           mdio_module_wrena;

mdio_module #(
  .N_PHY_PORTS(/*NUMBER_OF_PHY_PORTS*/1),
  .N_LOG_PORTS(/*NUMBER_OF_LOG_PORTS*/2)
) mdio (
  .clk(main_clock_125),
  .rst_n(mdio_module_rstn),
  .mdio_addr(mdio_module_adr),
  .mdio_rdata(mdio_module_rdata),
  .mdio_rd(mdio_module_rdena),
  .mdio_wr(mdio_module_wrena),
  .mdio_wdata(mdio_module_wdata),
  .mdio_wrq(mdio_module_wrq),
//  .eth_mdclk({eth_mdc_B0, eth_mdc_A0}),
//  .eth_mdio({eth_mdio_B0, eth_mdio_A0})
  .eth_mdclk(RGMII_0_1_MDIO0),
  .eth_mdio(RGMII_0_1_MDIO1)
);

`ifdef USE6CH
logic           mdio1_module_rstn;
logic [5 : 0]   mdio1_module_adr;
logic [31 : 0]  mdio1_module_wdata;
logic           mdio1_module_rdena;
logic [31 : 0]  mdio1_module_rdata;
logic           mdio1_module_wrq;
logic           mdio1_module_wrena;
mdio_module #(
  .N_PHY_PORTS(/*NUMBER_OF_PHY_PORTS*/1),
  .N_LOG_PORTS(/*NUMBER_OF_LOG_PORTS*/4)
) mdio25 (
  .clk(main_clock_125),
  .rst_n(mdio1_module_rstn),
  .mdio_addr(mdio1_module_adr),
  .mdio_rdata(mdio1_module_rdata),
  .mdio_rd(mdio1_module_rdena),
  .mdio_wr(mdio1_module_wrena),
  .mdio_wdata(mdio1_module_wdata),
  .mdio_wrq(mdio1_module_wrq),
  .eth_mdclk(/*RGMII_2_5_MDIO0*/),
  .eth_mdio(/*RGMII_2_5_MDIO1*/)
);
`endif	// USE6CH

//==============================================================================================================
interSw ethSw_A(main_clock_125, pll_lock & eth_cntrl_A_rstn);
interSw ethSw_B(main_clock_125, pll_lock & eth_cntrl_B_rstn);
interSw ethSw_C(main_clock_125, pll_lock & eth_cntrl_C_rstn);
interSw ethSw_D(main_clock_125, pll_lock & eth_cntrl_D_rstn);
//==============================================================================================================
/* ETHERNET MODULE 0 */
logic phy_reset_0;
//assign eth_rst_n_A0 = /*pwr_on_rst &*/ pll_lock & eth_pll_locked & ~phy_reset_0;

logic [31 : 0] arm_dma_A_addres;
logic arm_dma_A_read;
logic arm_dma_A_write;
logic [ARM_INTF_WIDTH - 1 : 0] arm_dma_A_readdata;
logic [ARM_INTF_WIDTH - 1 : 0] arm_dma_A_writedata;
logic arm_dma_A_waitrequest;
logic arm_dma_A_readdatavalid;
logic [BURST_CNT_WIDTH - 1 : 0]	arm_dma_A_burstcount;

logic eth_cntrl_A_rstn;
logic [CNTRL_ADDR_WIDTH - 1 : 0] eth_cntrl_A_adr;
logic eth_cntrl_A_wrena;
logic [31 : 0] eth_cntrl_A_wdata;
logic eth_cntrl_A_rdena;
logic [31 : 0] eth_cntrl_A_rdata;
logic eth_cntrl_A_irq;
logic eth_cntrl_A_wrq;


eth_ip_core eth0 (
  .tx_clkA(tx_clkA_0),
  .tx_phy_clkA(tx_clkA_0_phy),
  /* Ethernet port A external connection */
  .eth_rxclk_a(fpga_enet2_rx_clk),
  .eth_rxdv_a(fpga_enet2_rx_dv),
  .eth_rxd_a(fpga_enet2_rx_d),
  .eth_txclk_a(fpga_enet2_tx_clk),
  .eth_txdv_a(fpga_enet2_tx_en),
  .eth_txd_a(fpga_enet2_tx_d),

  .phy_reset(phy_reset_0),

  /* HPS DMA */
  .dma_addres(arm_dma_A_addres),
  .dma_read(arm_dma_A_read),
  .dma_write(arm_dma_A_write),
  .dma_readdata(arm_dma_A_readdata),
  .dma_writedata(arm_dma_A_writedata),
  .dma_waitrequest(arm_dma_A_waitrequest),
  .dma_readdatavalid(arm_dma_A_readdatavalid),
  .dma_burstcount(arm_dma_A_burstcount),
  /* HPS Control */
  .cntrl_adr(eth_cntrl_A_adr),
  .cntrl_wrena(eth_cntrl_A_wrena),
  .cntrl_wdata(eth_cntrl_A_wdata),
  .cntrl_rdena(eth_cntrl_A_rdena),
  .cntrl_rdata(eth_cntrl_A_rdata),
  .cntrl_irq(eth_cntrl_A_irq),
  .cntrl_wrq(eth_cntrl_A_wrq),

  .ethSw(ethSw_A)
);

//==============================================================================================================
/* ETHERNET MODULE 1 */
logic phy_reset_1;
//assign eth_rst_n_B0 = /*pwr_on_rst &*/ pll_lock & eth_pll_locked & ~phy_reset_1;/*internal*/

logic [31 : 0] arm_dma_B_addres;
logic arm_dma_B_read;
logic arm_dma_B_write;
logic [ARM_INTF_WIDTH - 1 : 0] arm_dma_B_readdata;
logic [ARM_INTF_WIDTH - 1 : 0] arm_dma_B_writedata;
logic arm_dma_B_waitrequest;
logic arm_dma_B_readdatavalid;
logic [BURST_CNT_WIDTH - 1 : 0]	arm_dma_B_burstcount;

logic eth_cntrl_B_rstn;
logic [CNTRL_ADDR_WIDTH - 1 : 0] eth_cntrl_B_adr;
logic eth_cntrl_B_wrena;
logic [31 : 0] eth_cntrl_B_wdata;
logic eth_cntrl_B_rdena;
logic [31 : 0] eth_cntrl_B_rdata;
logic eth_cntrl_B_irq;
logic eth_cntrl_B_wrq;


eth_ip_core eth1 (
  .tx_clkA(tx_clkA_1),
  .tx_phy_clkA(tx_clkA_1_phy),
  /* Ethernet port B external connection */
  .eth_rxclk_a(fpga_enet3_rx_clk),
  .eth_rxdv_a(fpga_enet3_rx_dv),
  .eth_rxd_a(fpga_enet3_rx_d),
  .eth_txclk_a(fpga_enet3_tx_clk),
  .eth_txdv_a(fpga_enet3_tx_en),
  .eth_txd_a(fpga_enet3_tx_d),

  .phy_reset(phy_reset_1),

  /* HPS DMA */
  .dma_addres(arm_dma_B_addres),
  .dma_read(arm_dma_B_read),
  .dma_write(arm_dma_B_write),
  .dma_readdata(arm_dma_B_readdata),
  .dma_writedata(arm_dma_B_writedata),
  .dma_waitrequest(arm_dma_B_waitrequest),
  .dma_readdatavalid(arm_dma_B_readdatavalid),
  .dma_burstcount(arm_dma_B_burstcount),
  /* HPS Control */
  .cntrl_adr(eth_cntrl_B_adr),
  .cntrl_wrena(eth_cntrl_B_wrena),
  .cntrl_wdata(eth_cntrl_B_wdata),
  .cntrl_rdena(eth_cntrl_B_rdena),
  .cntrl_rdata(eth_cntrl_B_rdata),
  .cntrl_irq(eth_cntrl_B_irq),
  .cntrl_wrq(eth_cntrl_B_wrq),

  .ethSw(ethSw_B)
);

assign RGMII_0_1_RESETn = /*pwr_on_rst &*/ pll_lock & eth_pll_locked & ~(phy_reset_1|phy_reset_0);/*internal*/

//==============================================================================================================
/* ETHERNET MODULE 2 */
logic phy_reset_2;
//assign eth_rst_n_C0 = /*pwr_on_rst &*/ pll_lock & eth_pll_locked & ~phy_reset_2;/*internal*/

logic [31 : 0] arm_dma_C_addres;
logic arm_dma_C_read;
logic arm_dma_C_write;
logic [ARM_INTF_WIDTH - 1 : 0] arm_dma_C_readdata;
logic [ARM_INTF_WIDTH - 1 : 0] arm_dma_C_writedata;
logic arm_dma_C_waitrequest;
logic arm_dma_C_readdatavalid;
logic [BURST_CNT_WIDTH - 1 : 0]	arm_dma_C_burstcount;

logic eth_cntrl_C_rstn;
logic [CNTRL_ADDR_WIDTH - 1 : 0] eth_cntrl_C_adr;
logic eth_cntrl_C_wrena;
logic [31 : 0] eth_cntrl_C_wdata;
logic eth_cntrl_C_rdena;
logic [31 : 0] eth_cntrl_C_rdata;
logic eth_cntrl_C_irq;
logic eth_cntrl_C_wrq;


eth_ip_core eth2 (
  .tx_clkA(tx_clkC_0),
  .tx_phy_clkA(tx_clkC_0_phy),
  /* Ethernet port B external connection */
  .eth_rxclk_a(fpga_enet4_rx_clk),
  .eth_rxdv_a(fpga_enet4_rx_dv),
  .eth_rxd_a(fpga_enet4_rx_d),
  .eth_txclk_a(fpga_enet4_tx_clk),
  .eth_txdv_a(fpga_enet4_tx_en),
  .eth_txd_a(fpga_enet4_tx_d),

  .phy_reset(phy_reset_2),

  /* HPS DMA */
  .dma_addres(arm_dma_C_addres),
  .dma_read(arm_dma_C_read),
  .dma_write(arm_dma_C_write),
  .dma_readdata(arm_dma_C_readdata),
  .dma_writedata(arm_dma_C_writedata),
  .dma_waitrequest(arm_dma_C_waitrequest),
  .dma_readdatavalid(arm_dma_C_readdatavalid),
  .dma_burstcount(arm_dma_C_burstcount),
  /* HPS Control */
  .cntrl_adr(eth_cntrl_C_adr),
  .cntrl_wrena(eth_cntrl_C_wrena),
  .cntrl_wdata(eth_cntrl_C_wdata),
  .cntrl_rdena(eth_cntrl_C_rdena),
  .cntrl_rdata(eth_cntrl_C_rdata),
  .cntrl_irq(eth_cntrl_C_irq),
  .cntrl_wrq(eth_cntrl_C_wrq),

  .ethSw(ethSw_C)
);

//==============================================================================================================
/* ETHERNET MODULE 3 */
logic phy_reset_3;
//assign eth_rst_n_D0 = /*pwr_on_rst &*/ pll_lock & eth_pll_locked & ~phy_reset_3;/*internal*/

logic [31 : 0] arm_dma_D_addres;
logic arm_dma_D_read;
logic arm_dma_D_write;
logic [ARM_INTF_WIDTH - 1 : 0] arm_dma_D_readdata;
logic [ARM_INTF_WIDTH - 1 : 0] arm_dma_D_writedata;
logic arm_dma_D_waitrequest;
logic arm_dma_D_readdatavalid;
logic [BURST_CNT_WIDTH - 1 : 0]	arm_dma_D_burstcount;

logic eth_cntrl_D_rstn;
logic [CNTRL_ADDR_WIDTH - 1 : 0] eth_cntrl_D_adr;
logic eth_cntrl_D_wrena;
logic [31 : 0] eth_cntrl_D_wdata;
logic eth_cntrl_D_rdena;
logic [31 : 0] eth_cntrl_D_rdata;
logic eth_cntrl_D_irq;
logic eth_cntrl_D_wrq;


eth_ip_core eth3 (
  .tx_clkA(tx_clkC_1),
  .tx_phy_clkA(tx_clkC_1_phy),
  /* Ethernet port B external connection */
  .eth_rxclk_a(fpga_enet5_rx_clk),
  .eth_rxdv_a(fpga_enet5_rx_dv),
  .eth_rxd_a(fpga_enet5_rx_d),
  .eth_txclk_a(fpga_enet5_tx_clk),
  .eth_txdv_a(fpga_enet5_tx_en),
  .eth_txd_a(fpga_enet5_tx_d),

  .phy_reset(phy_reset_3),

  /* HPS DMA */
  .dma_addres(arm_dma_D_addres),
  .dma_read(arm_dma_D_read),
  .dma_write(arm_dma_D_write),
  .dma_readdata(arm_dma_D_readdata),
  .dma_writedata(arm_dma_D_writedata),
  .dma_waitrequest(arm_dma_D_waitrequest),
  .dma_readdatavalid(arm_dma_D_readdatavalid),
  .dma_burstcount(arm_dma_D_burstcount),
  /* HPS Control */
  .cntrl_adr(eth_cntrl_D_adr),
  .cntrl_wrena(eth_cntrl_D_wrena),
  .cntrl_wdata(eth_cntrl_D_wdata),
  .cntrl_rdena(eth_cntrl_D_rdena),
  .cntrl_rdata(eth_cntrl_D_rdata),
  .cntrl_irq(eth_cntrl_D_irq),
  .cntrl_wrq(eth_cntrl_D_wrq),

  .ethSw(ethSw_D)
);


//==============================================================================================================
wire clk_0 = main_clock_25;

logic [2:0]  hps_reset_req;
logic        hps_fpga_reset_n;
logic        hps_cold_reset_n;
logic        hps_warm_reset_n;
logic        hps_debug_reset_n;

assign hps_fpga_reset_n = 1'b1;

// Source/Probe megawizard instance
hps_reset hps_reset_inst (
  .source_clk (clk_0),
  .source     (hps_reset_req)
);

altera_edge_detector pulse_cold_reset (
  .clk       (clk_0),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[0]),
  .pulse_out (hps_cold_reset_n)
);
defparam pulse_cold_reset.PULSE_EXT = 6;
defparam pulse_cold_reset.EDGE_TYPE = 1;
defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY = 1;
  
altera_edge_detector pulse_warm_reset (
  .clk       (clk_0),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[1]),
  .pulse_out (hps_warm_reset_n)
);
defparam pulse_warm_reset.PULSE_EXT = 2;
defparam pulse_warm_reset.EDGE_TYPE = 1;
defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY = 1;
  
altera_edge_detector pulse_debug_reset (
  .clk       (clk_0),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[2]),
  .pulse_out (hps_debug_reset_n)
);
defparam pulse_debug_reset.PULSE_EXT = 32;
defparam pulse_debug_reset.EDGE_TYPE = 1;
defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;

endmodule
