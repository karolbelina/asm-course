# karol belina, 2nd of june, 2018
# labs #5
# tic tac toe

# X X O 
# X _ 0 
# _ 0 X 

.data
#board: .space 9 # 0 is empty, 1 is player, 2 is ai
board: .byte 1,1,0,2,1,2,0,0,1
row_preferences: .space 8 # top, middle, bottom, left, center, right, diagonal (\), backdiagonal (/), 0 for neutral, -1 and -2 for player, 1 and 2 for ai

top: .byte 0, 1, 2
middle: .byte 3, 4, 5
bottom: .byte 6, 7, 8
left: .byte 0, 3, 6
center: .byte 1, 4, 7
right: .byte 2, 5, 8
diagonal: .byte 0, 4, 8
backdiagonal: .byte 2, 4, 6

indexes: .byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 3, 6, 1, 4, 7, 2, 5, 8, 0, 4, 8, 2, 4, 6

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


ai_move:
	li $v0, -1 # preferenced index, default value is -1
	check_for_lethal_to_player: # check for 2s or -2s
		li $t0, 0 # initialize the iterator (0-7)
		check_for_lethal_to_player_row:
			lb $t1, row_preferences($t0) # get the preference of the row
			beq $t1, 2, check_for_lethal_to_player_row_found_2
			nop
			beq $t1, -2, check_for_lethal_to_player_row_found_2
			nop
			# didn't found 2 or -2
			addiu $t0, $t0, 1
			blt $t0, 8, check_for_lethal_to_player_row
			nop
			# $t0 is equal to 8
			#j check_for_lethal_to_ai
			nop
			# found the 2 or -2, exit
			check_for_lethal_to_player_row_found_2:
			move $v0, $t0 # set the preferenced row index
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
