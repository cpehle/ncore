/// @file Core.sv
/// @author Christian Pehle
/// @brief the processor core
`include "Bundle.sv"
module Core(input clk,
            input  reset,
            input  Bundle::MemoryOut imem_in,
            output Bundle::MemoryIn imem_out,
            input  Bundle::MemoryOut dmem_in,
            output Bundle::MemoryIn dmem_out
            );

   Bundle::ControlToData ctl;
   Bundle::DataToControl dat;
   /*AUTOWIRE*/

   ControlPath c(/*AUTOINST*/
                 // Interfaces
                 .ctl                   (ctl),
                 .dat                   (dat),
                 .imem_in               (imem_in),
                 .imem_out              (imem_out),
                 .dmem_in               (dmem_in),
                 .dmem_out              (dmem_out),
                 // Inputs
                 .clk                   (clk),
                 .reset                 (reset));
   DataPath d(/*AUTOINST*/
              // Interfaces
              .ctl                      (ctl),
              .dat                      (dat),
              .imem_in                  (imem_in),
              .imem_out                 (imem_out),
              .dmem_in                  (dmem_in),
              .dmem_out                 (dmem_out),
              // Inputs
              .clk                      (clk));
endmodule; // Core
