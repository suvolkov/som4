set_global_assignment -entity "eth_pll" -library "lib_eth_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "eth_pll" -library "lib_eth_pll" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "eth_pll" -library "lib_eth_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_eth_pll" -name SPD_FILE [file join $::quartus(sip_path) "eth_pll.spd"]

set_global_assignment -library "lib_eth_pll" -name MISC_FILE [file join $::quartus(sip_path) "eth_pll_sim/eth_pll.vo"]
