# karol belina, 11-15th of may, 2018
# labs #2
# vigenère cipher encryption and decryption

.data
operation_msg: .asciiz "Choose an operation (0 - encryption, 1 - decryption): "
invalid_operation_msg: .asciiz "Invalid operation code!\n"
key_msg: .asciiz "Enter the key: "
key_error_msg: .asciiz "Key cannot be empty!\n"
text_msg: .asciiz "Enter the text: "

key_buffer: .space 9
text_buffer: .space 17

operations: .word encrypt, decrypt

first_char: .byte 97 # 'a'

.text
main:
	# get data from the user
	jal input
	nop
	# switch on the operator code
	la $t0, operations
	sll $t1, $s0, 2 # shift to the left by two (multiply the chosen operator by 4)
	add $t1, $t1, $t0 # add the multiplied operator code to the base address of the operator list
	lw $t2, 0($t1) # load an operator address
	jalr $t2 # perform the operation
	nop
	move $s0, $v0 # store the returned value
	# print the result
	li $v0, 4
	la $a0, text_buffer
	syscall
	# exit
	li $v0, 10
	syscall
	
encrypt:
	li $t0, 0 # initialize the text counter
	li $t1, 0 # initialize the key counter
	lbu $t2, first_char
	encrypt_loop:
		lbu $t3, text_buffer($t0) # load the n-th character of the text
		beqz $t3, encrypt_return # check for null character of the text
		nop
		sub $t3, $t3, $t2 # subtract 'a'
		lbu $t4, key_buffer($t1) # load the n-th character of the key
		bnez $t4, encrypt_null_skip # check for null character of the key
		nop
		li $t1, 0 # if reached the end of the key, loop back to the beginning
		lbu $t4, key_buffer+0 # load the first character of the key
	encrypt_null_skip:
		sub $t4, $t4, $t2 # subtract 'a'
		add $t3, $t3, $t4 # add both differences
		# t2 mod 26
		# subtract 26 from t3 if it's greater or equal to 26, since t3 can only be between 0 and 50
		blt $t3, 26, encrypt_modulo_skip
		nop
		subi $t3, $t3, 26
	encrypt_modulo_skip:
		add $t3, $t3, $t2 # add 'a'
		sb $t3, text_buffer($t0)
		addi $t0, $t0, 1 # increment the text counter
		addi $t1, $t1, 1 # increment the text counter
		j encrypt_loop
		nop
	encrypt_return:
		jr $ra
		nop
	
decrypt:
	li $t0, 0 # initialize the text counter
	li $t1, 0 # initialize the key counter
	lbu $t2, first_char
	decrypt_loop:
		lbu $t3, text_buffer($t0) # load the n-th character of the text
		beqz $t3, decrypt_return # check for null character of the text
		nop
		lbu $t4, key_buffer($t1) # load the n-th character of the key
		bnez $t4, decrypt_null_skip # check for null character of the key
		nop
		li $t1, 0 # if reached the end of the key, loop back to the beginning
		lbu $t4, key_buffer+0 # load the first character of the key
	decrypt_null_skip:
		sub $t3, $t3, $t4 # sub key character from the text charater
		# ($t3 + 26) mod 26
		# add 26 to t3 if it's lower than zero, since t3 can only be between -25 and 25
		bgez $t3, decrypt_modulo_skip
		nop
		addi $t3, $t3, 26
	decrypt_modulo_skip:
		add $t3, $t3, $t2 # add 'a'
		sb $t3, text_buffer($t0)
		addi $t0, $t0, 1 # increment the text counter
		addi $t1, $t1, 1 # increment the text counter
		j decrypt_loop
		nop
	decrypt_return:
		jr $ra
		nop
	
input:
	operation:
		# print the message
		la $a0, operation_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		move $s0, $v0 # move loaded integer to t0
		bltu $s0, 2, key # jump if the operator code is valid
		nop
		# print the invalid operation message
		la $a0, invalid_operation_msg
		li $v0, 4
		syscall
		j operation
		nop
	key:
		# print the message
		la $a0, key_msg
		li $v0, 4
		syscall
		# load a string
		li $v0, 8
		la $a0, key_buffer
		li $a1, 9
		syscall
		li $t1, 0
		key_replace_newline:
			lbu $t1, key_buffer($t0)
			addiu $t0, $t0, 1
			bnez $t1, key_replace_newline # search the null char code
			nop
			beq $a1, $t0, key_replace_newline_skip # check whether the buffer was fully loaded
			nop
			subiu $t0, $t0, 2 # otherwise "remove" the last character
			sb $zero, key_buffer($t0)
			bne $t0, 0, key_replace_newline_skip # if string was empty, print the message and loop back
			nop
			# print the message
			la $a0, key_error_msg
			li $v0, 4
			syscall
			j key
			nop
		key_replace_newline_skip:
	text:
		# print the message
		la $a0, text_msg
		li $v0, 4
		syscall
		# load a string
		li $v0, 8
		la $a0, text_buffer
		li $a1, 17
		syscall
		li $t1, 0
		text_replace_newline:
			lbu $t1, text_buffer($t0)
			addiu $t0, $t0, 1
			bnez $t1, text_replace_newline # search the null char code
			nop
			beq $a1, $t0, text_replace_newline_skip # check whether the buffer was fully loaded
			nop
			subiu $t0, $t0, 2 # otherwise "remove" the last character
			sb $zero, text_buffer($t0)
		text_replace_newline_skip:
	# return
	jr $ra
	nop
