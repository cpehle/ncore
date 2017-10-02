// file: Bundle
`ifndef _Bundle
`define _Bundle
package Bundle;

   localparam logic [31:0] Bubble = 32'h4033;

   localparam int 	  fetchWidth = 4;
   localparam int 	  opaqueBits = 10;
   
   
   typedef enum [3:0] {
                       FN_X    = 4'bxxxx,
                       FN_ADD  = 4'd0,
                       FN_SL   = 4'd1,
                       FN_SEQ  = 4'd2,
                       FN_SNE  = 4'd3,
                       FN_XOR  = 4'd4,
                       FN_SR   = 4'd5,
                       FN_OR   = 4'd6,
                       FN_AND  = 4'd7,
                       FN_SUB  = 4'd10,
                       FN_SRA  = 4'd11,
                       FN_SLT  = 4'd12,
                       FN_SGE  = 4'd13,
                       FN_SLTU = 4'd14,
                       FN_SGEU = 4'd15
                       } AluFn;

   typedef enum [1:0] {
                       DW_32 = 2'd0,
                       DW_64 = 2'd1,
                       DW_XPR = 2'd2,
                       DW_X = 2'bxx
                       } Dw;

   typedef enum [2:0] {
                 CSR_N,
                 CSR_W,
                 CSR_S,
                 CSR_I,
                 CSR_C
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
                       // enum: WriteBackSelect
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
                       ALU_XOR,
                       ALU_COPY_1,
                       ALU_COPY_2
                       } AluFun;

   typedef enum [1:0] {
                       OP1_RS1,
                       OP1_PC,
                       OP1_IMZ,
                       OP1_X
                       } Op1Sel;


   typedef enum [1:0] {
                       A2_ZERO = 2'd0,
                       A2_FOUR = 2'd1,
                       A2_IMM = 2'd3,
                       A2_RS2 = 2'd2,
                       A2_X = 2'bXX
   } A2Sel;

   typedef enum [1:0] {
                       A1_ZERO = 2'd0,
                       A1_RS1 = 2'd1,
                       A1_PC = 2'd2,
                       A1_X = 2'bXX
                       } A1Sel;


   typedef enum [2:0] {
                       IMM_X = 3'bxxx,
                       IMM_S = 3'd0,
                       IMM_SB = 3'd1,
                       IMM_U = 3'd2,
                       IMM_UJ = 3'd3,
                       IMM_I = 3'd4,
                       IMM_Z = 3'd5
                       } ImmSel;


   typedef enum [2:0] {
                       OP2_RS2,   // 000
                       OP2_ITYPE, // 001
                       OP2_STYPE, // 010
                       OP2_SBTYPE,// 011
                       OP2_UTYPE, // 100
                       OP2_UJTYPE,// 101
                       OP2_X
                       } Op2Sel;

   typedef enum [1:0] {
                       M_XRD,
                       M_XWR,
                       M_X,
                       M_FLUSH_ALL
                       } MemoryWriteSignal;

   typedef enum [0:0] {
                       REN_0,
                       REN_1
                       } RegisterFileWriteEnable;

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

   typedef struct packed {
      logic       dec_stall;
      logic       cmiss_stall;
      logic [1:0] exe_pc_sel;
      BranchType br_type;
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

   typedef struct packed {
      logic 	  xx;
   } BTBEntry;

   typedef struct packed {
      logic [31:0] addr;
      logic 	   valid;
   } BTBRequest;

   typedef struct  packed {
      logic [5:0]  history;
      logic [1:0]  value;
   } BHTResp;
      
   typedef struct packed {
      logic taken;
      logic [fetchWidth-1:0] mask;
      logic [$clog2(fetchWidth)-1:0] bridx;
      logic [31:0] target;
      logic [opaqueBits-1:0] entry;
      BHTResp bht;
      logic valid;
   } BTBResponse;
           
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
      logic 	  br_lt;
      logic 	  br_ltu;      
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

   typedef struct packed {
      logic legal;
      logic br;
      logic jal;
      logic jalr;
      logic rxs2;
      logic rxs1;
      A2Sel sel_alu2;
      A1Sel sel_alu1;
      ImmSel sel_imm;
      Dw alu_dw;
      AluFn alu_fun;
      logic mem;
      MemoryWriteSignal mem_cmd;
      MemoryMaskType mem_mask_type;
      logic rfs1;
      logic rfs2;
      logic rfs3;
      logic wfd;
      logic div;
      logic wxd;
      ControlRegisterCommand csr;
      logic fence_i;
      logic fence;
      logic amo;
   } ControlSignals;

   typedef struct packed {
      logic [31:0] address;
   } ICacheRequest;

   typedef struct packed {
      logic [31:0] data;
      logic [128:0] data_block;
   } ICacheResponse;

   typedef struct packed {
      ICacheResponse response;
      logic       response_valid;
      logic       invalidate;
   } ICacheIn;

   typedef struct packed {
      ICacheRequest request;
      logic       request_valid;
      logic       response_ready;
   } ICacheOut;

   // CSR File Registers
   typedef struct packed {
      logic 	  sd;
      logic [7:0] zero1;
      logic 	  tsr;
      logic 	  tw;
      logic 	  tvm;
      logic 	  mxr;
      logic 	  sum;
      logic 	  mprv;
      logic [1:0] xs;
      logic [1:0] fs;
      logic [1:0] mpp;
      logic [1:0] hpp;
      logic [1:0] spp;
      logic 	  mpie;
      logic 	  hpie;
      logic 	  spie;
      logic 	  upie;
      logic 	  mie;
      logic 	  hie;
      logic 	  sie;
      logic 	  uie;
   } MStatus;   
endpackage // Bundle
`endif
