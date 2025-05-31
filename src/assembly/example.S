.section .text
.globl draw
.type draw, @function
draw:
    li a0,120
    li a1,15
    li a2,8
    li a3,65535
    addi sp,sp,-4
    sw ra,0(sp)
    jal LCD_DrawCircle
    lw ra,0(sp)
    addi sp,sp,4
    ret

.globl scenario_select
.type scenario_select, @function
scenario_select:
    # Prologue
    addi sp,sp,-16
    sw ra,12(sp)
    sw s0,8(sp)
    sw s1,4(sp)

    # Use global variable if initial_choice is -1
    li t0,-1
    bne a0,t0,use_param
    la t0,selected_scenario
    lw s0,0(t0)     # Load from global
    j after_init
use_param:
    # Save initial choice (a0) in s0
    mv s0,a0
after_init:

    # Display menu options
    li a0,30        # x pos
    li a1,10        # y pos
    la a2,option1   # text
    li a3,0xFFFF    # color (white)
    jal LCD_ShowString

    li a0,30
    li a1,20
    la a2,option2
    li a3,0xFFFF
    jal LCD_ShowString

    li a0,30
    li a1,30
    la a2,option3
    li a3,0xFFFF
    jal LCD_ShowString

    # Highlight initial choice
    mv a0,s0
    jal highlight_option

menu_loop:
    # Check for button presses
    li a0,JOY_UP
    jal Get_Button
    bnez a0,up_pressed

    li a0,JOY_DOWN
    jal Get_Button
    bnez a0,down_pressed

    li a0,JOY_CTR
    jal Get_Button
    bnez a0,select_pressed

    j menu_loop

up_pressed:
    li a0,1
    blt s0,a0,menu_loop  # if choice <=1, ignore
    addi s0,s0,-1        # else decrement choice
    mv a0,s0
    jal highlight_option
    j menu_loop

down_pressed:
    li a0,2
    bge s0,a0,menu_loop  # if choice >=2, ignore
    addi s0,s0,1         # else increment choice
    mv a0,s0
    jal highlight_option
    j menu_loop

select_pressed:
    # Update global variable
    la t0,selected_scenario
    sw s0,0(t0)     # Store to global
    
    # Return selected choice (in s0)
    mv a0,s0

    # Epilogue
    lw ra,12(sp)
    lw s0,8(sp)
    lw s1,4(sp)
    addi sp,sp,16
    ret

highlight_option:
    # a0 = option to highlight (0-2)
    # Implementation would go here
    ret

.section .rodata
option1: .string "1. Scenario 1"
option2: .string "2. Scenario 2"
option3: .string "3. Scenario 3"
