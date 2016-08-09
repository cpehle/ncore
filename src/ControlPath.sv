//@file ControlPath.sv
//@author Christian Pehle
//@brief control path of the the fixed point facility
`include "Bundle.sv"
`include "Instructions.sv"
module ControlPath (
                   input  clk,
                   input  reset,
                   output Bundle::ControlToData ctl,
                   input  Bundle::DataToControl dat,
                   input  Bundle::MemoryOut imem_out,
                   output Bundle::MemoryIn imem_in,
                   input  Bundle::MemoryOut dmem_out
                   // output Bundle::MemoryIn dmem_in
);

   typedef struct packed {
      logic inst;
      Bundle::BranchType  br_type;
      Bundle::Op1Sel op1_sel;
      Bundle::Op2Sel op2_sel;
      Bundle::RegisterOpEn rs1_oen;
      Bundle::RegisterOpEn rs2_oen;
      Bundle::AluFun  alu_fun;
      Bundle::WriteBackSelect wb_sel;
      Bundle::RegisterFileWriteEnable rf_wen;
      Bundle::MemoryEnable mem_en;
      Bundle::MemoryWriteSignal mem_fcn;
      Bundle::MemoryMaskType msk_sel;
   } ControlSignals;

   ControlSignals cs_default = '{1'b0,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_B};
   ControlSignals cs;

   import Bundle::*;
   always_comb begin
      cs = cs_default;
      case (dat.dec_inst) inside
        // load/store instructions
        `LBZ: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_B};
        `LBZU: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD, MT_BU};
        `LBZX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_B};
        `LBZUX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_BU};
        `LHZ: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `LHZU: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_HU};
        `LHZX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_H};
        `LHZUX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_HU};
        `LWZ: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_W};
        `LWZU: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_W};
        `LWZX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_W};
        `LWZUX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XRD, MT_W};
        `STB: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XWR, MT_B};
        `STBX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XWR, MT_B};
        `STH: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XWR, MT_H};
        `STHX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XWR, MT_H};
        `STW: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XWR, MT_W};
        `STWX: cs = '{1'b1,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1, M_XWR, MT_W};
        // immediate instructions
        `ADDI: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_ADD, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ADDIC: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_ADD, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ADDIS: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_ADD, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ANDI: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_AND, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ANDIS: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_AND, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ORI: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_OR, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `ORIS: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_OR, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `XORI: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_XOR, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        `XORIS: cs = '{1'b1, BR_N, OP1_RS1, OP2_ITYPE, OEN_1, OEN_0, ALU_XOR, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        // alu instructions
        `ADD:  cs = '{1'b1, BR_N, OP1_RS1, OP2_RS2, OEN_1, OEN_1, ALU_ADD, WB_ALU, REN_1, MEN_0, M_X, MT_X};
        default: cs = cs_default;
      endcase // case (dat.dec_inst)
   end // always_comb

   // Branch logic
   BranchIn branch_in = '{ctl.pipeline_kill, dat.exe_br_type, dat.exe_br_eq};
   BranchOut branch_out;
   Branch b(/*AUTOINST*/
            // Interfaces
            .branch_in                  (branch_in),
            .branch_out                 (branch_out));
   logic if_kill = (branch_out.pc_sel != PC_4) || !imem_out.res_valid;
   logic dec_kill = (branch_out.pc_sel != PC_4);

   // TODO(Christian): Exception handling

   // Stall logic
   logic hazard_stall = 1'b0;
   logic cmiss_stall = 1'b0;

   logic [4:0] dec_rs1_addr = dat.dec_inst[15:11];
   logic [4:0] dec_rs2_addr = dat.dec_inst[20:16];
   logic [4:0] dec_wb_addr = dat.dec_inst[10:6];
   RegisterOpEn dec_rs1_oen = dec_kill ? OEN_0 : cs.rs1_oen;
   RegisterOpEn dec_rs2_oen = dec_kill ? OEN_0 : cs.rs2_oen;

   typedef struct packed {
      logic [4:0] exe_reg_wbaddr;
      logic [4:0] mem_reg_wbaddr;
      logic [4:0] wb_reg_wbaddr;
      logic       exe_reg_ctrl_rf_wen;
      logic       mem_reg_ctrl_rf_wen;
      logic       wb_reg_ctrl_rf_wen;
      logic       exe_reg_exception;
      logic       exe_reg_is_csr;
   } StallLogicState;

   StallLogicState sl;
   StallLogicState sln;
   logic           stall;

   always_comb begin
      sln = sl;
      if (!hazard_stall && !cmiss_stall) begin
         if (dec_kill) begin
            // kill exe stage
            sln.exe_reg_wbaddr = 5'b0;
            sln.exe_reg_ctrl_rf_wen = 1'b0;
            sln.exe_reg_is_csr = 1'b0;
            sln.exe_reg_exception = 1'b0;
         end else begin
            sln.exe_reg_wbaddr = dec_wb_addr;
            sln.exe_reg_ctrl_rf_wen = cs.rf_wen;
            sln.exe_reg_is_csr = 1'b0; // TODO
            sln.exe_reg_exception = 1'b0; // TODO
         end
      end else if (hazard_stall && !cmiss_stall) begin // if (!hazard_stall && !cmiss_stall)
         sln.exe_reg_wbaddr = 5'b0;
         sln.exe_reg_ctrl_rf_wen = 1'b0;
         sln.exe_reg_is_csr = 1'b0;
         sln.exe_reg_exception = 1'b0;
      end
      sln.mem_reg_wbaddr = sl.exe_reg_wbaddr;
      sln.wb_reg_wbaddr = sl.mem_reg_wbaddr;
      sln.mem_reg_ctrl_rf_wen = sl.exe_reg_ctrl_rf_wen;
      sln.wb_reg_ctrl_rf_wen = sl.mem_reg_ctrl_rf_wen;
   end // always_comb
   always @(posedge clk or posedge clk) begin
      if (reset) begin
      end begin
         sl <= sln;
      end
   end

   logic exe_inst_is_load = cs.mem_en && (cs.mem_fcn == M_XRD);
   assign stall = (exe_inst_is_load && (sl.exe_reg_wbaddr == dec_rs1_addr) && dec_rs1_oen) || (exe_inst_is_load && (sl.exe_reg_wbaddr == dec_rs2_addr) && dec_rs2_oen); // TODO(Christian) exe_reg_is_csr

   // Output
   always_comb begin
      ctl.dec_stall = stall;
      ctl.cmiss_stall = !imem_out.res_valid || !((dat.mem_ctrl_dmem_val && dmem_out.res_valid) || !dat.mem_ctrl_dmem_val);
      ctl.exe_pc_sel = branch_out.pc_sel;
      ctl.br_type = cs.br_type;
      ctl.if_kill = if_kill;
      ctl.dec_kill = dec_kill;
      ctl.op1_sel = cs.op1_sel;
      ctl.op2_sel = cs.op2_sel;
      ctl.alu_fun = cs.alu_fun;
      ctl.wb_sel = cs.wb_sel;
      ctl.rf_wen = cs.rf_wen;
      // TODO(Christian): Fence, Exceptions
      imem_in.req_valid = 1'b1;
      imem_in.req.fcn = M_XRD;
      imem_in.req.typ = MT_W;
      ctl.mem_val = cs.mem_en;
      ctl.mem_fcn = cs.mem_fcn;
      ctl.mem_typ = cs.msk_sel;
   end

endmodule; // ControlPath
