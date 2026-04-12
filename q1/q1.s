#assuming no equal nodes are there as in the question its mentioned set of integers
.globl make_node
.globl insert
.globl get
.globl getAtMost

#a0 has the int val stored, returns the new node pointer in a0
make_node:
    addi sp,sp,-16
    sd ra,0(sp)
    sw a0,8(sp)
    addi a0,x0,24
    jal ra,malloc   #space created for new node
    beq a0,x0,exit_malloc_fail

    lw t0,8(sp)
    sw t0,0(a0)     #offset 0 stores the value of node
    sd x0,8(a0)     #offset 8 stores the left pointer
    sd x0,16(a0)    #offset 16 stores the right pointer

    ld ra,0(sp)
    addi sp,sp,16
    jalr x0,0(ra)

exit_malloc_fail:
    ld ra,0(sp)
    addi sp,sp,16
    jalr x0,0(ra)

#Insert Function: return address in a0, a0=pointer to root node,a1=value of new node
insert:
    beq x0,a0,insert_node   #jump to insert_node if a0==NULL
    lw t0,0(a0)
    blt t0,a1,right_insert  #compare t0=value of current node with the value to be inserted(a1) if t0<a1 go to right_insert
    bge t0,a1,left_insert   #if t0>a1 go to left_insert

insert_node:
    addi sp,sp,-16
    sd ra,0(sp)
    add a0,a1,x0
    jal ra,make_node
    ld ra,0(sp)
    addi sp,sp,16
    jalr x0,0(ra)

left_insert:
    addi sp,sp,-16  #save ra and a0 as jal ra,insert will overwrite this
    sd a0,0(sp)
    sd ra,8(sp)
    ld a0,8(a0)
    jal ra,insert
    #update current node's left pointer with updated subtree returned by the recursive call
    ld t1,0(sp)
    sd a0,8(t1)
    addi a0,t1,0
    ld ra,8(sp)
    addi sp,sp,16
    jalr x0,0(ra)

right_insert:
    addi sp,sp,-16
    sd a0,0(sp)
    sd ra,8(sp)
    ld a0,16(a0)
    jal ra,insert
    #update current node's right pointer with updated subtree returned by the recursive call
    ld t1,0(sp)
    sd a0,16(t1)
    addi a0,t1,0
    ld ra,8(sp)
    addi sp,sp,16
    jalr x0,0(ra)

#get function a0=root node, a1=val
get:
    beq x0,a0,get_exit_nonode   #if the value doesn.t exist so if the root pointer is NULL
    lw t0,0(a0)     #t0=value of the root node
    blt a1,t0,get_left  #if a1<t0 
    bgt a1,t0,get_right
    beq a1,t0,found_node

get_left:
    ld a0,8(a0) #go to left pointer node
    jal x0,get  #no need to return so directly jump to get without modifying the stack or ra

get_right:
    ld a0,16(a0)
    jal x0,get

found_node:
    jalr x0,0(ra)

get_exit_nonode:
    addi a0,x0,0
    jalr x0,0(ra)

#greatest value of a node<=given val or -1 if none, input is a0=val, a1=root node
getAtMost:
    addi t3,x0,-1   #t3 is storing the greatest value stored so far

getAtMost_recurse:
    beq x0,a1,getAtMost_exit
    lw t0,0(a1)
    blt a0,t0,left_getAtMost
    bge a0,t0,right_getAtMost

left_getAtMost:
    ld a1,8(a1)     #current node value>val, so we dont save it, traverse left to find smaller values
    jal x0,getAtMost_recurse

right_getAtMost:    #current node<val, so save it, treverse right to find larger values
    lw t3,0(a1)
    ld a1,16(a1)
    jal x0,getAtMost_recurse

getAtMost_exit:
    addi a0,t3,0
    jalr x0,0(ra)
    