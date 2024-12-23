module VS_GENERR(
    input [9:0] RX_DATA_T,
    input GEN_FRT_ERR,
    input GEN_PAR_ERR,
    output [9:0] DATA
    );
    
wire xor_1;
wire xor_2;

assign xor_1 = RX_DATA_T[9] ^ GEN_FRT_ERR;
assign xor_2 = RX_DATA_T[8] ^ GEN_PAR_ERR;
assign DATA = {xor_1, xor_2, RX_DATA_T[7:0]};
    
endmodule
