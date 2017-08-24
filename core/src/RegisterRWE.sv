module RegisterRWE #(parameter int width = 32) (input clk, input reset, input wen, input [width-1:0] in, output [width-1:0] out);

   logic [width-1:0] r, rn;

   always_comb begin
      rn = r;
      if (wen) begin
         rn[width-1:0] = in[width-1:0];
      end
   end

   always_ff @(posedge clk) begin
        if (reset) begin
           r[width-1:0] <= 0;
        end else begin
           r[width-1:0] <= rn[width-1:0];
        end
   end

   assign out[width-1:0] = r;
endmodule
