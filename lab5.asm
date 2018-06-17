# karol belina, 2nd of june, 2018
# labs #5
# tic tac toe

# X X O 
# X _ 0 
# _ 0 X 

.data
# 0 is empty, 1 is player, 2 is ai
# 0 1 2
# 3 4 5
# 6 7 8
#board: .space 9
board: .byte 1,1,0,2,1,2,0,0,1

# 0 - top, 1 - middle, 2 - bottom, 3 - left, 4 - center, 5 - right, 6 - diagonal (\), 7 - backdiagonal (/)
# 0 for neutral, 1 and 2 for player, 3 and 4 for ai, 5 for wasted
row_preferences: .space 8 

#top: .byte 0, 1, 2
#middle: .byte 3, 4, 5
#bottom: .byte 6, 7, 8
#left: .byte 0, 3, 6
#center: .byte 1, 4, 7
#right: .byte 2, 5, 8
#diagonal: .byte 0, 4, 8
#backdiagonal: .byte 2, 4, 6

# 0 --x-> 1
# 0 --o-> 3
# 1 --x-> 2
# 1 --o-> 5
# 2 --x-> x's win
# 2 --o-> 5
# 3 --x-> 5
# 3 --o-> 4
# 4 --x-> 5
# 4 --o-> o's win
# 5 --x-> 5
# 5 --o-> 5
#                                        0x 0o 1x 1o 2x 2o 3x 3o 4x 4o 5x 5o
row_preference_state_lookup_table: .byte 1, 3, 2, 5, 6, 5, 5, 4, 5, 7, 5, 5

# 8 is null
cell_to_rows: .byte 0, 3, 6, 8,    0, 4, 8, 8,    0, 5, 7, 8,
                    1, 3, 8, 8,    1, 4, 6, 7,    1, 5, 8, 8,
                    2, 3, 7, 8,    2, 4, 8, 8,    2, 5, 6, 8

row_to_cells: .byte 0, 1, 2,    3, 4, 5,    6, 7, 8,    0, 3, 6,    1, 4, 7,    2, 5, 8,    0, 4, 8,    2, 4, 6
                    
start_msg: .asciiz "Enter the number of matches: "
start_error_msg: .asciiz "Invalid number of marches!\n"
start_match_msg: .asciiz "Match #"
colon: .asciiz ": "
newline: .asciiz "\n"
_: .asciiz "_ "
x: .asciiz "X "
o: .asciiz "O "
move_msg: .asciiz "Make a move (1-9): "
occupied_msg: .asciiz "Cell already occupied!\n"
invalid_index_msg: .asciiz "Invalid cell index!\n"
tie: .asciiz "Tie!\n"
x_win: .asciiz "X's win!\n"
o_win: .asciiz "O's win!\n"

debug_space: .asciiz " "

.text
main:
	jal game
	nop
	# exit
	li $v0, 10
	syscall

game:
	game_enter_number:
		# print the enter number of matches message
		la $a0, start_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		blt $v0, 1, input_invalid_amount # < 1
		nop
		move $s0, $v0
		j game_matches
		nop
		input_invalid_amount:
			# print the invalid number message
			la $a0, start_error_msg
			li $v0, 4
			syscall
			j game_enter_number
			nop
	game_matches:
		li $s1, 0 # initialize the iterator
		li $s2, 0 # initialize the x's wins
		li $s3, 0 # initialize the o's wins
		game_match:
			# exit condition
			beq $s1, $s0, game_return
			# print the match messaage
			la $a0, start_match_msg
			li $v0, 4
			syscall
			# print the iterator
			add $a0, $s1, 1
			li $v0, 1
			syscall
			# print the colon
			la $a0, colon
			li $v0, 4
			syscall
			# print the newline
			la $a0, newline
			li $v0, 4
			syscall
			# play the actual match
			addi $sp, $sp, -20
			sw $ra, 0($sp) # store return address
			sw $s0, 4($sp) # store $s0
			sw $s1, 8($sp) # store $s1
			sw $s2, 12($sp) # store $s2
			sw $s3, 16($sp) # store $s3
			jal match
			nop
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s2, 12($sp)
			lw $s3, 16($sp)
			addi $sp, $sp, 12
			add $s2, $s2, $v0 # add x's win
			add $s3, $s3, $v1 # add x's win
			addi $s1, $s1, 1 # increment the iterator
			# display the win message
			or $t1, $v0, $v1
			beqz $t1, game_match_result_tie # tie
			nop
			# not a tie
			beqz $v0, game_match_result_o_won # o's wom
			nop
			game_match_result_x_won:
				la $a0, x_win
				li $v0, 4
				syscall
				j game_match
				nop
			game_match_result_o_won:
				la $a0, o_win
				li $v0, 4
				syscall
				j game_match
				nop
			game_match_result_tie:
				la $a0, tie
				li $v0, 4
				syscall
				j game_match
				nop
	game_return:
		jr $ra
		nop
		
match:
	addi $sp, $sp, 4
	sw $ra, 0($sp) # store return address
	li $t0, 0 # initialize the clear board iterator
	match_clear_board:
		# exit condition
		beq $t0, 9, match_turn
		sb $zero, board($t0)
		addi $t0, $t0, 1
		j match_clear_board
		nop
	li $s0, 0 # initialize the turn number iterator
	match_turn:
		addi $sp, $sp, 4
		sw $s0, 0($sp) # store $s0
		jal board_print
		nop
		# player move
		jal player_move
		nop
		# store x on the board
		li $t0, 1
		sb $t0, board($v0)
		# update row preferences
		move $a0, $v0
		li $a1, 0 # x's
		jal update_row_preference_state
		nop
		beq $v0, 1, match_turn_x_win
		nop
		
		jal debug_print_preferences
		nop
		
		lw $s0, 0($sp)
		addi $sp, $sp, -4
		beq $s0, 8, match_turn_tie # tie after 9 moves without a win
		nop
		addi $s0, $s0, 1 # increment the turn number
		addi $sp, $sp, 4
		sw $s0, 0($sp) # store $s0
		# ai move
		jal ai_move
		nop
		# store o on the board
		li $t0, 2
		sb $t0, board($v0)
		# update row preferences
		move $a0, $v0
		li $a1, 1 # o's
		jal update_row_preference_state
		nop
		beq $v0, 1, match_turn_o_win
		nop
		
		jal debug_print_preferences
		nop
		
		lw $s0, 0($sp)
		addi $sp, $sp, -4
		addi $s0, $s0, 1 # increment the turn number
		j match_turn
		nop
		match_turn_tie:
			li $v0, 0
			li $v1, 0
			j match_return
			nop
		match_turn_x_win:
			li $v0, 1
			li $v1, 0
			j match_return
			nop
		match_turn_o_win:
			li $v0, 0
			li $v1, 1
	match_return:
		jr $ra
		nop
		

# a0 - cell index
# a1 - 0 - x, 1 - o
# v0 - win occured
update_row_preference_state:
	mul $t0, $a0, 4
	li $t1, 0 # initialize the iterator
	li $v0, 0 # default return value
	update_row_preference_state_get_row:
		# exit confition
		beq $t1, 4, update_row_preference_state_return
		nop
		add $t2, $t0, $t1 # offset
		lb $t3, cell_to_rows($t2) # get the $t1-th row of this cell
		bne $t3, 8, update_row_preference_state_update # row is not null
		nop
		addi $t1, $t1, 1 # increment the iterator
		j update_row_preference_state_get_row
		nop
		update_row_preference_state_update:
			addi $t1, $t1, 1 # increment the iterator
			# $t3 is now the row
			lb $t4, row_preferences($t3) # the preference of the $t3-th row
			mul $t4, $t4, 2
			add $t4, $t4, $a1 # add the x or o value
			lb $t5, row_preference_state_lookup_table($t4) # new preference
			sb $t5, row_preferences($t3) # update the preferene
			# check for win occurence
			bge $t5, 6, update_row_preference_state_update_win_occured
			nop
			j update_row_preference_state_get_row
			nop
			update_row_preference_state_update_win_occured:
				li $v0, 1 # return value
			j update_row_preference_state_get_row
			nop
	update_row_preference_state_return:
		jr $ra
		nop

player_move:
	player_move_enter_number:
		# print the make move message
		la $a0, move_msg
		li $v0, 4
		syscall
		# load an integer
		li $v0, 5
		syscall
		blt $v0, 1, player_move_invalid_index # < 1
		nop
		bgt $v0, 9, player_move_invalid_index # > 9
		nop
		addi $v0, $v0, -1 # shift to proper 0-8 indexes
		lb $t0, board($v0)
		bnez $t0, player_move_cell_occupied # cell already occupied
		nop
		j player_move_return
		nop
		player_move_cell_occupied:
			# print the invalid number message
			la $a0, occupied_msg
			li $v0, 4
			syscall
			j player_move_enter_number
			nop
		player_move_invalid_index:
			# print the invalid number message
			la $a0, invalid_index_msg
			li $v0, 4
			syscall
			j player_move_enter_number
			nop
	player_move_return:
		jr $ra
		nop

ai_move:
	check_for_lethal: # check for 2s or -2s
		li $t0, 0 # initialize the iterator (0-7)
		check_for_lethal_row:
			lb $t1, row_preferences($t0) # get the preference of the row
			beq $t1, 2, check_for_lethal_found
			nop
			beq $t1, -2, check_for_lethal_found
			nop
			# didn't found 2 or -2
			addiu $t0, $t0, 1
			blt $t0, 8, check_for_lethal_row
			nop
			# found the 2 or -2, exit
			check_for_lethal_found:
				# get the only empty cell of row in $t0
				mul $t0, $t0, 3 # multiply times 3 for row_to_cells lookup
				lb $v0, row_to_cells+0($t0)
				lb $t2, board($v0)
				beqz $t2, ai_move_return
				nop
				lb $v0, row_to_cells+1($t0)
				lb $t2, board($v0)
				beqz $t2, ai_move_return
				nop
				lb $v0, row_to_cells+2($t0)
				lb $t2, board($v0)
				beqz $t2, ai_move_return
				nop
	random_cell:
		# generate a random integer between 0 and 7
		li $a0, 0
		li $a1, 8
		li $v0, 42
		syscall
		# check if the cell is empty
		lb $t0, board($a0)
		bnez $t0, random_cell
		nop
		move $v0, $a0
	ai_move_return:
		jr $ra
		nop

board_print:
	li $t0, 0 # 0-8
	board_print_collumn:
		li $t1, 0 # 0-2
		beq $t0, 9, board_print_end # if $t0 is equal to 9, the printing is complete
		board_print_row:
			lbu $t2, board($t0) # load the current cell to $t2
			beq $t2, 1, board_print_x
			nop
			beq $t2, 2, board_print_o
			nop
			board_print_space: # if $t2 is neither 1 or 2, print the space
				li $v0, 4
				la $a0, _
				syscall
				j board_print_skip
				nop
			board_print_x:
				li $v0, 4
				la $a0, x
				syscall
				j board_print_skip
				nop
			board_print_o:
				li $v0, 4
				la $a0, o
				syscall
			board_print_skip:
			addiu $t0, $t0, 1
			addiu $t1, $t1, 1
			blt $t1, 3, board_print_newline_skip # if $t1 is equal to 3, print the newline and go back to print another row
			nop
				# print newline
				li $v0, 4
				la $a0, newline
				syscall
				j board_print_collumn
				nop
			board_print_newline_skip:
			# $t1 is less than 3, so there are other cells to print out
			j board_print_row
			nop
	board_print_end:
	jr $ra
	nop

debug_print_preferences:
	li $t0, 0 # 0-7
	debug_print_preferences_loop:
		# exit condition
		beq $t0, 8, debug_print_preferences_return
		nop
		# print the preference
		lb $a0, row_preferences($t0)
		li $v0, 1
		syscall
		# print the space
		la $a0, debug_space
		li $v0, 4
		syscall
		addi $t0, $t0, 1 # increment the iterator
		j debug_print_preferences_loop
		nop
	debug_print_preferences_return:
		# print the newline
		la $a0, newline
		li $v0, 4
		syscall
		jr $ra
		nop