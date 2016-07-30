
module Core(input clk,
            input  reset,
            input  Bundle::MemoryOut imem_in,
            output Bundle::MemoryIn imem_out,
            input  Bundle::MemoryOut dmem_in,
            output Bundle::MemoryIn dmem_out
            );


   Bundle::ControlToData ctl;
   Bundle::DataToControl dat;

   ControlPath c(.ctl, .dat, .imem_in, .imem_out, .dmem_in, .dmem_out);
   DataPath d(.ctl, .dat, .imem_in, .imem_out, .dmem_in, .dmem_out);




endmodule; // Core
