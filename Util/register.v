//Simple register

module register#(
  parameter WIDTH = 1
)(
  input clk,
  input [WIDTH-1:0] in_i,
  output reg [WIDTH-1:0]  out_o
);
  
  always@(posedge clk) begin
    out_o <= in_i;
  end
endmodule