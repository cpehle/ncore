module BypassMux(
                 input logic [4:0]  ex_waddr,
                 input logic        ex_reg_valid,
                 input logic        ex_ctrl_wxd,
                 input logic [4:0]  mem_waddr,
                 input logic        mem_reg_valid,
                 input logic        mem_ctrl_wxd,
                 input logic [31:0] mem_reg_wdata,
                 input logic [4:0]  wb_waddr,
                 input logic        wb_reg_valid,
                 input logic        wb_ctrl_wxd,
                 input logic [31:0] wb_reg_wdata

);

endmodule
