module VS_ROM #(
    parameter WIDTH = 7
)(
    input [WIDTH-1:0] ADDR,
    output [7:0] DATA
);
    
reg [7:0] ROM0 [0:2**WIDTH - 1];

initial begin 
    $readmemh("ROM.mem", ROM0);
end

assign DATA = ROM0[ADDR];
    
endmodule
