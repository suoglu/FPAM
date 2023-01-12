`timescale 1ns / 1ps

/* ------------------------------------------------ *
 * Title       : Floating Point Adder               *
 * Project     : Floating Point Adder Multiplier    *
 * ------------------------------------------------ *
 * File        : fp_adder.v                         *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 12/01/2023                         *
 * ------------------------------------------------ *
 * Description : Floating point adder               *
 * ------------------------------------------------ *
 * Revisions                                        *
 *     v1      : Inital version                     *
 * ------------------------------------------------ */

module fp_adder#(
  parameter BIT_SIZE = 32,
  parameter ROUNDING_TYPE = 0,
  parameter ENABLE_FLAGS_MASTER = 1,
  parameter ENABLE_FLAGS_COMMON = 1,
  parameter ENABLE_FLAGS_OF     = 1,
  parameter ENABLE_FLAGS_ZERO   = 1,
  parameter ENABLE_FLAGS_NaN    = 1,
  parameter ENABLE_FLAGS_PLost  = 1,
  parameter FORMAT_OVERRIDE     = 0, //!not supported, if enabled BIT_SIZE must be set accordingly
  parameter EXPONENT_SIZE_OR    = 5, // BIT_SIZE = 1 + EXPONENT_SIZE_OR + FRACTION_SIZE_OR
  parameter FRACTION_SIZE_OR    = 10
)(
  //Optional Flags
  output overflow,
  output zero,
  output NaN,
  output precisionLost,
  output flagRaised,

  input  [BIT_SIZE-1:0] num0,
  input  [BIT_SIZE-1:0] num1,
  output [BIT_SIZE-1:0] res
);
  integer i, j;
  localparam ENABLE_NaN      = ENABLE_FLAGS_MASTER && ENABLE_FLAGS_NaN;
  localparam ENABLE_ZERO     = ENABLE_FLAGS_MASTER && ENABLE_FLAGS_ZERO;
  localparam ENABLE_OVERFLOW = ENABLE_FLAGS_MASTER && ENABLE_FLAGS_OF;
  localparam ENABLE_PRESLOST = ENABLE_FLAGS_MASTER && ENABLE_FLAGS_PLost;
  initial begin
    if(BIT_SIZE != 32 && BIT_SIZE != 64 && !FORMAT_OVERRIDE) begin
      $error("Only binary32 and binary64 are supported!");
    end
    if(FORMAT_OVERRIDE) begin
      $display("WARNING: Set to override mode. This mode is not supported/tested, design may not work properly.");
    end
  end
  localparam EXPONENT_SIZE = FORMAT_OVERRIDE ? EXPONENT_SIZE_OR : BIT_SIZE == 64 ? 11 :  8;
  localparam FRACTION_SIZE = FORMAT_OVERRIDE ? FRACTION_SIZE_OR : BIT_SIZE == 64 ? 52 : 23;

  //Decode values
  wire sign0, sign1, signBig, signSmall, signRes;
  wire [EXPONENT_SIZE-1:0] exp0, exp1, expBig, expSmall, expRes;
  wire [FRACTION_SIZE-1:0] frac0, frac1, fracBig, fracSmall, fracRes;
  wire [BIT_SIZE-1:0] numBig, numSmall, numRes;

  assign {sign0,     exp0,     frac0}     = num0;
  assign {sign1,     exp1,     frac1}     = num1;
  assign {signBig,   expBig,   fracBig}   = numBig;
  assign {signSmall, expSmall, fracSmall} = numSmall;

  wire op = sign0 ^ sign1; //or equal maybe; 0: add 1: subtract
  wire bothSubnorm = ~|{exp0, exp1};

  //Determine big and small number
  wire bigNum = (exp1 == exp0) ? (frac1 > frac0) : (exp1 > exp0);
  assign numBig   = bigNum ? num1 : num0;
  assign numSmall = bigNum ? num0 : num1;
  wire  bigInf    = &expBig && ~|fracBig;
  wire  bigSubN   = ~|expBig;
  wire  smallInf  = &expSmall && ~|fracSmall;
  wire  smallSubN = ~|expSmall;
  wire [FRACTION_SIZE:0]   bigFloat = {|expBig,  fracBig};
  wire [FRACTION_SIZE:0] smallFloat = {|expSmall,fracSmall};
  wire [FRACTION_SIZE:0] resFloat_pre;
  wire [FRACTION_SIZE:0] resFloat;

  //Calculation helpers
  wire resZero = op ?  {exp0, frac0} == {exp1, frac1} : //sub: both has same value
                    !(|{exp0, frac0} | |{exp1, frac1}); //add: both zero
  wire resOverflow = (&expBig || (&expBig[1+:EXPONENT_SIZE-1] && expInc)) && ~NaN; 
  //if big num is inf or exponent of result overflows and both nums are number ^
  wire [EXPONENT_SIZE-1:0] expDiff = expBig - expSmall - (!bothSubnorm && smallSubN);
  wire [FRACTION_SIZE:0] lostValue, smallFloat_shifted, smallFloat_shifted_pre;
  wire lostAll = ENABLE_FLAGS_PLost ? expDiff > (FRACTION_SIZE+1) : 0;
  assign {smallFloat_shifted_pre, lostValue} = {smallFloat, {FRACTION_SIZE+1{1'b0}}} >> expDiff;
  assign smallFloat_shifted = ROUNDING_TYPE && lostValue[FRACTION_SIZE] ?  smallFloat_shifted_pre + 1 : smallFloat_shifted_pre;
  reg expInc;
  always@* begin //gaint array of and-or
    expInc = 0;
    for(i = 0; FRACTION_SIZE >= i; i = i + 1) begin
      expInc = expInc ? bigFloat[i] | smallFloat_shifted[i] | (bothSubnorm && (i == FRACTION_SIZE)) : bigFloat[i] & smallFloat_shifted[i];
    end
    expInc = expInc && !op;
  end 
  reg [EXPONENT_SIZE-1:0] expDec;
  reg prevSame;
  always@* begin
    if(op && (exp0 == exp1)) begin
      expDec = 1;
      prevSame = 1;
      for (j = FRACTION_SIZE; j > 0; j = j-1) begin
        expDec   = expDec + (!(frac0[j-1] ^ frac1[j-1]) && prevSame);
        prevSame =           !(frac0[j-1] ^ frac1[j-1]) && prevSame;
      end
      expDec = expDec < exp0 ? expDec : (exp0-1); //!exponent cannot underflow
    end else begin
      expDec = 0;
    end
  end

  //Calculate the result
  wire expSign_extention; //redundant
  wire [EXPONENT_SIZE-1:0] expRes_pre;
  assign signRes = signBig;
  assign {expSign_extention, expRes_pre} = {1'b0, expBig} + {{EXPONENT_SIZE{1'b0}}, expInc} - {1'b0, expDec}; //MSB is redundant
  assign resFloat_pre = op ? bigFloat - smallFloat_shifted : bigFloat + smallFloat_shifted;
  assign resFloat = (!bothSubnorm && expInc) ? {1'b1, resFloat_pre[1+:FRACTION_SIZE]} : (resFloat_pre << expDec);

  assign fracRes = (resZero || resOverflow) ?                         {FRACTION_SIZE{1'b0}}        : resFloat[0+:FRACTION_SIZE];
  assign expRes  = (resZero || resOverflow || (expDec == (exp0-1))) ? {EXPONENT_SIZE{resOverflow}} : (expRes_pre);
  assign res = {signRes,expRes,fracRes};
  
  //Optional Flags
  assign NaN = ENABLE_NaN ?  (&exp0 && |frac0) || (&exp1 && |frac1): 0; //if at least one of the operands NaN
  assign overflow = ENABLE_OVERFLOW ? resOverflow : 0; 
  assign precisionLost = ENABLE_PRESLOST ? |lostValue || (lostAll && |smallFloat) : 0;
  assign zero = !ENABLE_ZERO ? 0 : resZero;
  assign flagRaised = ENABLE_FLAGS_COMMON ? NaN | overflow | precisionLost | zero : 0;
endmodule

