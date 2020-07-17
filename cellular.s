########################################################################
# COMP1521 20T2 --- assignment 1: a cellular automaton renderer
#
# Written by <<YOU>>, July 2020.


# Maximum and minimum values for the 3 parameters.

MIN_WORLD_SIZE	=    1
MAX_WORLD_SIZE	=  128
MIN_GENERATIONS	= -256
MAX_GENERATIONS	=  256
MIN_RULE	=    0
MAX_RULE	=  255

# Characters used to print alive/dead cells.

ALIVE_CHAR	= '#'
DEAD_CHAR	= '.'

# Maximum number of bytes needs to store all generations of cells.

MAX_CELLS_BYTES	= (MAX_GENERATIONS + 1) * MAX_WORLD_SIZE

	.data

# `cells' is used to store successive generations.  Each byte will be 1
# if the cell is alive in that generation, and 0 otherwise.

cells:	.space MAX_CELLS_BYTES


# Some strings you'll need to use:

prompt_world_size:	.asciiz "Enter world size: "
error_world_size:	.asciiz "Invalid world size\n"
prompt_rule:		.asciiz "Enter rule: "
error_rule:		.asciiz "Invalid rule\n"
prompt_n_generations:	.asciiz "Enter how many generations: "
error_n_generations:	.asciiz "Invalid number of generations\n"

	.text

	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `main', AND THE PURPOSES THEY ARE ARE USED FOR
	#
	# $s0: world_size
	# $s1: rule
	# $s2: n_generations
	# $s3: reverse
	# $s4: g/which_generation
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `run_generation' FINISHES
	#

main:
	#
	# REPLACE THIS COMMENT WITH YOUR CODE FOR `main'.
	#

	li		$v0, 4												# printf("Enter world size: ")
	la		$a0, prompt_world_size
	syscall 
	
	li		$s0, 0												# world_size = 0
		
	li		$v0, 5												# scanf("%d", &world_size)
	syscall
	move	$s0, $v0

	blt		$s0, MIN_WORLD_SIZE, invalid_world_size				# if $s0 < MIN_WORLD_SIZE then invalid_world_size
	bgt		$s0, MAX_WORLD_SIZE, invalid_world_size				# if $s0 > MAX_WORLD_SIZE then invalid_world_size




	li		$v0, 4												# printf("Enter rule: ")
	la		$a0, prompt_rule
	syscall 

	li		$s1, 0												# rule = 0

	li		$v0, 5												# scanf("%d", &rule)
	syscall
	move	$s1, $v0

	blt		$s1, MIN_RULE, invalid_rule							# if $s1 < MIN_RULE then invalid_rule
	bgt		$s1, MAX_RULE, invalid_rule							# if $s1 > MAX_RULE then invalid_rule




	li		$v0, 4												# printf("Enter how many generations: ")
	la		$a0, prompt_n_generations
	syscall

	li		$s2, 0												# n_generations = 0

	li		$v0, 5												# scanf("%d", &n_generations)
	syscall
	move	$s2, $v0

	blt		$s2, MIN_GENERATIONS, invalid_generations			# if $s1 < MIN_GENERATIONS then invalid_generations
	bgt		$s2, MAX_GENERATIONS, invalid_generations			# if $s1 > MAX_GENERATIONS then invalid_generations


	li		$v0, 11												# putchar('\n')
	li		$a0, '\n'
	syscall

	li		$s3, 0												# reverse = 0

	bgtz	$s2, positive_generations							# if $s2 (n_generations) > 0 then positive_generations

	li		$s3, 1												# reverse = 1
	mul 	$s2, $s2, -1										# n_generations = -n_generations	 


positive_generations:

																# cells[0][world_size / 2] = 1;

	la		$t1, cells											# Loads the beginning address of cells array

	li		$t2, 2												# Loads 2 into register $t2 for division
	div		$s0, $t2											# $s0 / $t2
	mflo	$t3													# $t3 = floor($s0 / $t2)
	
	add		$t1, $t1, $t3										# Move to address of corresponding middle of Array: $t1 = $t1 + t3

	li		$t2, 1												# Loads 1 into $t2 to be stored at middle array index
	sb		$t2, ($t1)											# Sets middle array index as alive

loop_init:

	li		$s4, 1												# g = 1

loop_cond:

	bgt		$s4, $s2, loop_end									# if (g > n_generations) goto loop_end

loop_main:

	sub		$sp, $sp, 4											# $sp = $sp - 4
	sw		$ra, 0($sp)											# saves return onto stack
	
	jal		run_generation										# jump to run_generation and save position to $ra
	
	lw		$ra, 0($sp)											# recover $ra from stack
	add		$sp, $sp, 4											# move stack pointer back to what it was
	

loop_increment:

	addi	$s4, $s4, 1											# $s4 = $s4 + 1
	j		loop_cond											# jump to loop_cond

loop_end:

	beqz	$s3, not_reverse									# if(!reverse) goto not_reverse

reverse_loop_init:												# for (int g = n_generations; g < 0; g--)

	move		$s4, $s2

reverse_loop_cond:

	bltz		$s4, reverse_loop_end

reverse_loop_body:

	sub		$sp, $sp, 4											# $sp = $sp - 4
	sw		$ra, 0($sp)											# saves return onto stack

	jal		print_generation									# print_generation(world_size, g)

	lw		$ra, 0($sp)											# recover $ra from stack
	add		$sp, $sp, 4											# move stack pointer back to what it was

reverse_loop_decrement:

	addi	$s4, $s4, -1

	j		reverse_loop_cond

reverse_loop_end:

	li	$v0, 0													# return 0
	jr	$ra

not_reverse:

not_reverse_loop_init:											# for (int g = 0; g > n_generations; g++)

	li		$s4, 0

not_reverse_loop_cond:

	bgt		$s4, $s2, not_reverse_loop_end

not_reverse_loop_body:

	sub		$sp, $sp, 4											# $sp = $sp - 4
	sw		$ra, 0($sp)											# saves return onto stack

	jal		print_generation									# print_generation(world_size, g)

	lw		$ra, 0($sp)											# recover $ra from stack
	add		$sp, $sp, 4											# move stack pointer back to what it was

not_reverse_loop_increment:

	addi	$s4, $s4, 1

	j 		not_reverse_loop_cond

not_reverse_loop_end:

	li	$v0, 0													# return 0
	jr	$ra

invalid_generations:

	li		$v0, 4												# printf("Invalid number of generations\n")
	la		$a0, error_n_generations
	syscall
																
	li	$v0, 1													# return 1
	jr	$ra

invalid_rule:
	
	
	li		$v0, 4												# printf("Invalid rule\n")
	la		$a0, error_rule
	syscall
																
	li	$v0, 1													# return 1
	jr	$ra

invalid_world_size:
		


	# replace the syscall below with
	#
	# li	$v0, 0
	# jr	$ra
	#
	# if your code for `main' preserves $ra by saving it on the
	# stack, and restoring it after calling `print_world' and
	# `run_generation'.  [ there are style marks for this ]

	li		$v0, 4												# printf("Invalid world size\n")
	la		$a0, error_world_size
	syscall
																
	li	$v0, 1													# return 1
	jr	$ra


	#
	# Given `world_size', `which_generation', and `rule', calculate
	# a new generation according to `rule' and store it in `cells'.
	#

	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `run_generation', AND THE PURPOSES THEY ARE ARE USED FOR
	#
	# $t1 used for x in loop
	# $t2 used for checking byte value for left, centre, right
	# $t3 used for location ofd byte
	# $t6 used for storing which_generation - 1
	# $t7 used for storing state
	#
	# $s0 passed in for world_size
	# $s1 passed in for rule
	# $s4 passed in for which_generation
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `run_generation' FINISHES
	#

run_generation:

gen_loop_init:

	li		$t1, 0												# int x = 0

gen_loop_cond:

	bge		$t1, $s0, gen_loop_end								# if $t1 >= $s0 then gen_loop_end

	move	$t6, $s4											# $t6 = $s4 - 1 = which_generation - 1
	addi	$t6, -1

gen_loop_main:

	li		$t2, 0												# int left = 0

	blez	$t1, x_not_pos										# if (x <= 0) goto x_not_pos

	move	$t3, $t6											# $t3 = [which_generation - 1]
	mul 	$t3, $t3, MAX_WORLD_SIZE

	move	$t4, $t1											# $t4 = x - 1
	addi	$t4, -1

	add		$t3, $t3, $t4 										# $t3 = [which_generation - 1][x - 1]

	la		$t4, cells											# Loads address of start of cells
	add		$t3, $t4, $t3										# adds bytes to get to location of byte required

	lb		$t2, ($t3)											# loads value from memory location $t3


x_not_pos:

	sll 	$t7, $t2, 2											# state = left << 2

	li		$t2, 0												# $t2 = int centre = 0
	
	move	$t3, $t6											# $t3 = [which_generation - 1]
	mul 	$t3, $t3, MAX_WORLD_SIZE

	move	$t4, $t1											# $t4 = x

	add		$t3, $t3, $t4										# $t3 = [which_generation - 1][x]

	la		$t4, cells											# Loads address of start of cells
	add		$t3, $t4, $t3										# adds bytes to get to location of byte required

	lb		$t2, ($t3)											# loads value from memory location $t3 into $t2
	
	sll		$t2, $t2, 1											# $t2 = centre << 1

	or		$t7, $t7, $t2										# $t7 = $t7 | $t2 = state | centre << 1

	li		$t2, 0												# $t2 = int right = 0

	move	$t5, $s0											# $t5 = $s0 = world_size
	addi	$t5, -1												# $t5 = world_size - 1

	bge		$t1, $t5, x_at_end									# if $t1 >= $t5 then x_at_end

	move	$t3, $t6											# $t3 = [which_generation - 1]
	mul		$t3, $t3, MAX_WORLD_SIZE

	move	$t4, $t1											# $t4 = x - 1
	addi	$t4, 1

	add		$t3, $t3, $t4										# $t3 = [which_generation - 1][x + 1]

	la		$t4, cells											# Loads address of start of cells
	add		$t3, $t4, $t3										# adds bytes to get to location of byte required

	lb		$t2, ($t3)											# loads value from memory location $t3

x_at_end:
	
	or		$t7, $t7, $t2										# $t7 = $t7 | $t2 = state | right << 0

	li		$t3, 1												# $t3 = int bit = 1

	sllv	$t3, $t3, $t7										# $t3 = $t3 << $t7 = bit << state

	and		$t4, $s1, $t3										# $t4 = $s1 & $t3 = rule & bit

	beqz	$t4, set_equal_zero									# if (!set) goto set_equal_zero

	move	$t3, $s4											# $t3 = $s4 = which_generation
	mul		$t3, $t3, MAX_WORLD_SIZE
	add 	$t3, $t3, $t1										# $t3 = $s4 * $t1 = [which_generation][x]
	
	la		$t5, cells											# loads address for start of cells array
	add		$t3, $t5, $t3										# adjusts memory location to correct byte -> cells[which_generation][x]

	li 		$t4, 1												# sets register = 1 to get ready to store in memory

	sb		$t4, ($t3)											# cells[which_generation][x] = 1
	
	j gen_loop_increment

set_equal_zero:

	move	$t3, $s4											# $t3 = $s4 = which_generation
	mul 	$t3, $t3, MAX_WORLD_SIZE

	add 	$t3, $t3, $t1										# $t3 = $s4 * $t1 = [which_generation][x]
	
	la		$t5, cells											# loads address for start of cells array
	add		$t3, $t5, $t3										# adjusts memory location to correct byte -> cells[which_generation][x]

	li 		$t4, 0												# sets register = 1 to get ready to store in memory

	sb		$t4, ($t3)											# cells[which_generation][x] = 1

	j gen_loop_increment

gen_loop_increment:

	addi	$t1, 1												# x = x + 1
	j		gen_loop_cond										# jump to gen_loop_cond
	

gen_loop_end:

	jr		$ra


	#
	# Given `world_size', and `which_generation', print out the
	# specified generation.
	#
	# $t1 = x
	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `print_generation', AND THE PURPOSES THEY ARE ARE USED FOR
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `print_generation' FINISHES
	#

print_generation:

	li		$v0, 1												# print("%d", which_generation)
	move	$a0, $s4												
	syscall

	li		$v0, 11												# putchar('\t')
	li		$a0, '\t'
	syscall

print_loop_init:

	li		$t1, 0

print_loop_cond:

	bge		$t1, $s0, print_loop_end							# if (x >= world_size) goto print_loop_end

print_loop_body:

	la		$t3, cells											# loads start of cells address into $t3
	
	move	$t2, $s4											# $t2 = $s4 = which_generation
	mul 	$t2, $t2, MAX_WORLD_SIZE
	add 	$t2, $t2, $t1

	add		$t2, $t2, $t3										# $t2 = addres of cells[which_generation][x]

	lb		$t4, ($t2)											# gets value at cells[which_generation][x]

	beqz	$t4, print_dead_char								# if(!cells[which_generation][x]) goto print_dead_char

	li		$v0, 11												# putchar(ALIVE_CHAR)
	li		$a0, ALIVE_CHAR
	syscall

	j 		print_loop_increment

print_dead_char:

	li		$v0, 11												# putchar(DEAD_CHAR)
	li		$a0, DEAD_CHAR
	syscall
	
print_loop_increment:

	addi	$t1, $t1, 1											# x++

	j		print_loop_cond										# jump back to condition

print_loop_end:

	li		$v0, 11												# putchar('\n')
	li		$a0, '\n'
	syscall

	jr	$ra
