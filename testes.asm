.model small
.code
;description
main PROC
    mov ah,08
    int 21h

    mov ah,4ch
    int 21h
main ENDP
end main