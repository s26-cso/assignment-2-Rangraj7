#assuming no new line char if its there then checking it together for the palindrome and that input.txt is always provided as mentioned in the pdf.
.section .rodata
filename:
    .string "input.txt"
filereadmode:   #we just have to read the file so readmode "r"=read
    .string "r"
print_yes:
    .string "Yes\n"
print_no:
    .string "No\n"
string_format:
    .string "%s"

.section .text
.globl main

main:
    la a0,filename
    la a1,filereadmode
    addi sp,sp,-32
    sd ra,0(sp)
    sd s0,8(sp)
    sd s4,16(sp)

    jal ra,fopen
    addi s0,a0,0        #s0=file pointer
    beq s0,x0,exit_fopen    #exit if file is not there

    la a0,filename
    la a1,filereadmode
    jal ra,fopen
    addi s4,a0,0        #s4=file pointer, opening file 2nd time to use a 2 pointer approach
    beq s4,x0,exit_fopen_2      #exit if can;t open file second time

    jal ra,check_palindrome

    add a0,s0,x0
    jal ra,fclose
    add a0,s4,x0
    jal ra,fclose
    jal x0,exit_fopen

check_palindrome:
    addi sp,sp,-32
    sd s1,0(sp)
    sd s2,8(sp)
    sd s3,16(sp)
    sd ra,24(sp)

    addi s1,x0,0    #s1=left index
    jal ra,length_s2    #calling function length+s2 and storing the length of the palindrome in s2 register
    jal x0,check_palindrome_loop

length_s2:
    addi sp,sp,-16
    sd ra,0(sp)
    add a0,s4,x0
    addi a1,x0,0
    addi a2,x0,2    #a2=2 corresponds to SEEK_END in c
    jal ra,fseek

    addi a0,s4,0
    jal ra,ftell    #ftell given the length of string

    addi s2,a0,-1   #right index=s2
    ld ra,0(sp)
    addi sp,sp,16
    jalr x0,0(ra)

check_palindrome_loop:
    bge s1,s2,palindrome_true   #if left index equals or becomes greater than right index, its a palindrome
    
    addi a0,s0,0    #reading left char using s0
    jal ra,fgetc    #fgetc moves pointer automatically +1 byte forward
    addi s3,a0,0    #left index char

    addi a0,s4,0    #reading right char using s4
    addi a1,s2,0    #a1=s2 right side current index
    addi a2,x0,0    #a2=0 seekset, offset from start of file
    jal ra,fseek    #force cursor pointer to index s2
    addi a0,s4,0
    jal ra,fgetc    #readd the char at index s2
    addi t0,a0,0    #store right index char in t0

    bne t0,s3,palindrome_false  #if left and right char are not equal jump to the case that the string is not a palindrome
    addi s1,s1,1    #left index++
    addi s2,s2,-1   #right index--
    jal x0,check_palindrome_loop    #again jump to check_palindrome_loop to check for the new left and right indices

palindrome_true:    #if the string is a palindrome
    la a0,string_format     #argument 1 for the printf function, "%s"
    la a1,print_yes     #argument 2 for the printf function, "Yes"
    jal ra,printf   #call printf
    jal x0,exit_check_palin     #goto exit_check_palin function

palindrome_false:   #if string is not a palindrome
    la a0,string_format
    la a1,print_no
    jal ra,printf
    
exit_check_palin:   #restore all the saved registers used and make the stack pointer as before
    ld ra,24(sp)
    ld s1,0(sp)
    ld s2,8(sp)
    ld s3,16(sp)
    addi sp,sp,32
    jalr x0,0(ra)   #jump back to return address stored in the return address register

exit_fopen:     #reallocate the stack pointer
    ld ra,0(sp)
    ld s0,8(sp)
    ld s4,16(sp)
    addi sp,sp,32
    addi a0,x0,0
    jalr x0,0(ra)   #jump to saved return address

exit_fopen_2:   #reallocate the stack pointer
    add a0,s0,x0
    jal ra,fclose   #close the file from the file pointer
    ld ra,0(sp)
    ld s0,8(sp)
    ld s4,16(sp)
    addi sp,sp,32
    addi a0,x0,0
    jalr x0,0(ra)   #jump to saved return address
