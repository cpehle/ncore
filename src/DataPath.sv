//@file DataPath.sv
//@author Christian Pehle
//@brief data path of one core
`include "Bundle.sv"
module DataPath(
                input  clk,
                input  Bundle::ControlToData ctl,
                output Bundle::DataToControl dat,
                output Bundle::MemoryIn imem_in,
                input  Bundle::MemoryOut imem_out,
                output Bundle::MemoryIn dmem_in,
                input  Bundle::MemoryOut dmem_out
);
   // datapath is a five stage pipeline.
   typedef struct packed {
      logic [31:0] pc; // program counter
   } InstructionFetchState;

   typedef struct packed {
      logic [31:0] inst; // instruction
      logic [31:0] pc; // program counter
   } InstructionDecodeState;

   typedef struct packed {
      logic [4:0] rs1_addr;
      logic [4:0] rs2_addr;
      logic [4:0] wb_addr;
      logic [31:0] alu_op2;
      logic [31:0] op1_data;
      logic [31:0] op2_data;
      logic [31:0] rs2_data;
      logic [15:0] imm;
   } DecodeSignals;

   typedef struct packed {
      logic [31:0] alu_out;
   } ExecuteSignals;


   typedef struct packed {
      logic [31:0] inst; // instruction
      logic [31:0] pc; // program counter
      logic [4:0] wb_addr; // write back address
      logic [4:0] rs1_addr; // result 1 address
      logic [4:0] rs2_addr; // result 2 address
      logic [31:0] op1_data; // operand 1 address
      logic [31:0] op2_data; // operand 2 address
      logic [31:0] rs2_data; // result 2 data
      Bundle::BranchType ctrl_br_type; // control branch type
      Bundle::Op2Sel ctrl_op2_sel; // control operand 2 select
      Bundle::AluFun ctrl_alu_fun; // control alu function
      logic        ctrl_wb_sel; // control writeback select
      logic        ctrl_rf_wen; // control register file write enable
      logic        ctrl_mem_val; // control memory value
      Bundle::MemoryWriteSignal ctrl_mem_fcn; // control memory function
      logic        ctrl_mem_typ; // control memory type
      logic        ctrl_csr_cmd; // control condition state register command
   } ExecuteState;

   typedef struct packed {
      logic [31:0] pc;
      logic [31:0] inst;
      logic [31:0] alu_out;
      logic [4:0]  wb_addr;
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
      logic [4:0] wb_addr;
      logic [31:0] wb_data;
      logic        ctrl_rf_wen;
   } WriteBackState;

   // This structure captures the whole state of
   // the fixed point facility pipeline.
   typedef struct packed {
      InstructionFetchState ifs;
      InstructionDecodeState ids;
      ExecuteState es;
      MemoryState ms;
      WriteBackState wbs;
   } DataPathState;

   DataPathState r; // current register state
   DataPathState rn; // register state at next time step

   DecodeSignals dec;
   ExecuteSignals exe;


   Bundle::RegisterFileIn rf_in;
   Bundle::RegisterFileOut rf_out;
   RegisterFile rf(/*AUTOINST*/
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

   Bundle::BypassIn bp_in;
   Bundle::BypassOut bp_out;
   Bypass bp(/*AUTOINST*/
             // Interfaces
             .bp_in                     (bp_in),
             .bp_out                    (bp_out));



   always_comb begin
      rn = r;
      // instruction fetch state
      if ((!ctl.dec_stall && !ctl.cmiss_stall) || ctl.pipeline_kill) begin
         rn.ifs.pc = ctl.exe_pc_sel == Bundle::PC_4 ? (r.ifs.pc + 4) : '0;
                     // ctl.exe_pc_sel == Bundle::PC_BRJMP ? r.exe.brjmp_target :
                     // ctl.exe_pc_sel == Bundle::PC_JALR ? r.exe.jump_reg_target :
                     // r.exception_target;
      end
      imem_in.req.addr = r.ifs.pc;
      rn.ids.inst = imem_out.res.data;

      // decode stage

      // signals
      dec.rs1_addr = r.ids.inst[15:11];
      dec.rs2_addr = r.ids.inst[20:16];
      dec.wb_addr = r.ids.inst[10:6];

      // input to the register file
      rf_in.rs1_addr = dec.rs1_addr;
      rf_in.rs2_addr = dec.rs2_addr;
      rf_in.waddr = r.wbs.wb_addr;
      rf_in.wdata = r.wbs.wb_data;
      rf_in.we = r.wbs.ctrl_rf_wen;

      // TODO(Christian): Immediates
      dec.imm[15:0] = r.ids.inst[31:16];


      // mux for second operand of alu
      // TODO(Christian): Put this logic in another module
      dec.alu_op2 = (ctl.op2_sel == Bundle::OP2_RS2) ? rf_out.rs2_data :
                    (ctl.op2_sel == Bundle::OP2_ITYPE) ? 0 : 0; // immediate

      dec.op1_data = (ctl.op1_sel == Bundle::OP1_IMZ) ? '0 : // TODO(Christian) : immediate
                     (ctl.op1_sel == Bundle::OP1_PC) ? r.ids.pc :
                     (r.es.wb_addr == dec.rs1_addr && r.es.ctrl_rf_wen) ? exe.alu_out :
//                     (r.ms.wb_addr == dec.rs1_addr && r.ms.ctrl_rf_wen) ? r.ms.mem_wbdata :
                     (r.wbs.wb_addr == dec.rs1_addr && r.wbs.ctrl_rf_wen) ? r.wbs.wb_data :  rf_out.rs1_data;

      dec.op2_data = (r.es.wb_addr == dec.rs2_addr) && r.es.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? alu_out.data :
       //              (r.ms.wb_addr == dec.rs2_addr) && r.ms.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? r.mem.wb_data :
                     (r.wbs.wb_addr == dec.rs2_addr) && r.wbs.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? r.wbs.wb_data : dec.alu_op2;

      rn.es.rs2_data = (r.es.wb_addr == dec.rs2_addr) && r.es.ctrl_rf_wen ? exe.alu_out: 0;
                        // (r.ms.wb_addr == dec.rs2_addr) && r.ms.ctrl_rf_wen ? r.mem.wbdata :
                        // (r.wbs.wb_addr == dec.rs2_addr) && r.wb.ctrl_rf_wen ? r.wbs.wb_data : rf_out.rs2_data;


      // stall logic
      if (ctl.dec_stall && !ctl.cmiss_stall || ctl.pipeline_kill) begin
         rn.es.wb_addr = 0;
         rn.es.ctrl_rf_wen = 1'b0;
         rn.es.ctrl_mem_val = 1'b0;
         rn.es.ctrl_mem_fcn = Bundle::M_X;
         rn.es.ctrl_br_type = Bundle::BR_N;
      end else if (!ctl.dec_stall && !ctl.cmiss_stall) begin
         rn.es.pc = r.ids.pc;
         rn.es.rs1_addr = dec.rs1_addr;
         rn.es.rs2_addr = dec.rs2_addr;
         //rn.es.op1_data = r.ids.op1_data;
         //rn.es.op2_data = r.ids.op2_data;
         rn.es.ctrl_op2_sel = ctl.op2_sel;
         rn.es.ctrl_alu_fun = ctl.alu_fun;
         // rn.es.wb_sel = ctl.wb_sel;

         if (ctl.dec_kill) begin
            rn.es.inst = 0; // BUBBLE
            rn.es.wb_addr = 0;
            rn.es.ctrl_rf_wen = 1'b0;
            // rn.es.mem_val = 1'b0;
            // rn.es.mem_fcn = Bundle::M_X;
            // es_next.mem_typ =
            // es_next.ctrl_csr_cmd = ctl.csr_cmd;
            // rn.es.br_type = Bundle::BR_N;
         end else begin
            rn.es.inst = r.ids.inst;
            // rn.es.wb_addr = r.ids.wb_addr;
            rn.es.ctrl_rf_wen = ctl.rf_wen;
            rn.es.ctrl_mem_val = ctl.mem_val;
            rn.es.ctrl_mem_fcn = ctl.mem_fcn;
            // rn.es.ctrl_mem_typ = ctl.mem_typ;
            // rn.es.ctrl_csr_cmd = ctl.csr_cmd;
            rn.es.ctrl_br_type = ctl.br_type;
         end
      end // if (!ctl.dec_stall && !ctl.ccache_stall)

      // Execute stage
      // alu_in.op1 = r.es.reg_op1;
      // alu_in.op2 = r.es.reg_op2;
      // alu_in.fun = r.es.ctrl_alu_fun;


      // branch calculation
      if (ctl.pipeline_kill) begin

      end else begin
         // rn.ms = r.es;
         // rn.ms.alu_out = r.es.ctr_wb_sel == Bundle::WB_PC4 ? (r.exe.pc + 4) : r.exe.alu_out;
      end

      // write back stage
      if (!ctl.cmiss_stall) begin
         rn.wbs.wb_addr = r.ms.wb_addr;
         // rn.wbs.wb_data = r.ms.wb_data;
         rn.wbs.ctrl_rf_wen = r.ms.ctrl_rf_wen; // TODO
      end else begin
         rn.wbs.ctrl_rf_wen = 1'b0;
      end

      // rn.ms.wb_data = (r.ms.wb_select == Bundle::WB_ALU) ? 0 : 0;
   end

   always_ff @(posedge clk) begin
      r <= rn;
   end
endmodule
