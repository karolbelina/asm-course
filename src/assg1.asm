# asgg1
# a basic calculator

.data
# pointers to all the operations
operations: .word addition, subtraction, multiplication, division
operator_count: .word 4

# messages displayed to the user
first_operand_msg: .asciiz "Please enter the first operand: "
operator_msg: .asciiz "Please enter the operation code: "
invalid_operator_msg: .asciiz "Invalid operation code!\n"
second_operand_msg: .asciiz "Please enter the second operand: "
division_by_zero_msg: .asciiz "Cannot divide by zero!"
result_msg: .asciiz "Result = "
again_msg: .asciiz "\n\nDo you want to make another calculation? (0/1): "

.text
main:
	# get data from the user
	jal input
	nop
	# switch on the operator code
	# load pointers to all the operations
	la $t0, operations
	# multiply the chosen operation code by 4
	sll $t1, $s0, 2
	# add the multiplied operator code to the base address of the operator list
	add $t1, $t1, $t0
	# load the chosen operation address
	lw $t2, 0($t1)
	# perform the operation
	jalr $t2
	nop
	# store the returned value
	move $s0, $v0
	# store the returned division by zero flag
	move $s1, $v1
	# check the division by zero flag
	beqz $s1, print_result
	nop
	# print the division by zero message
	la $a0, division_by_zero_msg
	li $v0, 4
	syscall
	# reset the division by zero flag
	li $v1, 0
	j print_again
	nop
	print_result:
		# print the result message
		la $a0, result_msg
		li $v0, 4
		syscall
		# print the result
		li $v0, 1
		move $a0, $s0
		syscall
	print_again:
		# print the again message
		la $a0, again_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		beq $v0, 1, main
	# exit
	li $v0, 10
	syscall

input:
	first_operand:
		# print the first operand message
		la $a0, first_operand_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		# move loaded integer to t1
		move $t1, $v0
	operator:
		# print the operator message
		la $a0, operator_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		# move loaded integer to t0
		move $t0, $v0
		lw $t3, operator_count
		# jump if the operator code is valid (less than 4 in this case)
		bltu $t0, $t3, second_operand
		nop
		# print the invalid operator message
		la $a0, invalid_operator_msg
		li $v0, 4
		syscall
		j operator
		nop
	second_operand:
		# print the first operand message
		la $a0, second_operand_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		# move loaded integer to t2
		move $t2, $v0
	# return
	move $s0, $t0
	move $a0, $t1
	move $a1, $t2
	jr $ra
	nop

# adds two integers
addition:
	add $v0, $a0, $a1
	li $v1, 0
	# return
	jr $ra
	nop

# subtracts one integer from another
subtraction:
	sub $v0, $a0, $a1
	li $v1, 0
	# return
	jr $ra
	nop

# multiplies two integers
multiplication:
	mul $v0, $a0, $a1
	li $v1, 0
	# return
	jr $ra
	nop

# divides one integer by another
division:
	# check if the divisor is equal to zero
	beqz $a1, division_division_by_zero
	nop
	# divide
	div $v0, $a0, $a1
	li $v1, 0
	j division_return
	nop
	division_division_by_zero:
		# throw an exception
		li $v0, 0
		li $v1, 1
	division_return:
		jr $ra
		nop

.ktext 0x80000180
# get value in cause register and copy it to $k0
mfc0 $k0, $13
# mask all but the exception code (bits 2 - 6) to zero
andi $k1, $k0, 0x00007c
# shift two bits to the right to get the exception code in a comparable form
srl  $k1, $k1, 2
# now $k0 = value of cause register
#     $k1 = exception code

__exception:
	# branch on value of the the exception code in $k1.
	# (overflow exception has the code 12)
 	beq $k1, 12, __overflow_exception
 	j __resume_from_exception
	__overflow_exception:
		# use the MARS built-in system call 4 (print string) to print error messsage.
 		li $v0, 0
 		li $v1, 1
		j __resume_from_exception
	__resume_from_exception:
		# use the eret (Exception RETurn) instruction to set the program counter
		# (PC) to the value saved in the ECP register (register 14 in coporcessor 0).
		eret
		nop
