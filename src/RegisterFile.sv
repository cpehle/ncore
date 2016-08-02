`include "Bundle.sv"
module RegisterFile(input clk,
                    input  Bundle::RegisterFileIn rf_in,
                    output Bundle::RegisterFileOut rf_out);

   logic [31:0]            regfile[32];
   logic [31:0]            regfile_next[32];

   always_comb begin
      regfile_next = regfile;
      if (rf_in.we) begin
         regfile_next[rf_in.waddr] = rf_in.wdata;
      end
   end

   always_ff @(posedge clk) begin
      regfile <= regfile_next;
   end

   assign rf_out.rs1_data = regfile[rf_in.rs1_addr];
   assign rf_out.rs2_data = regfile[rf_in.rs2_addr];
endmodule; // RegisterFile
