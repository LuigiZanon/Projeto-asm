.model small
.stack 100h
.data
    alunos db 25 dup(?)

    menu    db 'Diga o que vc gostaria de fazer?'
            db 10,13,'[1]-cadastrar um aluno'
.code
main PROC
    mov ax,@data
    mov ds,ax



    mov ah,4ch
    int 21h
main ENDP


end main