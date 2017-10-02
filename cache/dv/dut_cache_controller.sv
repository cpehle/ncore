`include "cache_pkg.sv"
module dut_cache_controller(/*AUTOARG*/
   // Outputs
   cpu_resp_data, cpu_resp_ready, mem_req_addr, mem_req_data,
   mem_req_rw, mem_req_valid,
   // Inputs
   clk, reset, cpu_req_rw, cpu_req_valid, cpu_req_addr, cpu_req_data,
   mem_resp_data, mem_resp_ready
   );

   input clk, reset;
      
   input logic cpu_req_rw;
   input logic cpu_req_valid;
   input logic [31:0] cpu_req_addr;
   input logic [31:0] cpu_req_data;

   output logic [31:0] cpu_resp_data;
   output logic        cpu_resp_ready;

   output logic [31:0]        mem_req_addr; 
   output logic [127:0]       mem_req_data; 
   output logic 	      mem_req_rw;
   output logic 	      mem_req_valid;

   input logic [127:0] 	      mem_resp_data;
   input logic 		      mem_resp_ready;

   cache::cpu_req_t cpu_req;
   cache::cpu_resp_t cpu_resp;
   cache::mem_req_t mem_req;
   cache::mem_resp_t mem_data;

   always_comb begin
      cpu_req.rw = cpu_req_rw;
      cpu_req.valid = cpu_req_valid;
      cpu_req.addr = cpu_req_addr;
      cpu_req.data = cpu_req_data;
      
      cpu_resp_data = cpu_resp.data;      
      cpu_resp_ready = cpu_resp.ready;      
      
      mem_req_addr = mem_req.addr; 
      mem_req_data = mem_req.data; 
      mem_req_rw = mem_req.rw;      
      mem_req_valid = mem_req.valid;      

      mem_data.data = mem_resp_data;
      mem_data.ready = mem_resp_ready;
   end
   
   cache_controller dut(/*AUTOINST*/
			// Interfaces
			.cpu_req	(cpu_req),
			.mem_data	(mem_data),
			.mem_req	(mem_req),
			.cpu_resp	(cpu_resp),
			// Inputs
			.clk		(clk),
			.reset		(reset));   
endmodule
// Local Variables:
// verilog-library-directories:("." "../src/")
// End:
