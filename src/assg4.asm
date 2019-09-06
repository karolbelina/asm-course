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
result_msg: .asciiz "Result: "

delimeter: .asciiz ", "

.text
main:
	# run the input function
	jal input
	nop
	# run the output function
	# word count
	move $a0, $v0
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
		# initialize the iterator
		li $t0, 0
		# initialize the word iterator
		li $t4, 0
		# push the initial \0 onto the stack
		addi $sp, $sp, -1
		sb $zero, 0($sp)
		input_enter_string:
			# exit condition
			# no more strings need to be read
			beq $t0, $s0, input_return
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
			# initialize the string iterator
			li $t1, 0
			# initialize the regular character occurence flag
			# (0 - no char yet, 1 - char occured)
			li $t3, 0
			addiu $t0, $t0, 1
			input_iterate_string:
				lb $t2, string($t1)
				addiu $t1, $t1, 1
				# char is a regular character
				bgtu $t2, 32, input_iterate_string_character
				nop
				input_iterate_string_delimeter:
					# push \0 onto the stack only if some other
					# regular characters have been present
					beqz $t3, input_iterate_string_delimeter_push_null_skip
					nop
					addi $sp, $sp, -1
					sb $zero, 0($sp)
					# increment the word count
					addi $t4, $t4, 1
					input_iterate_string_delimeter_push_null_skip:
					# look ahead until you find a next regular character
					input_iterate_string_delimeter_lookahead:
						# char is a null
						beqz $t2, input_enter_string
						nop
						lb $t2, string($t1)
						# char is a regular character again
						bgtu $t2, 32, input_iterate_string
						nop
						addiu $t1, $t1, 1
						j input_iterate_string_delimeter_lookahead
						nop
				input_iterate_string_character:
					# switch the flag
					li $t3, 1
					# push char onto the stack
					addi $sp, $sp, -1
					sb $t2, 0($sp)
					j input_iterate_string
					nop
	input_return:
		# return the word count
		move $v0, $t4
		jr $ra
		nop
					
output:
	# word count
	move $t4, $a0
	# point at the last char in the stack because the last char added was \0
	addi $sp, $sp, 1
	# string length
	li $t1, 0
	# print the result message
	la $a0, result_msg
	li $v0, 4
	syscall
	output_iterate_string:
		# exit condition
		# outputted all the words in the stack
		beqz $t4, output_return
		nop
		lb $t2, 0($sp)
		addi $sp, $sp, 1
		# increment length
		addi $t1, $t1, 1
		# search the null char code
		bnez $t2, output_iterate_string
		nop
		# char is null
		# store the pointer to the next string on the stack
		addi $t0, $sp, 0
		# decrement length
		addi $t1, $t1, -1
		# initialize the stack pointer to point at the first char of the read string
		addi $sp, $sp, -2
		output_print_string:
			# check if remaining lenght is 0
			beqz $t1, output_print_string_delimeter
			nop
			output_print_string_character:
				# print the character
				lb $a0, 0($sp)
				li $v0, 11
				syscall
				addi $sp, $sp, -1
				addi $t1, $t1, -1
				j output_print_string
				nop
			output_print_string_delimeter:
				# point at the next string on the stack
				move $sp, $t0
				# decrease the remaining word count
				addi $t4, $t4, -1
				# print the delimeter
				la $a0, delimeter
				li $v0, 4
				syscall
				j output_iterate_string
				nop
	output_return:
		jr $ra
		nop
