module VS_DIVIDER #(
    parameter DIV = 100000
)(
    input CLK,
    input RST,
    output reg CEO
    );

reg [$clog2(DIV) - 1:0] CLK_DIV_FLTR;

always @ (posedge CLK, posedge RST)
    if(RST) begin
        CLK_DIV_FLTR <= 17'h00000;
        CEO <= 1'b0;
    end
    else begin
        if(CLK_DIV_FLTR == DIV - 1) begin
            CLK_DIV_FLTR <= 17'h00000;
            CEO <= 1'b1;
        end
        else begin
            CLK_DIV_FLTR <= CLK_DIV_FLTR + 1;
            CEO <= 1'b0;
       end
    end
    
endmodule
