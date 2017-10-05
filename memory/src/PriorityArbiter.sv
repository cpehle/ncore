module PriorityArbiter(
   // Outputs
   grant,
   // Inputs
   request
   );

   parameter N = 10;
   input [N-1:0] request;
   output [N-1:0] grant; ///< one hot encoding

   wire [N-1:0] waitmask;
   genvar         j;
   generate
         assign waitmask[0]   = 1'b0;
         for (j=N-1; j>=1; j=j-1) begin
                assign waitmask[j] = |request[j-1:0];
         end
   endgenerate

   //grant circuit
   assign grant [N-1:0] = request[N-1:0] & ~waitmask[N-1:0];
endmodule
