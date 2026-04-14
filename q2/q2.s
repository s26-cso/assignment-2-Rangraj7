.section .rodata
output_format:
    .string "%d "

.section .text
.globl main

main:
    addi sp,sp,-96     #store all the saved registers used in the program in stack
    sd ra,0(sp)
    sd s0,8(sp)     #total elements(n)
    sd s1,16(sp)
    sd s2,24(sp)    #stores start index
    sd s3,32(sp)    #base pointer for nums array
    sd s4,40(sp)
    sd s5,48(sp)
    sd s6,56(sp)
    sd s7,64(sp)    #base pointer for ans array
    sd s8,72(sp)
    sd s10,80(sp)
    sd s11,88(sp)   #base pointer for stack array

    addi s0,a0,-1    #total no. of numbers given
    addi s1,a1,8    #pointer to the array of elements skipping the first element given as command line arguments

    slli s4,s0,3
    add a0,s4,x0
    jal ra,malloc
    addi s3,a0,0    #base pointer for nums array
    add a0,s4,x0
    jal ra,malloc
    addi s7,a0,0    #base pointer for ans array
    add a0,s4,x0
    jal ra,malloc
    addi s11,a0,0    #base pointer for stack array
    addi s2,x0,0    #index 0, start index

convert_to_nums:    #convert the string numbers to integer numbers using atoi
    bge s2,s0,initialise_ans

    addi s4,s2,0
    slli s4,s4,3    #s4=s2*8, offset from base pointer
    addi s2,s2,1    #increment index s2++

    add t0,s4,s1    #base pointer to the array of elements given as command line arguments + offset s4
    ld a0,0(t0)
    jal ra,atoi     #call atoi to convet string numbers to integer numbers

    add s5,s4,s3
    sd a0,0(s5)

    jal x0,convert_to_nums

initialise_ans:     #SET S2=0 starting index
    addi s2,x0,0

initialise_ans_array:   #intialise the entire ans array with -1, so if an elements doesnt have nge, it will output -1 at its index
    bge s2,s0,next_greater_initialise
    addi s6,s2,0
    slli s6,s6,3
    add s6,s6,s7
    addi s8,x0,-1
    sd s8,0(s6)
    addi s2,s2,1
    jal x0,initialise_ans_array

next_greater_initialise:    #iterate through the array from right to left s2=s0-1 to 0, stack stores the indices of elements, and we pop the elems from top of stack till current element>=element at stack's top index
    addi s2,s0,-1
    addi s10,x0,0   #s10=0, storess current stack size
    
next_greater:
    addi t2,x0,-1
    beq s2,t2,print_answer

    slli t1,s2,3
    add t1,t1,s3
    ld t1,0(t1)     #current element
    jal x0,stack_empty

#check if array[stack.top()]<=array[i], if so pop elments from stack by decrementing s10
stack_empty:
    beq s10,x0,push_new
    addi t2,s10,-1
    slli t2,t2,3
    add t2,t2,s11
    ld t2,0(t2)     #index stored in stack top
    slli t0,t2,3
    add t0,t0,s3
    ld t0,0(t0)     #value stored at top most index in stack in nums array

    bgt t0,t1,answer
    addi s10,s10,-1
    beq x0,x0,stack_empty

#push current index onto stack and move to the next element s2--
push_new:
    slli t0,s10,3
    add t0,t0,s11
    sd s2,0(t0)
    addi s2,s2,-1
    addi s10,s10,1
    jal x0,next_greater

#the element at stack.top() is greater, save its index to ans[s2]
answer:
    slli t4,s2,3
    add t4,t4,s7
    sd t2,0(t4)
    beq x0,x0,push_new

print_answer:
    addi s2,x0,0

print_answer_loop:  #iterate from left to right in the ans array and print elements calculated for each index
    beq s2,s0,exit_all
    la a0,output_format
    slli t0,s2,3
    add t0,s7,t0
    ld t0,0(t0)
    add a1,t0,x0
    jal ra,printf
    addi s2,s2,1
    beq x0,x0,print_answer_loop

exit_all:   #restore the saved registers used and return address and return
    addi a0,s3,0
    jal ra,free
    addi a0,s7,0
    jal ra,free
    addi a0,s11,0
    jal ra,free

    ld ra,0(sp)
    ld s0,8(sp)
    ld s1,16(sp)
    ld s2,24(sp)
    ld s3,32(sp)
    ld s4,40(sp)
    ld s5,48(sp)
    ld s6,56(sp)
    ld s7,64(sp)
    ld s8,72(sp)
    ld s10,80(sp)
    ld s11,88(sp)
    addi sp,sp,96
    addi a0,x0,0
    jalr x0,0(ra)
    