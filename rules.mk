# rules.mk文件用于被其他makefile include
# inlcude rules.mk的文件需要：
# 		1. 定义 SRC 变量
#		2. 定义 EXEC 变量
#		3. 定义 GDBINIT 变量

# riscv-gcc交叉编译器参数
#		1. -notstdlib: 在连接的时候不链接LD_LIBRARY_PATH中的库, 只链接用户传入的库
#		2. -fno_builtin: 不使用库函数（即使用自己写的printf）
#		3. -march: 指定编译生成的指令集
#		4. -mabi: 指定编译生成的程序的函数调用传参方式
#		5. -g: 编译的时候将调试信息写入到生成的文件中, 方便后续使用gdb调试
#		6. -Wall: 编译时候输出所有的警告信息。
CFLAGS = -nostdlib -fno-builtin -march=rv32ima -mabi=ilp32 -g -Wall

# QEMU模拟器参数
#		1. -nographic: 不模拟显示器
#		2. -smp: 指定CPU数, 对于RISC-V就是只有一个HART
#		3. -machine: 指定设备种类, 因为QEMU有System模式, 即模拟除了CPU以外的所有外围设备. 不同的计算机有不同的设备
#				     例如qemu-system-aarch64可以指定-machine为raspi3b, 即直接模拟一个树莓派3B. 这里直接是啥都有的虚拟机
#		4. -bios: 指定使用那种bios
QFLAGS = -nographic -smp 1 -machine virt -bios none


# QEMU
QEMU = qemu-system-riscv32

# GDB
GDB = gdb-multiarch

# CROSS_COMPILE 变量指定交叉编译工具链类型
CROSS_COMPILE = riscv64-unknown-elf-

# GCC
CC = ${CROSS_COMPILE}gcc

# OBJCOPY
OBJCOPY = ${CROSS_COMPILE}objcopy

# OBJDUMP
OBJDUMP = ${CROSS_COMPILE}objdump



# all 目标用于生成可执行文件
#		1. 编译 SRC 变量指定的源代码, 并生成elf格式的可执行文件
#		2. 使用 objcopy 将elf可执行文件转换为binary文件, 主要是为了删除elf里面没用的节, 留下代码的节, 方面后面的反汇编
.DEFAULT_GOAL := all
all:
	@${CC} ${CFLAGS} ${SRC} -Ttext=0x80000000 -o ${EXEC}.elf
	@${OBJCOPY} -O binary ${EXEC}.elf ${EXEC}.bin


# all 目标用于生成可执行文件和所有的中间文件
full : all hex code 

# .PHONY : kill
# kill:
# 	@echo "Kill all QEMU process..."
# 	# ps aux | grep -e 'qemu' | awk '{print $$2}' | xargs kill
# 	ps aux | grep -e 'qemu' 

# run 伪目标依赖于 all 目标, 用于直接运行elf可执行文件
.PHONY : run
run: all
	@echo "Press Ctrl-A and then X to exit QEMU"
	@echo "------------------------------------"
	@echo "No output, please run 'make debug' to see details"
	@${QEMU} ${QFLAGS} -kernel ./${EXEC}.elf

# debug 伪目标依赖于 all 伪目标, 用于调试elf可执行文件
#		1. qemu -kernel参数指定内核程序
#		2. qemu -s 参数指定启动qemu内建的的GDB server, 端口默认为1234
#		3. qemu -S 参数指定开始调试后停止运行（freeze CPU at Start）, 待GDB client链接后再开始调试
#		4. 后台启动qemu, 因为要在前台运行GDB Client
#		5. 启动GDB -q 静默一些连接的输出信息
#		6. 启动GDB -x 在连接后自动运行的GDB调试命令, 主要是方便进行初始化
.PHONY : debug
debug: all
	@echo "Press Ctrl-C and then input 'quit' to exit GDB and QEMU"
	@echo "-------------------------------------------------------"
	@${QEMU} ${QFLAGS} -kernel ${EXEC}.elf -s -S &
	@${GDB} ${EXEC}.elf -q -x ${GDBINIT}

# code 伪目标依赖于 all 伪目标, 用于反汇编生产的可执行程序
.PHONY : code
code: all
	@echo "Disassmbly code can be found in" ${EXEC}.code
	@echo "-------------------------------------------------------"
	@${OBJDUMP} -S ${EXEC}.elf > ${EXEC}.code
	@${OBJDUMP} -S ${EXEC}.elf | less

# hex 伪目标依赖于 all 伪目标, 用于输出可执行文件的二进制内容
.PHONY : hex
hex: all
	@echo "Machine code can be found in" ${EXEC}.machine
	@echo "-------------------------------------------------------"
	@hexdump -C ${EXEC}.bin > ${EXEC}.machine
	@hexdump -C ${EXEC}.bin

# clean 伪目标删除编译得到的所有中间文件
.PHONY : clean
clean:
	rm -rf *.o *.bin *.elf *.machine *.code

