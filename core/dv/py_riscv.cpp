#include "core/dv/riscv.h"
#include "pybind11/pybind11.h"
namespace py = pybind11;
#include "pybind11/stl.h"
#include "pybind11/stl_bind.h"

PYBIND11_MAKE_OPAQUE(std::vector<unsigned int>);

PYBIND11_MODULE(libriscv, m) {
  // core/dv/riscv.h

  py::bind_vector<std::vector<unsigned int> >(m, "Instructions");
  
  py::enum_<riscv::reg>(m, "reg")
      .value("x0", riscv::reg::x0)
      .value("x1", riscv::reg::x1)
      .value("x2", riscv::reg::x2)
      .value("x3", riscv::reg::x3)
      .value("x4", riscv::reg::x4)
      .value("x5", riscv::reg::x5)
      .value("x6", riscv::reg::x6)
      .value("x7", riscv::reg::x7)
      .value("x8", riscv::reg::x8)
      .value("x9", riscv::reg::x9)
      .value("x10", riscv::reg::x10)
      .value("x11", riscv::reg::x11)
      .value("x12", riscv::reg::x12)
      .value("x13", riscv::reg::x13)
      .value("x14", riscv::reg::x14)
      .value("x15", riscv::reg::x15)
      .value("x16", riscv::reg::x16)
      .value("x17", riscv::reg::x17)
      .value("x18", riscv::reg::x18)
      .value("x19", riscv::reg::x19)
      .value("x20", riscv::reg::x20)
      .value("x21", riscv::reg::x21)
      .value("x22", riscv::reg::x22)
      .value("x23", riscv::reg::x23)
      .value("x24", riscv::reg::x24)
      .value("x25", riscv::reg::x25)
      .value("x26", riscv::reg::x26)
      .value("x27", riscv::reg::x27)
      .value("x28", riscv::reg::x28)
      .value("x29", riscv::reg::x29)
      .value("x30", riscv::reg::x30)
      .value("x31", riscv::reg::x31);
  m.def("bits", &riscv::bits);
  m.def("imm_ujtype", &riscv::imm_ujtype);
  m.def("imm_utype", &riscv::imm_utype);
  m.def("offset_branch", &riscv::offset_branch);
  m.def("imm_12_10$5", &riscv::imm_12_10$5);
  m.def("imm_4$1_11", &riscv::imm_4$1_11);
  m.def("nop", &riscv::nop);
  m.def("lui", &riscv::lui);
  m.def("auipc", &riscv::auipc);
  m.def("jal", &riscv::jal);
  m.def("jalr", &riscv::jalr);
  m.def("beq", &riscv::beq);
  m.def("bne", &riscv::bne);
  m.def("blt", &riscv::blt);
  m.def("bge", &riscv::bge);
  m.def("bltu", &riscv::bltu);
  m.def("bgeu", &riscv::bgeu);
  m.def("lb", &riscv::lb);
  m.def("lh", &riscv::lh);
  m.def("lw", &riscv::lw);
  m.def("lbu", &riscv::lbu);
  m.def("lhu", &riscv::lhu);
  m.def("sb", &riscv::sb);
  m.def("sh", &riscv::sh);
  m.def("sw", &riscv::sw);
  m.def("addi", &riscv::addi);
  m.def("add", &riscv::add);
  m.def("sub", &riscv::sub);
  m.def("xor_op", &riscv::xor_op);
  m.def("sll", &riscv::sll);
  m.def("sra", &riscv::sra);
  m.def("srl", &riscv::srl);
  m.def("land", &riscv::land);
  m.def("lor", &riscv::lor);
  m.def("lxor", &riscv::lxor);
  m.def("li", &riscv::li);
}
