module axi_reg_target
  #(parameter int NUM_REGS = 1,
    parameter int ADDR_WIDTH = 32,
    parameter int REG_WIDTH = 32,
    parameter int BASE_ADDR   = 32'h0000_0000,
    parameter int BASE_MASK   = 32'hffff_ffff,
    parameter int OFFSET_MASK = 32'h0000_0001,
    parameter bit[0:NUM_REGS-1] WRITEABLE = '1,
    parameter logic[REG_WIDTH-1 : 0] RESET_VALUES[0:NUM_REGS-1] = '{default: '0} )
  ( input clk,
    input nreset,
    axi_ifc.slave s,
    input logic[REG_WIDTH-1:0] regs_in[0:NUM_REGS-1],
    output logic[REG_WIDTH-1:0] regs[0:NUM_REGS-1],
    output logic reading[0:NUM_REGS-1],
    output logic writing[0:NUM_REGS-1] );

   // TODO:
   //
   // - implement address masking as in Bus_reg_target (omnibus)
   // - implement writable constraint
   // - implement base address
   
   typedef logic [ADDR_WIDTH-1:0] Addr_t;
   typedef logic [REG_WIDTH-1:0] Reg_t;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 o_rd;                   // From reg_ctrl of axi_registers.v
   wire [R_ADDR_WIDTH-1:0] o_rreg;              // From reg_ctrl of axi_registers.v
   wire [31:0]          o_wdata;                // From reg_ctrl of axi_registers.v
   wire                 o_wr;                   // From reg_ctrl of axi_registers.v
   wire [R_ADDR_WIDTH-1:0] o_wreg;              // From reg_ctrl of axi_registers.v
   // End of automatics
   
   axi_registers reg_ctrl(.clk, 
                          .s, 
                          /*AUTOINST*/
                          // Outputs
                          .o_rreg               (o_rreg[R_ADDR_WIDTH-1:0]),
                          .o_wreg               (o_wreg[R_ADDR_WIDTH-1:0]),
                          .o_wdata              (o_wdata[31:0]),
                          .o_rd                 (o_rd),
                          .o_wr                 (o_wr),
                          // Inputs
                          .i_rdata              (i_rdata[31:0]));

   always_comb begin
      for (int i = 0; i < NUM_REGS; i++) begin
         reading[i] = o_rd & (o_rreg[R_ADDR_WIDTH-1:0] == i);         
         writing[i] = o_wr & (o_wreg[R_ADDR_WIDTH-1:0] == i);
         next_regs[i] = regs[i];         
      end      
      i_rdata = regs[o_rreg];      
      next_regs[o_wreg] = o_wr ? regs[o_wreg] : regs[o_wreg];      
   end

   Reg_t regs[0:NUM_REGS-1], next_regs[0:NUM_REGS-1];
   
   always_ff @(posedge clk) begin
      if (nreset) begin
         for (int i = 0; i < NUM_REGS; i++) begin
            regs[i] <= next_regs[i];
         end         
      end else begin
         for (int i = 0; i < NUM_REGS; i++) begin
            regs[i] <= RESET_VALUES[i];            
         end 
      end
   end
endmodule
