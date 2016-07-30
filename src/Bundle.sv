package Bundle;
   typedef struct packed {
      logic       dec_stall;
      logic       cmiss_stall;
      logic [1:0] exe_pc_sel;
      logic [3:0] br_type;
      logic       if_kill;
      logic       dec_kill;
      logic [2:0] op1_sel;
      logic [3:0] op2_sel;
      logic [3:0] alu_fun;
      logic [1:0] wb_sel;
      logic       rf_wen;
      logic       mem_val;
      logic       mem_fcn;
      logic       pipeline_kill;
   } ControlToData;

   typedef struct packed {
      logic [31:0] dec_inst;
      logic        exe_br_eq;
      logic        exe_br_lt;
      logic        exe_br_ltu;
      logic [3:0]  exe_br_type;
      logic        mem_ctrl_dmem_val;
   } DataToControl;

   typedef struct  packed {
      logic [31:0] addr;
      logic [31:0] data;
      logic [1:0]  fcn;
      logic [2:0]  typ;
   } MemoryRequest;

   typedef struct  packed {
      logic [31:0] data;
   } MemoryResponse;

   typedef struct  packed {
      MemoryRequest req;
      logic        req_valid;
   } MemoryIn;

   typedef struct  packed {
      MemoryResponse res;
      logic        req_ready;
      logic        res_valid;
   } MemoryOut;
endpackage // Bundle
