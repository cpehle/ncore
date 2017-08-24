#include "obj_dir/VDutCore.h"
#include "verilated_vcd_c.h"
#include "pybind11/pybind11.h"

namespace py = pybind11;

PYBIND11_MODULE(libcore, m) {  
  py::class_<::VerilatedModule>(m, "VerilatedModule",
                                "Base class for all Verilated module classes")
      .def(py::init<const char *>(), py::arg("namep"))
      .def("name", &::VerilatedModule::name);
  // VDutCore.h
  py::class_<::VDutCore, VerilatedModule>(m, "VDutCore")
      .def(py::init<const char *>(), py::arg("name"))
      .def("eval", &::VDutCore::eval)
      .def("final", &::VDutCore::final)
      .def("trace", &::VDutCore::trace)
      .def_readwrite("clk", &::VDutCore::clk)
      .def_readwrite("reset", &::VDutCore::reset)
      .def_readwrite("imem_in_req_fcn", &::VDutCore::imem_in_req_fcn)
      .def_readwrite("imem_in_req_typ", &::VDutCore::imem_in_req_typ)
      .def_readwrite("imem_in_req_valid", &::VDutCore::imem_in_req_valid)
      .def_readwrite("dmem_in_req_fcn", &::VDutCore::dmem_in_req_fcn)
      .def_readwrite("dmem_in_req_typ", &::VDutCore::dmem_in_req_typ)
      .def_readwrite("dmem_in_req_valid", &::VDutCore::dmem_in_req_valid)
      .def_readwrite("imem_out_req_ready", &::VDutCore::imem_out_req_ready)
      .def_readwrite("imem_out_res_valid", &::VDutCore::imem_out_res_valid)
      .def_readwrite("dmem_out_req_ready", &::VDutCore::dmem_out_req_ready)
      .def_readwrite("dmem_out_res_valid", &::VDutCore::dmem_out_res_valid)
      .def_readwrite("imem_in_req_addr", &::VDutCore::imem_in_req_addr)
      .def_readwrite("imem_in_req_data", &::VDutCore::imem_in_req_data)
      .def_readwrite("dmem_in_req_addr", &::VDutCore::dmem_in_req_addr)
      .def_readwrite("dmem_in_req_data", &::VDutCore::dmem_in_req_data)
      .def_readwrite("imem_out_res_data", &::VDutCore::imem_out_res_data)
      .def_readwrite("dmem_out_res_data", &::VDutCore::dmem_out_res_data);
}
