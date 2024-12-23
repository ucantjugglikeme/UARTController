module VS_LR_TOP(
    input  CLK,
    input  SYS_NRST,
    input  BTN_0,
    input  BTN_1,
    input  UART_RXD,
    output UART_TXD
    );

reg [1:0] SYNC;
        
wire RST;
wire CE_1KHz;

wire GEN_FRT_ERR;
wire GET_PAR_ERR;

wire RX_DATA_EN;
wire [9:0] RX_DATA_T;
wire TX_RDY_T;
wire [7:0] TX_DATA_R;
wire TX_RDY_R;

wire [9:0] DATA_ERR;

wire [7:0] ASCII_DATA;
wire HEX_FLG;
wire [3:0] DC_HEX_DATA;

wire [3:0] HEX_DATA;
wire [7:0] DC_ASCII_DATA;

wire [6:0] ADDR; // from var ADDR WIDTH = 7
wire [7:0] MEM_DATA;

always @(posedge CLK, negedge SYS_NRST) begin
    if (~SYS_NRST)
        SYNC <= 2'b11;
    else 
        SYNC <= {SYNC[0], 1'b0};
end
        
assign RST = SYNC[1];
    
VS_DIVIDER divider_inst(
    .CLK(CLK),
    .RST(RST),
    .CEO(CE_1KHz)
);

VS_BTN_FLTR filt_inst0(
    .CLK(CLK),
    .BTN_IN(BTN_0),
    .CE(CE_1KHz),
    .RST(RST),
    .BTN_OUT(GEN_FRT_ERR),
    .BTN_CEO()
);
VS_BTN_FLTR filt_inst1(
    .CLK(CLK),
    .BTN_IN(BTN_1),
    .CE(CE_1KHz),
    .RST(RST),
    .BTN_OUT(GET_PAR_ERR),
    .BTN_CEO()
);

VS_UART uart_inst(
    .RXD(UART_RXD),
    .TXD(UART_TXD),
    .CLK(CLK),
    .RST(RST),
    
    .RX_DATA_EN(RX_DATA_EN),
    .RX_DATA_T(RX_DATA_T),
    .TX_RDY_T(TX_RDY_T),
    
    .TX_DATA_R(TX_DATA_R),
    .TX_RDY_R(TX_RDY_R)
);

VS_GENERR generr_inst(
    .RX_DATA_T(RX_DATA_T),
    .GEN_FRT_ERR(GEN_FRT_ERR),
    .GEN_PAR_ERR(GET_PAR_ERR),
    .DATA(DATA_ERR)
);

VS_FSM fms_inst(
    .CLK(CLK),
    .RST(RST),
    .RX_DATA_EN(RX_DATA_EN),
    .RX_DATA_R(DATA_ERR),
    .TX_RDY_T(TX_RDY_T),
    .TX_DATA_T(TX_DATA_R),
    .TX_RDY_R(TX_RDY_R),
    .ASCII_DATA(ASCII_DATA),
    .HEX_FLG(HEX_FLG),
    .DC_HEX_DATA(DC_HEX_DATA),
    .HEX_DATA(HEX_DATA),
    .DC_ASCII_DATA(DC_ASCII_DATA),
    .ADDR(ADDR),
    .DATA(MEM_DATA)
);

VS_ROM rom_inst(
    .ADDR(ADDR),
    .DATA(MEM_DATA)
);

VS_DC_ASCII_HEX dc_inst(
    .ASCII(ASCII_DATA),
    .HEX(DC_HEX_DATA),
    .HEX_FLG(HEX_FLG)
);
VS_DC_HEX_ASCII dc_hex_ascii_inst(
    .HEX(HEX_DATA),
    .ASCII(DC_ASCII_DATA)
);
    
endmodule
