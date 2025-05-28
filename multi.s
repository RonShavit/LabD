section .rodata
    multi_print_fmt db '%02hhx',10,0 ; must add linefeed duo to flushing issues
    number_debug_format db 'only: %X',10,0
    dnumber_format db '1st: %d | 2nd: %d',10,0
    mask dw 1101001000101101b
    multi_print_format db 'multi %c:',10,'_______',10,0
    seperator_foramt db "enter input for multi number %c",10,0




section .data
    state dw 0xa5
    temp_struct dd 0
    in_struct dd 0
    in_struct_2 dd 0
    temp_buffer dd 0
    x_struct: dw 6
    x_number: db 0x70, 0x71, 0x72, 0x73, 0x74, 0x75,
    y_struct: dw 2
    y_number: db 0xff, 1
    first_current dw 0
    temp_num dw 0
    mode db 0 ; 0=>use x|y, 1=>call get_multi, 2=>call PRmulti
    
    


section .text
    global main
    extern printf
    extern malloc
    extern free
    extern stdin
    extern fgets

    PRmulti:
    push ebp
    mov ebp, esp

    .gen_len:
        call rand_num
        xor ah, ah
        cmp al, 0
        jz .gen_len
    ;;ax now contains a non-zero pr-gen num
    add ax, 2
    mov bx, ax
    pushad

    push eax
    call malloc
    add esp, 4
    mov [temp_struct], eax
    popad
    sub bx, 2
    mov esi, [temp_struct]
    
    mov [esi], bx

    add esi, 2

    .add_num_loop:
        cmp bx, 0
        jz .finish
        pushad
        call rand_num
        mov [temp_num], ax
        popad
        mov ax, [temp_num]
        cmp ax, 0
        jz .add_num_loop

        mov [esi], al
        add esi, 1
        dec bx
        jmp .add_num_loop

        
    
    .finish:
    mov eax, [temp_struct]


    pop ebp
    ret

    rand_num:
    push ebp
    mov ebp, esp

    xor edx, edx

    xor ebx, ebx
    xor eax, eax
    mov bx, [state]
    mov ax, [mask]
    and ax, bx
    jpe .par_is_zero
    mov dx, 1
    shl dx, 15
    .par_is_zero:
    mov bx, [state]
    shr bx, 1
    or bx, dx
    mov [state], bx
    
    xor eax, eax
    mov ax, bx


    .finish:
    pop ebp
    ret


    get_min_max:
    push ebp
    mov ebp, esp

    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    
    mov eax, [esp+8] ;; eax = first_multi
    mov cx, [eax]  ;; cx = first_multi.len


    mov ebx, [esp+12]    ;;ebx = sec_multi
    mov dx, [ebx]   ;;dx = sec_multi.len

    cmp cx, dx
    jge .first_larger

    xor esi, esi
    mov esi, eax
    mov eax, ebx
    mov ebx, esi

    .first_larger:


    
    pop ebp
    ret



    add_multi:
    push ebp
    mov ebp, esp

    xor eax, eax
    xor ebx, ebx
    
    mov ecx, [esp+8] ;; ecx = first_multi
    mov ax, [ecx]  ;; ax = first_multi.len


    mov edx, [esp+12]    ;;edx = sec_multi
    mov bx, [edx]   ;;bx = sec_multi.len


    cmp eax, ebx
    jg .first_bigger

    xor edi, edi

    mov edi, ecx
    mov ecx, edx
    mov edx, edi

    xor edi, edi

    mov edi, eax
    xor eax, eax
    mov eax, ebx
    xor ebx, ebx
    mov ebx, edi

    jmp .first_bigger

    .first_bigger:
    
    xor edi, edi
    mov edi, eax
    add edi, 2
    xor esi, esi
    mov esi, eax

    pushad
    push edi
    call malloc
    add esp, 4


    mov [temp_struct], eax
    popad
    mov eax, esi

    mov esi, [temp_struct]
    mov [esi], ax
    add esi,2 ;; esi = ret_multi.number
    add ecx, 2 ;; ecx = 1st_multi.number
    xor edi, edi
    mov edi, edx; edi = 2nd_multi.number
    add edi, 2
    xor edx, edx;


    ;;ret_struct[i] = cy+1st_multi[i]+2nd_multi[i]
    .add_loop:
    cmp bx, 0
    jz .single_loop



    xor dl, dl
    mov dl, [ecx]
    mov [first_current], ecx
    xor ecx, ecx
    mov cl, dl
    xor dl, dl
    mov dl, [edi]
    add dl, dh
    xor dh, dh
    add dx, cx
    mov [esi], dl

    
    xor edx, edx
    mov dl, [esi]


    inc esi
    inc edi
    mov ecx, [first_current]
    inc ecx



    dec bx
    dec ax
    jmp .add_loop



    .single_loop:
    cmp ax, 0
    jz .finish
    
    xor edx, edx
    mov dl, [ecx]
    mov [esi], dl

    inc ecx
    inc esi


    dec ax
    jmp .single_loop






    
    .finish:
    xor eax, eax
    mov eax, [temp_struct]

    pop ebp
    ret



    get_multi:
    push ebp
    mov ebp, esp

    xor ebx, ebx
    mov ebx, 602
    push ebx
    call malloc ;eax = &buffer (malloc(600))

    add esp, 4
    mov [temp_buffer], eax

    push dword [stdin]
    mov ebx, 600
    push ebx
    push eax
    call fgets
    add esp, 12
    ;; eax now contains the string read from stdin

    xor edi, edi
    mov ebx, eax
    ;; get length of str read into edi
    .get_len:

    mov cl, [ebx]
    cmp cl, 0
    jz .got_len
    cmp cl, 10
    jz .got_len
    inc edi
    inc ebx
    jmp .get_len

    ;; allocate [edi]+2 bytes for the new struct
    .got_len:
    xor edx, edx
    inc edx
    and edx, edi
    shr edi, 1
    add edi, edx

    mov ebx, eax
    xor ecx, ecx
    mov ecx, 2
    add ecx, edi
    mov ebx, eax

    pushad
    push ecx
    call malloc ;;allocates memoty atop existing buffer TODO : fix
    mov [temp_struct], eax
    add esp, 4
    popad
    mov ebx, [temp_buffer]

    mov eax, [temp_struct]
    mov [eax], edi ;;mov [edi] into struct.len

    mov ecx, [temp_struct]    ;ecx points to struct
                    ;ebx point to buffer
    add ecx, 2      ; ecx points to struct.number

    .get_byte:
        xor edx, edx
        xor edi, edi
        mov dx, [ebx]
        cmp dl, 0
        jz .finish
        cmp dl, 10
        jz .finish

        cmp dl, '0'
        jl .finish
        cmp dl, '9'
        jle .number1
        jmp .letter1

    .number1:
        sub dx, 0x30
        jmp .char2
    .letter1:
        sub dx, 0x57
        jmp .char2

    .char2:
        cmp dh, 0
        jz .single
        cmp dh, 10
        jz .single

        cmp dh, '0'
        jl .finish
        cmp dh, '9'
        jle .number2
        jmp .letter2

    .number2:
        sub dx, 0x3000
        jmp .insert
    .letter2:
        sub dx, 0x5700
        jmp .insert
    


    .single:
        xor dh, dh
        mov dh, dl
        xor dl,dl
        jmp .insert

    .insert:
        shl dl, 4
        add dl, dh
        mov [ecx], dl
        add ecx, 1





    add ebx, 2
    jmp .get_byte


    
    
    



    .finish:

    pop ebp
    ret
    

    print_multi:
        push ebp
        mov ebp, esp

        mov edi, [esp+8]
        xor ecx, ecx
        mov cx,  [edi]

        dec ecx
        mov edx, edi
        add edx, 2
        add edx, ecx

        .loop:
            mov ebx, [edx]

            pushad
            push ebx
            push multi_print_fmt
            call printf
            add esp, 8
            popad
            
            cmp ecx,0
            jz .end
            dec ecx
            dec edx
            jmp .loop


        .end:
        pop ebp
        ret

    main:

        mov eax, [esp+4] ;edi = argc
        cmp eax, 2
        jl .no_flag

        mov eax, [esp+8]; edi = arg[0]
        xor edx, edx
        mov edx, [eax+4]
        mov bl, byte [edx]
        cmp bl, '-'
        jz .pot_flag
        jmp .no_flag

        .pot_flag:
            mov bl, byte [edx+1]
            cmp bl, 'i'
            jz .input
            cmp bl, 'r'
            jz .random
            jmp .no_flag

        .input:

            mov eax, '1'
            push eax
            push seperator_foramt
            call printf
            add esp , 8

            call get_multi
            mov [in_struct], eax

            mov eax, '2'
            push eax
            push seperator_foramt
            call printf
            add esp , 8

            call get_multi
            mov [in_struct_2], eax


            mov eax, '1'
            push eax
            push multi_print_format
            call printf
            add esp ,8

            mov eax, [in_struct]
            push eax
            call print_multi
            add esp, 4

            mov eax, '2'
            push eax
            push multi_print_format
            call printf
            add esp ,8

            mov eax, [in_struct_2]
            push eax
            call print_multi
            add esp, 4

            mov ebx, 's'
            push ebx
            push multi_print_format
            call printf
            add esp ,8


            mov eax, [in_struct]
            push eax
            mov eax, [in_struct_2]
            push eax
            call add_multi
            add esp,8 

            push eax
            call print_multi
            add esp, 4
            jmp exit.finish

        .random:
            mov eax, '1'
            push eax
            push multi_print_format
            call printf
            add esp , 8

            call PRmulti
            mov [in_struct], eax
            push eax
            call print_multi
            add esp,4


            mov eax, '2'
            push eax
            push multi_print_format
            call printf
            add esp , 8

            call PRmulti
            mov [in_struct_2], eax
            push eax
            call print_multi
            add esp,4

            mov eax, 's'
            push eax
            push multi_print_format
            call printf
            add esp , 8

            .stp:
            mov eax, [in_struct]
            push eax
            mov eax, [in_struct_2]
            push eax
            call add_multi
            add esp, 8

            mov [in_struct], eax


            mov eax, [in_struct]
            push eax
            call print_multi
            add esp, 4
            





            jmp exit.finish

        


        .no_flag:
            mov eax, 'x'
            push eax
            push multi_print_format
            call printf
            add esp ,8
            push x_struct
            call print_multi
            add esp, 4

            mov eax, 'y'
            push eax
            push multi_print_format
            call printf
            add esp ,8
            push y_struct
            call print_multi
            add esp, 4

        .addm:



            mov ebx, 's'
            push ebx
            push multi_print_format
            call printf
            add esp ,8


            mov eax, x_struct
            push eax
            mov eax, y_struct
            push eax
            call add_multi
            add esp,8 

            push eax
            call print_multi
            add esp, 4

            mov eax, 0


            jmp exit.finish


    
    exit:
        .finish:
        mov eax, 1
        mov ebx, 0
        int 0x80