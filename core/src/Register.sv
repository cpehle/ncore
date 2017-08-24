module Register #(parameter int width = 32) (input clk, input [width-1:0] in, output [width-1:0] out);
   logic [width-1:0] r;

   always_ff @(posedge clk) begin
      r[width-1:0] <= in;
   end

   assign out[width-1:0] = r;
endmodule
