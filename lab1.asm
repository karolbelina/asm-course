# karol belina, 11th of may, 2018
# labs #1
# a basic calculator

.data
first_operand_msg: .asciiz "Please enter the first operand: "
operator_msg: .asciiz "Please enter the operator code: "
invalid_operator_msg: .asciiz "Invalid operator code!\n"
second_operand_msg: .asciiz "Please enter the second operand: "
division_by_zero_msg: .asciiz "Cannot divide by zero!"
result_msg: .asciiz "Result = "
again_msg: .asciiz "\n\nDo you want to make another calculation? (0/1): "

operators: .word addition, subtraction, multiplication, division
operator_count: .word 4

.text
main:
	# get data from the user
	jal input
	nop
	# switch on the operator code
	la $t0, operators
	sll $t1, $s0, 2 # shift to the left by two (multiply the chosen operator by 4)
	add $t1, $t1, $t0 # add the multiplied operator code to the base address of the operator list
	lw $t2, 0($t1) # load an operator address
	jalr $t2 # perform the operation
	nop
	move $s0, $v0 # store the returned value
	move $s1, $v1 # store the division by zero flag
	beqz $s1, print_result # check the division by zero flag
	nop
	# print the division by zero message
	la $a0, division_by_zero_msg
	li $v0, 4
	syscall
	li $v1, 0 # reset the division by zero flag
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
	beq $v0, 1, main # again
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
		move $t1, $v0 # move loaded integer to t1
	operator:
		# print the operator message
		la $a0, operator_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		move $t0, $v0 # move loaded integer to t0
		lw $t3, operator_count
		bltu $t0, $t3, second_operand # jump if the operator code is valid (<4)
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
		move $t2, $v0 # move loaded integer to t2
	# return
	move $s0, $t0
	move $a0, $t1
	move $a1, $t2
	jr $ra
	nop

# adds two integers
addition:
	add $v0, $a0, $a1
	jr $ra
	nop

# subtracts one integer from another
subtraction:
	sub $v0, $a0, $a1
	jr $ra
	nop

# multiplies two integers
multiplication:
	mul $v0, $a0, $a1
	jr $ra
	nop

# divides one integer by another
division:
	bnez $a1, division_correct
	nop
	# print the divisiojn by zero message
	li $v1, 1
	j division_return
	nop
	division_correct:
	div $v0, $a0, $a1
	division_return:
	jr $ra
	nop
