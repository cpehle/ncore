//@file DataPath.sv
//@author Christian Pehle
//@brief data path of one core
`include "Bundle.sv"
module DataPath(
                input  clk,
                // Control signals from control to data path
                input  Bundle::ControlToData ctl,
                // Signals from data path to control
                output Bundle::DataToControl dat,
                output Bundle::MemoryIn imem_in,
                input  Bundle::MemoryOut imem_out,
                output Bundle::MemoryIn dmem_in,
                input  Bundle::MemoryOut dmem_out
    );
   // datapath is a five stage pipeline.

   // the following are the pipeline registers
   typedef struct packed {
      logic [31:0] pc; // program counter
   } InstructionFetchState;

   typedef struct packed {
      logic [31:0] pc;   // program counter
      logic [31:0] inst; // instruction
   } InstructionDecodeState;

   typedef struct packed {
      logic [31:0]              pc;           // program counter
      logic [31:0]              inst;         // instruction
      logic [4:0]               wb_addr;      // write back address
      logic [4:0]               rs1_addr;     // result 1 address
      logic [4:0]               rs2_addr;     // result 2 address
      logic [31:0]              op1_data;     // operand 1 address
      logic [31:0]              op2_data;     // operand 2 address
      logic [31:0]              rs2_data;     // result 2 data
      Bundle::BranchType        ctrl_br_type; // control branch type
      Bundle::Op2Sel            ctrl_op2_sel; // control operand 2 select
      Bundle::AluFun            ctrl_alu_fun; // control alu function
      Bundle::WriteBackSelect   ctrl_wb_sel;  // control writeback select
      logic                     ctrl_rf_wen;  // control register file write enable
      logic                     ctrl_mem_val; // control memory value
      Bundle::MemoryWriteSignal ctrl_mem_fcn; // control memory function
      Bundle::MemoryMaskType    ctrl_mem_typ; // control memory type
      Bundle::ControlRegisterCommand  ctrl_csr_cmd; // control condition state register command
   } ExecuteState;

   typedef struct packed {
      logic [31:0]              pc;
      logic [31:0]              inst;
      logic [31:0]              alu_out;
      logic [4:0]               wb_addr;
      logic [4:0]               rs1_addr;
      logic [4:0]               rs2_addr;
      logic [31:0]              op1_data;     // operand 1 data
      logic [31:0]              op2_data;     // operand 2 data
      logic [31:0]              rs2_data;     // result 2 data
      logic                     ctrl_rf_wen;  // control register file write enable
      logic                     ctrl_mem_val; // control memory value
      Bundle::MemoryWriteSignal ctrl_mem_fcn; // control memory function
      Bundle::MemoryMaskType    ctrl_mem_typ; // control memory type
      Bundle::WriteBackSelect   ctrl_wb_sel;  // control writeback select
      Bundle::ControlRegisterCommand ctrl_csr_cmd; // control condition state register command
   } MemoryState;

   typedef struct packed {
      logic [4:0]  wb_addr;
      logic [31:0] wb_data;
      logic        ctrl_rf_wen;
   } WriteBackState;

   // This structure captures the whole state of
   // the fixed point pipeline
   typedef struct packed {
      InstructionFetchState  ifs;
      InstructionDecodeState ids;
      ExecuteState           es;
      MemoryState            ms;
      WriteBackState         wbs;
   } DataPathState;


   DataPathState r; // current register state
   DataPathState rn; // register state at next time step


   Bundle::RegisterFileIn rf_in;
   Bundle::RegisterFileOut rf_out;
   logic [4:0]    dec_rs1_addr;
   logic [4:0]    dec_rs2_addr;


   // register file i/o
   assign rf_in.rs1_addr = dec_rs1_addr;
   assign rf_in.rs2_addr = dec_rs2_addr;
   assign rf_in.waddr = r.wbs.wb_addr;
   assign rf_in.wdata = r.wbs.wb_data;
   assign rf_in.we = r.wbs.ctrl_rf_wen;
   assign rf_rs1_data = rf_out.rs1_data;
   assign rf_rs2_data = rf_out.rs2_data;

   RegisterFile register_file(/*AUTOINST*/
                   // Interfaces
                   .rf_in               (rf_in),
                   .rf_out              (rf_out),
                   // Inputs
                   .clk                 (clk));

   Bundle::AluIn alu_in;
   Bundle::AluOut alu_out;
   Alu alu(/*AUTOINST*/
           // Interfaces
           .alu_in                      (alu_in),
           .alu_out                     (alu_out));


   logic [31:0]   exe_brjmp_target = '0;
   logic [31:0]   exe_jump_reg_target = '0;
   logic [31:0]   exception_target = '0;
   logic [31:0]   if_instruction;
   logic [4:0]    dec_wb_addr;
   logic [31:0]   dec_alu_op2;
   logic [31:0]   dec_op1_data;
   logic [31:0]   dec_op2_data;
   logic [31:0]   dec_rs2_data;
   logic [31:0]   mem_wb_data;
   logic [31:0]   rf_rs1_data;
   logic [31:0]   rf_rs2_data;


   assign exe_brjmp_target = r.es.pc + r.es.op2_data;

   // instruction fetch stage
   always_comb begin
      // default assignment
      rn.ifs = r.ifs;
      if ((!ctl.dec_stall && !ctl.cmiss_stall) || ctl.pipeline_kill) begin
         rn.ifs.pc = ctl.exe_pc_sel == Bundle::PC_4 ? (r.ifs.pc + 32'd4) :
                     ctl.exe_pc_sel == Bundle::PC_BRJMP ? exe_brjmp_target :
                     ctl.exe_pc_sel == Bundle::PC_JALR ? exe_jump_reg_target :
                     exception_target;
      end
   end

   assign imem_in.req.addr = r.ifs.pc;
   assign imem_in.req_valid = 1'b1;
   assign if_instruction = imem_out.res.data;

   always_comb begin
      rn.ids = r.ids;
      if (ctl.pipeline_kill) begin
         rn.ids.inst = 32'b0;
      end else if (!ctl.dec_stall && !ctl.cmiss_stall) begin
         if (ctl.if_kill) begin
            rn.ids.inst = 32'b0;
         end else begin
            rn.ids.inst = if_instruction;
         end
         rn.ids.pc = r.ifs.pc;
      end
   end

   // instruction decode stage
   // register addresses
   assign dec_rs1_addr[4:0] = r.ids.inst[19:15];
   assign dec_rs2_addr[4:0] = r.ids.inst[24:20];
   assign dec_wb_addr[4:0] = r.ids.inst[11:7];
   // immediate variables

   // immediates
   logic [11:0] imm_itype = r.ids.inst[31:20];
   logic [11:0] imm_stype = {r.ids.inst[31:25],r.ids.inst[11:7]};
   logic [11:0] imm_sbtype = {r.ids.inst[31],r.ids.inst[7],r.ids.inst[30:25],r.ids.inst[11:8]};
   logic [19:0] imm_utype = r.ids.inst[31:12];
   logic [19:0] imm_ujtype = {r.ids.inst[31], r.ids.inst[19:12], r.ids.inst[20], r.ids.inst[30:21]};
   logic [31:0] imm_z = {27'b0,r.ids.inst[19:15]};

   // sign extended intermediates
   logic [31:0] imm_itype_sext  = {{20{imm_itype[11]}}, imm_itype};
   logic [31:0] imm_stype_sext  = {{20{imm_stype[11]}}, imm_stype};
   logic [31:0] imm_sbtype_sext = {{19{imm_sbtype[11]}}, imm_sbtype, 1'b0};
   logic [31:0] imm_utype_sext  = {imm_utype, 12'b0};
   logic [31:0] imm_ujtype_sext = {{11{imm_ujtype[19]}}, imm_ujtype, 1'b0};

   always_comb begin
      // default assignments
      rn.es = r.es;
      // operand 2 multiplexer
      dec_alu_op2[31:0] = (ctl.op2_sel == Bundle::OP2_RS2)    ? rf_out.rs2_data[31:0] :
                          (ctl.op2_sel == Bundle::OP2_ITYPE)  ? imm_itype_sext[31:0] :
                          (ctl.op2_sel == Bundle::OP2_STYPE)  ? imm_stype_sext[31:0] :
                          (ctl.op2_sel == Bundle::OP2_SBTYPE) ? imm_sbtype_sext[31:0] :
                          (ctl.op2_sel == Bundle::OP2_UTYPE)  ? imm_utype_sext[31:0] :
                          (ctl.op2_sel == Bundle::OP2_UJTYPE) ? imm_ujtype_sext[31:0] :
                          32'b0;

      // bypass multiplexers
      dec_op1_data = (ctl.op1_sel == Bundle::OP1_IMZ) ? imm_z :
                     (ctl.op1_sel == Bundle::OP1_PC) ? r.ids.pc :
                     (r.es.wb_addr  == dec_rs1_addr) && (dec_rs1_addr != 0) && r.es.ctrl_rf_wen  ? alu_out.data :
                     (r.ms.wb_addr  == dec_rs1_addr) && (dec_rs1_addr != 0) && r.ms.ctrl_rf_wen  ? mem_wb_data :
                     (r.wbs.wb_addr == dec_rs1_addr) && (dec_rs1_addr != 0) && r.wbs.ctrl_rf_wen ? r.wbs.wb_data :
                     rf_rs1_data;

      dec_op2_data = (r.es.wb_addr  == dec_rs2_addr) && (dec_rs2_addr != 0) && r.es.ctrl_rf_wen  && (ctl.op2_sel == Bundle::OP2_RS2) ? alu_out.data :
                     (r.ms.wb_addr  == dec_rs2_addr) && (dec_rs2_addr != 0) && r.ms.ctrl_rf_wen  && (ctl.op2_sel == Bundle::OP2_RS2) ? mem_wb_data :
                     (r.wbs.wb_addr == dec_rs2_addr) && (dec_rs2_addr != 0) && r.wbs.ctrl_rf_wen && (ctl.op2_sel == Bundle::OP2_RS2) ? r.wbs.wb_data :
                     dec_alu_op2;

      dec_rs2_data = (r.es.wb_addr  == dec_rs2_addr) && r.es.ctrl_rf_wen  && (dec_rs2_addr != 0) ? alu_out.data :
                     (r.ms.wb_addr  == dec_rs2_addr) && r.ms.ctrl_rf_wen  && (dec_rs2_addr != 0) ? mem_wb_data :
                     (r.wbs.wb_addr == dec_rs2_addr) && r.wbs.ctrl_rf_wen && (dec_rs2_addr != 0) ? r.wbs.wb_data :
                     rf_rs2_data;

      // stall logic
      if (ctl.dec_stall && !ctl.cmiss_stall || ctl.pipeline_kill) begin
         // kill exe stage
         rn.es.inst = 0; // TODO(BUBBLE)
         rn.es.wb_addr = 0;
         rn.es.ctrl_rf_wen = 1'b0;
         rn.es.ctrl_mem_val = 1'b0;
         rn.es.ctrl_mem_fcn = Bundle::M_X;
         rn.es.ctrl_br_type = Bundle::BR_N;
         rn.es.ctrl_csr_cmd = Bundle::CSR_N;
      end else if (!ctl.dec_stall && !ctl.cmiss_stall) begin
         rn.es.pc = r.ids.pc;
         rn.es.rs1_addr = dec_rs1_addr;
         rn.es.rs2_addr = dec_rs2_addr;
         rn.es.op1_data = dec_op1_data;
         rn.es.op2_data = dec_op2_data;
         rn.es.rs2_data = dec_rs2_data;
         rn.es.ctrl_op2_sel = ctl.op2_sel;
         rn.es.ctrl_alu_fun = ctl.alu_fun;
         rn.es.ctrl_wb_sel = ctl.wb_sel;
         if (ctl.dec_kill) begin
            rn.es.inst = 0; // BUBBLE
            rn.es.wb_addr = 0;
            rn.es.ctrl_rf_wen = 1'b0;
            rn.es.ctrl_mem_val = 1'b0;
            rn.es.ctrl_mem_fcn = Bundle::M_X;
            rn.es.ctrl_mem_typ = Bundle::MT_X;
            rn.es.ctrl_csr_cmd = ctl.csr_cmd;
            rn.es.ctrl_br_type = Bundle::BR_N;
         end else begin
            rn.es.inst = r.ids.inst;
            rn.es.wb_addr = dec_wb_addr;
            rn.es.ctrl_rf_wen = ctl.rf_wen;
            rn.es.ctrl_mem_val = ctl.mem_val;
            rn.es.ctrl_mem_fcn = ctl.mem_fcn;
            rn.es.ctrl_mem_typ = ctl.mem_typ;
            rn.es.ctrl_csr_cmd = ctl.csr_cmd;
            rn.es.ctrl_br_type = ctl.br_type;
         end
      end // if (!ctl.dec_stall && !ctl.ccache_stall)
   end

   // execute stage
   always_comb begin
      rn.ms = r.ms;
      // alu input
      alu_in.op1 = r.es.op1_data;
      alu_in.op2 = r.es.op2_data;
      alu_in.fun = r.es.ctrl_alu_fun;
      // branch calculation
      if (ctl.pipeline_kill) begin
         rn.ms.pc = '0;
         rn.ms.ctrl_mem_val = 1'b0;
         rn.ms.ctrl_rf_wen = 1'b0;
      end else if (!ctl.cmiss_stall) begin
         rn.ms.pc = r.es.pc;
         rn.ms.inst = r.es.inst;
         rn.ms.alu_out = (r.es.ctrl_wb_sel == Bundle::WB_PC4) ? (r.es.pc + 4) : alu_out.data;
         rn.ms.wb_addr = r.es.wb_addr;
         rn.ms.rs1_addr = r.es.rs1_addr;
         rn.ms.rs2_addr = r.es.rs2_addr;
         rn.ms.op1_data = r.es.op1_data;
         rn.ms.op2_data = r.es.op2_data;
         rn.ms.rs2_data = r.es.rs2_data;
         rn.ms.ctrl_rf_wen = r.es.ctrl_rf_wen;
         rn.ms.ctrl_mem_val = r.es.ctrl_mem_val;
         rn.ms.ctrl_mem_fcn = r.es.ctrl_mem_fcn;
         rn.ms.ctrl_mem_typ = r.es.ctrl_mem_typ;
         rn.ms.ctrl_wb_sel = r.es.ctrl_wb_sel;
         rn.ms.ctrl_csr_cmd = r.es.ctrl_csr_cmd;
      end // if (!ctl.cmiss_stall)
   end

   // memory stage
   always_comb begin
      rn.wbs = r.wbs;
      // writeback data mux
      mem_wb_data = (r.ms.ctrl_wb_sel == Bundle::WB_ALU) ? r.ms.alu_out :
                    (r.ms.ctrl_wb_sel == Bundle::WB_PC4) ? r.ms.alu_out :
                    (r.ms.ctrl_wb_sel == Bundle::WB_MEM) ? dmem_out.res.data :
                    // (r.ms.ctrl_wb_sel == Bundle::WB_CSR) ? csr_in.rdata;
                    // TODO(Christian) CSR
                    r.ms.alu_out;
   end

   // write back stage
   always_comb begin
      if (!ctl.cmiss_stall) begin
         rn.wbs.wb_addr = r.ms.wb_addr;
         rn.wbs.wb_data = mem_wb_data;
         rn.wbs.ctrl_rf_wen = r.ms.ctrl_rf_wen; // TODO(Christian) Exception handling
      end else begin
         rn.wbs.ctrl_rf_wen = 1'b0;
      end
   end // always_comb

   always_ff @(posedge clk) begin
      // debug printout
/* -----\/----- EXCLUDED -----\/-----
      $display(
               "(0x%x, 0x%x, 0x%x, 0x%x) [%x, %x, %x, %x] %s %s", r.ifs.pc, r.ids.pc, r.es.pc, rn.es.pc, if_instruction[6:0], r.ids.inst[6:0], r.es.inst[6:0], rn.es.inst[6:0], ctl.cmiss_stall ? "FREEZE" : ctl.dec_stall ? "STALL " : "", ctl.exe_pc_sel == 1 ? "BJ" : ctl.exe_pc_sel == 2 ? "JR" : ctl.exe_pc_sel == 3 ? "EX" : ctl.exe_pc_sel == 0 ? "  " : "??"
               );
 -----/\----- EXCLUDED -----/\----- */
      r <= rn;
   end

   // external signals
   assign dat.dec_inst = r.ids.inst;
   assign dat.exe_br_eq = (r.es.op1_data == r.es.rs2_data);
   assign dat.exe_br_lt = (r.es.op1_data < r.es.op2_data);
   assign dat.exe_br_ltu = (r.es.op1_data < r.es.op2_data); //TODO(Christian): Figure unsinged compare out
   assign dat.exe_br_type = r.es.ctrl_br_type;
   // datapath to memory signals
   assign dmem_in.req_valid = r.ms.ctrl_mem_val;
   assign dmem_in.req.addr = r.ms.alu_out;
   assign dmem_in.req.fcn = r.ms.ctrl_mem_fcn;
   assign dmem_in.req.typ = r.ms.ctrl_mem_typ;
   assign dmem_in.req.data = r.ms.rs2_data;
endmodule
