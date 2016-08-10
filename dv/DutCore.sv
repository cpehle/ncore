`include "Bundle.sv"
module DutCore(/*AUTOARG*/
   // Outputs
   imem_out_req_ready, imem_out_res_valid, imem_out_res_data,
   dmem_out_req_ready, dmem_out_res_valid, dmem_out_res_data,
   // Inputs
   clk, reset, imem_in_req_addr, imem_in_req_data, imem_in_req_fcn,
   imem_in_req_typ, imem_in_req_valid, dmem_in_req_addr,
   dmem_in_req_data, dmem_in_req_fcn, dmem_in_req_typ,
   dmem_in_req_valid
   );
   input clk, reset;
   input logic [31:0] imem_in_req_addr;
   input logic [31:0] imem_in_req_data;
   input logic [1:0] imem_in_req_fcn;
   input logic [2:0] imem_in_req_typ;
   input imem_in_req_valid;
   input logic [31:0] dmem_in_req_addr;
   input logic [31:0] dmem_in_req_data;
   input logic [1:0]  dmem_in_req_fcn;
   input logic [2:0]  dmem_in_req_typ;
   input              dmem_in_req_valid;
   output logic       imem_out_req_ready;
   output logic       imem_out_res_valid;
   output logic [31:0] imem_out_res_data;
   output logic        dmem_out_req_ready;
   output logic        dmem_out_res_valid;
   output logic [31:0] dmem_out_res_data;

   Bundle::MemoryIn imem_in;
   Bundle::MemoryOut imem_out;
   Bundle::MemoryIn dmem_in;
   Bundle::MemoryOut dmem_out;

   always_comb begin
      imem_in.req.addr = imem_in_req_addr;
      imem_in.req.data = imem_in_req_data;
      imem_in.req.fcn  = imem_in_req_fcn;
      imem_in.req.typ  = imem_in_req_typ;
      imem_in.req_valid = imem_in_req_valid;
      dmem_in.req.addr = dmem_in_req_addr;
      dmem_in.req.data = dmem_in_req_data;
      dmem_in.req.fcn  = dmem_in_req_fcn;
      dmem_in.req.typ  = dmem_in_req_typ;
      dmem_in.req_valid = dmem_in_req_valid;
      imem_out_req_ready = imem_out.req_ready;
      imem_out_res_valid = imem_out.res_valid;
      imem_out_res_data = imem_out.res.data;
      dmem_out_req_ready = dmem_out.req_ready;
      dmem_out_res_valid = dmem_out.res_valid;
      dmem_out_res_data = dmem_out.res.data;
   end

   Core c(/*AUTOINST*/
          // Interfaces
          .imem_out                     (imem_out),
          .imem_in                      (imem_in),
          .dmem_out                     (dmem_out),
          .dmem_in                      (dmem_in),
          // Inputs
          .clk                          (clk),
          .reset                        (reset));

endmodule
// Local Variables:
// verilog-library-directories:("." "../src/")
// End:
