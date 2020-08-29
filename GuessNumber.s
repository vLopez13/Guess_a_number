     .data
min:       .word 1  
max:       .word 10
num:       .word 8   #the secret number  
                       
msgintro:  .asciiz "\nGuess must be a hexadecimal number between "
msgand:    .asciiz " and "
msgend:    .asciiz "\nEnter your guess (or nothing to quit).\n"
msgnl:     .asciiz "\n"
msgwin:    .asciiz "Got it!"
msghigh:   .asciiz "Guess is too high. "
msglow:    .asciiz "Guess is too low. "

    .text
    .globl main
main:

       subi $sp $sp 40
       sw $ra 36($sp)
        
      lw $a0, min        #itoax
      la $a1, 16($sp)   
      jal itoax         
       			   		   
      la $a0, msgintro
      la $a1, 16($sp)   #intro 
      jal strdup2
 
      la $a0,($v0)   
      la $a1, msgand   #and
      jal strdup2
       
      
       la $t0, ($v0)     #move the $v0 to safeKeeping 
       sw $t0, 32($sp)     #to the 32 $sp

     
      lw $a0, max  
      la $a1, 16($sp)   #itoax
      jal itoax
      
      
      lw $a0, 32($sp) #lw the address that is stored in 32
      la $a1, 16($sp)  #the buffer
      jal strdup2
			#prompt = strdup2(prompt, msgend);
     la $a0,($v0) 
     la $a1, msgend
     jal strdup2      #it ends up at $v0
   
     la $t5, ($v0)                 #move the $v0 to safeKeeping 
     
    
guess_loop:  #so the address is the *prompt and not the actual word and guess wants address

	la $a0, ($t5)        # the prompt is in the heap 
	lw $a1, min  
	lw $a2, max
	jal GetGuess # #<- Exception at 4 [Address error in inst/data fetch] ####
	
	
	lw $t3, num
	beq $v0, -1, done  #if nothing entered or quit
	blt $v0, $t3, toolow #too low branch if less than the guess num
	bgt $v0, $t3, toohigh #too high  branch if higher than the guess num
	beq $v0, $t3, win   # branch if go it correct
	 
	
	toolow:
	la $a0,  msglow
	jal PrintString
	b guess_loop
	
	toohigh:
	la $a0, msghigh
	jal PrintString
	b guess_loop
	
	win:
	la $a0, msgwin
	jal PrintString
	
done:

lw $ra 36($sp)
addi $sp $sp 40

jr $ra
	
	
	
################################
# GetGuess
################################
    .data
invalid:    .asciiz "Not a valid hexadecimal number"
badrange:   .asciiz "Guess not in range"
    .text
    .globl  GetGuess
# 
# int GetGuess(char * question, int min, int max)
# -----
# This is your function from assignment 5. It repeatedly
# asks the user for a guess until the guess is a valid
# hexadecimal number between min and max.
GetGuess:
    
    ###################################
    # YOUR CODE FROM ASMT 5 HERE      #
    ################################### 
	
	#set up
	subi $sp $sp 40 
	sw $ra 36($sp)   #save space $ra  
	 
	sw $a0 40($sp) #the guess is stored in there; the guess here 
	sw $a1 44($sp) #store min
	sw $a2 48($sp) 	#store max
	
	
	input_loop:
	lw $a0, 40($sp)  #to get what is in the guess quest not the address
	la $a1, 16($sp)     	#buffer as second arg
	li $a2, 16		#addi  $a1, $sp 16 
	jal  InputConsoleString 
        
	beq $v0, $zero,  neg_one       #if (bytes_read == 0) return -1;
	             
	#status = axtoi(&theguess, buffer);
        
	 la $a0, 32($sp)
	 la $a1, 16($sp)       
         jal axtoi	
	   #if (status != 1)  {PrintString(invalid);  // invalid is a global
          # continue; 
          bne $v0, 1, status_not_one
	  #if (theguess < min || theguess > max)
	 #PrintString(badrange); // badrange is a global
  
  
	lw $t0, 32($sp) 
	lw $t1, 44($sp)
	lw $t2, 48($sp)
     blt $t0,$t1, OutOfRange  #if guess is less than the min 
     bgt $t0,$t2, OutOfRange  # if guess is more than the max 
  
  
  move $v0, $t0      #if guess was valid, return the guess
  b end_get_guess
  		
    		
	     
	        neg_one:
  		addi   $v0, $zero, -1
	       	b end_get_guess
	
	 	
	       
	        
	        
	        status_not_one:
	        
	        la $a0, invalid		
		jal  PrintString
		b  input_loop
		
		
		
	        OutOfRange:	
		
		la $a0, badrange	
		jal PrintString
 	 	b input_loop
 	  
 	  end_get_guess:     
	        
	         
     		 lw $ra 36($sp)
     		 addi $sp $sp 40
	 	jr $ra
	 	

###################################
#     OTHER HELPER FUNCTIONS      #
###################################

#
# char * strdup2 (char * str1, char * str2)
# -----
# strdup2 takes two strings, allocates new space big enough to hold 
# of them concatenated (str1 followed by str2), then copies each 
# string to the new space and returns a pointer to the result.
#
# strdup2 assumes neither str1 no str2 is NULL AND that malloc
# returns a valid pointer.
    .globl  strdup2
strdup2:
    # $ra   at 28($sp)
    # len1  at 24($sp)
    # len2  at 20($sp)
    # new   at 16($sp)
    sub     $sp,$sp,32
    sw      $ra,28($sp)
    
    # save $a0,$a1
    # str1  at 32($sp)
    # str2  at 36($sp)
    sw      $a0,32($sp)
    sw      $a1,36($sp)
    
    # get the lengths of each string 
    jal     strlen
    sw      $v0,24($sp)

    lw      $a0,36($sp)
    jal     strlen
    sw      $v0,20($sp)

    # allocate space for the new concatenated string 
    add     $a0,$v0,1
    lw      $t0,24($sp)
    add     $a0,$a0,$t0
    jal     malloc
    
    sw      $v0,16($sp)

    # copy each to the new area 
    move    $a0,$v0
    lw      $a1,32($sp)
    jal     strcpy

    lw      $a0,16($sp)
    lw      $t0,24($sp)
    add     $a0,$a0,$t0
    lw      $a1,36($sp)
    jal     strcpy

    # return the new string
    lw      $v0,16($sp)
    lw      $ra,28($sp)
    add     $sp,$sp,32
    jr      $ra

    .include  "utils.s"
