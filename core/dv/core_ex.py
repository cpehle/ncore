import libcore as core
import numpy as np

def step(dut, memory):
    for i in range(2):
        dut.clk = ~dut.clk
    
        # service instruction memory requests       
        iaddr = int(dut.imem_in_req_addr/4)
        dut.imem_out_req_ready = 1
        if dut.imem_in_req_valid:
            if (iaddr > memory.instruction_memory.size):
                dut.imem_out_res_data = 0x13
                dut.imem_out_res_valid = 1
            else:
                dut.imem_out_res_data = memory.instruction_memory[iaddr]
                dut.imem_out_res_valid = 1
        
        # service data memory requests        
        daddr = dut.imem_in_req_addr/4       
        dut.dmem_out_req_ready = 1
        if dut.dmem_in_req_valid:
            if (daddr > memory.data_memory.size):
                dut.dmem_out_res_data = 0x0
                dut.dmem_out_res_valid = 1
            else:
                if (dut.dmem_in_req_fcn == 0x0):
                    dut.dmem_out_res_data = memory.instruction_memory[daddr]
                    dut.dmem_out_res_valid = 1
                elif (dut.dmem_in_req_fcn == 0x1):
                    memory.data_memory[daddr] = dut.dmem_in_eq_data            
        dut.eval()

class Memory:
    """
    Simple Memory abstraction
    """
    def __init__(self):
        self.instruction_memory = np.zeros(10000, dtype=np.uint32)
        self.data_memory = np.zeros(10000, dtype=np.uint32)


        
if __name__ == "__main__":
    m = Memory()
    dut = core.VDutCore("core")
    for i in range(100):
        step(dut,m)
    
