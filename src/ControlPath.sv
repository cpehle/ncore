module ControlPath(
                   output Bundle::ControlToData ctl,
                   input  Bundle::DataToControl dat,
                   input  Bundle::MemoryOut imem_in,
                   output Bundle::MemoryIn imem_out,
                   input  Bundle::MemoryOut dmem_in,
                   output Bundle::MemoryIn dmem_out
);

   typedef struct packed {
      logic       inst;
      logic       br_type;
      logic       op1_sel;
      logic       op2_sel;
      logic       rs1_oen;
      logic       rs2_oen;
      logic       alu_fun;
      logic       wb_sel;
      logic       rf_wen;
      logic       mem_en;
      logic       mem_fcn;
      logic       msk_sel;
      logic       csr_cmd;
   } ControlSignals;

   ControlSignals cs_default;
   ControlSignals cs;


   always_comb begin
      ControlSignals v;
      v = cs_default;
      // case (dat.dec_inst) begin
       //  default:
        //   v.inst = 1'b0;
     // endcase // case (dat.dec_inst)
   end // always_comb


   // Branch logic


   // Exception handling


   // Stall logic



endmodule; // ControlPath
