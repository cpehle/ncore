//@file ControlPath.sv
//@author Christian Pehle
//@brief This implements the control path of the core.
`include "Bundle.sv"
`include "Instructions.sv"
module ControlPath (input  clk,
                   input  reset,
                   output Bundle::ControlToData ctl,
                   input  Bundle::DataToControl dat,
                   input  logic imem_out_res_valid,
                   output Bundle::MemoryIn imem_in,
                   input  logic dmem_out_res_valid
);

   typedef struct packed {
      logic valid;                            ///< valid instruction
      Bundle::BranchType br_type;             ///< branch type
      Bundle::Op1Sel op1_sel;                 ///< operand 1 select for alu
      Bundle::Op2Sel op2_sel;                 ///< operand 2 select for alu
      Bundle::RegisterOpEn rs1_oen;           ///< register source 1 operand enable
      Bundle::RegisterOpEn rs2_oen;           ///< register source 2 operand enable
      Bundle::AluFun  alu_fun;                ///< alu function select
      Bundle::WriteBackSelect wb_sel;         ///< writeback select
      Bundle::RegisterFileWriteEnable rf_wen; ///< register file write enable
      Bundle::MemoryEnable mem_en;            ///< memory write enable
      Bundle::MemoryWriteSignal mem_fcn;      ///< memory write/read signal
      Bundle::MemoryMaskType msk_sel;         ///< memory mask
      Bundle::ControlRegisterCommand csr_cmd; ///< control register command
      logic fence_i;                          ///< thread fence
   } ControlSignals;


   import Bundle::*;

   localparam T = 1'b1;
   localparam F = 1'b0;

   ControlSignals cs;
   ControlSignals cs_default;
   assign cs_default =  '{1'b0,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_B,CSR_N,1'b0};


   BranchIn branch_in;
   BranchOut branch_out;

   logic [4:0] dec_rs1_addr;
   logic [4:0] dec_rs2_addr;
   logic [4:0] dec_wb_addr;
 
   always_comb begin
      cs = '{F,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_B,CSR_N,F};
      case (dat.dec_inst) inside
        ///< load upper immediate / add unsigned immediate program counter (section X.X)
        `AUIPC: cs = '{T,BR_N,OP1_PC,OP2_UTYPE,OEN_0,OEN_0,ALU_ADD,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `LUI:   cs = '{T,BR_N,OP1_X ,OP2_UTYPE,OEN_0,OEN_0,ALU_COPY_2,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};

        ///< branch/jump instructions (section X.X)
        `JAL:  cs = '{T,BR_J  ,OP1_RS1,OP2_UJTYPE,OEN_0,OEN_0,ALU_X,WB_PC4,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `JALR: cs = '{T,BR_JR ,OP1_RS1,OP2_ITYPE ,OEN_1,OEN_0,ALU_X,WB_PC4,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
	`BEQ:  cs = '{T,BR_EQ ,OP1_RS1,OP2_SBTYPE,OEN_1,OEN_1,ALU_X,WB_X  ,REN_0,MEN_0,M_X,MT_X,CSR_N,F};
        `BNE:  cs = '{T,BR_NE ,OP1_RS1,OP2_SBTYPE,OEN_1,OEN_1,ALU_X,WB_X  ,REN_0,MEN_0,M_X,MT_X,CSR_N,F};
        `BLT:  cs = '{T,BR_LT ,OP1_RS1,OP2_SBTYPE,OEN_1,OEN_1,ALU_X,WB_X  ,REN_0,MEN_0,M_X,MT_X,CSR_N,F};
        `BLTU: cs = '{T,BR_LTU,OP1_RS1,OP2_SBTYPE,OEN_1,OEN_1,ALU_X,WB_X  ,REN_0,MEN_0,M_X,MT_X,CSR_N,F};
        `BGE:  cs = '{T,BR_GE ,OP1_RS1,OP2_SBTYPE,OEN_1,OEN_1,ALU_X,WB_X  ,REN_0,MEN_0,M_X,MT_X,CSR_N,F};
        `BGEU: cs = '{T,BR_GEU,OP1_RS1,OP2_SBTYPE,OEN_1,OEN_1,ALU_X,WB_X  ,REN_0,MEN_0,M_X,MT_X,CSR_N,F};

        ///< load/store instructions (section X.X)
        `LB:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_B ,CSR_N,F};
        `LH:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_H ,CSR_N,F};
        `LW:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_W ,CSR_N,F};
        `LBU: cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_BU,CSR_N,F};
        `LHU: cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD,WB_MEM,REN_1,MEN_1,M_XRD,MT_HU,CSR_N,F};
        `SB:  cs = '{T,BR_N,OP1_RS1,OP2_STYPE,OEN_1,OEN_1,ALU_ADD,WB_X  ,REN_0,MEN_1,M_XWR,MT_B ,CSR_N,F};
        `SH:  cs = '{T,BR_N,OP1_RS1,OP2_STYPE,OEN_1,OEN_1,ALU_ADD,WB_X  ,REN_0,MEN_1,M_XWR,MT_H ,CSR_N,F};
        `SW:  cs = '{T,BR_N,OP1_RS1,OP2_STYPE,OEN_1,OEN_1,ALU_ADD,WB_X  ,REN_0,MEN_1,M_XWR,MT_W ,CSR_N,F};

        ///< immediate alu (section X.X)
        `ADDI:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_ADD ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SLTI:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_SLT ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SLTIU: cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_SLTU,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `ANDI:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_AND ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `ORI:   cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_OR  ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `XORI:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_XOR ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SLLI:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_SLL ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SRLI:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_SRL ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SRAI:  cs = '{T,BR_N,OP1_RS1,OP2_ITYPE,OEN_1,OEN_0,ALU_SRA ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};

        ///< alu (section X.X)
        `ADD:  cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_ADD ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SUB:  cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_SUB ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SLT:  cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_SLT ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SLTU: cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_SLTU,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `AND:  cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_AND ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `OR:   cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_OR  ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `XOR:  cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_XOR ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SLL:  cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_SLL ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SRL:  cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_SRL ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};
        `SRA:  cs = '{T,BR_N,OP1_RS1,OP2_RS2,OEN_1,OEN_1,ALU_SRA ,WB_ALU,REN_1,MEN_0,M_X,MT_X,CSR_N,F};

        // See Section (X.X)
        `CSRRWI: cs = '{T,BR_N,OP1_IMZ,OP2_X,OEN_1,OEN_1,ALU_COPY_1,WB_CSR,REN_1,MEN_0,M_X,MT_X,CSR_W,F};
        `CSRRSI: cs = '{T,BR_N,OP1_IMZ,OP2_X,OEN_1,OEN_1,ALU_COPY_1,WB_CSR,REN_1,MEN_0,M_X,MT_X,CSR_S,F};
        `CSRRW:  cs = '{T,BR_N,OP1_RS1,OP2_X,OEN_1,OEN_1,ALU_COPY_1,WB_CSR,REN_1,MEN_0,M_X,MT_X,CSR_W,F};	
        `CSRRS:  cs = '{T,BR_N,OP1_RS1,OP2_X,OEN_1,OEN_1,ALU_COPY_1,WB_CSR,REN_1,MEN_0,M_X,MT_X,CSR_S,F};
        `CSRRC:  cs = '{T,BR_N,OP1_RS1,OP2_X,OEN_1,OEN_1,ALU_COPY_1,WB_CSR,REN_1,MEN_0,M_X,MT_X,CSR_C,F};
        `CSRRCI: cs = '{T,BR_N,OP1_IMZ,OP2_X,OEN_1,OEN_1,ALU_COPY_1,WB_CSR,REN_1,MEN_0,M_X,MT_X,CSR_C,F};

        // Priviledged Instructions
        `SCALL:  cs = cs_default;
        `SRET:   cs = cs_default;
        `MRTS:   cs = cs_default;
        `SBREAK: cs = cs_default;
        `WFI:    cs = cs_default;

        // TODO
        `FENCE_I: cs = cs_default;
        `FENCE:   cs = cs_default;

	// Single Precision Floating Point
	`FADD: cs = cs_default;	
	`FMUL: cs = cs_default;	
	`FSUB: cs = cs_default;	
	`FSW: cs = cs_default;	
	`FLW: cs = cs_default;
        // TODO: Investigate generated code, probably should put an invalid here
        default: cs = cs_default;
      endcase // case (dat.dec_inst)
      

      branch_in.pipeline_kill = 1'b0;
      branch_in.br_type = dat.exe_br_type;
      branch_in.br_eq = dat.exe_br_eq;
      branch_in.br_lt = dat.exe_br_lt;
      branch_in.br_ltu = dat.exe_br_ltu;      
      branch_in.imem_res_valid = imem_out_res_valid;
      dec_rs1_addr = dat.dec_inst[19:15];
      dec_rs2_addr = dat.dec_inst[24:20];
      dec_wb_addr = dat.dec_inst[11:7];
   end // always_comb

   /// Branch Control logic
   Branch b(.fence_i			(cs.fence_i),
	    /*AUTOINST*/
	    // Interfaces
	    .branch_in			(branch_in),
	    .branch_out			(branch_out),
	    // Inputs
	    .clk			(clk));
   // TODO(Christian): Exception handling

   /// Decode Control logic

   RegisterOpEn dec_rs1_oen;
   assign dec_rs1_oen = branch_out.dec_kill ? OEN_0 : cs.rs1_oen;
   RegisterOpEn dec_rs2_oen;
   assign dec_rs2_oen = branch_out.dec_kill ? OEN_0 : cs.rs2_oen;

   /// Stall Control Logic
   logic       hazard_stall; // stall because of hazard
   logic       cmiss_stall;  // stall because of cache miss

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

   always_comb begin
      sln = sl;
      if (!hazard_stall && !cmiss_stall) begin
         if (branch_out.dec_kill) begin
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
      end else if (hazard_stall && !cmiss_stall) begin
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

   always @(posedge clk) begin
      if (reset) begin
         sl <= '0;
      end begin
         sl <= sln;
      end
   end

   /// Bypassing Control Logic   
   logic mem_fcn_is_read;
   assign mem_fcn_is_read = (cs.mem_fcn == M_XRD);
   logic exe_inst_is_load;
   assign exe_inst_is_load = cs.mem_en && mem_fcn_is_read;
   // we want to stall execution if the previous instruction was a load
   logic exe_inst_is_load_reg;
   always_ff @(posedge clk) begin
      if (reset) begin
	 exe_inst_is_load_reg <= '0;
      end else begin
	 exe_inst_is_load_reg <= cs.mem_en && mem_fcn_is_read;
      end
   end
   
   assign cmiss_stall = !imem_out_res_valid || !((dat.mem_ctrl_dmem_val && dmem_out_res_valid) || !dat.mem_ctrl_dmem_val);
   always_comb begin
      if (1) begin
         hazard_stall = (exe_inst_is_load_reg && (sl.exe_reg_wbaddr == dec_rs1_addr) && dec_rs1_oen)
                     || (exe_inst_is_load_reg && (sl.exe_reg_wbaddr == dec_rs2_addr) && dec_rs2_oen)
                     || (sl.exe_reg_is_csr);
      end else begin
         hazard_stall = ((sl.exe_reg_wbaddr == dec_rs1_addr) && (dec_rs1_addr != 0) && sl.exe_reg_ctrl_rf_wen && dec_rs1_oen) ||
                        ((sl.mem_reg_wbaddr == dec_rs1_addr) && (dec_rs1_addr != 0) && sl.mem_reg_ctrl_rf_wen && dec_rs1_oen) ||
                        ((sl.wb_reg_wbaddr  == dec_rs1_addr) && (dec_rs1_addr != 0) && sl.wb_reg_ctrl_rf_wen && dec_rs1_oen) ||
                        ((sl.exe_reg_wbaddr == dec_rs2_addr) && (dec_rs2_addr != 0) && sl.exe_reg_ctrl_rf_wen && dec_rs2_oen) ||
                        ((sl.mem_reg_wbaddr == dec_rs2_addr) && (dec_rs2_addr != 0) && sl.mem_reg_ctrl_rf_wen && dec_rs2_oen) ||
                        ((sl.wb_reg_wbaddr  == dec_rs2_addr) && (dec_rs2_addr != 0) &&  sl.wb_reg_ctrl_rf_wen && dec_rs2_oen) ||
                        ((exe_inst_is_load) && (sl.exe_reg_wbaddr == dec_rs1_addr) && (sl.exe_reg_wbaddr != 0) && dec_rs1_oen) ||
                        ((exe_inst_is_load) && (sl.exe_reg_wbaddr == dec_rs2_addr) && (sl.exe_reg_wbaddr != 0) && dec_rs2_oen) ||
                        ((sl.exe_reg_is_csr));
      end
   end

   /// Output
   always_comb begin
      ctl.dec_stall = hazard_stall;
      ctl.cmiss_stall = !imem_out_res_valid || !((dat.mem_ctrl_dmem_val && dmem_out_res_valid) || !dat.mem_ctrl_dmem_val);
      ctl.exe_pc_sel = branch_out.pc_sel;
      ctl.br_type = cs.br_type;
      ctl.if_kill = branch_out.if_kill;
      ctl.dec_kill = branch_out.dec_kill;
      ctl.op1_sel = cs.op1_sel;
      ctl.op2_sel = cs.op2_sel;
      ctl.alu_fun = cs.alu_fun;
      ctl.wb_sel = cs.wb_sel;
      ctl.rf_wen = cs.rf_wen;
      // TODO(Christian): Fence, Exceptions, CSR
      ctl.csr_cmd = cs.csr_cmd;      
      imem_in.req_valid = 1'b1;
      imem_in.req.fcn = M_XRD;
      imem_in.req.typ = MT_WU;
      ctl.mem_val = cs.mem_en;
      ctl.mem_fcn = cs.mem_fcn;
      ctl.mem_typ = cs.msk_sel;
   end
endmodule // ControlPath
