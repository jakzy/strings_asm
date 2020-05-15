.model medium
public  inputline,input,readfile,output,writefile,menu,algorithm
extrn   start:far
extrn   reps:byte
extrn   array:byte
extrn   n:word
    .code
    
inputline   proc
    locals @@
@@buffer    equ [bp+6]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    mov ah,3fh
    xor bx,bx
    mov cx,80
    mov dx,@@buffer
    int 21h
    jc @@ex
    cmp ax,80
    jne @@m
    stc
    jmp short @@ex
@@m:    mov di,@@buffer
    dec ax
    dec ax
    add di,ax
    xor al,al
    stosb
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
    endp
    
input   proc
    locals @@
@@buffer    equ [bp+6]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    xor bx,bx
    mov cx,4095
    mov dx,@@buffer
@@m1:   mov ah,3fh
    int 21h
    jc @@ex
    cmp ax,2
    je @@m2
    sub cx,ax
    jcxz @@m2
    add dx,ax
    jmp @@m1
@@m2:   mov di,@@buffer
    add di,4095
    sub di,cx
    xor al,al
    stosb
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
    endp
    
output  proc
    locals @@
@@buffer    equ [bp+6]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    mov di,@@buffer
    xor al,al
    mov cx,0ffffh
    repne scasb
    neg cx
    dec cx
    dec cx
    jcxz @@ex
    cmp cx,4095
    jbe @@m
    mov cx,4095
@@m:    mov ah,40h
    xor bx,bx
    inc bx
    mov dx,@@buffer
    int 21h
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
    endp
    
readfile    proc
    locals @@
@@buffer    equ [bp+6]
@@filnam    equ [bp+8]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    mov ax,3d00h
    mov dx,@@filnam
    int 21h
    jc @@ex
    mov bx,ax
    mov cx,4095
    mov dx,@@buffer
@@m1:   mov ah,3fh
    int 21h
    jc @@er
    or ax,ax
    je @@m2
    sub cx,ax
    jcxz @@m2
    add dx,ax
    jmp @@m1
@@m2:   mov di,@@buffer
    add di,4095
    sub di,cx
    xor al,al
    stosb
    mov ah,3eh
    int 21h
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
@@er:   mov ah,3eh
    int 21h
    stc
    jmp @@ex
    endp
    
writefile proc
    locals @@
@@filnam    equ [bp+8]
@@buffer    equ [bp+6]
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push di
    mov ah,3ch
    xor cx,cx
    mov dx,@@filnam
    int 21h
    jc @@ex
    mov bx,ax
    mov di,@@buffer
    xor al,al
    mov cx,0ffffh
    repne scasb
    neg cx
    dec cx
    dec cx
    jcxz @@ex
    cmp cx,4095
    jbe @@m
    mov cx,4095
@@m:    mov ah,40h
    mov dx,@@buffer
    int 21h
    jc @@er
    mov ah,3eh
    int 21h
@@ex:   pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
@@er:   mov ah,3eh
    int 21h
    stc
    jmp @@ex
    endp
    
menu    proc
    locals @@
@@ax        equ [bp-82]
@@buffer    equ [bp-80]
@@items equ [bp+6]
    push bp
    mov bp,sp
    sub sp,80
    push ax
@@m:    push @@items
    call output
    pop ax
    jc @@ex
    push ds
    push es
    push ss
    push ss
    pop ds
    pop es
    mov ax,bp
    sub ax,80
    push ax
    call inputline
    pop ax
    pop es
    pop ds
    jc @@ex
    mov al,@@buffer
    cbw
    sub ax,'0'
    cmp ax,0
    jl @@m
    cmp ax,@@ax
    jg @@m
    clc
@@ex:   mov sp,bp
    pop bp
    ret
    endp

algorithm   proc
    locals @@
@@ibuf  equ [bp+6] 
@@obuf  equ [bp+8] 
    push bp   ; 1
    mov bp,sp
    push ax   ; 2
    push bx   ; 3
    push cx   ; 4
    push si   ; 5
    push di   ; 6
    mov bx, @@obuf
    push bx   ; 7
    mov si, @@ibuf
    lea di,reps
;MAIN PART
@@m1: 
    cmp byte ptr [si],13  
    jne @@m31
    jmp near ptr @@m3
    @@m31:    
    xor ax,ax
    lodsb
;IS THAT A LETTER?
    mov dh, 041h
    cmp al,dh  
    jnge @@m1    
    mov dh, 07ah
    cmp al,dh  
    jg @@m1
    mov dh, 05ah
    cmp al, dh  
    jle @@m5      ;we met a letter in a higher register
    mov dh, 061h
    cmp al, dh  
    jge @@m4      ;we met a letter in a lower register
    jmp @@m1
    @@m5: add al, 020h    ;change a letter to a lower register 
;ANALYZE THE LETTER WE GOT   
@@m4: 
    push di  ; 8
    mov cx,di
    lea di, reps  
    sub cx, offset reps  ; 
    cmp cx, 0
    je @@m7
    repne scasb
    pop di   ; 7
    je @@m6  
    
@@m7: stosb ;CX == 0, we haven't met the letter, should add it to the check-string
    ;also we should add a counter of met symbols for this letter
    push si  ; 8
    mov si, n
    mov byte ptr [array + si], 0
    pop si   ;7
    inc n
    jmp @@m1
@@m6: 
    push di ;saved current adress of a last met symbol  ; 8
    push si
    neg cx ; as cx returns unchecked letters, curr index  ; 9
    dec cx ; si = n-cx-1
    add cx, n
    mov si, cx
@@sec:
    inc byte ptr[array + si] ;count met letter
    cmp [array + si], 1 ; if thats the second rep of this letter, we should add 2 to count both
    je @@sec
    pop si  ; 8
    pop di ;return to array of letters  ; 7
    jmp @@m1
 @@m3: 

    push si  ; 8
    xor bx,bx
    mov cx, n
    lea di, array
    xor ax,ax
    mov si, 0
 @@cycleA:
    xor ax,ax
    mov al, [array + si]
    mov array[si], 0
    mov reps[si], '$'
    add bx, ax
    inc si
    loop @@cycleA
    pop si   ; 7
    add sp, 2
    pop di  ; 6
    push si  ; 7
    mov ax, bx

    xor cx,cx   
    mov ax,bx  
    mov bx,10
div10:  
    xor dx,dx
    div bx
    push dx
    inc cx
    or ax,0
    jnz div10
 
    mov dx,cx   ;
    xor bx,bx   
nxt:    
    pop ax
    add al,30h
    stosb
    inc bx
    loop nxt

   
    mov al, 13
    stosb
    mov al, 10
    stosb
    pop si  ; 6
    push di  ; 7
    add si, 4
    cmp byte ptr [si], 0
    je @@ex
    dec si
    dec si
    xor bx, bx
    lea di, reps
    jmp @@m1
@@ex: pop dx  ;6
    pop di  ; 5
    pop si  ; 4
    pop cx  ; 3
    pop bx  ; 2
    pop ax  ; 1
    pop bp  ; 0
    ret
    endp
    
    end start