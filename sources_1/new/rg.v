module rg(
    input CLK,
    input [2:0] D,
    input RST,
    input SET,
    input EN,
    output [2:0] Q
    );
    
dtr dtr2_isnt(
    .CLK(CLK),
    .D(D[2]),
    .RST(RST),
    .SET(SET),
    .EN(EN),
    .Q(Q[2])
);
dtr dtr1_isnt(
    .CLK(CLK),
    .D(D[1]),
    .RST(RST),
    .SET(SET),
    .EN(EN),
    .Q(Q[1])
);
dtr dtr0_isnt(
    .CLK(CLK),
    .D(D[0]),
    .RST(RST),
    .SET(SET),
    .EN(EN),
    .Q(Q[0])
);
    
endmodule
