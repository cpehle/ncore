module Execute();
   // execute stage
   always_comb begin
      // default assignments
      esn = es;
      // bypass multiplexers
      // op1 multiplexer
      dec_op1_data = (ctl.op1_sel == Bundle::OP1_IMZ) ? imm_z :
                     (ctl.op1_sel == Bundle::OP1_PC) ? ids.pc :
                     (es.wb_addr  == dec_rs1_addr) && (dec_rs1_addr != 0) && es.ctrl_rf_wen  ? alu_out.data :
                     (ms.wb_addr  == dec_rs1_addr) && (dec_rs1_addr != 0) && ms.ctrl_rf_wen  ? mem_wb_data :
                     (wbs.wb_addr == dec_rs1_addr) && (dec_rs1_addr != 0) && wbs.ctrl_rf_wen ? wbs.wb_data :
                     rf_out.rs1_data;

      // op2 multiplexer
      dec_op2_data = (es.wb_addr  == dec_rs2_addr) && (dec_rs2_addr != 0) && es.ctrl_rf_wen  && (ctl.op2_sel == Bundle::OP2_RS2) ? alu_out.data :
                     (ms.wb_addr  == dec_rs2_addr) && (dec_rs2_addr != 0) && ms.ctrl_rf_wen  && (ctl.op2_sel == Bundle::OP2_RS2) ? mem_wb_data :
                     (wbs.wb_addr == dec_rs2_addr) && (dec_rs2_addr != 0) && wbs.ctrl_rf_wen && (ctl.op2_sel == Bundle::OP2_RS2) ? wbs.wb_data :
                     dec_alu_op2;

      // register 2 data
      dec_rs2_data = (es.wb_addr  == dec_rs2_addr) && es.ctrl_rf_wen  && (dec_rs2_addr != 0) ? alu_out.data :
                     (ms.wb_addr  == dec_rs2_addr) && ms.ctrl_rf_wen  && (dec_rs2_addr != 0) ? mem_wb_data :
                     (wbs.wb_addr == dec_rs2_addr) && wbs.ctrl_rf_wen && (dec_rs2_addr != 0) ? wbs.wb_data :
                     rf_out.rs2_data;

      // stall logic
      if ((ctl.dec_stall && !ctl.cmiss_stall) || ctl.pipeline_kill) begin
         // kill exe stage
         esn.inst = 0; // BUBBLE
         esn.wb_addr = 0;
         esn.ctrl_rf_wen = 1'b0;
         esn.ctrl_mem_val = 1'b0;
         esn.ctrl_mem_fcn = Bundle::M_X;
         esn.ctrl_br_type = Bundle::BR_N;
         esn.ctrl_csr_cmd = Bundle::CSR_N;
      end else if (!ctl.dec_stall && !ctl.cmiss_stall) begin
         esn.pc = ids.pc;
         esn.rs1_addr = dec_rs1_addr;
         esn.rs2_addr = dec_rs2_addr;
         esn.op1_data = dec_op1_data;
         esn.op2_data = dec_op2_data;
         esn.rs2_data = dec_rs2_data;
         esn.ctrl_op2_sel = ctl.op2_sel;
         esn.ctrl_alu_fun = ctl.alu_fun;
         esn.ctrl_wb_sel = ctl.wb_sel;
         if (ctl.dec_kill) begin
            esn.inst = 0; // BUBBLE
            esn.wb_addr = 0;
            esn.ctrl_rf_wen = 1'b0;
            esn.ctrl_mem_val = 1'b0;
            esn.ctrl_mem_fcn = Bundle::M_X;
            esn.ctrl_mem_typ = Bundle::MT_X;
            esn.ctrl_csr_cmd = ctl.csr_cmd;
            esn.ctrl_br_type = Bundle::BR_N;
         end else begin
            esn.inst = ids.inst;
            esn.wb_addr = dec_wb_addr;
            esn.ctrl_rf_wen = ctl.rf_wen;
            esn.ctrl_mem_val = ctl.mem_val;
            esn.ctrl_mem_fcn = ctl.mem_fcn;
            esn.ctrl_mem_typ = ctl.mem_typ;
            esn.ctrl_csr_cmd = ctl.csr_cmd;
            esn.ctrl_br_type = ctl.br_type;
         end
      end // if (!ctl.dec_stall && !ctl.ccache_stall)
   end // always_comb
   always_ff @(posedge clk) begin
      es <= esn;
   end
endmodule
