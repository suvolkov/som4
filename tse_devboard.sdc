#create_clock -name "inclk_gnrl" -period 20.000ns [get_ports {CLK0P_50}]
#create_clock -name "inclk_gnrl_1" -period 20.000ns [get_ports {CLK1P_50}]

# For enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdo]

# For async resets
set_false_path -from {tse_devboard_hps:hps|altera_reset_controller:reset_cntrl|altera_reset_synchronizer:alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out} -to *

#automatically created clocks by derive pll clocks:
derive_pll_clocks
# generates uncertainty jitter values for clocks:
derive_clock_uncertainty 

set clk_mn [get_clocks {hps|pll_0|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
#set clk_1 [get_clocks {hps|pll_0|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}]

#QSPI =======================================================================================================================
set_false_path -to [get_ports {HPS_FLASH_DATA[*] HPS_FLASH_NCSO HPS_FLASH_DCLK}]
set_false_path -from [get_ports {HPS_FLASH_DATA[*]}]

# UART ARM =====================================================================================================================
set_false_path -to [get_ports {HPS_UART_TX}]
set_false_path -from [get_ports {HPS_UART_RX}]

# ETH all ports =======================================================================================================
set_false_path -to [get_ports {eth_rst_n_*}]
set_false_path -to [get_ports {eth_mdc_*}]
set_false_path -from [get_ports {eth_mdio_*}]
set_max_skew 3 -to [get_ports {eth_mdio_*}]

# ETH A0 ==================================================================
create_clock -name "eth_rx_A0_clk_1000" -period 8.0ns -waveform { 2.0 6.0 } [get_ports {eth_rxclk_A0}]
create_clock -name "eth_rx_A0_clk_100" -period 40.0ns -waveform { 10.0 30.0 } [get_ports {eth_rxclk_A0}] -add
set clkinA0_1000 [get_clocks eth_rx_A0_clk_1000]
set clkinA0_100 [get_clocks eth_rx_A0_clk_100]

set setup 2.0
set hold 7.0

set ports_in [get_ports "eth_rxd_A0[*] eth_rxdv_A0"]
set_input_delay -clock eth_rx_A0_clk_1000 -max $setup $ports_in
set_input_delay -clock eth_rx_A0_clk_1000 -min $hold $ports_in
set_input_delay -clock eth_rx_A0_clk_1000 -clock_fall -add_delay -max $setup $ports_in
set_input_delay -clock eth_rx_A0_clk_1000 -clock_fall -add_delay -min $hold $ports_in

#-----------------
create_generated_clock -name clk_ethout_A0 -source [get_pins {eth0|mii_port_a|clk_io|auto_generated|ddio_outa[0]|dataout}] [get_ports {eth_txclk_A0}]

set setup 0.4
set hold 1.2

set ports_out [get_ports "eth_txd_A0[*] eth_txdv_A0"]
set_output_delay -add_delay -clock clk_ethout_A0 -max $setup $ports_out
set_output_delay -add_delay -clock clk_ethout_A0 -min $hold $ports_out
set_output_delay -clock clk_ethout_A0 -clock_fall -add_delay -max $setup $ports_out
set_output_delay -clock clk_ethout_A0 -clock_fall -add_delay -min $hold $ports_out

# ETH B0 ==================================================================
create_clock -name "eth_rx_B0_clk_1000" -period 8.0ns -waveform { 2.0 6.0 } [get_ports {eth_rxclk_B0}]
create_clock -name "eth_rx_B0_clk_100" -period 40.0ns -waveform { 10.0 30.0 } [get_ports {eth_rxclk_B0}] -add
set clkinB0_1000 [get_clocks eth_rx_B0_clk_1000]
set clkinB0_100 [get_clocks eth_rx_B0_clk_100]

set setup 1.0
set hold 6.0

set ports_in [get_ports "eth_rxd_B0[*] eth_rxdv_B0"]
set_input_delay -clock eth_rx_B0_clk_1000 -max $setup $ports_in
set_input_delay -clock eth_rx_B0_clk_1000 -min $hold $ports_in
set_input_delay -clock eth_rx_B0_clk_1000 -clock_fall -add_delay -max $setup $ports_in
set_input_delay -clock eth_rx_B0_clk_1000 -clock_fall -add_delay -min $hold $ports_in

#-----------------
# Don't forget to change mii_port_a->mii_port_b for RTSE-ipcore!!
create_generated_clock -name clk_ethout_B0 -source [get_pins {eth1|mii_port_a|clk_io|auto_generated|ddio_outa[0]|dataout}] [get_ports {eth_txclk_B0}]

set setup 0.4
set hold 1.2

set ports_out [get_ports "eth_txd_B0[*] eth_txdv_B0"]
set_output_delay -add_delay -clock clk_ethout_B0 -max $setup $ports_out
set_output_delay -add_delay -clock clk_ethout_B0 -min $hold $ports_out
set_output_delay -clock clk_ethout_B0 -clock_fall -add_delay -max $setup $ports_out
set_output_delay -clock clk_ethout_B0 -clock_fall -add_delay -min $hold $ports_out

# ==============================================================================

set_clock_groups -exclusive -group $clk_mn -group $clkinA0_1000
set_clock_groups -exclusive -group $clk_mn -group $clkinA0_100
set_clock_groups -logically_exclusive -group $clkinA0_1000 -group $clkinA0_100

set_clock_groups -exclusive -group $clk_mn -group $clkinB0_1000
set_clock_groups -exclusive -group $clk_mn -group $clkinB0_100
set_clock_groups -logically_exclusive -group $clkinB0_1000 -group $clkinB0_100

# ==============================================================================
set_false_path -from {*ethSw_?.link_speed}
set_false_path -from {*cntrl.work_ena}
# set_false_path -to {**}