pipeline {
  agent any
  stages {
    stage('Prerequisites') {
      steps {
        sh '''# git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
'''
        sh '''# mkdir riscv_tools
# export RISCV = $PWD/riscv_tools
# cd riscv-gnu-toolchain
# mkdir build; cd build
# ../configure --prefix=$RISCV --disable-linux --with-arch=rv32i
# make install
'''
      }
    }
    stage('Build') {
      steps {
        sh '''cd core/dv && make -f core.mk
bazel build //core/dv:instruction_tests'''
      }
    }
    stage('Test') {
      steps {
        sh 'bazel test //core/dv:instruction_tests'
      }
    }
  }
}