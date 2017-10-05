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

   ControlPath c(.imem_out_res_valid	(imem_out.res_valid),
		 .dmem_out_res_valid    (dmem_out.res_valid),
		 /*AUTOINST*/
		 // Interfaces
		 .ctl			(ctl),
		 .dat			(dat),
		 .imem_in		(imem_in),
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
	      .clk			(clk),
	      .reset			(reset));
endmodule // Core
