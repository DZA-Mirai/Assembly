        section .text
        global  ellipsecut
ellipsecut:
        ; ellipse equation b^2 * (x - a)^2 + a^2 * (y - b)^2 <= a^2 * b^2
        push    ebp
        mov     ebp, esp
        push    esi
        push    edi
        push    ebx
        
        mov     ecx, [ebp + 8]          ; img pointer
        mov     esi, [ebp + 12]         ; width (x) a
        mov     ebx, [ebp + 16]         ; height (y) b
        sar     esi, 1                  ; a = width / 2
        sar     ebx, 1                  ; b = height / 2
        imul    ebx, ebx                ; b^2
        imul    esi, esi                ; a^2
        imul    esi, ebx                ; a^2 * b^2

        mov     ebx, [ebp + 16]         ; y 

right_part_eq:          ; a^2 * (y - b)^2
        mov     edx, [ebp + 12]         ; width
        sar     edx, 1                  ; a = width / 2
        imul    edx, edx                ; a^2
        push    ebx                     ; save current value of y 
        mov     edi, [ebp + 16]         ; height
        sar     edi, 1                  ; b = height / 2
        sub     ebx, edi                ; y - b
        imul    ebx, ebx                ; (y - b)^2
        imul    ebx, edx                ; a^2 * (y - b)^2
        mov     eax, [ebp + 12]         ; reset x to width
        
left_part_eq:             ; b^2 * (x - a)^2
        mov     edi, eax                ; di is the current x in the equation
        mov     edx, [ebp + 12]         ; width
        sar     edx, 1                  ; a = width / 2
        sub     edi, edx                ; x - a
        imul    edi, edi                ; (x - a)^2
        mov     edx, [ebp + 16]         ; height
        sar     edx, 1                  ; b = height / 2
        imul    edx, edx                ; b^2
        imul    edi, edx                ; b^2 * (x - a)^2
        add     edi, ebx                ; b^2 * (x - a)^2 + a^2 * (y - b)^2
        cmp     edi, esi                ; b^2 * (x - a)^2 + a^2 * (y - b)^2 <= a^2 * b^2
        jle     pass
        mov     edx, [ebp + 20]         ; Color
        mov     [ecx], dx
        shr     edx, 16
        mov     [ecx+2], dl
pass:
        add     ecx, 3
        dec     eax
        jnz     left_part_eq
height_check:
        pop     ebx                     ; restore current value of y
        dec     ebx
        jnz     right_part_eq

end:
        mov     eax, [ebp + 8]
        pop     ebx
        pop     edi
        pop     esi
        pop     ebp
        ret