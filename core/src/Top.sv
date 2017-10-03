`include "Bundle.sv"
module top(
	   input clk,
	   input reset
);   
   Core c(/*AUTOINST*/
	  // Interfaces
	  .imem_out			(imem_out),
	  .imem_in			(imem_in),
	  .dmem_out			(dmem_out),
	  .dmem_in			(dmem_in),
	  // Inputs
	  .clk				(clk),
	  .reset			(reset));

   cache_controller dcache(/*AUTOINST*/
			   // Interfaces
			   .cpu_req		(cpu_req),
			   .mem_data		(mem_data),
			   .mem_req		(mem_req),
			   .cpu_resp		(cpu_resp),
			   // Inputs
			   .clk			(clk),
			   .reset		(reset));
   cache_controller icache(/*AUTOINST*/);   
endmodule
// Local Variables:
// verilog-library-directories:("." "../../cache/src")
// End:
