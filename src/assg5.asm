# karol belina, 2nd of june, 2018
# labs #5
# tic tac toe

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
score_msg: .asciiz "Final scores: "
dash: .asciiz "-"

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
		# initialize the iterator
		li $s1, 0
		# initialize the x's wins
		li $s2, 0
		# initialize the o's wins
		li $s3, 0
		game_match:
			# exit condition
			beq $s1, $s0, game_print_scores
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
			# store return address
			sw $ra, 0($sp)
			# store $s0
			sw $s0, 4($sp)
			# store $s1
			sw $s1, 8($sp)
			# store $s2
			sw $s2, 12($sp)
			# store $s3
			sw $s3, 16($sp)
			jal match
			nop
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s2, 12($sp)
			lw $s3, 16($sp)
			addi $sp, $sp, 20
			# increment the iterator
			addi $s1, $s1, 1
			# add x's win
			add $s2, $s2, $v0
			# add o's win
			add $s3, $s3, $v1
			# display the win message
			or $t1, $v0, $v1
			# tie
			beqz $t1, game_match_result_tie
			nop
			# not a tie
			# o's won
			beqz $v0, game_match_result_o_won
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
	game_print_scores:
		# print the score messaage
		la $a0, score_msg
		li $v0, 4
		syscall
		# print the x's score
		move $a0, $s2
		li $v0, 1
		syscall
		# print the dash
		la $a0, dash
		li $v0, 4
		syscall
		# print the o's score
		move $a0, $s3
		li $v0, 1
		syscall
		# print the newline
		la $a0, newline
		li $v0, 4
		syscall
	game_return:
		jr $ra
		nop
		
match:
	addi $sp, $sp, -4
	# store return address
	sw $ra, 0($sp)
	# initialize the clear board iterator
	li $t0, 0
	# initialize the clear preferences iterator
	li $t1, 0
	match_clear_board:
		# exit condition
		beq $t0, 9, match_clear_preferences
		nop
		sb $zero, board($t0)
		addi $t0, $t0, 1
		j match_clear_board
		nop
	match_clear_preferences:
		# exit condition
		beq $t1, 8, match_preturn
		nop
		sb $zero, row_preferences($t1)
		addi $t1, $t1, 1
		j match_clear_preferences
		nop
	match_preturn:
	# initialize the turn number iterator
	li $s0, 0
	match_turn:
		addi $sp, $sp, -4
		# store $s0
		sw $s0, 0($sp)
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
		# x's
		li $a1, 0
		jal update_row_preference_state
		nop
		beq $v0, 1, match_turn_x_win
		nop
		lw $s0, 0($sp)
		addi $sp, $sp, 4
		# tie after 9 moves without a win
		beq $s0, 8, match_turn_tie
		nop
		# increment the turn number
		addi $s0, $s0, 1
		addi $sp, $sp, -4
		# store $s0
		sw $s0, 0($sp)
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
		lw $s0, 0($sp)
		addi $sp, $sp, 4
		# increment the turn number
		addi $s0, $s0, 1
		j match_turn
		nop
		match_turn_tie:
			# print the board one last time
			jal board_print
			nop
			li $v0, 0
			li $v1, 0
			j match_return
			nop
		match_turn_x_win:
			# pop
			addi $sp, $sp, 4
			# print the board one last time
			jal board_print
			nop
			li $v0, 1
			li $v1, 0
			j match_return
			nop
		match_turn_o_win:
			# pop
			addi $sp, $sp, 4
			# print the board one last time
			jal board_print
			nop
			li $v0, 0
			li $v1, 1
	match_return:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		nop
		

# a0 - cell index
# a1 - 0 - x, 1 - o
# v0 - win occured
update_row_preference_state:
	mul $t0, $a0, 4
	# initialize the iterator
	li $t1, 0
	# default return value
	li $v0, 0
	update_row_preference_state_get_row:
		# exit confition
		beq $t1, 4, update_row_preference_state_return
		nop
		# offset
		add $t2, $t0, $t1
		# get the $t1-th row of this cell
		lb $t3, cell_to_rows($t2)
		# row is not null
		bne $t3, 8, update_row_preference_state_update
		nop
		# increment the iterator
		addi $t1, $t1, 1
		j update_row_preference_state_get_row
		nop
		update_row_preference_state_update:
			# increment the iterator
			addi $t1, $t1, 1
			# $t3 is now the row
			# the preference of the $t3-th row
			lb $t4, row_preferences($t3)
			mul $t4, $t4, 2
			# add the x or o value
			add $t4, $t4, $a1
			# new preference
			lb $t5, row_preference_state_lookup_table($t4)
			# update the preferene
			sb $t5, row_preferences($t3)
			# check for win occurence
			bge $t5, 6, update_row_preference_state_update_win_occured
			nop
			j update_row_preference_state_get_row
			nop
			update_row_preference_state_update_win_occured:
				# return value
				li $v0, 1
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
		# < 1
		blt $v0, 1, player_move_invalid_index
		nop
		# > 9
		bgt $v0, 9, player_move_invalid_index
		nop
		# shift to proper 0-8 indexes
		addi $v0, $v0, -1
		lb $t0, board($v0)
		# cell already occupied
		bnez $t0, player_move_cell_occupied
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
	# check for 4s
	ai_move_attack:
		# initialize the iterator (0-7)
		li $t0, 0
		ai_move_attack_loop:
			# exit condition
			beq $t0, 8, ai_move_defend
			nop
			# get the preference of the row
			lb $t1, row_preferences($t0)
			# check for 4
			beq $t1, 4, ai_move_lethal_found
			nop
			# didn't found 4
			addiu $t0, $t0, 1
			j ai_move_attack_loop
			nop
	# check for 2s
	ai_move_defend:
		# initialize the iterator (0-7)
		li $t0, 0
		ai_move_defend_loop:
			# exit condition
			beq $t0, 8, random_cell
			nop
			# get the preference of the row
			lb $t1, row_preferences($t0)
			# check for 2
			beq $t1, 2, ai_move_lethal_found
			nop
			# didn't found 2
			addiu $t0, $t0, 1
			j ai_move_defend_loop
			nop
	ai_move_lethal_found:
		# get the only empty cell of row in $t0
		# multiply times 3 for row_to_cells lookup
		mul $t0, $t0, 3
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
	# 0-8
	li $t0, 0
	board_print_collumn:
		# 0-2
		li $t1, 0
		# if $t0 is equal to 9, the printing is complete
		beq $t0, 9, board_print_end
		board_print_row:
			# load the current cell to $t2
			lbu $t2, board($t0)
			beq $t2, 1, board_print_x
			nop
			beq $t2, 2, board_print_o
			nop
			# if $t2 is neither 1 or 2, print the space
			board_print_space:
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
			# if $t1 is equal to 3, print the newline and go back to print another row
			blt $t1, 3, board_print_newline_skip
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
