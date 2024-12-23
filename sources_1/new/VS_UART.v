module VS_UART(
    input  CLK,
    input  RST, 
    // UART
    input  RXD,
    output reg TXD,
    // STP
    output reg RX_DATA_EN,
    output reg [9:0] RX_DATA_T,
    // DRP
    input  TX_RDY_T,
    input  [7:0] TX_DATA_R,
    output reg TX_RDY_R
    );
    
reg [2:0] TX_STATE;
reg [2:0] RX_STATE;
reg [7:0] TX_DATA;
reg TX_PAR_BIT_RG;
reg [2:0] TX_DATA_CT;
reg [2:0] RX_DATA_CT;
reg TXCT_R;
reg [2:0] RX_SAMP_CT;
reg [3:0] TX_SAMP_CT;
reg RXCT_R;
reg [2:0] SYNC; // WIDTH = 3 from var

wire UART_CE;
wire RX_CE;
wire TX_CE;
wire RXD_RG;

localparam IDLE = 3'd0,
           WCE = 3'd1,
           TSTRB = 3'd2,
           TDT = 3'd3,
           TPARB = 3'd4,
           TSTB1 = 3'd5,
           TSTB2 = 3'd6,
           RSTRB = 3'd1,
           RDT = 3'd2,
           RPARB = 3'd3,
           RSTB1 = 3'd4, // from var 2 stop bits
           RSTB2 = 3'd5, // from var 2 stop bits
           WEND = 3'd6;

// SYNC WIDTH = 3 from var
always @(posedge CLK, posedge RST)
    if (RST)
        SYNC <= 3'b111;
    else
        SYNC <= {SYNC[1], SYNC[0], RXD};
        
assign RXD_RG = SYNC[2];

always @(posedge CLK, posedge RST) 
    if (RST)
        RX_SAMP_CT <= 3'h0;
    else if (RXCT_R)
        RX_SAMP_CT <= 3'h0;
    else if (RXCT_R)
        RX_SAMP_CT <= RX_SAMP_CT + 1'b1;
        
assign RX_CE = UART_CE & (RX_SAMP_CT == 3'h7); // from var: RATIO = 16

always @(posedge CLK, posedge RST) 
    if (RST)
        TX_SAMP_CT <= 4'h0;
    else if (RXCT_R)
        TX_SAMP_CT <= 4'h0;
    else if (RXCT_R)
        TX_SAMP_CT <= TX_SAMP_CT + 1'b1;
        
assign TX_CE = UART_CE & (TX_SAMP_CT == 4'hf); // from var: RATIO = 16

VS_DIVIDER#(
    .DIV(868) // from var: 100_000_000 / (7200 * 16)
) div_inst ( 
    .CLK(CLK),
    .RST(RST),
    .CEO(UART_CE)
);

// RX_FSM 2 stop bits from var
always @(posedge CLK, posedge RST)
    if (RST) begin
        RX_STATE <= IDLE;
        RX_DATA_EN <= 1'b0;
        RX_DATA_T <= 10'h000;
        RX_DATA_CT <= {3{1'b0}};
        RXCT_R <= 1'b1;
    end
    else
        case (RX_STATE)
        
            IDLE: begin
                if (~RXD_RG) begin
                    RX_STATE <= RSTRB;
                    RX_DATA_EN <= 1'b0;
                    RX_DATA_T[9] <= 1'b0;
                    RXCT_R <= 1'b0;
                end
                else
                    RX_DATA_EN <= 1'b0;
            end
            
            RSTRB: begin
                if (RX_CE) begin
                    if (RXD_RG) begin
                        RX_STATE <= IDLE;
                        RXCT_R <= 1'b1;
                    end
                    else
                        RX_STATE <= RDT;
                end
            end
            
            RDT: begin
                if (RX_CE) begin
                    RX_DATA_T[7:0] <= {RXD_RG, RX_DATA_T[7:1]}; // should be ok
                    RX_DATA_CT <= RX_DATA_CT + 1'b1;
                    if (RX_DATA_CT == 4'h7)
                        RX_STATE <= RPARB;
                end
            end
            
            RPARB: begin
                if (RX_CE) begin
                    RX_STATE <= RSTB1;
                    RX_DATA_T[8] <= ^{RX_DATA_T[7:0]} ^ RXD_RG;  // from var parity = EVEN
                end
            end
            
            RSTB1: begin // from var 2 stop bits
                if (RX_CE) begin
                    RX_STATE <= RSTB2;
                    RX_DATA_T[9] <= ~RXD_RG;
                end
            end
            
            RSTB2: begin // from var 2 stop bits
                if (RX_CE) begin
                    if (RXD_RG) begin
                        RX_STATE <= IDLE;
                        RX_DATA_EN <= 1'b1;
                        RXCT_R <= 1'b1;
                    end
                    else begin
                        RX_STATE <= WEND;
                        RX_DATA_T[9] <= 1'b1;
                    end
                end
            end
            
            WEND: begin
                if (RXD_RG) begin
                     RX_STATE <= IDLE;
                     RX_DATA_EN <= 1'b1;
                     RXCT_R <= 1'b1;
                end
            end
            default: RX_STATE <= IDLE;
            
        endcase
           
// TX_FSM 2 stop bits
always @(posedge CLK, posedge RST) 
    if (RST) begin
        TX_STATE <= IDLE;
        TX_DATA <= 8'h00;
        TX_PAR_BIT_RG <= 1'b0;
        TX_RDY_R <= 1'b1;
        TX_DATA_CT <= 3'b000;
        TXD <= 1'b1;
        TXCT_R <= 1'b1;
    end
    else 
        case (TX_STATE)
            IDLE: begin
                if (TX_RDY_T) begin
                    TX_DATA <= TX_DATA_R;
                    // from var parity = EVEN
                    TX_PAR_BIT_RG <= ^{TX_DATA_R[7:0]}; // parity bit calc from manual ~^(TX_DATA_R)
                    TX_RDY_R <= 1'b0;
                    if (UART_CE) begin
                        TX_STATE <= TSTRB;
                        TXD <= 1'b0;
                        TXCT_R <= 1'b0;
                    end
                    else
                        TX_STATE <= WCE;
                end
            end
            
            WCE: begin
                if (UART_CE) begin
                    TX_STATE <= TSTRB;
                    TXD <= 1'b0;
                    TXCT_R <= 1'b0;
                end
            end
            
            TSTRB: begin
                if (TX_CE) begin
                    TX_STATE <= TDT;
                    TXD <= TX_DATA[0];
                    TX_DATA  <= {1'b0, TX_DATA[7:1]};
                end
            end
            
            TDT: begin
                if (TX_CE) begin
                    TX_DATA  <= {1'b0, TX_DATA[7:1]};
                    TX_DATA_CT <= TX_DATA_CT + 1'b1;
                    if (TX_DATA_CT == 4'h7) begin
                        TX_STATE <= TPARB;
                        TXD <= TX_PAR_BIT_RG;
                    end
                    else
                        TXD <= TX_DATA[0];  
                end
            end
            
            TPARB: begin
                if (TX_CE) begin
                    TX_STATE <= TSTB1;
                    TXD <= 1'b1;
                end
            end
            
            TSTB1: begin
                if (TX_CE) begin
                    TX_STATE <= TSTB2;
                    TXD <= 1'b1;
                end
            end
            
            TSTB2: begin
                if (TX_CE) begin
                    TX_STATE <= IDLE;
                    TX_RDY_R <= 1'b1;
                    TXCT_R <= 1'b1;
                end
            end
            
            default: TX_STATE <= IDLE;
        endcase
endmodule
