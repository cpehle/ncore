//@file DataPath.sv
//@author Christian Pehle
//@brief data path of one core
`include "Bundle.sv"
module DataPath(
                input clk,
                input  Bundle::ControlToData ctl,
                output Bundle::DataToControl dat,
                input  Bundle::MemoryOut imem_in,
                output Bundle::MemoryIn imem_out,
                input  Bundle::MemoryOut dmem_in,
                output Bundle::MemoryIn dmem_out
);
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
      logic [4:0] wb_addr;
      logic [31:0] wb_data;
      logic        ctrl_rf_wen;
   } WriteBackState;

   typedef struct packed {
      InstructionFetchState ifs;
      InstructionDecodeState ids;
      ExecuteState es;
      MemoryState ms;
      WriteBackState wbs;
   } DataPathState;

   DataPathState r;
   DataPathState rn;

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
      rn = r;
      /// Instruction fetch state
      if ((!ctl.dec_stall && !ctl.ccache_stall) || ctl.pipeline_kill) begin
         rn.ifs.pc = ctl.exe_pc_sel == Bundle::PC_4 ? (ifs.pc + 4) :
                     ctl.exe_pc_sel == Bundle::PC_BRJMP ? exe_brjmp_target :
                     ctl.exe_pc_sel == Bundle::PC_JALR ? exe_jump_reg_target :
                     exception_target;
      end
      imem_in.req.addr = r.ifs.pc;
      rn.ifs.inst = imem_out.res.data;

      // input to the register file
      rf_in.rs1_addr = r.ids.inst[19:15];;
      rf_in.rs2_addr = r.ids.inst[24:20];
      rf_in.waddr = r.wbs.wb_addr;
      rf_in.wdata = r.wbs.wb_data;
      rf_in.we = r.wbs.ctrl_rf_wen;

      // mux for second operand of alu
      rn.exe.alu_op2 = (ctl.op2_sel == Bundle::OP2_RS2) ? rf_out.rs2_data :
                       (ctl.op2_sel == Bundle::OP2_ITYPE) ? 0 : 0;

      rn.exe.op1_data = (ctl.op1_sel == Bundle::OP1_IMZ) ? '0 :
                        (ctl.op1_sel == Bundle::OP1_PC) ? r.ids.pc :
                        (r.es.wbaddr == r.dec.rs1_addr && r.es.ctrl_rf_wen) ? r.ms.alu_out :
                        (r.ms.wbaddr == r.dec.rs1_addr && r.ms.ctrl_rf_wen) ? r.ms.mem_wbdata :
                        (r.wbs.wb_addr == r.dec_rs1_addr && wbs.ctrl_rf_wen) ? wbs.wb_data :  rf_out.rs1_data;
      rn.exe.op2_data = (es.wb_addr == dec_rs2_addr) && es.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? exe_alu_out :
                        (ms.wb_addr == dec_rs2_addr) && ms.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? mem_wbdata :
                        (wbs.wb_addr == dec_rs2_addr) && wbs.ctrl_rf_wen && ctl.op2_sel == Bundle::OP2_RS2 ? wbs.wb_data : dec_alu_op2;

      rn.exe.rs2_data = (es.wb_addr == dec_rs2_addr) && es.ctrl_rf_wen ? exe_alu_out:
                        (ms.wb_addr == dec_rs2_addr) && ms.ctrl_rf_wen ? mem_wbdata :
                        (wbs.wb_addr == dec_rs2_addr) && wb.ctrl_rf_wen ? wbs.wb_data : rf_rs2_data;

      if (ctl.dec_stall && !ctl.ccache_stall || ctl.pipeline_kill) begin
         rn.es.wb_addr = 0;
         rn.es.ctrl_rf_wen = 1'b0;
         rn.es.ctrl_mem_val = 1'b0;
         rn.es.ctrl_mem_fcn = Bundle::M_X;
         rn.es.ctrl_br_type = Bundle::BR_N;
      end else if (!ctl.dec_stall && !ctl.ccache_stall) begin
         rn.es.pc = ids.pc;
         rn.es.rs1_addr = ids.rs1_addr;
         rn.es.rs2_addr = ids.rs2_addr;
         rn.es.op1_data = ids.op1_data;
         rn.es.op2_data = ids.op2_data;
         rn.es.ctrl_op2_sel = ctl.op2_sel;
         rn.es.ctrl_alu_fun = ctl.alu_fun;
         rn.es.wb_sel = ctl.wb_sel;

         if (ctl.dec_kill) begin
            rn.es.inst = 0; // BUBBLE
            rn.es.wb_addr = 0;
            rn.es.ctrl_rf_wen = 1'b0;
            rn.es.mem_val = 1'b0;
            rn.es.mem_fcn = Bundle::M_X;
            // es_next.mem_typ =
            // es_next.ctrl_csr_cmd = ctl.csr_cmd;
            rn.es.br_type = Bundle::BR_N;
         end else begin
            rn.es.inst = ids.inst;
            rn.es.wb_addr = ids.wb_addr;
            rn.es.ctrl_rf_wen = ctl.rf_wen;
            rn.es.mem_val = ctl.mem_val;
            rn.es.mem_fcn = ctl.mem_fcn;
            rn.es.mem_typ = ctl.mem_typ;
            rn.es.ctrl_csr_cmd = ctl.csr_cmd;
            rn.es.br_type = ctl.br_type;
         end
      end // if (!ctl.dec_stall && !ctl.ccache_stall)

      // branch calculation
      if (ctl.pipeline_kill) begin

      end else begin
         rn.ms = r.es;
         rn.ms.alu_out = r.es.ctr_wb_sel == Bundle::WB_PC4 ? exe_pc_plus4 : exe_alu_out;
      end

      // write back stage
      if (!ctl.ccache_stall) begin
         rn.wbs.wb_addr = ms.wb_addr;
         rn.wbs.wb_data = ms.wb_data;
         rn.wbs.ctrl_rf_wen = ms.ctrl_rf_wen; // TODO
      end else begin
         rn.wbs.ctrl_rf_wen = 1'b0;
      end

      rn.ms.wb_data = (r.ms.wb_select == Bundle::WB_ALU) ? 0 : 0;
   end

   always_ff @(posedge clk) begin
      r <= rn;
   end
endmodule
