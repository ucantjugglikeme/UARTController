`timescale 1ns / 1ps


module test_dc_ascii_hex;

reg [7:0] ASCII_test;
wire [3:0] HEX_test;
wire HEX_FLG_test;

VS_DC_ASCII_HEX dc_inst(
    .ASCII(ASCII_test),
    .HEX(HEX_test),
    .HEX_FLG(HEX_FLG_test)
);

initial begin
    ASCII_test = 8'h00;
    #20;
    ASCII_test = 8'h30;
    #20;
    ASCII_test = 8'h31;
    #20;
    ASCII_test = 8'h32;
    #20;
    ASCII_test = 8'h33;
    #20;
    ASCII_test = 8'h34;
    #20;
    ASCII_test = 8'h35;
    #20;
    ASCII_test = 8'h36;
    #20;
    ASCII_test = 8'h37;
    #20;
    ASCII_test = 8'h38;
    #20;
    ASCII_test = 8'h39;
    #20;
    ASCII_test = 8'h41;
    #20;
    ASCII_test = 8'h61;
    #20;
    ASCII_test = 8'h42;
    #20;
    ASCII_test = 8'h62;
    #20;
    ASCII_test = 8'h43;
    #20;
    ASCII_test = 8'h63;
    #20;
    ASCII_test = 8'h44;
    #20;
    ASCII_test = 8'h64;
    #20;
    ASCII_test = 8'h45;
    #20;
    ASCII_test = 8'h65;
    #20;
    ASCII_test = 8'h46;
    #20;
    ASCII_test = 8'h66;
    #20;
    $stop;
end

endmodule
