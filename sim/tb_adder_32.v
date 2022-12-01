`timescale 1ns / 1ps

/* ------------------------------------------------ *
 * Title       : Floating Point Adder Testbench     *
 * Project     : Floating Point Adder Multiplier    *
 * ------------------------------------------------ *
 * File        : tb_adder_32.v                      *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 01/12/2022                         *
 * ------------------------------------------------ */

module tb_add32();
  task compare_;
    input[31:0] a;
    input[31:0] b;

    if(a == b) begin
      $display("PASSED: Both values match!");
    end else begin
      $display("FAILED: Wrong calculation! ***********************");
    end
  endtask

  reg[40*8:0] state = "init";

  localparam BIT_SIZE = 32;
  localparam EXPONENT_SIZE =  8;
  localparam FRACTION_SIZE = 23;

  reg sign0, sign1, signExpected;
  wire signRes;
  reg  [EXPONENT_SIZE-1:0] exp0, exp1, expExpected;
  wire [EXPONENT_SIZE-1:0] expRes;
  reg  [FRACTION_SIZE-1:0] frac0, frac1, fracExpected;
  wire [FRACTION_SIZE-1:0] fracRes;

  wire overflow;
  wire zero;
  wire NaN;
  wire precisionLost;
  wire flagRaised;

  wire [BIT_SIZE-1:0] num0 = {sign0, exp0, frac0};
  wire [BIT_SIZE-1:0] num1 = {sign1, exp1, frac1};
  wire [BIT_SIZE-1:0] res;
  wire [BIT_SIZE-1:0] expected = {signExpected, expExpected, fracExpected};
  assign {signRes, expRes, fracRes} = res;

  wire error = res != expected;


  wire signed  [EXPONENT_SIZE:0] exp0_signed_abs        = (exp0-127+~|exp0);
  wire signed  [EXPONENT_SIZE:0] exp1_signed_abs        = (exp1-127+~|exp1);
  wire signed  [EXPONENT_SIZE:0] expRes_signed_abs      = (expRes-127+~|expRes);
  wire signed  [EXPONENT_SIZE:0] expExpected_signed_abs = (expExpected-127+~|expExpected);

  wire signed [1:0] sign0_pretty        = sign0        ? -1 : 1;
  wire signed [1:0] sign1_pretty        = sign1        ? -1 : 1;
  wire signed [1:0] signRes_pretty      = signRes      ? -1 : 1;
  wire signed [1:0] signExpected_pretty = signExpected ? -1 : 1;

  fp_adder #(
    .BIT_SIZE(BIT_SIZE),
    .FORMAT_OVERRIDE(0)
  )uut(
    .overflow(overflow),
    .zero(zero),
    .NaN(NaN),
    .precisionLost(precisionLost),
    .flagRaised(flagRaised),
    .num0(num0),
    .num1(num1),
    .res(res)
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,tb_add32);
    #1
    
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 0;
    exp1 = 0;
    expExpected = 0;
    frac0 = 0;
    frac1 = 0;
    fracExpected = 0;
    state = "add zeros";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);

    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 128;
    exp1 = 127;
    expExpected = 128;
    frac0 = 0;
    frac1 = 0;
    fracExpected = 23'h400000;
    state = "add 2 + 1";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);
    
    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 1;
    signExpected = 0;
    exp0 = 198;
    exp1 = 198;
    expExpected = 0;
    frac0 = 23'h241532;
    frac1 = 23'h241532;
    fracExpected = 23'h0;
    state = "same val diff sign";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 8'hFE;
    exp1 = 8'hFE;
    expExpected = 8'hFF;
    frac0 = 23'h7FFFFF;
    frac1 = 23'h7FFFFF;
    fracExpected = 23'h0;
    state = "Overflow 2 max";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 8'hFE;
    exp1 = 8'hFE - 23;
    expExpected = 8'hFF;
    frac0 = 23'h7FFFFF;
    frac1 = 23'h0;
    fracExpected = 23'h0;
    state = "Overflow carry chain";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 8'hFE;
    exp1 = 8'hFE - 24;
    expExpected = 8'hFE;
    frac0 = 23'h7FFFFF;
    frac1 = 23'h0;
    fracExpected = 23'h7FFFFF;
    state = "Close to overflow, p lost";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 1;
    signExpected = 0;
    exp0 = 8'hFE;
    exp1 = 8'h0;
    expExpected = 8'hFE;
    frac0 = 23'h7FFFFF;
    frac1 = 23'h1;
    fracExpected = 23'h7FFFFF;
    state = "Max min";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 1;
    signExpected = 0;
    exp0 = 8'hf4;
    exp1 = 8'hff;
    expExpected = 8'hFE;
    frac0 = 23'hbaba;
    frac1 = 23'h1;
    fracExpected = 23'h7FFFFF;
    state = "Not a Number";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(NaN, 1); //!special case


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 8'd142;
    exp1 = 8'd140;
    expExpected = 8'd143;
    frac0 = 23'd5285888;
    frac1 = 23'd6598785;
    fracExpected = 23'd322064;
    state = "Precision Lost + Valid calc";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 1;
    signExpected = 0;
    exp0 = 8'd126;
    exp1 = 8'd108;
    expExpected = 8'd126;
    frac0 = 23'd6421534;
    frac1 = 23'd1028205;
    fracExpected = 23'd6421499;
    state = "Random Tests";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 1;
    sign1 = 1;
    signExpected = 1;
    exp0 = 8'd169;
    exp1 = 8'd169;
    expExpected = 8'd170;
    frac0 = 23'd1560955;
    frac1 = 23'd6322329;
    fracExpected = 23'b01111000010010100001010;
    state = "Random Tests";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 1;
    signExpected = 1;
    exp0 = 8'd169;
    exp1 = 8'd169;
    expExpected = 8'd168;
    frac0 = 23'd1560955;
    frac1 = 23'd6322329;
    fracExpected = 23'b00100010100111000111100;
    state = "Random Tests";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 8'd0;
    exp1 = 8'd0;
    expExpected = 8'd0;
    frac0 = 23'd142415;
    frac1 = 23'd7152532;
    fracExpected = frac1+frac0;
    state = "2 Subnormal adds to subnormal";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 8'd0;
    exp1 = 8'd0;
    expExpected = 8'd1;
    frac0 = 23'b10110011010111011001111;
    frac1 = 23'b01001101001010100100100;
    fracExpected = frac1+frac0;
    state = "2 Subnormal adds to normal";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 0;
    sign1 = 0;
    signExpected = 0;
    exp0 = 8'd0;
    exp1 = 8'd1;
    expExpected = 8'd1;
    frac0 = 23'b10110001111100110100010;
    frac1 = 23'b00110100100001111000000;
    fracExpected = frac1+frac0;
    state = "Add normal and subnormal";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
    sign0 = 1;
    sign1 = 0;
    signExpected = 0;
    exp0 = 8'd10;
    exp1 = 8'd10;
    expExpected = 8'd0;
    frac0 = 23'b11010011001000110100010;
    frac1 = 23'b11010011001001111000000;
    fracExpected = (frac1-frac0) << 9;
    state = "Normal results to subnormal";
    #5
    $display("%s", state);
    $display("");
    $display("            %d * %b.%b * 2^(%d)", sign0_pretty, |exp0, frac0, exp0_signed_abs);
    $display("            %d * %b.%b * 2^(%d)", sign1_pretty, |exp1, frac1, exp1_signed_abs);
    $display("±_________________________________________________________________");
    $display("Calculated: %d * %b.%b * 2^(%d)", signRes_pretty, |expRes, fracRes, expRes_signed_abs);
    $display("Expected:   %d * %b.%b * 2^(%d)", signExpected_pretty, |expExpected, fracExpected, expExpected_signed_abs);
    $display("");
    if(NaN) begin
      $display("NaN!");
    end
    if(zero) begin
      $display("Zero!");
    end
    if(overflow) begin
      $display("Overflow!");
    end
    if(precisionLost) begin
      $display("Precision Lost!");
    end
    $display("");
    compare_(res, expected);


    #5
    $display("-----------------------------------------------------------");
  end
endmodule
