
.data
    # MMIO addresses for keyboard input
    RECEIVER_CONTROL:   .word 0xffff0000  # Keyboard receiver control
    RECEIVER_DATA:      .word 0xffff0004  # Keyboard receiver data
    
    # Display messages
    welcome_msg:    .asciiz "=== TRAFFIC LIGHT CONTROLLER ===\n"
    start_msg:      .asciiz "Traffic simulation started!\n"
    menu_msg:       .asciiz "\nControls during simulation:\n"
    controls_msg:   .asciiz "  'p' - Pedestrian request\n  'm' - Return to menu\n  'q' - Quit\n\n"
    
    menu_options:   .asciiz "\n1. Start simulation\n2. Change green time\n3. Change yellow time\n4. Set speed limit\n5. Exit\nChoice: "
    green_prompt:   .asciiz "Enter green light duration (seconds): "
    yellow_prompt:  .asciiz "Enter yellow light duration (seconds): "
    speed_prompt:   .asciiz "Enter speed limit (mph): "
    current_green:  .asciiz "Current green time: "
    current_yellow: .asciiz "Current yellow time: "
    current_speed:  .asciiz "Current speed limit: "
    seconds_msg:    .asciiz " seconds\n"
    mph_msg:        .asciiz " mph\n"
    invalid_msg:    .asciiz "Invalid choice! Try again.\n"
    
    # Traffic light states
    ns_green:       .asciiz "North-South: GREEN  | East-West: RED    "
    ns_yellow:      .asciiz "North-South: YELLOW | East-West: RED    "
    ew_green:       .asciiz "North-South: RED    | East-West: GREEN  "
    ew_yellow:      .asciiz "North-South: RED    | East-West: YELLOW "
    
    # Pedestrian messages
    ped_request:    .asciiz " [PEDESTRIAN REQUEST]"
    ped_walk:       .asciiz "\nPEDESTRIAN WALK - All directions RED\n"
    
    # Status messages
    time_left:      .asciiz " - Time left: "
    sec_msg:        .asciiz "s"
    newline:        .asciiz "\n"
    
    # Timing (in seconds)
    green_time:     .word 8     # Green light duration
    yellow_time:    .word 3     # Yellow light duration
    ped_walk_time:  .word 5     # Pedestrian walk time
    speed_limit:    .word 35    # Speed limit in mph
    
    # State variables
    ped_requested:  .word 0     # 1 if pedestrian button pressed
    
    # Exit message
    goodbye_msg:    .asciiz "\nGoodbye!\n"

.text
.globl main

main:
    # Show welcome message
    li $v0, 4
    la $a0, welcome_msg
    syscall
    
    # Show controls
    li $v0, 4
    la $a0, menu_msg
    syscall
    
    li $v0, 4
    la $a0, controls_msg
    syscall

main_menu:
    # Show current settings
    li $v0, 4
    la $a0, current_speed
    syscall
    
    li $v0, 1
    lw $a0, speed_limit
    syscall
    
    li $v0, 4
    la $a0, mph_msg
    syscall
    
    li $v0, 4
    la $a0, current_green
    syscall
    
    li $v0, 1
    lw $a0, green_time
    syscall
    
    li $v0, 4
    la $a0, seconds_msg
    syscall
    
    li $v0, 4
    la $a0, current_yellow
    syscall
    
    li $v0, 1
    lw $a0, yellow_time
    syscall
    
    li $v0, 4
    la $a0, seconds_msg
    syscall
    
    #Show menu
    li $v0, 4
    la $a0, menu_options
    syscall
    
    #Geting user choice
    li $v0, 5
    syscall
    move $t0, $v0
    
    #Process choice
    beq $t0, 1, start_simulation
    beq $t0, 2, change_green
    beq $t0, 3, change_yellow
    beq $t0, 4, change_speed
    beq $t0, 5, exit_program
    
    #Invalid choice
    li $v0, 4
    la $a0, invalid_msg
    syscall
    j main_menu

start_simulation:
    #Clearing pedestrian request
    sw $zero, ped_requested
    
    #Showing start message
    li $v0, 4
    la $a0, start_msg
    syscall
    
    #Starting traffic light cycle
    j traffic_cycle

change_green:
    #Getting new green time
    li $v0, 4
    la $a0, green_prompt
    syscall
    
    li $v0, 5
    syscall
    
    # Simple validation - just check if positive
    blez $v0, main_menu
    sw $v0, green_time
    
    j main_menu

change_yellow:
    #Getting new yellow time
    li $v0, 4
    la $a0, yellow_prompt
    syscall
    
    li $v0, 5
    syscall
    
    # Simple validation - just check if positive
    blez $v0, main_menu
    sw $v0, yellow_time
    
    j main_menu

change_speed:
    #Getting new speed limit
    li $v0, 4
    la $a0, speed_prompt
    syscall
    
    li $v0, 5
    syscall
    
    # Simple validation - just check if positive
    blez $v0, main_menu
    sw $v0, speed_limit
    
    #Speed-based yellow time adjustment
    #For every 10 mph increase above 25, add 1 second to yellow
    li $t0, 25          	#Base speed
    sub $t1, $v0, $t0   	#Speed above base
    blez $t1, use_min_yellow  	#If speed <= 25, use minimum
    
    #Calculating additional yellow time (speed_above_25 / 10)
    li $t2, 10
    div $t1, $t2
    mflo $t1            # Additional seconds
    
    #Base yellow time of 3 seconds + additional
    li $t0, 3
    add $t0, $t0, $t1
    sw $t0, yellow_time
    j main_menu
    
use_min_yellow:
    #Use minimum of 3 seconds for low speeds
    li $t0, 3
    sw $t0, yellow_time
    j main_menu

traffic_cycle:
    # State 1: North-South Green
    la $a0, ns_green
    lw $a1, green_time
    jal display_state_with_timer
    
    # Check if we should return to menu or quit
    beq $v0, 1, main_menu
    beq $v0, 2, exit_program
    
    # State 2: North-South Yellow
    la $a0, ns_yellow
    lw $a1, yellow_time
    jal display_state_with_timer
    
    beq $v0, 1, main_menu
    beq $v0, 2, exit_program
    
    # Check for pedestrian request after yellow phase
    lw $t0, ped_requested
    bnez $t0, pedestrian_phase
    
    # State 3: East-West Green
    la $a0, ew_green
    lw $a1, green_time
    jal display_state_with_timer
    
    beq $v0, 1, main_menu
    beq $v0, 2, exit_program
    
    # State 4: East-West Yellow
    la $a0, ew_yellow
    lw $a1, yellow_time
    jal display_state_with_timer
    
    beq $v0, 1, main_menu
    beq $v0, 2, exit_program
    
    # Check for pedestrian request after yellow phase
    lw $t0, ped_requested
    bnez $t0, pedestrian_phase
    
    # Repeat cycle
    j traffic_cycle

pedestrian_phase:
    # Clear the pedestrian request
    sw $zero, ped_requested
    
    # Show pedestrian walk phase
    li $v0, 4
    la $a0, ped_walk
    syscall
    
    # Wait for pedestrian walk time
    la $a0, ped_walk
    lw $a1, ped_walk_time
    jal display_state_with_timer
    
    beq $v0, 1, main_menu
    beq $v0, 2, exit_program
    
    # Return to normal cycle
    j traffic_cycle


# Display state with countdown timer and input checking
# $a0 = state message, $a1 = duration in seconds
# Returns: $v0 = 0 (continue), 1 (menu), 2 (quit)
display_state_with_timer:
    move $s0, $a0       # Save state message
    move $s1, $a1       # Save duration
    move $s2, $ra       # Save return address
    
    li $s3, 0           # Current second counter
    
timer_loop:
    #Calculating remaining time
    sub $t0, $s1, $s3   	#remaining = duration - current
    blez $t0, timer_done
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    move $a0, $s0       	#Stating message
    syscall
    
    #Show pedestrian request if active
    lw $t1, ped_requested
    beqz $t1, no_ped_display
    li $v0, 4
    la $a0, ped_request
    syscall
    
no_ped_display:
    li $v0, 4
    la $a0, time_left
    syscall
    
    li $v0, 1
    move $a0, $t0       	#Time remaining
    syscall
    
    li $v0, 4
    la $a0, sec_msg
    syscall
    
    # Wait 1 second with input checking (10 checks per second)
    li $t2, 0           	#100ms interval counter
    
inner_timer_loop:
    beq $t2, 10, next_seconD	#10 intervals = 1 second
    
    #Waiting for 100ms
    li $v0, 32
    li $a0, 100
    syscall
    
    #Check for keyboard input
    jal check_keyboard_input
    beq $v0, 1, return_menu
    beq $v0, 2, return_quit
    
    addi $t2, $t2, 1
    j inner_timer_loop
    
next_second:
    addi $s3, $s3, 1
    j timer_loop
    
timer_done:
    li $v0, 0           #Continue simulation
    move $ra, $s2
    jr $ra
    
return_menu:
    li $v0, 1           #Return to menu
    move $ra, $s2
    jr $ra
    
return_quit:
    li $v0, 2           #Quit program
    move $ra, $s2
    jr $ra

# Check for keyboard input using MMIO
# Returns: $v0 = 0 (no action), 1 (menu), 2 (quit)

check_keyboard_input:
    # Load MMIO addresses
    lw $t0, RECEIVER_CONTROL
    lw $t1, ($t0)               #Reading receiver control
    
    #Checking if data is ready (bit 0 = ready bit)
    andi $t1, $t1, 1
    beqz $t1, no_input
    
    #Reading the character
    lw $t0, RECEIVER_DATA
    lw $t2, ($t0)               
        
    #Check what key was pressed
    beq $t2, 112, pedestrian_pressed  # 'p' = 112
    beq $t2, 80, pedestrian_pressed   # 'P' = 80
    beq $t2, 109, menu_pressed        # 'm' = 109
    beq $t2, 77, menu_pressed         # 'M' = 77
    beq $t2, 113, quit_pressed        # 'q' = 113
    beq $t2, 81, quit_pressed         # 'Q' = 81
    
no_input:
    li $v0, 0           #No action
    jr $ra
    
pedestrian_pressed:
    #Setting pedestrian request flag
    li $t0, 1
    sw $t0, ped_requested
    li $v0, 0           #Continue, don't interrupt current state
    jr $ra
    
menu_pressed:
    li $v0, 1           #Return to menu
    jr $ra
    
quit_pressed:
    li $v0, 2           #Quit program
    jr $ra

exit_program:
    li $v0, 4
    la $a0, goodbye_msg
    syscall
    
    li $v0, 10
    syscall
