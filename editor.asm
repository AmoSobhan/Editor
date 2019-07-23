;%include "io64.inc"
;define Constants for read and write
SYS_WRIT equ 4 
SYS_READ equ 3
STDIN    equ 2
STDOUT   equ 1
;define COnstants for Exit
SYS_EXIT equ 1

;Macro for write on Screan
%macro print_string 2
    mov eax, SYS_WRIT
    mov ebx, STDOUT
    mov ecx, %1
    mov edx, %2
    int 80h
%endmacro

;Macro for read input string
%macro read_string 2
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, %1
    mov edx, %2
    int 80h
    xor r8 , r8
    mov r8d , eax
%endmacro

%macro exit_code 0
    mov eax, SYS_EXIT
    mov ebx, 0
    int 80h
%endmacro    

%macro check_operator 1
    cmp byte [op], '1'
    je efile
    cmp byte [op], '2'
    je nfile
    cmp byte [op], '3'
    je shofile
    cmp byte [op], '4'
    je search
    cmp byte [op], '5'
    je replace
    cmp byte [op], '6'
    je exit

%endmacro    

section .data
    msg_menu db 'Edit File:1 || New File:2 || Show File:3 || Search:4 || replace:5 || exit:6 ',0x0a,0xD
    len_menu equ $ - msg_menu
    msg_enter_address db 'Enter Address and File Name at the end of it: ',0x0a,0xD
    len_enter equ $ - msg_enter_address
    msg_linenum db 'file lines: '
    len_linenum equ $ - msg_linenum
    msg_wordnum db 'file words: '
    len_wordnum equ $ - msg_wordnum
    msg_charnum db 'file chars: '
    len_charnum equ $ - msg_charnum
    msg_end_or_goto db 'Enter "e" to edit at the en Or Enter "g" to goto at the line ',0x0a,0xD
    len_end_or_goto equ $ - msg_end_or_goto
    msg_enter_line db 'Enter the line:' 
    len_line equ $-msg_enter_line
    msg_enter_col db 'Enter the column based on the character: '
    len_col equ $ - msg_enter_col
    msg_notvalid db 'location is not valid. ',0x0a,0xD
    len_not_valid equ $-msg_notvalid
    write_msg db 'Now Edit: ',0x0a,0xD
    len_write equ $ - write_msg
    msg_editfinish db 'Edit Finished. ',0x0a,0xD
    len_editfinish equ $ - msg_editfinish
    msg_search_input db 'Enter Search Input: '
    len_search_input equ $-msg_search_input
    msg_occure_index db 'Find index: '
    len_occure_index equ $-msg_occure_index
    msg_ender_index db 'Enter index: '
    len_enter_index equ $-msg_ender_index

    newl db 0xA,0xD          ;newline
    newlen equ $ - newl


    strlen dd 0
    
    charcounter dq 0
    linecounter dq 0
    wordcounter dq 0
    
    zero equ byte'0'
    plus equ byte'+'
    minus equ byte'-'
    
    space db 32
    tab db 9
    nlchar db 10
    backspace db 8
    delete db 16

    isapend db 0
    
    lentowrite dd 0
    ;address db '/home/sobhan/Desktop/asd.txt ',0
    selen dd 0
    
    indexgo dd 0
            
section .bss
    address resb 150
    len_address equ $-address
    
    temptxtfile resb 10000000
    len_temptxt equ $ - temptxtfile
    
    search_inp resb 100
    len_search_ip equ $-search_inp
    
    get_index resb 100
    len_get_index equ $-get_index
 
;bfordebug====    
    op resb 10
    len_op equ $-op
   
    fd_in  resb 10
    
    txtfile resb 10000000
    len_txt equ $ - txtfile
    
    end_goto resb 10
    len_end_goto equ $-end_goto
    
    line_nom resb 10
    len_line_nom equ $ - line_nom

    col_no resb 10
    len_col_no equ $ - col_no
    
    rsi_movement resb 10
    len_rsi_movement equ $ - rsi_movement
    
    location resb 10
    
    backspace_count resb 10
    len_backspace_count equ $ - backspace_count
    
    delete_count resb 10
    len_delete_count equ $ - delete_count
    
    bsnum resb 10
    dnum resb 10
    
    stoi_input resb 100
    len_stoi_input equ $-stoi_input
    linetogo resb 100
    len_linetogo equ $-linetogo
    coltogo resb 100
    len_coltogo equ $-coltogo
    
        
    temp resb 10000000
    len_temp equ $ - temp
            
    input resb 10000000
    len_input equ $ - input
    
                
    tail resb 100
    head resb 100
    head_len equ $-head

;    address resb 150
;    len_address equ $ - address
 
                                            
section .text
global _start
_start:
    mov rbp, rsp; for correct debugging
    mov ebp, esp; for correct debugging

menu:        
    print_string msg_menu, len_menu
h1:
    read_string op, len_op
    check_operator op

efile:
    call loadfile
    call goto               ; now rsi is pointing to the location
     

    ;save "from location to end" to temp
    cmp byte[isapend], 0
    jne  getinput
    xor rdi, rdi
    mov rdi, temp
lpsave:
    cmp byte [rsi+1], 0
    je  getinput
    xor rdx, rdx
    mov dl, byte[rsi+1]
    mov byte[rdi], dl
    inc rsi
    inc rdi
    jmp lpsave

getinput: ;location and rsi movement
    print_string write_msg, len_write
    read_string input, len_input
    ;remove the line feed
    dec eax
    xor rdi, rdi
    mov edi, input
    add edi, eax
    mov byte[edi], 0
        
    xor r13, r13
    mov rdi, input
bsanalys:
    mov bl, [backspace]
    cmp byte[rdi],  bl
    je  backspacecounter
    mov [bsnum], r13
    xor r13, r13
danalys:
    mov bl, [delete]
    cmp byte [rdi], bl
    je  deletecounter
    mov [dnum], r13
    xor r13, r13
    mov rsi, txtfile
    add rsi, [rsi_movement]
    mov rdi, input
    sub rsi, [bsnum]
    add rdi, [dnum]
    lpinp:                    ;add input to the location
        xor rdx, rdx
        mov dl, [rdi]
        mov [rsi], dl
        inc rdi
        inc rsi
        cmp byte[rdi], 0
        jne lpinp
    mov rdi, temp              ;append temp to the end 
    add rdi, [dnum]        
    lptemp:
        xor rdx, rdx
        mov dl, [rdi]
        mov [rsi], dl
        inc rsi
        inc rdi
        cmp byte[rdi], 0
        jne lptemp
    jmp updatefile
backspacecounter:
    inc r13
    inc rdi
    jmp bsanalys
deletecounter:
    inc r13
    inc rdi
    jmp danalys


updatefile:
    xor rsi, rsi
    mov esi,txtfile
    call string_get_len
    mov [lentowrite], eax

    mov eax , 19
    mov ebx , [fd_in]
    mov ecx , 0
    mov edx , 0
    int 0x80    
 
             
    ; write into the file
    mov  eax, 4
    mov  ebx, [fd_in]
    mov  ecx, txtfile
    mov  edx, [lentowrite]
    int  0x80
 
    print_string msg_editfinish, len_editfinish
    
    mov eax, 6
    mov ebx, [fd_in]
    int  0x80    
    
    mov byte[isapend], 0
    jmp menu
nfile:
    print_string msg_enter_address, len_enter
    read_string address, len_address
    dec eax
    xor rdi, rdi
    mov edi, address
    add edi, eax
    mov byte[edi], 0

    
    ;create the file
    mov  eax, 8
    mov  ebx, address
    mov  ecx, 0o777        ;read, write and execute by all
    int  80h              ;call kernel
    
    mov [fd_in], eax
    
    ; close the file
    mov eax, 6
    mov ebx, [fd_in]
    int 80h
    
    call clear_address
    jmp menu
    
shofile:
    call loadfile
    call clear_address
    
    mov eax, 6
    mov ebx, [fd_in]
    int 80h

            
    jmp menu
    
search:
    call search_func
    
    mov eax, 6
    mov ebx, [fd_in]
    int 80h

    jmp menu

replace:        
    call search_func
    print_string msg_ender_index, len_enter_index
    read_string get_index, len_get_index
    
    ;make int index
    mov rsi, get_index
    call stoi
    mov qword[rsi_movement], 0                         ; to be roei sar of the index
    mov dword[rsi_movement], eax                      ;now we have linetogo integer
f1:
    call clear_get_index
    xor rsi, rsi
    
    
    mov rsi, txtfile
    xor rbx, rbx
    mov ebx, [selen]
    add eax, ebx
f2:
    ;save "from location to end" to temp
    cmp byte[isapend], 0
    jne  getinput1
    xor rdi, rdi
    mov rdi, temp
lpsave1:
    cmp byte [rsi+rax], 0
    je  getinput1
    xor rdx, rdx
    mov dl, byte[rsi+rax]
    mov byte[rdi], dl
    inc rsi
    inc rdi
    jmp lpsave1

getinput1: ;location and rsi movement
    print_string write_msg, len_write
    read_string input, len_input
    ;remove the line feed
    dec eax
    xor rdi, rdi
    mov edi, input
    add edi, eax
    mov byte[edi], 0
        
    xor r13, r13
    mov rdi, input
bsanalys1:
    mov bl, [backspace]
    cmp byte[rdi],  bl
    je  backspacecounter1
    mov [bsnum], r13
    xor r13, r13
danalys1:
    mov bl, [delete]
    cmp byte [rdi], bl
    je  deletecounter1
    mov [dnum], r13
    xor r13, r13
    mov rsi, txtfile
    add rsi, [rsi_movement]
    mov qword[rsi_movement], 0
    mov rdi, input
    sub rsi, [bsnum]
    add rdi, [dnum]
    lpinp1:                    ;add input to the location
        xor rdx, rdx
        mov dl, [rdi]
        mov [rsi], dl
        inc rdi
        inc rsi
        cmp byte[rdi], 0
        jne lpinp1
    mov rdi, temp              ;append temp to the end 
    add rdi, [dnum]        
    lptemp1:
        xor rdx, rdx
        mov dl, [rdi]
        mov [rsi], dl
        inc rsi
        inc rdi
        cmp byte[rdi], 0
        jne lptemp1
    jmp updatefile1
backspacecounter1:
    inc r13
    inc rdi
    jmp bsanalys1
deletecounter1:
    inc r13
    inc rdi
    jmp danalys1


updatefile1:
    xor rsi, rsi
    mov esi,txtfile
    call string_get_len
    mov [lentowrite], eax

    mov eax , 19
    mov ebx , [fd_in]
    mov ecx , 0
    mov edx , 0
    int 0x80    
 
             
    ; write into the file
    mov  eax, 4
    mov  ebx, [fd_in]
    mov  ecx, txtfile
    mov  edx, [lentowrite]
    int  0x80
 
    print_string msg_editfinish, len_editfinish
    
    mov eax, 6
    mov ebx, [fd_in]
    int  0x80    
    
    mov byte[isapend], 0
    jmp menu
    
exit:
    exit_code

;functions======================================================

;loadfile======================================================================
loadfile:
    ;returns text file in "txtfile"
    ;print file and stats  
    print_string msg_enter_address, len_enter
    read_string address, len_address
    ;remove the line feed
    dec eax
    xor rdi, rdi
    mov edi, address
    add edi, eax
    mov byte[edi], 0
    ;load file
    ;open txt file
    mov ebx, address ; const char *filename
    mov eax, 5  
    mov ecx, 2
    int 80h   
    
    mov [fd_in], eax
    ;read txt from file
    mov eax, 3  
    mov ebx, [fd_in]
    mov ecx, txtfile 
    mov edx, len_txt    
    int 80h     
   
    xor rsi, rsi
    mov rsi, txtfile
    ;get stat
    call get_stat
    ;print file
    print_string txtfile, [charcounter]
    print_string newl, newlen    
    ;print stat
    print_string msg_linenum, len_linenum
    ;call itos then print linecounter
    mov rax, [linecounter]
    mov rsi, tail
    call itos
    xor rsi, rsi
    
    mov rax,4
    mov rbx,1
    mov rcx, head
    mov rdx, r9
    int 80h
    call clear_head
    print_string newl, newlen    
    print_string msg_wordnum, len_wordnum
    ;call itos then print wordcounter
    mov rax, [wordcounter]
    mov rsi, tail
    call itos
    xor rsi, rsi

        
    mov rax,4
    mov rbx,1
    mov rcx, head
    mov rdx, r9
    int 80h
    call clear_head
    print_string newl, newlen    
    print_string msg_charnum, len_charnum
    ;call itos then print charcounter
    mov rax, [charcounter]
    
    mov rsi, tail
    call itos
    xor rsi, rsi
    
    mov rax,4
    mov rbx,1
    mov rcx, head
    mov rdx, r9
    int 80h
    call clear_head
    print_string newl, newlen
    ret    
    
;goto==========================================================================    
goto:
    ;will retrun rsi as a location    
    print_string msg_end_or_goto, len_end_or_goto
    read_string end_goto, 2

    
    print_string newl, newlen
    cmp byte[end_goto], 'e'
    je gotoend
    print_string msg_enter_line, len_line
    read_string line_nom, len_line_nom
    print_string newl, newlen
    print_string msg_enter_col, len_col
    read_string col_no, len_col_no
    ;get integer line to go
    mov rsi, line_nom
    call stoi
    mov [linetogo], eax                      ;now we have linetogo integer
    call clear_line_nom
    xor rsi, rsi
    ;get integer col to go
    mov rsi, col_no
    call stoi
    mov [coltogo], eax                       ;now we have coltogo integer
    call clear_col_no
    xor rsi, rsi

    ;now move rsi to the location
    xor edx, edx
    mov rsi, txtfile                         ;it is better to push rsi before goto and pop it here
    mov r13, rsi ; to get the movment
    xor r15,r15
    mov ecx, [linetogo]
    dec ecx
linedetect:
    dec ecx
    cmp ecx, -1
    je  charfind
notline:    
    mov dl, byte [rsi]
    cmp dl, 0
    je  notvalid
    inc rsi
    inc r15
    cmp dl, [nlchar]
    je  linedetect
    jmp notline
charfind:
    mov ecx, [coltogo]
    dec ecx
lpchar:
    cmp ecx, 0 
    je  endgoto
    mov dl, byte [rsi]   ;at first rsi is at the start of line
    cmp dl, 0
    je  notvalid         ;end of file had been took cared by "e"
    cmp dl, [nlchar]
    je  notvalid
    inc rsi
    dec ecx
    inc r15
    jmp lpchar

notvalid:
    print_string msg_notvalid, len_not_valid
    jmp menu

gotoend:
    mov byte[isapend], 1
    mov rsi, txtfile
    add rsi, [charcounter]
    mov r15, [charcounter]
    inc rsi
    sub rsi, 8
    jmp endgoto

endgoto:
    mov dl, [rsi]
    cmp dl ,[nlchar]
    je notvalid
    mov [rsi_movement], r15
    ret
    
;statis====================================================================
get_stat:
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx
    xor r10, r10    ;reserve for charcounter   
    xor r11, r11    ;reserve for wordcounter
    xor r12, r12    ;reserve for linecounter
    xor rdi, rdi
    xor r9, r9      ;as a first of line flag
    mov r9, 1
lp1:    
    mov al, byte[rsi]
    cmp al, 0
    je  fin
    inc rsi
    inc r10
    cmp al, [space]
    je  check_first_of_line_word
    cmp al, [tab]
    je  check_first_of_line_word
    cmp al, [nlchar]
    je  line_inc
    xor r9, r9      ;for first of file flag
    jmp lp1
fin:
    cmp r10,0
    je next
    inc r12
    cmp byte[rsi-1], 32
    jna next
    inc r11
    next:
    mov [charcounter], r10
    mov [wordcounter], r11
    mov [linecounter], r12
    xor r10, r10    ;reserve for charcounter   
    xor r11, r11    ;reserve for wordcounter
    xor r12, r12    ;reserve for linecounter

    ret 
    
check_first_of_line_word:
    cmp r9, 0
    jne lp1
    mov bl, byte[rsi-2]
    cmp bl, [nlchar]
    je lp1
    cmp bl, [space]
    je lp1
    cmp bl, [tab]
    je lp1
    mov bl, byte[rsi]
    cmp bl, [nlchar]
    je lp1
wordin:
    inc r11
    jmp lp1

line_inc:
    mov bl, byte[rsi-2]
    cmp bl, byte[space]
    jbe notword     
    inc r11
notword:
    inc r9
    inc r12
    jmp lp1

;stoi================================================================================
stoi:
    ;rsi is pointing to the start of "input" string
    ;eax has the optput integer
    ;r15b is reserved for sign 
    ;r12 to keep the length
    xor rax, rax
    xor ecx, ecx
    xor r12, r12
    mov ecx, 10
    xor r15b, r15b
    cmp byte[rsi], plus
    je sign
    cmp byte[rsi], minus
    jne for
    sign:
        mov r15b, [rsi]
        inc rsi
        inc r12
    for:
        xor edx, edx
        xor ebx, ebx
        mov bl, [rsi]
        sub bl, zero
        mul ecx
        add eax, ebx
        inc rsi
        inc r12
        cmp byte[rsi+1], 0     
        jnz for
    cmp r15b, minus
    jne end
    neg eax
    end:
    ret

;itos=====================================================================
itos:
    ;create a revesre string of input int which is in eax
    ;head is pointing to the start of the String
    ;r9 will keep the length    
    xor rdi, rdi                
    xor rdx, rdx
    mov rdi, head
    xor r8, r8
    cmp eax, 0
    jnl while
    neg eax
    mov byte[rdi], minus
    inc rdi
    inc r8        
    while:
        inc r8b
        xor rdx, rdx
        mov ecx, 10    
        div ecx
        xor rbx, rbx
        mov ebx, eax
        add dl, '0'
        mov [rsi], dl            
        inc rsi
        cmp eax, 0
        jz div_zero
        xor rax, rax
        mov eax, ebx
        jmp while 
    div_zero:               ;will reverse the string to output
        mov r9,r8           ;r9 will keep the length
        inc r9
        dec rsi
        l1:
            xor rcx,rcx
            mov cl, [rsi]
            mov [rdi], cl
            inc rdi
            dec rsi
            dec r8
            cmp r8, 0
            jg  l1
    ret


clear_address:
    mov rsi, address
    mov ecx, len_address
    lpc:
        mov [rsi], byte 0
        inc rsi
        loop lpc
    ret                

clear_head:
            mov rsi, head
            mov ecx, head_len
            lpch:
                mov [rsi], byte 0
                inc rsi
                loop lpch
            ret                                                                   
clear_col_no:
            mov rsi, col_no
            mov ecx, len_col_no
            lpcol:
                mov [rsi], byte 0
                inc rsi
                loop lpcol
            ret  
clear_line_nom:
            mov rsi, line_nom
            mov ecx, len_line_nom
            lpclin:
                mov [rsi], byte 0
                inc rsi
                loop lpclin
            ret  


string_get_len:
    mov ecx , 0
    lenght_loop:
        cmp byte[esi] , 0
        je after_lenght_loop
        inc ecx
        inc esi
        jmp lenght_loop
    
    after_lenght_loop:
    xor rax, rax
    mov eax, ecx
    ret

search_func:
    call loadfile
    call clear_address
    xor rsi, rsi
    mov esi, txtfile
    call string_get_len
    mov [lentowrite], eax
    ;optional GOTO call
    
    print_string msg_search_input , len_search_input
    read_string  search_inp , len_search_ip
    
    dec eax
    mov [selen], eax          ;we got len search_inp in r10
    mov r14d, 0              ;to save the index    
    mov rsi, txtfile
    mov rdi, search_inp
loop_search:
    cmp byte[rsi], 0
    je  done_search
    xor rbx, rbx
    mov bl, byte[rsi]
    xor rdx, rdx 
    mov dl, byte[rdi]
    cmp bl, dl
    jne nxtround
    mov eax , [selen]
    call is_equal
    cmp rbx, 1
    je equal
    
    nxtround:
    inc rsi
    inc r14d
    jmp loop_search
    
    equal:
    push rsi
    push rdi
    print_string  msg_occure_index, len_occure_index
    xor rax, rax
    mov eax, r14d
    mov rsi, tail
    call itos
    xor rsi, rsi
    
    mov rax, 4
    mov rbx, 1
    mov rcx, head
    mov rdx, r9
    int 80h
    call clear_head
    
    print_string newl, newlen
    
    pop rdi
    pop rsi
    
    jmp nxtround
    
    done_search:
    ret

is_equal:
    ;esi = first string address
    ;edi = second string address
    ;eax = length
    mov ecx , 0
    loopEquals:
        cmp ecx , eax
        je equal1
        xor rbx , rbx
        xor rdx , rdx
        mov bl , byte[esi + ecx]
        mov dl , byte[edi + ecx]
        inc ecx
        cmp bl , dl
        jne notEqual
        jmp loopEquals
    
    
    notEqual:
    xor ebx , ebx
    mov bl , 0
    ret
    equal1:
    xor ebx , ebx
    mov bl , 1
    ret

clear_get_index:
        mov rsi, get_index
        mov ecx, len_get_index
        lpclin1:
            mov [rsi], byte 0
            inc rsi
            loop lpclin1
        ret  
                                                                                        