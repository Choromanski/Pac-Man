###########################################
#	NAME: 	Brian Choromanski         #
#	EMAIL: 	BJC76@pitt.edu		  #
###########################################
			.data
OOIIIIIIIIIIIIII:	.word	0xaaaaaa0a
IIIIIIIIIIIIIIII:	.word	0xaaaaaaaa
IIIIIIIIIIIIIIOO:	.word	0xa0aaaaaa
OOOOOOOIIOOOOOOI:	.word	0x02800200
IOOOOOOIIOOOOOOI:	.word	0x02800280
IOIIIIOIIOIIIIOI:	.word	0xa28aa28a
IOIOOIOIIOIOOIOI:	.word	0xe28be28b
IOOOOOOOOOOOOOOO:	.word	0x00000080
OOOOOOOOOOOOOOOI:	.word	0x02000000
IOIIIIIIIIOIIIII:	.word	0xaa8aaa8a
byte1:			.byte 	0x22
byte2:			.byte 	0x88
byte3:			.byte	0x98
byte4:			.byte	0x26
directions:		.byte	0, 1, 2, 3 				#stored at adress 0x1001002c
unsorted:		.byte	0, 1, 2					#stored at adress 0x10010030
victory1:		.asciiz "Success! You won! Your score is "
victory2:		.asciiz " moves.\n"
defeat1:		.asciiz "Sorry. You were captured."

		
			.text
			li $s7 0
			jal setBoard
			jal placeZombies
			jal fixBoard
			jal placePlayer
			jal wait
			j playerMovement
	
moveZombies:
			
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			
			bgt $s1, 31, bottom		
			li $a1, 0 			
			bgt $s0, 31, AI			
			li $a1, 1			
			j AI 				
		bottom:					
			li $a1, 2			
			blt $s0, 32, AI			
			li $a1, 3			
			j AI				
		AI:					
			add $a0, $s2, $zero		
			beq $a1, 0, tracking		
			add $a0, $s3, $zero		
			beq $a1, 1, tracking		
			add $a0, $s4, $zero		
			beq $a1, 2, tracking		
			add $a0, $s5, $zero		
			beq $a1, 3, tracking		
							
		tracking:				

			add $t6, $a0, $zero		
			jal decodeLocation		
			jal randomDirection		
			add $a0, $t6, $zero		
			jal decodeLocation		
			add $t6, $v1, $zero
			jal distance			
			lw $t0, directions
			lw $t1, 0x10010030
			lw $t2, 0x10010034
			j sort
		distance:				
				addi $sp, $sp, -4	
				sw $ra, 0($sp)		
				add $t9, $v1, $zero	
				la $t4, directions	
				la $t5, unsorted	
			distanceLoop:			
				lbu $t1, ($t4)		
				beq $t1, 0, distanceNorth	
				beq $t1, 1, distanceEast	
				beq $t1, 2, distanceWest	
				beq $t1, 3, distanceSouth	
			distanceNorth:				
				addi $a1, $a1, -1	
				jal pythagorean		
				addi $a1, $a1, 1	
				j nextDistance		
			distanceEast:				
				addi $a0, $a0, 1	
				jal pythagorean		
				addi $a0, $a0, -1	
				j nextDistance		
			distanceWest:				
				addi $a0, $a0, -1	
				jal pythagorean		
				addi $a0, $a0, 1	
				j nextDistance		
			distanceSouth:				
				addi $a1, $a1, 1	
				jal pythagorean		
				addi $a1, $a1, -1	
				j nextDistance		
							
			pythagorean:			
				sub $t0, $a0, $s0	
				sub $t1, $a1, $s1	
				mul $t0, $t0, $t0	
				mul $t1, $t1, $t1	
				add $t0, $t0, $t1	
				sh $t0, ($t5)		
				jr $ra			
							
			nextDistance:			
				beq $t4, 0x1001002e, exitDistance
				addi $t4, $t4, 1	
				addi $t5, $t5, 2	
				j distanceLoop		
				
			exitDistance:			
				lw $ra, 0($sp)		
				addi $sp, $sp, 4	
				jr $ra			
		sort: 
			lh $t0, 0x10010030
			lh $t1, 0x10010032
			lh $t2, 0x10010034
			bgt $t0, $t1, s3
			bgt $t0, $t2, s2
			bgt $t1, $t2, s1
			#ABC
			j moveAI
		s1:
			#ACB
			lb $t0, 0x1001002d
			lb $t1, 0x1001002e
			sb $t1, 0x1001002d
			sb $t0, 0x1001002e
			j moveAI
		s2:
			#CAB
			lb $t0, 0x1001002c
			lb $t1, 0x1001002d
			lb $t2, 0x1001002e
			sb $t2, 0x1001002c
			sb $t0, 0x1001002d
			sb $t1, 0x1001002e
			j moveAI
		s3:
			bgt $t1, $t2, s5
			bgt $t0, $t2, s4
			#BAC
			lb $t0, 0x1001002c
			lb $t1, 0x1001002d
			sb $t1, 0x1001002c
			sb $t0, 0x1001002d
			j moveAI
		s4:
			#BCA
			lb $t0, 0x1001002c
			lb $t1, 0x1001002d
			lb $t2, 0x1001002e
			sb $t1, 0x1001002c
			sb $t2, 0x1001002d
			sb $t0, 0x1001002e
			j moveAI
		s5:
			#CBA
			lb $t0, 0x1001002c
			lb $t1, 0x1001002d
			lb $t2, 0x1001002e
			sb $t2, 0x1001002c
			sb $t1, 0x1001002d
			sb $t0, 0x1001002e
			
		moveAI:
			beq $t6, 0, aIZombie0
			beq $t6, 1, aIZombie1
			beq $t6, 2, aIZombie2
			beq $t6, 3, aIZombie3
		aIZombie0:
			add $a0, $s2, $zero
			jal decodeLocation
			jal moveRandom
			j moveZombie1
		aIZombie1:
			add $a0, $s3, $zero
			jal decodeLocation
			jal moveRandom
			j moveZombie2
		aIZombie2:
			add $a0, $s4, $zero
			jal decodeLocation
			jal moveRandom
			j moveZombie3
		aIZombie3:
			add $a0, $s5, $zero
			jal decodeLocation
			jal moveRandom
			j moveZombie0
			
			
			
		moveZombie0:
			beq $t6, 0, exitMoveZombie
			add $a0, $s2, $zero
			jal decodeLocation
			jal randomDirection
			add $a0, $s2, $zero	
			jal decodeLocation		
			jal moveRandom			
		moveZombie1:
			beq $t6, 1, exitMoveZombie
			add $a0, $s3, $zero
			jal decodeLocation
			jal randomDirection
			add $a0, $s3, $zero
			jal decodeLocation
			jal moveRandom
		moveZombie2:
			beq $t6, 2, exitMoveZombie
			add $a0, $s4, $zero
			jal decodeLocation
			jal randomDirection
			add $a0, $s4, $zero
			jal decodeLocation
			jal moveRandom
		moveZombie3:
			beq $t6, 3, exitMoveZombie
			add $a0, $s5, $zero
			jal decodeLocation
			jal randomDirection
			add $a0, $s5, $zero
			jal decodeLocation
			jal moveRandom
			j moveZombie0
			
		exitMoveZombie:
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
	
	randomDirection:
			xori $t0, $v0, 0x3
			sb $t0, 0x1001002f
		rand1:
			li $v0, 42
			li $a0, 0
			li $a1, 4
			syscall
			lbu $t0, 0x1001002f
			beq $a0, $t0, rand1
			sb $a0, 0x1001002c
		rand2:
			li $a0, 0
			syscall
			lbu $t0, 0x1001002f
			beq $a0, $t0, rand2
			lbu $t0, 0x1001002c
			beq $a0, $t0, rand2
			sb $a0, 0x1001002d
		rand3:
			li $a0, 0
			syscall
			lbu $t0, 0x1001002f
			beq $a0, $t0, rand3
			lbu $t0, 0x1001002c
			beq $a0, $t0, rand3
			lbu $t0, 0x1001002d
			beq $a0, $t0, rand3
			sb $a0, 0x1001002e
			
			jr $ra
	
	moveRandom:
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			add $t9, $v1, $zero
			la $t4, directions
		validateLoop:
			lbu $t1, ($t4)
			beq $t1, 0, Up 
			beq $t1, 1, Right
			beq $t1, 2, Left
			beq $t1, 3, Down
		Up:	
			addi $a1, $a1, -1
			jal checkZombiePosition
			li $t7, 0
			beqz $v0, changeZombieLocation
			addi $a1, $a1, 1
			j nextDir
		Right:
			addi $a0, $a0, 1
			jal checkZombiePosition
			li $t7, 1
			beqz $v0, changeZombieLocation
			addi $a0, $a0, -1
			j nextDir
		Left:
			addi $a0, $a0, -1
			jal checkZombiePosition
			li $t7, 2
			beqz $v0, changeZombieLocation
			addi $a0, $a0, 1
			j nextDir
		Down:
			addi $a1, $a1, 1
			jal checkZombiePosition
			li $t7, 3
			beqz $v0, changeZombieLocation
			addi $a1, $a1, -1
			j nextDir
			
		nextDir:
			addi $t4, $t4, 1
			j validateLoop

			
	changeZombieLocation: 
			li $a2, 1
			add $v0, $t7, $zero
			add $v1, $t9, $zero
			jal encodeLocation
			jal setLED
			addi $a1, $a1, 1
			beq $t7, 0, deleteLED
			addi $a1, $a1, -1
			addi $a0, $a0, -1
			beq $t7, 1, deleteLED
			addi $a0, $a0, 2
			beq $t7, 2, deleteLED
			addi $a0, $a0, -1
			addi $a1, $a1, -1
			
		deleteLED:
			li $a2, 0
			jal setLED
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

movePlayer:
			addi $sp, $sp, -4
			sw $ra, 0($sp)
		
			add $s7, $s7, 1
			add $t8, $a0, $zero
			add $t9, $a1, $zero
			li $a2, 3
			jal setLED
			add $a0, $s0, $zero
			add $a1, $s1, $zero
			li $a2, 0
			jal setLED
			add $s0, $t8, $zero
			add $s1, $t9, $zero
			bne $s0, 63 exitMovePlayer
			beq $s1, 63 victory
	exitMovePlayer:
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
		
		
playerMovement:						#consider changing name to something more appropriate and making new function to move the player
			li $v0, 30
			syscall
			addi $s6, $a0, 500
	playerLoop:
			li $v0, 30
			syscall
			ble $a0, $s6, skipZombie
			addi $s6, $a0, 500
			jal moveZombies
	skipZombie:					#place this in movePlayer
			lbu $t0, 0xffff0000
			beqz $t0, playerLoop
		
			lbu $t0,  0xffff0004
			beq $t0, 0xe0 up
			beq $t0, 0xe1 down
			beq $t0, 0xe2 left
			beq $t0, 0xe3 right
			j playerLoop
		up:
			add $a0, $s0, $zero
			add $a1, $s1, -1
			jal checkPosition
			bnez $v0, playerLoop	
			add $a0, $s0, $zero	
			add $a1, $s1, -1	
			jal movePlayer	
			j playerLoop		
		down:
			add $a0, $s0, $zero
			add $a1, $s1, 1
			jal checkPosition
			bnez $v0, playerLoop
			add $a0, $s0, $zero
			add $a1, $s1, 1
			jal movePlayer
			j playerLoop
		left:
			add $a0, $s0, -1
			add $a1, $s1, $zero
			jal checkPosition
			bnez $v0, playerLoop
			add $a0, $s0, -1
			add $a1, $s1, $zero
			jal movePlayer
			j playerLoop
		right:	
			add $a0, $s0, 1
			add $a1, $s1, $zero
			jal checkPosition
			bnez $v0, playerLoop
			add $a0, $s0, 1
			add $a1, $s1, $zero
			jal movePlayer
			j playerLoop
			
checkZombiePosition:
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			
			li $v0, 2
			beq $t9, 0, topRight
			beq $t9, 1, topLeft
			beq $t9, 2, bottomLeft
			beq $t9, 3, bottomRight
			
	topRight:
			blt $a0, 32, exitPosition
			bgt $a1, 31, exitPosition
			j exitCheckZombie
	topLeft:
			bgt $a0, 31, exitPosition
			bgt $a1, 31, exitPosition
			j exitCheckZombie
	bottomLeft:
			bgt $a0, 31, exitPosition
			blt $a1, 32, exitPosition
			j exitCheckZombie
	bottomRight:
			blt $a0, 32, exitPosition
			blt $a1, 32, exitPosition
	exitCheckZombie:
			jal checkPosition
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
			
checkPosition:
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			add $t8, $v1, $zero
			li $v0, 2
			bltz $a0, exitPosition
			bltz $a1, exitPosition
			bgt $a0, 63, exitPosition
			bgt $a1, 63, exitPosition
			jal getLED
		
	exitPosition:
			beqz $s7, setup
			beq $v0, 3, defeat
			beq $v0, 1, defeat
		setup:
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
		
wait:		
			lbu $t0, 0xffff0000
			beqz $t0, wait
			lbu $t0, 0xffff0004	
			bne $t0, 0x42, wait
			jr $ra
placeZombies:
			addi $sp, $sp, -4
			sw $ra, 0($sp)
		
	placeZombie0:						
			jal genRand
			addi $a0, $t5, 32
			addi $a1, $t6, 1
			jal checkPosition
			bnez $v0, placeZombie0
			
			li $v0, 42			#maybe do this in its own function as well
			li $a0, 0
			li $a1, 4
			syscall
			li $v1, 0
			add $v0, $a0, $zero
			addi $a0, $t5, 32
			addi $a1, $t6, 1
			jal encodeLocation
			
			li $a2, 1
			jal setLED 
		
	placeZombie1:
			jal genRand
			addi $a0, $t5, 1
			addi $a1, $t6, 1
			jal checkPosition
			bnez $v0, placeZombie1
			
			li $v0, 42
			li $a0, 0
			li $a1, 4
			syscall
			li $v1, 1
			add $v0, $a0, $zero
			addi $a0, $t5, 1
			addi $a1, $t6, 1
			jal encodeLocation
			
			li $a2, 1
			jal setLED 
			
	placeZombie2:
			jal genRand
			addi $a0, $t5, 1
			addi $a1, $t6, 32
			jal checkPosition
			bnez $v0, placeZombie2
			
			li $v0, 42
			li $a0, 0
			li $a1, 4
			syscall
			li $v1, 2
			add $v0, $a0, $zero
			addi $a0, $t5, 1
			addi $a1, $t6, 32
			jal encodeLocation
			
			li $a2, 1
			jal setLED 
			
	placeZombie3:
			jal genRand
			addi $a0, $t5, 32
			addi $a1, $t6, 32
			jal checkPosition
			bnez $v0, placeZombie3
			
			li $v0, 42
			li $a0, 0
			li $a1, 4
			syscall
			li $v1, 3
			add $v0, $a0, $zero
			addi $a0, $t5, 32
			addi $a1, $t6, 32
			jal encodeLocation
			
			li $a2, 1
			jal setLED 
		
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
			
	genRand:
			li $v0, 42
			li $a0, 0
			li $a1, 31
			syscall
			add $t5, $a0, $zero
			li $v0, 42
			li $a0, 0
			li $a1, 31
			syscall
			add $t6, $a0, $zero
			jr $ra
			
encodeLocation:
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			
			li $t0, 0
			or $t0, $t0, $v1
			sll $t0, $t0, 2
			or $t0, $t0, $v0
			sll $t0, $t0, 6
			or $t0, $t0, $a0
			sll $t0, $t0, 6
			or $t0, $t0, $a1
			
			beq $v1, 0, setZombie0
			beq $v1, 1, setZombie1
			beq $v1, 2, setZombie2
			beq $v1, 3, setZombie3
	setZombie0:
			add $s2, $t0, $zero
			j exitEncode
	setZombie1:
			add $s3, $t0, $zero
			j exitEncode
	setZombie2:
			add $s4, $t0, $zero
			j exitEncode
	setZombie3:
			add $s5, $t0, $zero
			j exitEncode
	exitEncode:		
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

decodeLocation:
			addi $sp, $sp, -4			#see if we can use $t0 instead of $a2
			sw $ra, 0($sp)
			add $a2, $a0, $zero
			andi $a1, $a2, 0x003f
			andi $a0, $a2, 0x0fc0
			srl $a0, $a0, 6
			andi $v1, $a2, 0xc000
			srl $v1, $v1, 14
			andi $v0, $a2, 0x3000
			srl $v0, $v0, 12		
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
			
placePlayer:
			addi $sp, $sp, -4
			sw $ra, 0($sp)
		
			li $a0, 0
			li $a1, 0
			li $a2, 3
			jal setLED
			li $s0, 0
			li $s1, 0
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra	
			
victory:
			li $v0, 4
			la $a0, victory1
			syscall
			li $v0, 1
			add $a0, $s7, $zero
			syscall
			li $v0, 4
			la $a0, victory2
			syscall
			li $v0, 10
			syscall
		
defeat:
			beq $v0, 1, collision
			beq $v0, 3, capture
			
	collision:
			add $a0, $s0, $zero
			add $a1, $s1, $zero
			li $a2, 0
			
			j end
	capture:	
			li $a2, 1
			add $a0, $s0, $zero
			add $a1, $s1, $zero
			jal setLED
			add $a0, $s2, $zero
			jal decodeLocation		#see if the decodeLocation needs to be called that many times or if I could break out of it
			li $a2, 0
			beq $t8, 0, end			#copy $v1 to $t8 in capture not checkLocation
			add $a0, $s3, $zero
			jal decodeLocation
			li $a2, 0
			beq $t8, 1, end
			add $a0, $s4, $zero
			jal decodeLocation
			li $a2, 0
			beq $t8, 2, end
			add $a0, $s5, $zero
			jal decodeLocation
			li $a2, 0
			beq $t8, 3, end
			j end
	end:		
			jal setLED
			li $v0, 4
			la $a0, defeat1
			syscall
			li $v0, 10
			syscall	

fixBoard:
			la $t0, 0xffff0008
			la $t2, byte1
			lbu $t2, ($t2)
			la $t3, byte2
			lbu $t3, ($t3)
			la $t4, byte3
			lbu $t4, ($t4)
			la $t5, byte4
			lbu $t5, ($t5)
	fixLoop:
			bgt $t0, 0xffff03ea exitFix
			addi $t0, $t0, 1
			lbu $t1, ($t0)
			beq $t1, 0xe2, fix1
			beq $t1, 0x8b, fix2
			beq $t1, 0x9b, fix3
			beq $t1, 0xe6, fix4
			j fixLoop
		
	fix1:
			sb $t2, ($t0)
			j fixLoop
	fix2:
			sb $t3, ($t0)
			j fixLoop
	fix3:
			sb $t4, ($t0)
			j fixLoop
	fix4:
			sb $t5, ($t0)
			j fixLoop
	
	exitFix:
			jr $ra
		
setBoard:		
			li $t3, 0
		
			la $t1, OOIIIIIIIIIIIIII
			lw $t2, ($t1)
			li $t0, 0xffff0008
			sw $t2, ($t0)
		
			la $t1, IIIIIIIIIIIIIIII
			lw $t2, ($t1)
			sw $t2, 4($t0)
			sw $t2, 8($t0)
			sw $t2, 12($t0)
			sw $t2, 1008($t0)
			sw $t2, 1012($t0)
			sw $t2, 1016($t0)
		
			la $t1, OOOOOOOIIOOOOOOI
			lw $t2, ($t1)
			sw $t2, 16($t0)
		
			la $t1, IOOOOOOIIOOOOOOI
			lw $t2, ($t1)
			sw $t2, 20($t0)
			sw $t2, 24($t0)
			sw $t2, 28($t0)
		
			la $t1, IIIIIIIIIIIIIIOO
			lw $t2, ($t1)
			sw $t2, 1020($t0)
		
	boardLoop1:
			la $t1, OOOOOOOOOOOOOOOI
			lw $t2, ($t1)
			sw $t2, 108($t0)
			
			la $t1, IOIIIIIIIIOIIIII
			lw $t2, ($t1)
			sw $t2, 112($t0)
			sw $t2, 116($t0)
			sw $t2, 120($t0)
			sw $t2, 124($t0)
			sw $t2, 128($t0)
			sw $t2, 132($t0)
			sw $t2, 136($t0)
			sw $t2, 140($t0)
		
			la $t1, IOOOOOOIIOOOOOOI
			lw $t2, ($t1)
			sw $t2, 144($t0)
			sw $t2, 148($t0)
			sw $t2, 152($t0)
			sw $t2, 156($t0)
	
	boardLoop2:		
			la $t1, IOIIIIOIIOIIIIOI
			lw $t2, ($t1)
			sw $t2, 32($t0)
			sw $t2, 36($t0)
			sw $t2, 40($t0)
			sw $t2, 44($t0)
			sw $t2, 80($t0)
			sw $t2, 84($t0)
			sw $t2, 88($t0)
			sw $t2, 92($t0)

			la $t1, IOIOOIOIIOIOOIOI
			lw $t2, ($t1)
			sw $t2, 48($t0)
			sw $t2, 52($t0)
			sw $t2, 56($t0)
			sw $t2, 60($t0)
			sw $t2, 64($t0)
			sw $t2, 68($t0)
			sw $t2, 72($t0)
			sw $t2, 76($t0)
		
			la $t1, IOOOOOOOOOOOOOOO
			lw $t2, ($t1)
			sw $t2, 96($t0)		
			
			addi $t3, $t3, 1
			addi $t0, $t0, 128
			blt $t3, 7, boardLoop1
			beq $t3, 7, boardLoop2
			jr $ra
		
setLED:
			# byte offset into display = y * 16 bytes + (x / 4)
			sll	$t0,$a1,4      # y * 16 bytes
			srl	$t1,$a0,2      # x / 4
			add	$t0,$t0,$t1    # byte offset into display
			li	$t2,0xffff0008 # base address of LED display
			add	$t0,$t2,$t0    # address of byte with the LED
			# now, compute led position in the byte and the mask for it
			andi	$t1,$a0,0x3    # remainder is led position in byte
			neg	$t1,$t1        # negate position for subtraction
			addi	$t1,$t1,3      # bit positions in reverse order
			sll	$t1,$t1,1      # led is 2 bits
			# compute two masks: one to clear field, one to set new color
			li	$t2,3		
			sllv	$t2,$t2,$t1
			not	$t2,$t2        # bit mask for clearing current color
			sllv	$t1,$a2,$t1    # bit mask for setting color
			# get current LED value, set the new field, store it back to LED
			lbu	$t3,0($t0)     # read current LED value	
			and	$t3,$t3,$t2    # clear the field for the color
			or	$t3,$t3,$t1    # set color field
			sb	$t3,0($t0)     # update display
			jr	$ra
	
		
getLED:
			li $v0, 0
			# byte offset into display = y * 16 bytes + (x / 4)
			sll  $t0,$a1,4      # y * 16 bytes
			srl  $t1,$a0,2      # x / 4
			add  $t0,$t0,$t1    # byte offset into display
			la   $t2,0xffff0008
			add  $t0,$t2,$t0    # address of byte with the LED
			# now, compute bit position in the byte and the mask for it
			andi $t1,$a0,0x3    # remainder is bit position in byte
			neg  $t1,$t1        # negate position for subtraction
			addi $t1,$t1,3      # bit positions in reverse order
	    		sll  $t1,$t1,1      # led is 2 bits
			# load LED value, get the desired bit in the loaded byte
			lbu  $t2,0($t0)
			srlv $t2,$t2,$t1    # shift LED value to lsb position
			andi $v0,$t2,0x3    # mask off any remaining upper bits
			jr   $ra
