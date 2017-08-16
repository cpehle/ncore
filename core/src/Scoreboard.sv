module Scoreboard(/*AUTOARG*/
   // Outputs
   read, read_bypassed,
   // Inputs
   clk, nreset, addr, en, set, clear
   );
   parameter int width = 32;
   parameter logic zero = 1'b0;

   input logic     clk;
   input logic     nreset;
   input logic [$clog2(width)-1:0] addr;
   input logic                     en;
   input logic                     set;
   input logic                     clear;
   output logic                    read;
   output logic                    read_bypassed;

   // internal state
   logic [width-1:0] r, rn;

   always_comb begin
      read_bypassed = rn[addr];
      read = r[addr];
   end

   always_ff @(posedge clk) begin
      if (nreset) begin
         r <= rn;
      end else begin
         r <= '0;
      end
   end
endmodule
