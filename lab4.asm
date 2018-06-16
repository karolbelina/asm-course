# karol belina, 2nd of june, 2018
# labs #4
# stack

.data
string: .space 33
string_length: .word 33

enter_amount_msg: .asciiz "Enter the amount of strings: "
enter_amount_error_msg: .asciiz "Invalid amount of strings!\n"
enter_string_msg: .asciiz "Enter the string #"
colon: .asciiz ": "

delimeter: .asciiz ", "

.text
main:
	# run the input function
	jal input
	nop
	# run the output function
	jal output
	nop
	# exit
	li $v0, 10
	syscall
	
input:
	input_enter_amount:
		# print the enter amount message
		la $a0, enter_amount_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		blt $v0, 1, input_invalid_amount # < 1
		nop
		bgt $v0, 10, input_invalid_amount # > 10
		nop
		move $s0, $v0
		j input_enter_strings
		nop
		input_invalid_amount:
			# print the invalid amount message
			la $a0, enter_amount_error_msg
			li $v0, 4
			syscall
			j input_enter_amount
			nop
	input_enter_strings:
		li $t0, 0 # initialize the iterator
		# push the initial \0 onto the stack
		addi $sp, $sp, -1
		sb $zero, 0($sp)
		input_enter_string:
			# exit condition
			beq $t0, $s0, input_return # no more strings need to be read
			nop
			# print the enter string message
			la $a0, enter_string_msg
			li $v0, 4
			syscall
			# print the iterator
			add $a0, $t0, 1
			li $v0, 1
			syscall
			# print the colon
			la $a0, colon
			li $v0, 4
			syscall
			# load the string
			li $v0, 8
			la $a0, string
			lw $a1, string_length
			syscall
			li $t1, 0 # initialize the string iterator
			addiu $t0, $t0, 1
			input_iterate_string:
				lb $t2, string($t1)
				addiu $t1, $t1, 1
				beqz $t2, input_enter_string # char is a null
				nop
				bgtu $t2, 32, input_iterate_string_character # char is a regular character
				nop
				input_iterate_string_delimeter:
					# push \0 onto the stack
					addi $sp, $sp, -1
					sb $zero, 0($sp)
					j input_iterate_string
					nop
				input_iterate_string_character:
					# push char onto the stack
					addi $sp, $sp, -1
					sb $t2, 0($sp)
					j input_iterate_string
					nop
	input_return:
		jr $ra
		nop
					
output:
	addi $sp, $sp, 1 # point at the last char in the stack
	li $t1, 0 # string length
	output_iterate_string:
		# exit condition
		bge $sp, 0x7fffeffc, output_return # read all the strings in the stack and the stack pointer is at the bottom
		nop
		lb $t2, 0($sp)
		addi $sp, $sp, 1
		addi $t1, $t1, 1 # increment length
		bnez $t2, output_iterate_string # search the null char code
		nop
		# char is null
		addi $t0, $sp, 1 # store the pointer to the next string on the stack
		addi $t1, $t1, -1 # decrement length
		addi $sp, $sp, -2 # initialize the stack pointer to point at the first char of the read string
		output_print_string:
			lb $t3, 0($sp)
			addi $sp, $sp, -1
			bnez $t3, output_print_string_char
			nop
			output_print_string_null: # char is null
				move $sp, $t0 # point at the next string on the stack
				# print the delimeter
				la $a0, delimeter
				li $v0, 4
				syscall
				j output_iterate_string
				nop
			output_print_string_char:
				# print char
				move $a0, $t3
				li $v0, 11
				syscall
				j output_print_string
				nop
	output_return:
		jr $ra
		nop
