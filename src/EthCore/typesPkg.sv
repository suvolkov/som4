package typesPkg;
import params::*;

// Производные параметры очереди пакетов:
parameter int MAX_ETH_FRAME_CNT_WIDTH = $clog2(MAX_ETH_FRAME_CNT); // = 11
parameter int BITS_PAD = $clog2(PCKT_Q_INTF_W / 8); // $clog2(64 / 8) = 3
parameter int BITS_PAD_ARM = $clog2(ARM_INTF_WIDTH / 8); //= 3
//===============================================================================
// MII rx data stream
typedef struct { // Содержит параметры текущего принятого пакета
  logic rx_fl; // Строб выставляется в конце принятого пакета
  logic crc_val; // CRC packet is valid
  logic line_err; // Во время приема пакета была ошибка в линии. Выставляется от phy.
} mii_rx_status_t;

// TX to MII stream
typedef struct {
  logic tx_error;
  logic valid_tx; // tx data valid signal
  logic [7 : 0] data_tx; // tx_data
} mii_tx_t;
//===============================================================================
// packets queue structs
//Структура с данными для передачи в сеть со стороны блока forward
//pack_ln_b- фактическая длина передаваемого пакета в сеть в байтах. Известна на начало frw_valid_tx:
parameter int MEM_ETH_ADDR_W_EXT_TX = $clog2(PCKT_Q_BUF_LN_BYTES_TX + 1);
typedef struct packed {
  logic frw_valid_tx; // строб передачи пакета (от очереди в DMA)
  logic frw_sop_tx;
  logic frw_eop_tx;
  logic [BITS_PAD - 1 : 0] data_offs;
  logic [PCKT_Q_INTF_W - 1 : 0] frw_data_tx; // данные пакета
  logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] pack_ln_b; // кол-во байт в передаваемом пакете фактическое(выставлять в начале строба frw_valid_tx)
} pack_q_frw_tx_from_sw_t;

typedef struct {
  logic unsigned [MEM_ETH_ADDR_W_EXT_TX - 1 : 0] bytes_avlb; // Число доступных байт в очереди для записи пакета на отправку [0..MEM_ETH_LN]
} pack_q_frw_tx_to_sw_t;

//Структура используется блоком forwarding для того чтобы вычитывать данные из очереди приема пакетов
typedef struct packed {
  logic strb_rx; // 1 тактовый строб запроса пакета от switch к очереди.
  logic sop_rx;
  logic reset_rx;
} pack_q_frw_rx_from_sw_t;

typedef struct {
  logic frw_valid_rx; // строб чтения пакета из очереди (от очереди к forward)
  logic [PCKT_Q_INTF_W - 1 : 0] frw_data_rx; // Данные, вычитываемые из очереди
  logic packet_avlb; // Очередь сигнализирует forward что в ней есть принятые пакеты
  logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] cur_pckt_lnb; // Текущая длина ожидающего пакета в байтах
} pack_q_frw_rx_to_sw_t;

//MAX_DESC_RECORDS - Требуемое число дескрипторов пакетов в худшем случае при их длине = MIN_ETH_FRAME_CNT
parameter int MAX_DESC_RECORDS_RX = PCKT_Q_BUF_LN_BYTES_RX / MIN_ETH_FRAME_CNT; //=64 размер памяти/размер самого короткого пакета
parameter int MAX_DESC_RECORDS_TX = PCKT_Q_BUF_LN_BYTES_TX / MIN_ETH_FRAME_CNT; //=64 размер памяти/размер самого короткого пакета
parameter int N_DESC_RECORDS_RX = MAX_DESC_RECORDS_RX / 5; // =13 допущение для экономии ресурсов: средняя длина пакета >= 256байтам
parameter int N_DESC_RECORDS_TX = MAX_DESC_RECORDS_TX / 5; // =13 допущение для экономии ресурсов: средняя длина пакета >= 256байтам

// Структура содержит счетчики ошибок приема пакетов в модуле packets_rx_queue
typedef struct packed {
  logic [7:0] frm_size_err_cnt; //счетчик пакетов у которых длина превысила допустимую MAX_ETH_FRAME_CNT
  logic [7:0] rx_queue_ovf_cnt; //счетчик отброшенных пакетов по причине переполненной очереди
  logic [7:0] rx_desc_ovf_cnt; /* RX descriptors buffer is overflowed */
  logic [7:0] line_error_cnt; /* Counter of errors on the RX line */
  logic [15:0] crc_error_cnt; //счетчик отброшенных пакетов по причине неправильной crc в принятом от mii пакете
  logic [31:0] packets_received_cnt; // Число успешно принятых пакетов
} rx_queue_status_t;

//===============================================================================
typedef struct packed { // данные от switch к очереди ARM
  logic frw_valid_rx; // строб записи пакета в очередь (от forward switch к очереди ARM)
  logic [PCKT_Q_INTF_W - 1 : 0] frw_data_rx; // Данные, записываемые в очередь
  logic [MAX_ETH_FRAME_CNT_WIDTH - 1 : 0] cur_pckt_lnb; // Текущая длина записываемого пакета в байтах(д.б. установлена в )
  //pack_cntrl_bits_t cntrl_bits; // Биты указывающие что делать с пакетом
} pack_q_arm_rx_from_sw_t;

//===============================================================================
typedef struct packed { // данные от DMA к очереди TXQA ARM
  logic sop; // начало пакета
  logic val; // строб записи данных
  logic eop; // конец пакета
  logic [ARM_INTF_WIDTH-1:0] data_tx; // Данные на отправку от DMA к очереди TX
  logic [MAX_ETH_FRAME_CNT_WIDTH-1:0] cur_pckt_lnb; // Текущая длина передаваемого пакета в байтах
  //pack_cntrl_bits_t cntrl_bits; // Содержат информацию для switch о том в какой порт передавать пакет идущий от ARM
} pack_q_arm_tx_from_dma_t;

typedef struct { // От очереди TX ARM к switch
  logic packet_avlb; // Очередь сигнализирует switch о том что в ней есть пакеты на отправку от АРМ
  logic [MAX_ETH_FRAME_CNT_WIDTH-1:0] cur_pckt_lnb; // Текущая длина ожидающего пакета в байтах
  logic tx_val; // строб валидности данных от очереди TXQA к switch
  logic [PCKT_Q_INTF_W - 1 : 0] data_tx; // данные от очереди TXQA к switch
  //pack_cntrl_bits_t cntrl_bits; // биты, указывающие switch что делать с пакетом
} pack_q_arm_tx_to_sw_t;

typedef struct packed { // От switch к очереди TX ARM
  logic strb_rx; // 1 тактовый строб запроса пакета от switch к очереди TX ARM.
} pack_q_arm_tx_from_sw_t;
//===============================================================================
typedef enum logic [1 : 0] {
  LINK_1000 = 2'd0,
  LINK_100  = 2'd1,
  LINK_10   = 2'd2
} link_select_t;

// forwarding switch:
parameter int PACKETS_DEPTH_WIDTH = $clog2(ARM_DDR_PACKETS_BUF_LN);
// Control struct
typedef struct packed {
  logic multicast_filter_ena; /* 13 ethipcore forwards packets to HPS if they are multicast */
  logic vlan_filter_ena; /* 12 ethipcore uses vlan_id array for filtering packets */
  link_select_t link_speed; /* 11..10 Select link speed */
  logic promiscuous_mode; /* 9 Linux will receive all packets */
  logic eth_hard_reset; /* 8 If 1 => phy reset */
  logic res_3; /* 7 */
  logic res_2; /* 6 */
  logic res_1; /* 5 */
  logic res_0; /* 4 */
  logic irq_err_mask; /* 3 Enable IRQ ERR */
  logic irq_tx_mask; /* 2 Enable IRQ TX */
  logic irq_rx_mask; /* 1 Enable IRQ RX */
  logic work_ena; /* 0 Ethipcore enable */
} ethipcore_control;

// IRQ status struct
typedef struct packed {
  logic irq_from_tmr; /* 4 Forced interrupt from ethip timer */
  logic irq_tx_err; /* 3 TX error while transmiting */
  logic irq_rx_err; /* 2 RX error while receiving */
  logic irq_tx_flg; /* 1 Packets were transmited */
  logic irq_rx_flg; /* 0 Packets were received */
} ethipcore_irq_status;

// Структура с параметрами работы dma (от АРМ в dma)
typedef struct packed {
  logic [31 : 0] ddr_rcv_pckts_addr; //+ pointer to the ddr memory buffer with received packets
  logic [31 : 0] ddr_trm_pckts_addr; // pointer to the ddr memory buffer with transmit packets
  logic [PACKETS_DEPTH_WIDTH - 1 : 0] cur_pckt_tx_pos; // current packets trm position
  logic [PACKETS_DEPTH_WIDTH - 1 : 0] cur_pckt_rx_pos; // current packets rcv position
} dma_params_t;

//===============================================================================
typedef struct {
  logic wr_val;
  logic [$clog2(MAX_VLAN_NETS) - 1 : 0] addr;
  logic [11 : 0] vid;
} vlan_setup_t;
//===============================================================================
/* Rx filter status */
typedef struct packed {
  logic vlan_accept_flg;       /* RX packet is VLAN and should be forvarded to HPS */
  logic multicast_accept_flg;  /* RX packet is multicast and should be forvarded to HPS */
  logic brdcst_accept_flag;    /* RX packet is broadcast and should be forvarded to HPS */
  logic our_accept_flag;       /* RX packet is intended for HPS, dst. MAC = port MAC */
} filter_status_t;
//===============================================================================
endpackage

interface interSw #(parameter int NETH=1) (
  input clk,
  input rst_n
);
/* Common */
link_select_t link_speed;
logic main_rst_n;

/* Control flags */
logic vlan_filter_ena;
logic multicast_filter_ena;

/* MAC address designated on port */
logic [5:0][7:0] port_mac;

/* ARM DMA */
dma_params_t dma_par;
logic dma_rx_irq; /* Positive + negative edge triggered interrupt request from ARM DMA */
logic dma_tx_irq; /* Positive + negative edge triggered interrupt request from ARM DMA */
logic dma_rx_err_irq; /* Positive + negative edge triggered interrupt request from ARM DMA */
logic dma_tx_err_irq; /* Positive + negative edge triggered interrupt request from ARM DMA */
logic [3 : 0] dma_control_select; /* Inderect control: Select register */
logic [31 : 0] dma_control_reg; /* Inderect control: Data register */
logic [PACKETS_DEPTH_WIDTH - 1 : 0] ddr_rx_pckt_wr; // Номер текущего записываемого в DDR пакета
logic [PACKETS_DEPTH_WIDTH - 1 : 0] ddr_tx_pckt_rd; // Номер текущего вычитываемого из DDR пакета

/* RX statistic */

/* TX statistic */
logic [31:0] tx_cnt; /* TX packets counter */
logic [ERROR_COUNTERS_W -1 : 0] tx_errors_wr; /* Number of corrupted TX packet, write to fifo */
// logic [ERROR_COUNTERS_W -1 : 0] tx_errors_rd; /* Number of corrupted TX packet, read from fifo */
endinterface
