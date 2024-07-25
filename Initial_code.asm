.text
main:
lw $t6,0($a1)
lw $t7,4($a1)
lw $t8,8($a1)
lb $a0,0($t6)
addi $a0,$a0,-48  

lb $a1,0($t7)
addi $a1,$a1,-48

lb $a2,0($t8)
addi $a2,$a2,-48

j Euler_fn
#Tell the assembler that this is the program end
j Exit
#function to multiply two numbers
MUL:
        addi $t1,$zero,0           #initialize the sum holder to zero sum=0;
        addi $t0,$zero,0           #initialize the counter to zero    i=0; 
        #Accounting for if one of the two inputs or both are zero
        beq $a0,$zero,ZeroCase
        beq $a1,$zero,ZeroCase
        #Acccounting for multiplication calculation when one of the two inputs or both are negative
        slt $t2,$a0,$zero
        slt $t3,$a1,$zero
        addi $t4,$zero,1
        beq $t2,$t4,Check_Both_if_Negative 
        j Check_a1
Check_Both_if_Negative: 
        beq $t3,$t4,BothNegative        
        #Reaching this following part of the code means that only the first input of the two numbers to be multiplied is negative
        nor $a0,$a0,$zero
        addi $a0,$a0,1
        j MULLoop
Check_a1:
        bne $t3,$t4, MULLoop     #If branch is taken, it means that none of the inputs is negative and if it is not taken it means the second input only is negative
        nor $a1,$a1,$zero
        addi $a1,$a1,1  
        j MULLoop
BothNegative: 
        nor $a0,$a0,$zero
        addi $a0,$a0,1
        nor $a1,$a1,$zero
        addi $a1,$a1,1  
       
 
MULLoop:   beq $t0,$a0,ExitMULLoop
        add $t1,$t1,$a1          #sum+=input number;
        addi $t0,$t0,1           #increment the counter i++;
        j MULLoop
ZeroCase:
        add $v0,$zero,$zero      #Return zero either because the first input of the two numbers to be multiplied is zero or the second or both
        jr $ra 
        
ExitMULLoop :
#Accounting for the effect of the cases when of the two inputs or both are negative on the result to be returned
        beq $t2,$t4,check_both
        j a1_check
check_both:
        beq $t3,$t4,both_negative
#first input only is negative        
        nor $t1,$t1,$zero
        addi $t1,$t1,1
        add $v0,$t1,$zero
        jr $ra
both_negative:
        add $v0,$t1,$zero
        jr $ra
a1_check:
        bne $t3,$t4,return
#second input only is negative        
        nor $t1,$t1,$zero
        addi $t1,$t1,1
        add $v0,$t1,$zero
        jr $ra                                

return: add $v0,$t1,$zero        #Return the result in $v0
        jr $ra 

#function to substitute with x($a0) & y($a1) in the given unique equation to be solved (-526x^3 +73x^2 -38x -175y^2 +42y +51)
Substitute:
        add $t0,$a0,$zero     #$a0-->x
        add $t1,$a1,$zero     #$a1-->y
        addi $sp,$sp,-12
        sw $ra, 8($sp)
        sw $t1, 4($sp)
        sw $t0, 0($sp)
        add $a1,$a0,$zero
        jal MUL
        add $t2,$v0,$zero     #$v0=x^2  
        lw $t0, 0($sp)
        sw $t2, 0($sp)
        add $a0,$t0,$zero
        addi $a1,$zero,-526
        addi $sp,$sp,-4
        sw $t0, 0($sp)
        jal MUL
        lw $t2, 4($sp)
        add $a0,$t2,$zero
        add $a1,$v0,$zero    #$v0= -526x
        sw $t2,4($sp)
        jal MUL
        add $t3,$v0,$zero    #$t3= -526x^3
        lw $t2 ,4($sp)
        add $a0,$t2,$zero
        addi $a1,$zero,73
        sw $t3 ,4($sp)
        jal MUL
        lw $t3, 4($sp)
        add $t3,$t3,$v0      #$v0=73x^2 ,$t3= -526x^3+73x^2
        lw $t0, 0($sp)
        addi $sp,$sp,4
        sw $t3, 0($sp)
        add $a0,$t0,$zero
        addi $a1, ,$zero,-38
        jal MUL
        lw $t3, 0($sp)
        add $t3,$t3,$v0       #$v0= -38x , $t3= -526x^3+73x^2-38x
        sw $t3, 0($sp)
        lw $t1, 4($sp)
        add $a0,$t1,$zero     #$a0=y
        add $a1,$t1,$zero     #$a1=y
        sw $t1, 4($sp)
        jal MUL
        add $a1,$v0,$zero     #$v0=y^2 
        addi $a0,$zero,-175
        jal MUL
        lw $t3, 0($sp)
        add $t3,$t3,$v0       #$v0= -175y^2, $t3= -526x^3+73x^2-38x-175y^2
        lw $t1, 4($sp)
        addi $sp,$sp,4
        sw $t3, 0($sp)
        add $a1,$t1,$zero
        addi $a0,$zero,42
        jal MUL
        lw $t3, 0($sp)
        lw $ra, 4($sp)
        addi $sp,$sp,8
        add $t3,$t3,$v0       #$v0= 42y , $t3= -526x^3+73x^2-38x-175y^2+42y 
        addi $t3,$t3,51       # $t3= -526x^3+73x^2-38x-175y^2+42y+51
        add $v0,$t3,$zero     #return f'(xn,yn)
        jr $ra                 
        

#Function that performs Euler_method for approximation of yn at a certain xn
Euler_fn:
        add $t2,$a2,$zero           #$t2--->number of steps
        beq $t2,$zero,return_y0     #If number of steps=1 return y0
        add $t0,$a0,$zero           #$t0-->yn (initially =y0) 
        add $t1,$a1,$zero           #$t1-->h (step size) 
        add $t3,$zero,$zero         #$t3-->xn (initially =zero)
        add $t4,$zero,$zero         #initialize the counter with zero
        addi $sp,$sp,-4
        sw $ra, 0($sp)
euler_loop: beq $t4,$t2,End             #stop iterating when the counter reaches the required number of steps to approximate yn
       
        add $a0,$t3,$zero           #$a0=xn
        add $a1,$t0,$zero           #$a1=yn
        addi $sp,$sp,-20
        sw $t4, 16($sp)
        sw $t2, 12($sp)
        sw $t3, 8($sp)
        sw $t0, 4($sp)
        sw $t1, 0($sp)
        jal Substitute             # to be calculated
        lw $t1, 0($sp)
        add $a1,$v0,$zero          #$a1=f'(xn,yn)
        add $a0,$t1,$zero          #$a0=h
        sw $t1, 0($sp)
        jal MUL                    # h*f'(xn,yn) to be calculated
        lw $t1, 0($sp)
        lw $t0, 4($sp)
        lw $t3, 8($sp)
        addi $sp,$sp,12
        add $t0,$t0,$v0           #yn+1=yn+h*f'(xn,yn)
        add $t3,$t3,$t1           # xn=xn+h
        
        lw $t2,0($sp)
        lw $t4,4($sp)
        addi $t4,$t4,1            #increment counter
        addi $sp,$sp,8
        j euler_loop
End:
        lw $ra,0($sp)
        addi $sp,$sp,4
        add $v0,$t0,$zero         #return yn
        lui $t5,4097
        sw $v0,0($t5)
        jr $ra
return_y0:
        add $v0,$a0,$zero
        lui $t5,4097
        sw $v0,0($t5)
        jr $ra        
Exit:        
                
        
        
        
                        
                
