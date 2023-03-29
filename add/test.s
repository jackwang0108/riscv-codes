# Add
# Format:
#	ADD RD, RS1, RS2
# Description:
#	The contents of RS1 is added to the contents of RS2 and the result is 
#	placed in RD.

	.text			    # directive, 指示/伪操作, 下面的指令编译出来之后放到text段
	.global	_start		# directive, 定义符号表里的全局变量

_start:
	li x6, 1		    # pseudonym-instruction, load immediate, x6 = 1
	li x7, 2		    # pseudonym-instruction, load immediate, x7 = 2
	add x5, x6, x7		# x5 = x6 + x7

stop:
	j stop			    # Infinite loop to stop execution

	.end			    # End of file
