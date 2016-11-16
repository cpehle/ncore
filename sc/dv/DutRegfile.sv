module DutRegfile(/*AUTOARG*/
   // Outputs
   rf_out_rs1_data, rf_out_rs2_data,
   // Inputs
   clk, rf_in_rs1_addr, rf_in_rs2_addr, rf_in_waddr, rf_in_wdata,
   rf_in_we
   );
   input logic [4:0] rf_in_rs1_addr;
   input logic [4:0] rf_in_rs2_addr;
   input logic [4:0] rf_in_waddr;
   input logic [31:0] rf_in_wdata;
   input logic        rf_in_we;
   output logic       rf_out_rs1_data;
   output logic       rf_out_rs2_data;

   always_comb begin
      rf_in.rs1_addr = rf_in_rs1_addr;
      rf_in.rs2_addr = rf_in_rs2_addr;
      rf_in.waddr = rf_in_waddr;
      rf_in.wdata = rf_in_wdata;
      rf_in.we = rf_in_we;
      rf_out_rs1_data = rf_out.rs1_data;
      rf_out_rs2_data = rf_out.rs2_data;
   end

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To rf of RegisterFile.v
   // End of automatics
   Bundle::RegisterFileIn rf_in;
   Bundle::RegisterFileOut rf_out;



   RegisterFile rf(/*AUTOINST*/
                   // Interfaces
                   .rf_in               (rf_in),
                   .rf_out              (rf_out),
                   // Inputs
                   .clk                 (clk));
endmodule
// Local Variables:
// verilog-library-directories:("." "../src/")
// End:
