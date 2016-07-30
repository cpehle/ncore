module DataPath(
                input  Bundle::ControlToData ctl,
                output Bundle::DataToControl dat,
                input  Bundle::MemoryOut imem_in,
                output Bundle::MemoryIn imem_out,
                input  Bundle::MemoryOut dmem_in,
                output Bundle::MemoryIn dmem_out
);
   // Pipeline state
   typedef struct packed {
      logic [31:0] pc;
   } InstructionFetchState;

   typedef struct packed {
      logic [31:0] inst;
      logic [31:0] pc;
   } InstructionDecodeState;

   typedef struct packed {
      logic [31:0] inst;
      logic [31:0] pc;
      logic [31:0] wb_addr;
      logic [31:0] rs1_addr;
      logic [31:0] rs2_addr;
      logic [31:0] op1_data;
      logic [31:0] op2_data;
      logic [31:0] rs2_data;
      logic        ctrl_br_type;
      logic        ctrl_op2_sel;
      logic        ctrl_alu_fun;
      logic        ctrl_wb_sel;
      logic        ctrl_rf_wen;
      logic        ctrl_mem_val;
      logic        ctrl_mem_fcn;
      logic        ctrl_mem_typ;
      logic        ctrl_csr_cmd;
   } ExecuteState;

   typedef struct packed {
      logic [31:0] pc;
      logic [31:0] inst;
      logic [31:0] alu_out;
      logic        wb_addr;
      logic        rs1_addr;
      logic        rs2_addr;
      logic        op1_data;
      logic        op2_data;
      logic        rs2_data;
      logic        ctrl_rf_wen;
      logic        ctrl_mem_val;
      logic        ctrl_mem_fcn;
      logic        ctrl_mem_typ;
      logic        ctrl_wb_sel;
      logic        ctrl_csr_cmd;
   } MemoryState;

   typedef struct packed {
      logic [31:0] wb_addr;
      logic [31:0] wb_data;
      logic        ctrl_rf_wen;
   } WriteBackState;

   InstructionFetchState ifs;
   InstructionFetchState ifs_next;
   InstructionDecodeState ids;
   InstructionDecodeState ids_next;
   ExecuteState es;
   ExecuteState es_next;
   MemoryState ms;
   MemoryState ms_next;
   WriteBackState wbs;
   WriteBackState wbs_next;

   /// Instruction Fetch Stage

   /// Decode Stage
   // Bundle::RegisterFileIn rf_in;
   // Bundle::RegisterFileOut rf_out;
   RegisterFile regfile();

   // ds_next.alu_op2 = ....
   // ds_next.alu_op1 = ...
   // ds_next.op1_data = ...
   // ds_next.op2_data = ...
   // ds_next.rs2_data = ...

   /// Execute Stage
   // Bundle::AluIn alu_in;
   // Bundle::AluOut alu_out;
   Alu alu();

   /// Memory Stage

   /// Writeback Stage

endmodule
