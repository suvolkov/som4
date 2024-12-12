set_global_assignment -entity "eth_pll_reconf" -library "lib_eth_pll_reconf" -name IP_TOOL_NAME "altera_pll_reconfig"
set_global_assignment -entity "eth_pll_reconf" -library "lib_eth_pll_reconf" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "eth_pll_reconf" -library "lib_eth_pll_reconf" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_eth_pll_reconf" -name SPD_FILE [file join $::quartus(sip_path) "eth_pll_reconf.spd"]

set_global_assignment -library "lib_eth_pll_reconf" -name MISC_FILE [file join $::quartus(sip_path) "eth_pll_reconf_sim/eth_pll_reconf.v"]
set_global_assignment -library "lib_eth_pll_reconf" -name MISC_FILE [file join $::quartus(sip_path) "eth_pll_reconf_sim/altera_pll_reconfig/altera_pll_reconfig_top.v"]
set_global_assignment -library "lib_eth_pll_reconf" -name MISC_FILE [file join $::quartus(sip_path) "eth_pll_reconf_sim/altera_pll_reconfig/altera_pll_reconfig_core.v"]
set_global_assignment -library "lib_eth_pll_reconf" -name MISC_FILE [file join $::quartus(sip_path) "eth_pll_reconf_sim/altera_pll_reconfig/altera_std_synchronizer.v"]
