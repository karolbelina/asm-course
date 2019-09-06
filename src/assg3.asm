# karol belina, 2nd of june, 2018
# labs #3
# 16-bit integer randomizer

.data
# twenty two-byte (halfword) integers
array: .space 40
size: .word 40

comma: .asciiz ", "

.text
main:
	# run the generate function
	jal generate
	nop
	# run the display function
	jal display
	nop
	# exit
	li $v0, 10
	syscall

generate:
	li $t0, 0 # initialize the iterator
	lw $t1, size
	generate_loop:
		li $v0, 41
		li $a0, 0
		syscall
		# lower half
		move $t2, $a0
		andi $t2, 0x0000FFFF
		sh $a0, array($t0)
		addiu $t0, $t0, 2
		bge $t0, $t1, generate_return
		nop
		# upper half
		move $t2, $a0
		srl $t2, $t2, 16
		sh $a0, array($t0)
		addiu $t0, $t0, 2
		bge $t0, $t1, generate_return
		nop
		j generate_loop
		nop
	generate_return:
	jr $ra
	nop

display:
	li $t0, 0 # initialize the iterator
	lw $t1, size
	display_loop:
		li $v0, 1
		lhu $a0, array($t0)
		syscall
		li $v0, 4
		la $a0, comma
		syscall
		addiu $t0, $t0, 2
		bltu $t0, $t1, display_loop
		nop
	jr $ra
	nop
