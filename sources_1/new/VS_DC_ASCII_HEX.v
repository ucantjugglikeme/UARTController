module VS_DC_ASCII_HEX(
    input [7:0] ASCII,
    output reg [3:0] HEX,
    output reg HEX_FLG
    );
    
always @* begin
    HEX_FLG = 1'b1;
    case(ASCII)
        8'h30: HEX = 4'h0;
        8'h31: HEX = 4'h1;
        8'h32: HEX = 4'h2;
        8'h33: HEX = 4'h3;
        8'h34: HEX = 4'h4;
        8'h35: HEX = 4'h5;
        8'h36: HEX = 4'h6;
        8'h37: HEX = 4'h7;
        8'h38: HEX = 4'h8;
        8'h39: HEX = 4'h9;
        8'h41, 8'h61: HEX = 4'hA;
        8'h42, 8'h62: HEX = 4'hB;
        8'h43, 8'h63: HEX = 4'hC;
        8'h44, 8'h64: HEX = 4'hD;
        8'h45, 8'h65: HEX = 4'hE;
        8'h46, 8'h66: HEX = 4'hF;
        default: begin 
            HEX = 4'h0;
            HEX_FLG = 1'b0;
        end
    endcase
end
    
endmodule
