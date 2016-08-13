`include "Bundle.sv"
module RegisterFile(input clk,
                    input  Bundle::RegisterFileIn rf_in,
                    output Bundle::RegisterFileOut rf_out);
   logic [31:0]            rf[31:0];

   assign rf_out.rs1_data = rf[rf_in.rs1_addr];
   assign rf_out.rs2_data = rf[rf_in.rs2_addr];

   always_ff @(posedge clk) begin
      if (rf_in.we) begin
         rf[rf_in.waddr] <= rf_in.wdata;
      end
   end
endmodule; // RegisterFile
