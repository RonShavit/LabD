section .rodata
    cText db "argc: %d", 10,0
    vText db "argv[%d]: %s",10,0

section .text
        global main
        extern printf
    _start:
    main:
        push ebp
        mov ebp, esp
        mov ecx, [esp+8]  ;ecx = argc
        pushad
        push ecx
        push cText
        call printf
        add esp, 8
        popad
        xor edi, edi ; edi = 0
        mov edx, [ebp+12]  ; edx = argv[0]
        .print_loop:
        
        cmp edi, ecx
        jz exit
        pushad
        push dword [edx]
        push dword edi
        push dword vText
        call printf
        add esp, 12
        popad
        add edx, 4
        add edi, 1

        


        jmp .print_loop


    
    exit:
        mov eax, 1
        mov ebx, 0
        int 0x80