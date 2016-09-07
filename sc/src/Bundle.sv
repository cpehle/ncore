`ifndef _Bundle
`define _Bundle
package Bundle;
   typedef enum [1:0] {
                 CSR_N,
                 CSR_W,
                 CSR_S,
                 CSR_I
                 } ControlRegisterCommand;


   typedef enum [2:0] {
                       MT_B,
                       MT_BU,
                       MT_H,
                       MT_HU,
                       MT_W,
                       MT_WU,
                       MT_X
                       } MemoryMaskType;

   typedef enum [2:0] {
                       WB_ALU,
                       WB_MEM,
                       WB_PC4,
                       WB_CSR,
                       WB_X
                       } WriteBackSelect;

   typedef enum [4:0] {
                       ALU_X,
                       ALU_ADD,
                       ALU_SUB,
                       ALU_SLL,
                       ALU_SRL,
                       ALU_SRA,
                       ALU_SLT,
                       ALU_SLTU,
                       ALU_AND,
                       ALU_OR,
                       ALU_XOR
                       } AluFun;

   typedef enum [1:0] {
                       OP1_RS1,
                       OP1_PC,
                       OP1_IMZ,
                       OP1_X
                       } Op1Sel;

   typedef enum [2:0] {
                       OP2_RS2,
                       OP2_ITYPE,
                       OP2_STYPE,
                       OP2_SBTYPE,
                       OP2_UTYPE,
                       OP2_UJTYPE,
                       OP2_X
                       } Op2Sel;

   typedef enum [1:0] {
                       M_XRD,
                       M_XWR,
                       M_X
                       } MemoryWriteSignal;

   typedef enum [0:0] {
                       REN_0,
                       REN_1
                       } RegisterFileWriteEnable;

   typedef struct packed {
      logic       dec_stall;
      logic       cmiss_stall;
      logic [1:0] exe_pc_sel;
      logic [3:0] br_type;
      logic       if_kill;
      logic       dec_kill;
      Op1Sel op1_sel;
      Op2Sel op2_sel;
      AluFun alu_fun;
      WriteBackSelect wb_sel;
      RegisterFileWriteEnable rf_wen;
      logic       mem_val;
      MemoryWriteSignal       mem_fcn;
      MemoryMaskType mem_typ;
      logic       pipeline_kill;
      ControlRegisterCommand csr_cmd;
   } ControlToData;

   typedef struct packed {
      Op1Sel op1_sel;
      Op2Sel op2_sel;
      logic [4:0] es_wb_addr;
      logic [4:0] ms_wb_addr;
      logic [4:0] wbs_wb_addr;
      logic [31:0] alu_out;
      logic [31:0] wb_data;
      logic [31:0] rs1_data;
      logic [31:0] rs2_data;
   } BypassIn;

   typedef struct packed {
      logic [31:0] alu_op1;
      logic [31:0] alu_op2;
   } BypassOut;


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

   typedef struct packed {
      logic [4:0] rs1_addr;
      logic [4:0] rs2_addr;
      logic [4:0] waddr;
      logic [31:0] wdata;
      logic        we;
   } RegisterFileIn;

   typedef struct packed {
      logic [31:0] rs1_data;
      logic [31:0] rs2_data;
   } RegisterFileOut;

   typedef enum [0:0] {
                       OEN_0,
                       OEN_1
   } RegisterOpEn;


   typedef struct packed {
      AluFun fun;
      logic [31:0] op1;
      logic [31:0] op2;
   } AluIn;

   typedef struct packed {
      logic [31:0] data;
   } AluOut;


   typedef enum [1:0] {
                       PC_4,
                       PC_BRJMP,
                       PC_JALR,
                       PC_EXC
    } PcSel;


   typedef struct packed {
      logic       pipeline_kill;
      logic [3:0] br_type;
      logic       br_eq;
      logic       imem_res_valid;
   } BranchIn;

   typedef struct packed {
      PcSel pc_sel;
      logic       if_kill;
      logic       dec_kill;
   } BranchOut;



   typedef enum [0:0] {
                       MEN_0,
                       MEN_1
   } MemoryEnable;


   typedef enum [3:0] {
                       BR_N,
                       BR_NE,
                       BR_EQ,
                       BR_GE,
                       BR_GEU,
                       BR_LT,
                       BR_LTU,
                       BR_J,
                       BR_JR
   } BranchType;
endpackage // Bundle
`endif
