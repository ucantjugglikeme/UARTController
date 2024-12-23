`timescale 1ns / 1ps


module test_dc_hex_ascii;

reg [3:0] HEX_test;
wire [7:0] ASCII_test;

VS_DC_HEX_ASCII dc_inst(
    .HEX(HEX_test),
    .ASCII(ASCII_test)
);

initial begin
    HEX_test = 4'h0;
    #20;
    HEX_test = 4'h1;
    #20;
    HEX_test = 4'h2;
    #20;
    HEX_test = 4'h3;
    #20;
    HEX_test = 4'h4;
    #20;
    HEX_test = 4'h5;
    #20;
    HEX_test = 4'h6;
    #20;
    HEX_test = 4'h7;
    #20;
    HEX_test = 4'h8;
    #20;
    HEX_test = 4'h9;
    #20;
    HEX_test = 4'hA;
    #20;
    HEX_test = 4'hB;
    #20;
    HEX_test = 4'hC;
    #20;
    HEX_test = 4'hD;
    #20;
    HEX_test = 4'hE;
    #20;
    HEX_test = 4'hF;
    #20;
    $stop;
end

endmodule
