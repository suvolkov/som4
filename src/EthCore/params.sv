// Ели изменять ARM_INTF_WIDTH, то необходимо согласовать ее с QSYS и 
// вручную править eth_ip_core_export.sv + eth_ip_core_export_hw.tcl (в 14 квартусе не задать ширину шины через pMASTER_WIDTH- ругается)
// К ARM-у можно подключить до 256 бит авалон мастер портов. 128 * 3 eth_ip_core = 384 что перебор.
// 1-й вариант подключать все 3 eth_ip_core(по 128 бит) к одному 128 порту.
// 2-й вариант подключать 3 eth_ip_core к двум 128 портам (на одном из портов будет висеть 2 eth_ip_core).
// 3-й выриант собрать eth_ip_core с параметром ARM_INTF_WIDTH=64(а не 128) и подключить их к 3м независимым портам контроллера

// Правила работы фильтра принятых пакетов для порта A и B:
// 1. Если пакет HSR или не HSR и SRC_MAC == ARM_MAC то пакет отбрасывается.
// 2. Если пакет HSR и он уже приходил в течении 400 мс с того же порта то он отбрасывается.
// 3. Если пакет HSR и он уже приходил в течении 400 мс с противоположного порта то он отбрасывается.
// 4. Если пакет HSR и DST_MAC == BROADCAST или DST_MAC == MULTICAST и он не приходил в течении 400мс то пакет передается в соседний порт и в ARM.
// 5. Если пакет HSR и DST_MAC == BROADCAST или DST_MAC == MULTICAST и он приходил в течении 400мс то пакет отбрасывается.
// 6. Если пакет HSR и DST_MAC == ARM_MAC то пакет передается только в ARM.
// 7. Если пакет не HSR, то он передается только в ARM.

package params;

parameter int ETHIPCORE_VER = 28'h0030000; // Версия ядра ethip_core. старшие 16 бит - major; младшие 16 бит minor.

// Настраиваемые параметры:
parameter int NUMBER_OF_PHY_PORTS = 2; // Число физических MDIO ethernet портов
parameter int NUMBER_OF_LOG_PORTS = 4; // Число логических MDIO ethernet портов на каждом из физических

parameter int INT_PACK_GAP = 12; /* Interpacket Gap Insertion. 1 Gbit/s: 96 ns, 100 Mbit/s: 0.96 μs, 10 Mbit/s: 9.6 μs */
parameter int ARM_INTF_WIDTH = 64; // Разрядность интерфейса прямого доступа к памяти ARM == PCKT_Q_INTF_W(Сейчас они должны быть равны!)
parameter int PCKT_Q_BUF_LN_BYTES_RX = 4096; // Размер очереди RX пакетов в байтах для портов A и B(влияет на потребляемую onchip mem)
parameter int PCKT_Q_BUF_LN_BYTES_TX = 4096; // Размер очереди TX пакетов в байтах для портов A и B(влияет на потребляемую onchip mem)
parameter int ARM_DDR_PACKETS_BUF_LN = 128; // Размер буфера принимаемых/передаваемых пакетов в DDR (согласовать с ARM)

// Не изменяемые параметры:
parameter int PCKT_Q_INTF_W = 64; // Разрядность интерфейса очереди пакетов. Сейчас должно быть ARM_INTF_WIDTH = ARM_INTF_WIDTH!
parameter int MIN_ETH_FRAME_CNT = 60; //Минимальный размер принимаемого/передаваемого фрэйма без учета CRC и преамбулы
parameter int MAX_ETH_FRAME_CNT = 1664; // Максимальный размер принимаемого/передаваемого фрэйма без учета CRC и преамбулы (не ставить больше чем 2^16)
parameter int ARM_DMA_NUMBER_OF_AUX_WORDS = 1;
parameter int BURST_CNT_WIDTH = 8;//$clog2(MAX_ETH_FRAME_CNT/(ARM_INTF_WIDTH/8)); // Согласовать с eth_ip_core_export.sv
parameter int ERROR_COUNTERS_W = 8; /* Width of counters which counts different errors */
parameter int MAX_VLAN_NETS = 16; /* Number of VLAN nets to fileter */

endpackage
