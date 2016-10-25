`include "Bundle.sv"
module RegisterFile(input clk,
                    input  Bundle::RegisterFileIn rf_in,
                    output Bundle::RegisterFileOut rf_out);

   logic [31:0] rf[0:31];
   logic [31:0] rfn[0:31];

   always_comb begin
      for (int i = 0; i < 32; i++) begin
         rfn[i] = rf[i];
      end
      if (rf_in.we && (rf_in.waddr != 5'd0)) begin
         rfn[rf_in.waddr] = rf_in.wdata;
      end
   end

   always_ff @(posedge clk) begin
      for (int i = 0; i < 32; i++) begin
         rf[i] <= rfn[i];
      end
   end

   assign rf_out.rs1_data[31:0] = (rf_in.rs1_addr == 5'd0) ? 32'b0 : ((rf_in.rs1_addr == rf_in.waddr) && rf_in.we) ? rf_in.wdata : rf[rf_in.rs1_addr];
   assign rf_out.rs2_data[31:0] = (rf_in.rs2_addr == 5'd0) ? 32'b0 : ((rf_in.rs2_addr == rf_in.waddr) && rf_in.we) ? rf_in.wdata : rf[rf_in.rs2_addr];
endmodule // RegisterFile
