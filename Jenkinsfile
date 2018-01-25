pipeline {
  agent any
  stages {
    stage('prerequisites') {
      steps {
        sh '''# git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
'''
        sh '''mkdir riscv_tools
export RISCV = $PWD/riscv_tools
cd riscv-gnu-toolchain
mkdir build; cd build
../configure --prefix=$RISCV --disable-linux --with-arch=rv32i
make install
'''
        cleanWs(cleanWhenNotBuilt: true, cleanWhenAborted: true, cleanWhenFailure: true)
      }
    }
  }
}