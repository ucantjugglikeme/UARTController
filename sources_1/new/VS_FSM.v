module VS_FSM (
    // System:
    input  CLK,
    input  RST,
    // STP:
    input  RX_DATA_EN,
    input  [9:0] RX_DATA_R,
    // DTP:
    output reg TX_RDY_T,
    output reg [7:0] TX_DATA_T,
    input  TX_RDY_R,
    // DC ASCII->HEX
    output [7:0] ASCII_DATA,
    input  HEX_FLG,
    input  [3:0] DC_HEX_DATA,
    // DC HEX->ASCII
    output reg [3:0] HEX_DATA,
    input  [7:0] DC_ASCII_DATA,
    // ROM
    output reg [6:0] ADDR, // from var WIDTH = 7
    input  [7:0] DATA
    );
    
reg [3:0] STATE; 
reg [83:0] RES_REG; // from var RES WIDTH = 84
reg [4:0] RES_CT; // RES WIDTH / 4 = 21 -> RES_CT WITDH = 5
reg [27:0] DATA_REG; // from var input DATA WIDTH = 28
reg [2:0] DATA_CT; // 2*N - 1 = 28/4 - 1 = 6

reg [6:0] END_ADDR; // from var ADDR WIDTH = 7

reg RES_FLG;

reg [6:0] ERR_A0_MX; // from var ADDR WIDTH = 7
reg [6:0] ERR_A1_MX; // from var ADDR WIDTH = 7

wire [6:0] RES_A0;  // from var ADDR WIDTH = 7
wire [6:0] RES_A1;  // from var ADDR WIDTH = 7

localparam IDLE = 4'd0,
           RDT  = 4'd1,
           RCR  = 4'd2,
           RLF  = 4'd3,
           TRES = 4'd4,
           TMEM = 4'd5,
           TDT  = 4'd6,
           TCR  = 4'd7,
           TLF  = 4'd8;
           
assign ASCII_DATA[7:0] = RX_DATA_R[7:0];

always @* begin
    case(RES_CT)
        0: HEX_DATA = RES_REG[83:80];
        1: HEX_DATA = RES_REG[79:76];
        2: HEX_DATA = RES_REG[75:72];
        3: HEX_DATA = RES_REG[71:68];
        4: HEX_DATA = RES_REG[67:64];
        5: HEX_DATA = RES_REG[63:60];
        6: HEX_DATA = RES_REG[59:56];
        7: HEX_DATA = RES_REG[55:52];
        8: HEX_DATA = RES_REG[51:48];
        9: HEX_DATA = RES_REG[47:44];
        10: HEX_DATA = RES_REG[43:40];
        11: HEX_DATA = RES_REG[39:36];
        12: HEX_DATA = RES_REG[35:32];
        13: HEX_DATA = RES_REG[31:28];
        14: HEX_DATA = RES_REG[27:24];
        15: HEX_DATA = RES_REG[23:20];
        16: HEX_DATA = RES_REG[19:16];
        17: HEX_DATA = RES_REG[15:12];
        18: HEX_DATA = RES_REG[11:8];
        19: HEX_DATA = RES_REG[7:4];
        20: HEX_DATA = RES_REG[3:0];
        default: HEX_DATA = 0;
    endcase
end

assign RES_A0 = 0;
assign RES_A1 = 7'h07; // from var result msg

always@*
    case(RX_DATA_R[9:8])
        2'b00: begin
            ERR_A0_MX = 7'h08; // from 9
            ERR_A1_MX = 7'h19; // to 26
        end
        2'b01: begin
            ERR_A0_MX = 7'h1A; // from 27
            ERR_A1_MX = 7'h2B; // to 44
        end
        2'b10: begin
            ERR_A0_MX = 7'h2C; // from 45
            ERR_A1_MX = 7'h42; // to 67
        end
        2'b11: begin
            ERR_A0_MX = 7'h43; // from 68 
            ERR_A1_MX = 7'h4A; // to 75
        end
    endcase

// FSM
always @(posedge CLK, posedge RST)
    if (RST) begin
        STATE <= IDLE;
        TX_DATA_T <= 8'h00;
        TX_RDY_T <= 1'b0;
        DATA_CT <= {3{1'b0}};    // from var
        RES_CT <= {5{1'b0}};     // from var
        RES_REG <= {84{1'b0}};   // from var
        DATA_REG <= {28{1'b0}};  // from var
        ADDR <= {7{1'b0}};       // from var
        END_ADDR <= {7{1'b0}};   // from var
        RES_FLG <= 1'b0;
    end
    else
        case(STATE)
        
            IDLE: begin
                if (RX_DATA_EN) begin
                    if (RX_DATA_R[9] | RX_DATA_R[8] | ~HEX_FLG) begin
                        STATE <= TRES;
                        ADDR <= ERR_A0_MX;
                        END_ADDR <= ERR_A1_MX;
                    end
                    else 
                        if (HEX_FLG) begin
                            STATE <= RDT;
                            ADDR <= RES_A0;
                            END_ADDR <= RES_A1;
                            DATA_REG <= {DATA_REG[23:0], DC_HEX_DATA}; // from var
                            DATA_CT <= DATA_CT + 1'b1;
                        end
                end
            end
            
            RDT: begin
                if (RX_DATA_EN) begin
                    if (RX_DATA_R[9] | RX_DATA_R[8] | ~HEX_FLG) begin
                        STATE <= TRES;
                        ADDR <= ERR_A0_MX;
                        END_ADDR <= ERR_A1_MX;
                    end
                    else
                        if (HEX_FLG) begin
                            DATA_REG <= {DATA_REG[23:0], DC_HEX_DATA};  // from var
                            DATA_CT <= DATA_CT + 1'b1;
                            if (DATA_CT == 3'd6) begin // from var 28 / 4 = 7
                                STATE <= RCR;
                                DATA_CT <= {3{1'b0}}; // from var
                            end
                        end
                end
            end
            
            RCR: begin
                if (RX_DATA_EN) begin
                    if (RX_DATA_R[9] | RX_DATA_R[8] | RX_DATA_R[7:0]!=8'h0d) begin
                        STATE <= TRES;
                        ADDR <= ERR_A0_MX;
                        END_ADDR <= ERR_A1_MX;
                    end
                    else 
                        if (RX_DATA_R[7:0]==8'h0d)
                            STATE <= RLF;
                end
            end
            
            RLF: begin
                if (RX_DATA_EN) begin
                    if (RX_DATA_R[9] | RX_DATA_R[8] | RX_DATA_R[7:0]!=8'h0a) begin
                        STATE <= TRES;
                        ADDR <= ERR_A0_MX;
                        END_ADDR <= ERR_A1_MX;
                    end
                    else 
                        if (RX_DATA_R[7:0]==8'h0a) begin
                            STATE <= TRES;
                            RES_REG <= RES_REG - DATA_REG; // from var sign = -
                            RES_FLG <= 1'b1;
                        end
                end
            end
            
            TRES: begin
                STATE <= TMEM;
                TX_DATA_T <= DATA;
                TX_RDY_T <= 1'b1;
                ADDR <= ADDR + 1'b1;
            end
            
            TMEM: begin
                if (TX_RDY_R) begin
                    if (ADDR == END_ADDR + 1) begin
                        if (RES_FLG) begin
                            STATE <= TDT;
                            RES_FLG <= 1'b0;
                            TX_DATA_T <= DC_ASCII_DATA;
                            RES_CT <= RES_CT + 1'b1;
                        end
                        else begin
                            STATE <= TCR;
                            TX_DATA_T <= 8'h0D;
                        end
                    end
                    else begin
                        TX_DATA_T <= DATA;
                        ADDR <= ADDR + 1'b1;
                    end
                end
            end
            
            TDT: begin
                if (TX_RDY_R) begin
                    if (RES_CT == 5'd21) begin // from var K = 21
                        STATE <= TCR;
                        TX_DATA_T <= 8'h0D;
                        RES_CT <= {5{1'b0}}; // from var
                    end
                    else begin
                        TX_DATA_T <= DC_ASCII_DATA;
                        RES_CT <= RES_CT + 1'b1;
                    end
                end
            end
            
            TCR: begin
                if (TX_RDY_R) begin
                    STATE <= TLF;
                    TX_DATA_T <= 8'h0A;
                end
            end
            
            TLF: begin
                if (TX_RDY_R) begin
                    STATE <= IDLE;
                    TX_RDY_T <= 1'b0;
                end
            end
            
            default: STATE <= IDLE;
        endcase

endmodule 