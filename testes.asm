.model small
.stack 100h
.data
    vetor   DB 'teste$'
    vetor2  db 5 dup(?)

.code
main PROC
    mov ax,@data
    mov ds,ax
    mov es,ax

    xor si,si
    mov ah,01
    mov cx,5

volta:
    int 21h
    mov vetor2[si],al
    inc si
    loop volta

    mov ah,02
    mov cx,5

    CLD
    lea si,vetor
    lea di,vetor2

    repe cmpsb
    je deu_certo

    mov dl,'X'
    int 21h
    jmp fim

deu_certo:
    mov dl,'Y'
    int 21h

fim:
    mov ah,4ch
    int 21h
main ENDP
end main