module rg2#(
    parameter WDT = 8
)(
    input CLK,
    input [WDT - 1:0] D,
    input RST,
    input SET,
    input EN,
    output reg [WDT - 1:0] Q
);
    
always @(posedge CLK, posedge RST, posedge SET) begin
    if (RST) 
        Q <= 0;
    else if (SET)
        Q <= {WDT{1'b1}};
    else if (EN)
        Q <= D;
end
    
endmodule
