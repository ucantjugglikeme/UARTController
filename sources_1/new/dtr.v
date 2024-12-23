module dtr(
    input CLK,
    input D,
    input RST,
    input SET,
    input EN,
    output reg Q
    );
    
always @(posedge CLK, posedge RST, posedge SET) begin
    if (RST) 
        Q <= 1'b0;
    else if (SET)
        Q <= 1'b1;
    else if (EN)
        Q <= D;
end
    
endmodule
