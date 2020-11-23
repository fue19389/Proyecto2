//Universidad del Valle de Guatemala
//Gerardo Fuentes
//19389

//Modulo de contador 12 bits
module counter12b (input[11:0] val, input load, en, clk0, reset0, output reg[11:0]sal);

  always@(posedge clk0, load, val, posedge reset0)
    if (reset0) sal <= 12'b0;
    else if (load) sal <= val;
    else if (en) sal <= sal + 1;

endmodule

//Modulo Flipflop tipo D 1 BIT
module DFF1b(input clk1, reset1, E1, D1, output reg Q1);

  always@(posedge clk1, posedge reset1, E1)
    if (reset1)  Q1<=1'b0;
    else if (E1) Q1<=D1;

endmodule

//Modulo Flipflop tipo D 2 BIT
module DFF2b(input clk2, reset2, E2, input[1:0]D2, output reg[1:0] Q2);

  always@(posedge clk2, posedge reset2, E2)
    if (reset2)  Q2<=2'b0;
    else if (E2) Q2<=D2;

endmodule

//Modulo Flipflop tipo D 4 BIT
module DFF4b(input clk3, reset3, E3, input[3:0]D3, output reg[3:0] Q3);

  always@(posedge clk3, posedge reset3, E3)
    if (reset3)  Q3<=4'b0;
    else if (E3) Q3<=D3;

endmodule


//Modulo Flipflop tipo T 1 BIT
module TFF1b(input clk4, reset4, E4, output Q4, QA4);

  not (QA4,Q4);
  DFF1b D1(clk4, reset4, E4, QA4, Q4);

endmodule

//Modulo de ROM
module ROM4K(input [11:0]adrs5, output [7:0]outt5);
  reg[7:0] ROM4K [0:4095];

  initial begin
     $readmemh("memory.list", ROM4K);
  end
  assign outt5 = ROM4K[adrs5];

endmodule


//Modulo Flipflop tipo D 8 BIT
module F8b(input clk6, reset6, E6, input[7:0]outrom4k6, output reg[3:0]instr6, oprnd6);

  always@(posedge clk6, posedge reset6, E6)
    if (reset6)  {instr6,oprnd6} <=8'b0;
    else if (E6) {instr6,oprnd6} <=outrom4k6;

endmodule

//Modulo bus driver triestado 4 bits
module buff(input E7, input[3:0]D7, output [3:0]Q7);

  assign Q7 = (E7) ? D7:4'bz;

endmodule

//Modulo accumulator
module Acc4b(input clk8, reset8, E8, input[3:0]oalu8, output reg[3:0]oaccu8);

  always@(posedge clk8, posedge reset8, E8)
    if (reset8)  oaccu8 <=4'b0000;
    else if (E8) oaccu8 <=oalu8;

endmodule

//Modulo ALU
module ALU4b(input[3:0]inpta, inptb, input[2:0]seg,
             output reg carry, output zero, output reg[3:0]oupt);

  always@(*)begin
    case(seg)
      3'b000: {carry,oupt} <= inpta;
      3'b001: {carry,oupt} <= inpta - inptb;
      3'b010: {carry,oupt} <= inptb;
      3'b011: {carry,oupt} <= inpta + inptb;
      3'b100: {carry,oupt} <= ~(inpta & inptb);
    default:
     {carry,oupt} <= 5'b0;
   endcase
  end
  assign zero = (oupt==4'b0) ? 1'b1:1'b0;

endmodule


//Módulo decode
module dcdd(input[6:0] adrs9, output reg[12:0]data9);

  always @(adrs9) begin
    casez (adrs9)
      7'bzzzzzz0: data9 <= 13'b1000000001000;
      7'b00001z1: data9 <= 13'b0100000001000;
      7'b00000z1: data9 <= 13'b1000000001000;
      7'b00011z1: data9 <= 13'b1000000001000;
      7'b00010z1: data9 <= 13'b0100000001000;
      7'b0010zz1: data9 <= 13'b0001001000010;
      7'b0011zz1: data9 <= 13'b1001001100000;
      7'b0100zz1: data9 <= 13'b0011010000010;
      7'b0101zz1: data9 <= 13'b0011010000100;
      7'b0110zz1: data9 <= 13'b1011010100000;
      7'b0111zz1: data9 <= 13'b1000000111000;
      7'b1000z11: data9 <= 13'b0100000001000;
      7'b1000z01: data9 <= 13'b1000000001000;
      7'b1001z11: data9 <= 13'b1000000001000;
      7'b1001z01: data9 <= 13'b0100000001000;
      7'b1010zz1: data9 <= 13'b0011011000010;
      7'b1011zz1: data9 <= 13'b1011011100000;
      7'b1100zz1: data9 <= 13'b0100000001000;
      7'b1101zz1: data9 <= 13'b0000000001001;
      7'b1110zz1: data9 <= 13'b0011100000010;
      7'b1111zz1: data9 <= 13'b1011100100000;
      default: data9 <= 13'b0000000000000;
    endcase
  end
endmodule

//Modulo RAM
module Ram(input[11:0]adrs11, input cs, we, inout[3:0]data11);
    reg[3:0] data_out;
    reg[3:0] memory [0:4095];

  assign data11 = (cs && ~we) ? data_out : 4'bz;

  always @ (adrs11 or data11 or cs or we)
    if (cs && we) begin
      memory[adrs11] <= data11;
    end

    else if (cs && ~we) begin
      data_out <= memory[adrs11];
    end
endmodule


//Procesador
module uP(input clock, reset,
          input[3:0]pushbuttons,
          output nphase, phase, c_flag, z_flag, c_alu, zo_alu,
          output[1:0] flagsout, flagsin,
          output[3:0]instr, oprnd, accu, data_bus, FF_out, outalu,
          output[6:0]dcdrs,
          output[7:0]program_byte,
          output[11:0]PC, address_RAM,
          output[12:0]csignals);

  assign address_RAM = {oprnd,program_byte};
  assign dcdrs = {instr,c_flag,z_flag,phase};
  assign flagsout = {c_flag,z_flag};
  assign flagsin = {c_alu, zo_alu};

  counter12b  pCNT(address_RAM, csignals[11], csignals[12], clock, reset, PC);
  ROM4K       pROM(PC, program_byte);
  F8b         ftch(clock, reset, nphase, program_byte, instr, oprnd);
  buff        bus1(csignals[1], oprnd, data_bus);
  buff        bus2(csignals[3], outalu, data_bus);
  ALU4b       alu4(accu, data_bus, csignals[8:6], c_alu, zo_alu, outalu);
  Acc4b       acum(clock, reset, csignals[10], outalu, accu);
  dcdd        DCOD(dcdrs, csignals);
  DFF2b       FLGS(clock, reset, csignals[9], flagsin, flagsout);
  TFF1b       PHSE(clock, reset, 1'b1, phase, nphase);
  Ram         RAM4(address_RAM, csignals[5], csignals[4], data_bus);
  DFF4b       inpt(clock, reset, csignals[2], pushbuttons, data_bus);
  DFF4b       oupt(clock, reset, csignals[0], data_bus, FF_out);

endmodule
