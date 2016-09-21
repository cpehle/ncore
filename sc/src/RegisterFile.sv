`include "Bundle.sv"
module RegisterFile(input clk,
                    input  Bundle::RegisterFileIn rf_in,
                    output Bundle::RegisterFileOut rf_out);
   /*verilator public_module*/

   logic [31:0]            rf[0:31];
   logic [31:0]            rs1;
   logic [31:0]            rs2;

   always_comb begin
      if (rf_in.rs1_addr == 5'd0) begin
         rs1 = 32'd0;
      end else if (rf_in.rs1_addr == rf_in.waddr && rf_in.we) begin
         rs1 = rf_in.wdata;
      end else begin
         rs1[31:0] = rf[rf_in.rs1_addr][31:0];
      end
   end

   always_comb begin
      if (rf_in.rs2_addr == 5'd0) begin
         rs2 = 32'd0;
      end else if (rf_in.rs2_addr == rf_in.waddr && rf_in.we) begin
         rs2 = rf_in.wdata;
      end else begin
         rs2[31:0] = rf[rf_in.rs2_addr][31:0];
      end
   end

   always_ff @(posedge clk) begin
      if (rf_in.we && (rf_in.waddr != 5'd0)) begin
         rf[rf_in.waddr] <= rf_in.wdata;
      end
   end

   assign rf_out.rs1_data = rs1;
   assign rf_out.rs2_data = rs2;
endmodule // RegisterFile
