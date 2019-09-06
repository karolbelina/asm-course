# karol belina, 7th of may, 2018
# introduction labs
# exponents 2 by the specified integer and checks for the buffer overflow

.data
begin_msg: .asciiz "Please enter the exponent: "
result_msg: .asciiz "Result = "
overflow_msg: .asciiz "Buffer overflow"

.text
# prints the begin message, loads an integer, exponents 2 by said integer
# and prints the result or the buffer overflow message
main:
	# print the begin message
	la $a0, begin_msg
	li $v0, 4
	syscall
	# load an integer to t0
	li $v0, 5
	syscall
	# load 2 as the argument 0
	li $a0, 2
	# move loaded integer to the argument 1
	move $a1, $v0
	# call the exponentation function
	jal exponentation
	nop
	# store return values
	move $t0, $v0
	move $t1, $v1
	# if an overflow occured call the final overflow function
	bnez $t1, overflow
	nop
	# move the result to the argument 0
	move $a0, $t0
	# call the final result function
	j result
	nop

# exponents the base a0 by the exponent a1, puts the result in v0
# and the value 1 in v1 if an overflow occurs
exponentation:
	# load arguments
	move $t0, $a0
	move $t1, $a1
	# initialize the result
	li $t2, 1
	exponentation_loop:
		# finish exponenting if exponent is zero
		beq $t1, $zero, exponentation_return
		nop
		multu $t2, $t0 # multiply result times the base (2)
		mflo $t2 # move lo flag back to result
		beq $t2, $zero, exponentation_overflow # overflow occured if lo is zero
		nop
		sub $t1, $t1, 1 # decrement exponent
		j exponentation_loop # loop until exponent is decremented to zero
		nop
	exponentation_return:
		move $v0, $t2 # move the result to the return value 0
		li $v1, 0 # set the return flag 1 to 0
		jr $ra # return
		nop
	exponentation_overflow:
		li $v1, 1 # set the return flag 1 to 1
		jr $ra # return
		nop

# prints the result message, the argument a0 and terminates the program
result:
	# store the argument
	move $t0, $a0
	# print the result message
	la $a0, result_msg
	li $v0, 4
	syscall
	# print the result
	li $v0, 36 # unsigned int
	move $a0, $t0
	syscall
	# exit
	li $v0, 10
	syscall

# prints the overflow message and terminates the program
overflow:
	# print the error message
	la $a0, overflow_msg
	li $v0, 4
	syscall
	# exit
	li $v0, 10
	syscall
