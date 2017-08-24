import libcore as core

def step(c, memory):
    for i in range(2):
        c.clock == !core.clk
    
        # service instruction memory requests       
        iaddr = core.imem_in_req_addr/4       
        core.imem_out_req_ready = 1
        if core.imem_in_req_valid:
            if (iaddr > m.instruction_memory.size):
                core.imem_out_res_data = 0x13
                core.imem_out_res_valid = 1
            else:
                core.imem_out_res_data = m.instruction_memory[iaddr]
                core.imem_out_res_valid = 1
        
        # service data memory requests        
        daddr = core.imem_in_req_addr/4       
        core.dmem_out_req_ready = 1
        if core.dmem_in_req_valid:
            if (daddr > m.data_memory.size):
                core.dmem_out_res_data = 0x0
                core.dmem_out_res_valid = 1
            else:
                if (core.dmem_in_req_fcn == 0x0):
                    core.dmem_out_res_data = m.instruction_memory[daddr]
                    core.dmem_out_res_valid = 1
                else if (core.dmem_in_req_fcn == 0x1):
                    m.data_memory[daddr] = core.dmem_in_eq_data            
        core.eval()
