#assuming no equal nodes are there as in the question its mentioned set of integers
.globl make_node
.globl insert
.globl get
.globl getAtMost

#a0 has the int val stored, returns the new node pointer in a0
make_node:
    addi sp,sp,-16  #reserve space for return address and save the value of the new node constructed
    sd ra,0(sp)     
    sw a0,8(sp)
    addi a0,x0,24
    jal ra,malloc   #space created for new node

    lw t0,8(sp)
    sw t0,0(a0)     #offset 0 stores the value of node
    sd x0,8(a0)     #offset 8 stores the left pointer
    sd x0,16(a0)    #offset 16 stores the right pointer

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
    add a0,a1,x0    #a0=value of the new node to be allocated memory
    jal ra,make_node    #create memory for newnode and return its pointer in a0 register
    ld ra,0(sp)
    addi sp,sp,16
    jalr x0,0(ra)   #jump to the return address

left_insert:
    addi sp,sp,-16  #save ra and a0 as jal ra,insert will overwrite this
    sd a0,0(sp)
    sd ra,8(sp)
    ld a0,8(a0)     #a0=left node pointer of the current node
    jal ra,insert   #again jump back to the insert function to proceed until we find a NULL pointer where new node should be placed
    #update current node's left pointer with updated subtree returned by the recursive call
    ld t1,0(sp)
    sd a0,8(t1)     #store the value of the a0 register=pointer of the changed new subtree in the left pointer of the current node when recursive call is going back
    addi a0,t1,0
    ld ra,8(sp)
    addi sp,sp,16
    jalr x0,0(ra)

right_insert:
    addi sp,sp,-16      #save ra and a0 as jal ra,insert will overwrite this
    sd a0,0(sp)
    sd ra,8(sp)
    ld a0,16(a0)        #a0=right node pointer of the current node
    jal ra,insert       #again jump back to the insert function to proceed until we find a NULL pointer where new node should be placed
    #update current node's right pointer with updated subtree returned by the recursive call
    ld t1,0(sp)
    sd a0,16(t1)        #store the value of the a0 register=pointer of the changed new subtree in the right pointer of the current node when recursive call is going back
    addi a0,t1,0
    ld ra,8(sp)
    addi sp,sp,16
    jalr x0,0(ra)

#get function a0=pointer of the root node,a1=value of node to be found,searches the BST for a specific value using tail recursion.
get:
    beq x0,a0,get_exit_nonode   #if the value doesn.t exist so if the root pointer is NULL
    lw t0,0(a0)     #t0=value of the root node
    blt a1,t0,get_left  #if a1<t0, a1 will be in the left subtree as its a bst
    bgt a1,t0,get_right     #if a1>t0, a1 will be in the right subtree as its a bst
    beq a1,t0,found_node    #if a1=t0, we have found the node

get_left:
    ld a0,8(a0) #go to left pointer node
    jal x0,get  #no need to return so directly jump to get without modifying the stack or ra

get_right:
    ld a0,16(a0)    #go to right pointer node
    jal x0,get

found_node:
    jalr x0,0(ra)   #if found the node then save its pointer is in the a0 register already so just return from the function

get_exit_nonode:
    addi a0,x0,0    #if node not found, put a0=0 i.e. return NULL pointer and return to the call
    jalr x0,0(ra)

#greatest value of a node<=given val or -1 if none, a0=target integer value,a1=pointer to the root node of bst
getAtMost:
    addi t3,x0,-1   #t3 is storing the greatest value stored so far, initialised t3=-1

getAtMost_recurse:
    beq x0,a1,getAtMost_exit    #if current node=NULL, go to getAtMost_exit function
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

getAtMost_exit:     #save a0=t3 and return to from where the function was called
    addi a0,t3,0
    jalr x0,0(ra)
    