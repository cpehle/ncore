//@file ControlPath.sv
//@author Christian Pehle
//@brief control path of the the fixed point facility
`include "Bundle.sv"
`include "Instructions.sv"
module ControlPath(
                   input  clk,
                   input  reset,
                   output Bundle::ControlToData ctl,
                   input  Bundle::DataToControl dat,
                   input  Bundle::MemoryOut imem_in,
                   output Bundle::MemoryIn imem_out,
                   input  Bundle::MemoryOut dmem_in,
                   output Bundle::MemoryIn dmem_out
);

   typedef struct packed {
      logic       inst;
      Bundle::BranchType  br_type;
      Bundle::Op1Sel op1_sel;
      Bundle::Op2Sel op2_sel;
      Bundle::RegisterOpEn rs1_oen;
      Bundle::RegisterOpEn rs2_oen;
      Bundle::AluFun  alu_fun;
      Bundle::WriteBackSelect wb_sel;
      Bundle::RegisterFileWriteEnable rf_wen;
      Bundle::MemoryEnable mem_en;
      Bundle::MemoryWriteSignal mem_wr;
      Bundle::MemoryMaskType msk_sel;
   } ControlSignals;

   ControlSignals cs_default = {1'b0,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_B};
   ControlSignals cs;

   import Bundle::*;
   always_comb begin
      cs = cs_default;
      case (dat.dec_inst) inside
        // load/store instructions
        `LBZ: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_B};
        `LBZU: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD, MT_B};
        `LBZX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_B};
        `LBZUX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_B};
        `LHZ: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `LHZU: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `LHZX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `LHZUX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `LWZ: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_W};
        `LWZU: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_W};
        `LWZX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_W};
        `LWZUX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_W};
        `STW: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `STWX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `STB: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `STBX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `STH: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `STHX: cs = {1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        // immediate instructions
        `ADDI: cs = {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_ADD, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ADDIC: cs = {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_ADD, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ADDIS: cs = {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_ADD, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ANDI: cs = {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_AND, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ANDIS: cs = {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_AND, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ORI: cs =  {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_OR, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ORIS: cs = {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_OR, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `XORI: cs = {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_XOR, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `XORIS: cs = {1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_XOR, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        // alu instructions
        `ADD:  cs = {1'b1, BR_N, OP1_RS1, OP2_RS2, OEN_1, OEN_1, ALU_ADD, WB_ALU, REN_1, MEN_0, M_X, MT_X};
       //  default:
        //   v.inst = 1'b0;
      endcase // case (dat.dec_inst)
   end // always_comb

   // Branch logic
   PcSel ctrl_exe_pc_sel = ctl.pipeline_kill ? PC_EXC :
   (dat.exe_br_type == BR_N) ? PC_4 :
   (dat.exe_br_type == BR_NE) ? (!dat.exe_br_eq ? PC_BRJMP : PC_4) :
   (dat.exe_br_type == BR_EQ) ? (!dat.exe_br_eq ? PC_BRJMP : PC_4) :
   (dat.exe_br_type == BR_GE) ? (!dat.exe_br_eq ? PC_BRJMP : PC_4) :
   (dat.exe_br_type == BR_GEU) ? (!dat.exe_br_eq ? PC_BRJMP : PC_4) :
   (dat.exe_br_type == BR_LT) ? (!dat.exe_br_eq ? PC_BRJMP : PC_4) :
   (dat.exe_br_type == BR_LTU) ? (!dat.exe_br_eq ? PC_BRJMP : PC_4) :
   (dat.exe_br_type == BR_J) ? (!dat.exe_br_eq ? PC_BRJMP : PC_4) :
                     (dat.exe_br_type == BR_JR) ?  PC_JALR : PC_4;

   logic if_kill = (ctrl_exe_pc_sel != PC_4) || !imem_in.res_valid;
   logic dec_kill = (ctrl_exe_pc_sel != PC_4);

   // Exception handling


   // Stall logic

   logic hazard_stall = 1'b0;
   logic cmiss_stall = 1'b0;

   logic [4:0] dec_rs1_addr = dat.dec_inst[19:15];
   logic [4:0] dec_rs2_addr = dat.dec_inst[24:20];
   logic [4:0] dec_wb_addr = dat.dec_inst[11:7];
   RegisterOpEn dec_rs1_oen = dec_kill ? OEN_0 : cs.rs1_oen;
   RegisterOpEn dec_rs2_oen = dec_kill ? OEN_0 : cs.rs2_oen;

   typedef struct packed {
      logic [31:0] exe_reg_wbaddr;
      logic [31:0] mem_reg_wbaddr;
      logic [31:0] wb_reg_wbaddr;
      logic        exe_reg_ctrl_rf_wen;
      logic        mem_reg_ctrl_rf_wen;
      logic        wb_reg_ctrl_rf_wen;
      logic        exe_reg_exception;
      logic        exe_reg_is_csr;
   } StallLogicState;

   StallLogicState sl_state;
   StallLogicState sl_state_next;
   always_comb begin
      sl_state_next = sl_state;
      if (!hazard_stall && !cmiss_stall) begin
         if (dec_kill) begin
            // kill exe stage
            sl_state_next.exe_reg_wbaddr = 32'b0;
            sl_state_next.exe_reg_ctrl_rf_wen = 1'b0;
            sl_state_next.exe_reg_is_csr = 1'b0;
            sl_state_next.exe_reg_exception = 1'b0;
         end else begin
            sl_state_next.exe_reg_wbaddr = dec_wb_addr;
            sl_state_next.exe_reg_ctrl_rf_wen = cs.rf_wen;
            sl_state_next.exe_reg_is_csr = 1'b0; // TODO
            sl_state_next.exe_reg_exception = 1'b0; // TODO
         end
      end else if (hazard_stall && !cmiss_stall) begin // if (!hazard_stall && !cmiss_stall)
         sl_state_next.exe_reg_wbaddr = 32'b0;
         sl_state_next.exe_reg_ctrl_rf_wen = 1'b0;
         sl_state_next.exe_reg_is_csr = 1'b0;
         sl_state_next.exe_reg_exception = 1'b0;
      end
      sl_state_next.mem_reg_wbaddr = sl_state.exe_reg_wbaddr;
      sl_state_next.wb_reg_wbaddr = sl_state.mem_reg_wbaddr;
      sl_state_next.mem_reg_ctrl_rf_wen = sl_state.exe_reg_ctrl_rf_wen;
      sl_state_next.wb_reg_ctrl_rf_wen = sl_state.mem_reg_ctrl_rf_wen;
   end // always_comb
   always @(posedge clk) begin
      sl_state <= sl_state_next;
   end


   // Output
   always_comb begin
      ctl.exe_pc_sel = ctrl_exe_pc_sel;
      ctl.br_type = cs.br_type;
      ctl.if_kill = if_kill;
      ctl.dec_kill = dec_kill;
      ctl.op1_sel = cs.op1_sel;
      ctl.op2_sel = cs.op2_sel;
      ctl.alu_fun = cs.alu_fun;
      ctl.wb_sel = cs.wb_sel;
      ctl.rf_wen = cs.rf_wen;
      imem_out.req_valid = 1'b1;
      imem_out.req.fcn = M_XRD;
      imem_out.req.typ = MT_W;
      ctl.mem_val = cs.mem_en;
      // ctl.mem_fcn = cs.mem_fcn;
      // ctl.mem_typ = cs.msk_sel;
   end

endmodule; // ControlPath
