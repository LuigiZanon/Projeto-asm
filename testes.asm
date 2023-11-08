.model small
.data
    nome    db 'ola tudo bem$,sad'  ;16
            db 'oi, tudo bem$dasd'  ;16

    cad dw 2

    pula_linha  db 10,13,'$'
.code
;description
main PROC
    mov ax,@data
    mov ds,ax

    mov cx,cad

    mov ah,09
    lea dx, nome
    for:
        int 21h
        call pulalinha
        add dx,17
    loop for


    mov ah,4ch
    int 21h
main ENDP
pulalinha PROC
;procedimento que pula para linha de baixo juntamente com o cr

    push ax
    push dx

    mov ah,09
    lea dx, pula_linha          ;10,13 (LF,CR)
    int 21h

    pop dx
    pop ax

    ret
    
pulalinha ENDP
end main