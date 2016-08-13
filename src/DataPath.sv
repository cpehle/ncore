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
   typedef struct packed {
      logic [31:0] pc; // program counter
   } InstructionFetchState;

   typedef struct packed {
      logic [31:0] pc; // program counter
      logic [31:0] inst; // instruction
   } InstructionDecodeState;

   typedef struct packed {
      logic [31:0] pc; // program counter
      logic [31:0] inst; // instruction
      logic [4:0] wb_addr; // write back address
      logic [4:0] rs1_addr; // result 1 address
      logic [4:0] rs2_addr; // result 2 address
      logic [31:0] op1_data; // operand 1 address
      logic [31:0] op2_data; // operand 2 address
      logic [31:0] rs2_data; // result 2 data
      Bundle::BranchType ctrl_br_type; // control branch type
      Bundle::Op2Sel ctrl_op2_sel; // control operand 2 select
      Bundle::AluFun ctrl_alu_fun; // control alu function
      Bundle::WriteBackSelect ctrl_wb_sel; // control writeback select
      logic        ctrl_rf_wen; // control register file write enable
      logic        ctrl_mem_val; // control memory value
      Bundle::MemoryWriteSignal ctrl_mem_fcn; // control memory function
      Bundle::MemoryMaskType        ctrl_mem_typ; // control memory type
      logic        ctrl_csr_cmd; // control condition state register command
   } ExecuteState;

   typedef struct packed {
      logic [31:0] pc;
      logic [31:0] inst;
      logic [31:0] alu_out;
      logic [4:0]  wb_addr;
      logic [4:0]  rs1_addr;
      logic [4:0]  rs2_addr;
      logic [31:0]  op1_data;
      logic [31:0]  op2_data;
      logic [31:0]  rs2_data;
      logic         ctrl_rf_wen; // control register file write enable
      logic         ctrl_mem_val; // control memory value
      Bundle::MemoryWriteSignal ctrl_mem_fcn; // control memory function
      Bundle::MemoryMaskType        ctrl_mem_typ; // control memory type
      Bundle::WriteBackSelect ctrl_wb_sel; // control writeback select
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

   always_comb begin
      logic [4:0] dec_rs1_addr;
      logic [4:0] dec_rs2_addr;

      // logic [31:0] if_pc_next = '0;
      // logic [31:0] exe_brjmp_target = '0;
      logic [31:0] exe_jump_reg_target = '0;
      logic [31:0] exception_target = '0;
      logic [31:0] if_instruction;
      logic [4:0]  dec_wb_addr;
      // logic        imm_stype;
      // logic        imm_itype;
      // logic        imm_sbtype;
      // logic        imm_utype;
      //logic        imm_z;
      logic [31:0] dec_alu_op2;
      logic [31:0] dec_op1_data;
      logic [31:0] dec_op2_data;
      logic [31:0] dec_rs2_data;
      logic [31:0] mem_wb_data;
      logic [31:0] rf_rs1_data;
      logic [31:0] rf_rs2_data;


      // instruction fetch state
      if ((!ctl.dec_stall && !ctl.cmiss_stall) || ctl.pipeline_kill) begin
         rn.ifs.pc = ctl.exe_pc_sel == Bundle::PC_4 ? (r.ifs.pc + 4) :
                     // ctl.exe_pc_sel == Bundle::PC_BRJMP ? exe_brjmp_target :
                     ctl.exe_pc_sel == Bundle::PC_JALR ? exe_jump_reg_target :
                     exception_target;
      end
      imem_in.req.addr = r.ifs.pc;
      imem_in.req_valid = 1'b1; // TODO(Christian): Determine when this should actually be valid
      if_instruction = imem_out.res.data;

      if (ctl.pipeline_kill) begin
         rn.ids.inst = 0; //TODO(Christian): Bubble
      end else if (!ctl.dec_stall && !ctl.cmiss_stall) begin
         if (ctl.if_kill) begin
            rn.ids.inst = 0;
         end else begin
            rn.ids.inst = if_instruction;
         end
         rn.ids.pc = r.ifs.pc;
      end
      // instruction decode stage
      {dec_rs1_addr,dec_rs2_addr,dec_wb_addr} = {r.ids.inst[15:11],r.ids.inst[20:16],r.ids.inst[10:6]};

      rf_in.rs1_addr = dec_rs1_addr;
      rf_in.rs2_addr = dec_rs2_addr;
      rf_in.waddr = r.wbs.wb_addr;
      rf_in.wdata = r.wbs.wb_data;
      rf_in.we = r.wbs.ctrl_rf_wen;

      rf_rs1_data = rf_out.rs1_data;
      rf_rs2_data = rf_out.rs2_data;


      // TODO(Christian): Immediates
      // mux for second operand of alu
      // TODO(Christian): Put this logic in another module
      dec_op1_data = (ctl.op1_sel == Bundle::OP1_IMZ) ? '0 : // TODO(Christian) : immediate
                     (ctl.op1_sel == Bundle::OP1_PC) ? r.ids.pc :
                     (r.es.wb_addr == dec_rs1_addr && r.es.ctrl_rf_wen) ? alu_out.data :
                     //                     (r.ms.wb_addr == dec.rs1_addr && r.ms.ctrl_rf_wen) ? r.ms.mem_wbdata :
                     (r.wbs.wb_addr == dec_rs1_addr && r.wbs.ctrl_rf_wen) ? r.wbs.wb_data : rf_rs1_data;

      dec_op2_data = (r.es.wb_addr == dec_rs2_addr) && r.es.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? alu_out.data :
       //              (r.ms.wb_addr == dec.rs2_addr) && r.ms.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? r.mem.wb_data :
                     (r.wbs.wb_addr == dec_rs2_addr) && r.wbs.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? r.wbs.wb_data : dec_alu_op2;


      dec_rs2_data = (r.es.wb_addr == dec_rs2_addr) && r.es.ctrl_rf_wen ? alu_out.data : 0;
                        // (r.ms.wb_addr == dec.rs2_addr) && r.ms.ctrl_rf_wen ? r.mem.wbdata :
                        // (r.wbs.wb_addr == dec.rs2_addr) && r.wb.ctrl_rf_wen ? r.wbs.wb_data : rf_out.rs2_data;
      // stall logic
      if (ctl.dec_stall && !ctl.cmiss_stall || ctl.pipeline_kill) begin
         // kill exe stage
         rn.es.inst = 0; // TODO(BUBBLE)
         rn.es.wb_addr = 0;
         rn.es.ctrl_rf_wen = 1'b0;
         rn.es.ctrl_mem_val = 1'b0;
         rn.es.ctrl_mem_fcn = Bundle::M_X;
         rn.es.ctrl_br_type = Bundle::BR_N;
      end else if (!ctl.dec_stall && !ctl.cmiss_stall) begin
         rn.es.pc = r.ids.pc;
         rn.es.rs1_addr = dec_rs1_addr;
         rn.es.rs2_addr = dec_rs2_addr;
         rn.es.op1_data = dec_op1_data;
         rn.es.op2_data = dec_op2_data;
         rn.es.ctrl_op2_sel = ctl.op2_sel;
         rn.es.ctrl_alu_fun = ctl.alu_fun;
         rn.es.ctrl_wb_sel = ctl.wb_sel;
         if (ctl.dec_kill) begin
            rn.es.inst = 0; // BUBBLE
            rn.es.wb_addr = 0;
            rn.es.ctrl_rf_wen = 1'b0;
            rn.es.ctrl_mem_val = 1'b0;
            rn.es.ctrl_mem_fcn = Bundle::M_X;
            // es_next.mem_typ =
            // es_next.ctrl_csr_cmd = ctl.csr_cmd;
            rn.es.ctrl_br_type = Bundle::BR_N;
         end else begin
            rn.es.inst = r.ids.inst;
            rn.es.wb_addr = dec_wb_addr;
            rn.es.ctrl_rf_wen = ctl.rf_wen;
            rn.es.ctrl_mem_val = ctl.mem_val;
            rn.es.ctrl_mem_fcn = ctl.mem_fcn;
            rn.es.ctrl_mem_typ = ctl.mem_typ;
            // rn.es.ctrl_csr_cmd = ctl.csr_cmd;
            rn.es.ctrl_br_type = ctl.br_type;
         end
      end // if (!ctl.dec_stall && !ctl.ccache_stall)
      // execute stage
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
      end
      mem_wb_data = (r.ms.ctrl_wb_sel == Bundle::WB_ALU) ? r.ms.alu_out :
                    (r.ms.ctrl_wb_sel == Bundle::WB_PC4) ? r.ms.alu_out :
                    (r.ms.ctrl_wb_sel == Bundle::WB_MEM) ? dmem_out.res.data :
                    // TODO(Christian) CSR
                    r.ms.alu_out;
      // write back stage
      if (!ctl.cmiss_stall) begin
         rn.wbs.wb_addr = r.ms.wb_addr;
         rn.wbs.wb_data = mem_wb_data;
         rn.wbs.ctrl_rf_wen = r.ms.ctrl_rf_wen; // TODO(Christian) Exception handling
      end else begin
         rn.wbs.ctrl_rf_wen = 1'b0;
      end
      // external signals
      dat.dec_inst = r.ids.inst;
      dat.exe_br_eq = (r.es.op1_data == r.es.rs2_data);
      dat.exe_br_lt = (r.es.op1_data < r.es.op2_data);
      dat.exe_br_type = r.es.ctrl_br_type;
      // datapath to memory signals
      dmem_in.req_valid = r.ms.ctrl_mem_val;
      dmem_in.req.addr = r.ms.alu_out;
      dmem_in.req.fcn = r.ms.ctrl_mem_fcn;
      dmem_in.req.typ = r.ms.ctrl_mem_typ;
      dmem_in.req.data = r.ms.rs2_data;
   end

   always_ff @(posedge clk) begin
      r <= rn;
   end
endmodule
