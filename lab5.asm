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
start_match_msg: .asciiz "Match #"
semicolon: .asciiz ": "
newline: .asciiz "\n"
_: .asciiz "_ "
x: .asciiz "X "
o: .asciiz "O "
move_msg: .asciiz "Make a move (1-9): "

.text
main:
	jal board_print
	nop
	# exit
	li $v0, 10
	syscall

# a0 - cell index
# a1 - 0 - x, 1 - o
update_row_preference_state:
	mul $t0, $a0, 4
	li $t1, 0 # initialize the iterator
	update_row_preference_state_get_row:
		# exit confition
		beq $t1, 4, update_row_preference_state_return
		nop
		addi $t2, $t0, $t1 # offset
		lb $t3, cell_to_rows($t2) # get the $t1-th row of this cell
		bne $t3, 8, update_row_preference_state_update # row is null
		nop
		addi $t1, $t1, 1 # increment the iterator
		j update_row_preference_state_get_row
		nop
		update_row_preference_state_update:
			addi $t1, $t1, 1 # increment the iterator
			# $t3 is now the row
			lb $t4, row_preferences($t3) # the preference of the $t3-th row
			mul $t4, $t4, 2
			addi $t4, $t4, $a1 # add the x or o value
			lb $t5, row_preference_state_lookup_table($t4) # new preference
			sb $t5, row_preferences($t3) # update the preferene
	update_row_preference_state_return:
		jr $ra
		nop

ai_move:
	li $v0, -1 # preferenced index, default value is -1
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
			beqz $v0, ai_move_return
			nop
			lb $v0, row_to_cells+1($t0)
			beqz $v0, ai_move_return
			nop
			lb $v0, row_to_cells+2($t0)
			beqz $v0, ai_move_return
			nop
	random_cell:
		# generate a random integer between 0 and 7
		li $a0, 0
		li $a1, 8
		syscall
		# check if the cell is empty
		lb $t0, board($a0)
		bnez $t0, random_cell
		nop
		move $v0, $t0
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
