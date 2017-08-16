`include "Bundle.sv"
module Core(input clk,
            input  reset,
            input  Bundle::MemoryOut imem_out,
            output Bundle::MemoryIn imem_in,
            input  Bundle::MemoryOut dmem_out,
            output Bundle::MemoryIn dmem_in
            );

   Bundle::ControlToData ctl;
   Bundle::DataToControl dat;

   ControlPath c(/*AUTOINST*/
		 // Interfaces
		 .ctl			(ctl),
		 .dat			(dat),
		 .imem_out		(imem_out),
		 .imem_in		(imem_in),
		 .dmem_out		(dmem_out),
		 .dmem_in		(dmem_in),
		 // Inputs
		 .clk			(clk),
		 .reset			(reset));

   DataPath d(/*AUTOINST*/
	      // Interfaces
	      .ctl			(ctl),
	      .dat			(dat),
	      .imem_in			(imem_in),
	      .imem_out			(imem_out),
	      .dmem_in			(dmem_in),
	      .dmem_out			(dmem_out),
	      // Inputs
	      .clk			(clk));
endmodule // Core
