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
   
endmodule
