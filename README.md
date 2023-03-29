# riscv-codes
Codes when learning risc-v assembly

# Prerequisite
gdb-multiarch, riscv-toolchain and qemu are required. Detailed steps is coming soon...

## Usage
Each folder corresponds with a risc-v instruction/pseudo-instruction. You can run 

```shell
cd <INSTRUCTION>
make all/full/run/debug
```

to test them. GDB debug settings, i.e. GDBINIT, is provided.
