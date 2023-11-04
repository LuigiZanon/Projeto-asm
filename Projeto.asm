.model small
.stack 100h
.data
    alunos  db 30 dup(?)
            db 30 dup(?)
            db 30 dup(?)
            db 30 dup(?)
            db 30 dup(?)

    notas_p1  db 5 dup(?)
    notas_p2  db 5 dup(?)
    notas_p3  db 5 dup(?)

    n_cad   dw 0

    medias  db 5 dup(?)

    menu    db 'Selecione a ação desejada:'
            db 10,13,'[1]- CADASTRAR um aluno'
            db 10,13,'[2]- EXCLUIR um aluno'
            db 10,13,'[3]- CORRIGIR uma nota'
            db 10,13,'[4]- GERAR planilha'
            db 10,13,'[5]- ENCERRA PROGRAMA $'

    pula_linha  db 10,13,'$'

    cadastro_insert db 'Diga o nome do aluno:$'

    notas_p1_insert db 'Diga a nota da p1: $'
    notas_p2_insert db 'Diga a nota da p2: $'
    notas_p3_insert db 'Diga a nota da p3: $'

    del_msg db 'Insira o nome do aluno que sera deletado: '
    ;delet_vet db 30 dup
    
.code
main PROC
    mov ax,@data
    mov ds,ax

@MENU:
    mov ah,09
    lea dx, menu
    int 21h

    mov ah,01
@INVALID:
    int 21h

    cmp al,'1'
    je cad

    cmp al,'2'
    je del

    cmp al,'3'
    je edit

    cmp al,'4'
    je plani

    cmp al,'5'
    je encerra_prog
    jmp @INVALID

    cad:
        call cadastro
        call planilha
        call cadastro
        call planilha
        jmp encerra_prog

    del:
        call delete
        jmp @MENU

    edit:
        call editt
        jmp @MENU

    plani:
        call planilha
        jmp @MENU

        
encerra_prog:
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

cadastro PROC
;procedimento que adiciona um aluno ao banco de dados
    push ax
    push bx
    push cx

    mov ah,09
    lea dx, cadastro_insert
    int 21h
    
    mov cx,30                   ;num maximo de caracteres que o nome pode ter +1 (max 29)
    
    mov ax,30
    mul n_cad

    mov bx,ax
    mov ah,01

    @while:
        int 21h
        cmp al,13                                   ;al,13?
        jne diferente                               ;nao, pula para 'diferente' e move o caracter em al 
                                                    ;sim, coloca $ no final do nome digitado e pula para fora do @While
        mov alunos[bx] , '$'                        ;
        jmp fora                                    ;

        diferente:
        mov alunos[bx],al
        inc bx
    loop @while

    fora:
    mov ah,09
    lea dx, notas_p1_insert
    int 21h

    mov ah,01
    int 21h
    
    


    add n_cad,1

    pop ax
    pop bx
    pop cx

    ret
cadastro ENDP

editt PROC
;procedimento que edita o cadastro
    push ax
    push bx
    push cx

    

    pop ax
    pop bx
    pop cx

    ret
editt ENDP


edit_nome PROC
;procedimento que edita o nome cadastrado
    push ax
    push bx
    push cx

    

    pop ax
    pop bx
    pop cx

    ret
edit_nome ENDP


edit_nota PROC
;procedimento que edita a nota de um aluno
    push ax
    push bx
    push cx

    

    pop ax
    pop bx
    pop cx

    ret
edit_nota ENDP


delete PROC
;procedimento que deleta um aluno cadastrado
    push ax
    push bx
    push cx

    mov ah,09
    lea dx,del_msg
    int 21h

    
    

    pop cx
    pop bx
    pop cx

    ret
delete ENDP


planilha PROC
;procedimento que exibe a planilha com os dados
    push ax
    push bx
    push cx

    lea dx, alunos
    mov ah,09
    int 21h

    add dx,30
    int 21h


    pop cx
    pop bx
    pop cx

    ret
planilha ENDP

end main