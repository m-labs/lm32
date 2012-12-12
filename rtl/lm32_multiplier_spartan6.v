/*
 * LatticeMico32
 * Copyright (C) 2007, 2008, 2009, 2010 Sebastien Bourdeauducq
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module lm32_multiplier(
    input clk_i,
    input rst_i,
    input stall_x,
    input stall_m,
    input [31:0] operand_0,
    input [31:0] operand_1,
    output [31:0] result
);

// See UG389, esp. p. 29 "Fully Pipelined, 35 x 35 Multiplier Use Model (Large Multiplier)"

wire [17:0] au = {3'd0, operand_0[31:17]};
wire [17:0] al = {1'b0, operand_0[16:0]};
wire [17:0] bu = {3'd0, operand_1[31:17]};
wire [17:0] bl = {1'b0, operand_1[16:0]};

wire [17:0] bl_forward;
wire [35:0] al_bl;

reg [16:0] result_low;
always @(posedge clk_i) begin
    if(rst_i)
        result_low <= 17'd0;
    else
        result_low <= al_bl[16:0];
end
assign result[16:0] = result_low;

DSP48A1 #(
    .A0REG(1),
    .A1REG(0),
    .B0REG(1),
    .B1REG(0),
    .CARRYINREG(0),
    .CARRYINSEL("OPMODE5"),
    .CARRYOUTREG(0),
    .CREG(0),
    .DREG(0),
    .MREG(1),
    .OPMODEREG(0),
    .PREG(0),
    .RSTTYPE("SYNC")
) D1 (
    .BCOUT(bl_forward),
    .PCOUT(),
    .CARRYOUT(),
    .CARRYOUTF(),
    .M(al_bl),
    .P(),
    .PCIN(),
    .CLK(clk_i),
    .OPMODE(8'd1),
    .A(al),
    .B(bl),
    .C(),
    .CARRYIN(),
    .D(),
    .CEA(~stall_x),
    .CEB(~stall_x),
    .CEC(),
    .CECARRYIN(),
    .CED(),
    .CEM(~stall_m),
    .CEOPMODE(),
    .CEP(1'b1),
    .RSTA(rst_i),
    .RSTB(rst_i),
    .RSTC(),
    .RSTCARRYIN(),
    .RSTD(),
    .RSTM(rst_i),
    .RSTOPMODE(),
    .RSTP()
);

wire [47:0] au_bl_sum;

DSP48A1 #(
    .A0REG(1),
    .A1REG(0),
    .B0REG(0),
    .B1REG(0),
    .CARRYINREG(0),
    .CARRYINSEL("OPMODE5"),
    .CARRYOUTREG(0),
    .CREG(0),
    .DREG(0),
    .MREG(1),
    .OPMODEREG(0),
    .PREG(0),
    .RSTTYPE("SYNC")
) D2 (
    .BCOUT(),
    .PCOUT(au_bl_sum),
    .CARRYOUT(),
    .CARRYOUTF(),
    .M(),
    .P(),
    .PCIN(),
    .CLK(clk_i),
    .OPMODE(8'd13),
    .A(au),
    .B(bl_forward),
    .C({31'd0, al_bl[33:17]}),
    .CARRYIN(),
    .D(),
    .CEA(~stall_x),
    .CEB(),
    .CEC(),
    .CECARRYIN(),
    .CED(),
    .CEM(~stall_m),
    .CEOPMODE(),
    .CEP(),
    .RSTA(rst_i),
    .RSTB(),
    .RSTC(),
    .RSTCARRYIN(),
    .RSTD(),
    .RSTM(rst_i),
    .RSTOPMODE(),
    .RSTP()
);

wire [47:0] r_full;
assign result[31:17] = r_full[16:0];

DSP48A1 #(
    .A0REG(1),
    .A1REG(0),
    .B0REG(1),
    .B1REG(0),
    .CARRYINREG(0),
    .CARRYINSEL("OPMODE5"),
    .CARRYOUTREG(0),
    .CREG(0),
    .DREG(0),
    .MREG(1),
    .OPMODEREG(0),
    .PREG(1),
    .RSTTYPE("SYNC")
) D3 (
    .BCOUT(),
    .PCOUT(),
    .CARRYOUT(),
    .CARRYOUTF(),
    .M(),
    .P(r_full),
    .PCIN(au_bl_sum),
    .CLK(clk_i),
    .OPMODE(8'd5),
    .A(bu),
    .B(al),
    .C(),
    .CARRYIN(),
    .D(),
    .CEA(~stall_x),
    .CEB(~stall_x),
    .CEC(),
    .CECARRYIN(),
    .CED(),
    .CEM(~stall_m),
    .CEOPMODE(),
    .CEP(1'b1),
    .RSTA(rst_i),
    .RSTB(rst_i),
    .RSTC(),
    .RSTCARRYIN(),
    .RSTD(),
    .RSTM(rst_i),
    .RSTOPMODE(),
    .RSTP(rst_i)
);

endmodule
