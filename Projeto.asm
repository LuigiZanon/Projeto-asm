.model small
.stack 100h
.data
    alunos  db 29 dup(' '),'$'
            db 29 dup(' '),'$'
            db 29 dup(' '),'$'
            db 29 dup(' '),'$'
            db 29 dup(' '),'$'

    notas_p1  db 5 dup(?)
    notas_p2  db 5 dup(?)
    notas_p3  db 5 dup(?)
    medias  db 5 dup(?)

    n_cad   dw 0

    menu    db 10,13,'Selecione a ação desejada:'
            db 10,13,'[1]- CADASTRAR um aluno'
            db 10,13,'[2]- EXCLUIR um aluno'
            db 10,13,'[3]- CORRIGIR uma nota'
            db 10,13,'[4]- GERAR planilha'
            db 10,13,'[5]- ENCERRA PROGRAMA $'

    pula_linha  db 10,13,'$'

    cadastro_insert db 'Diga o nome do aluno (max 29 caracteres):$'

    notas_p1_insert db 'Diga a nota da p1: $'
    notas_p2_insert db 'Diga a nota da p2: $'
    notas_p3_insert db 'Diga a nota da p3: $'

    del_msg db 'Insira o nome do aluno que sera deletado: $'
    ;delet_vet db 30 dup

    busca_msg   db 'Insira o nome para busca: $'
    str_busca   db 29 dup(' ')
    n_busca     db 0
    indice_busc dw 0
    
    planilha_msg db 'Nome do aluno                P1 P2 P3 media$'

    erro db 'Nao eh possivel realizar outro cadastro pois ja ha 5 cadastros $'


.code
main PROC
    mov ax,@data
    mov ds,ax
    mov es,ax

@MENU:
    mov ah,09
    lea dx, menu
    int 21h

    mov ah,01
@INVALID:
    call pulalinha
    
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
        jmp @MENU

    del:
        call delete
        jmp @MENU

    edit:
        call editt
        jmp @MENU

    plani:
        call print_nomes
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

    cmp n_cad,5
    jnge @cad

    mov ah,09
    lea dx,erro
    int 21h

    jmp retorna

    @cad:
    mov ah,09
    lea dx, cadastro_insert
    int 21h
    
    mov cx,30                   ;número maximo de caracteres que o nome pode ter +1 (max 29)
    
    mov ax,30                   ;
    mul n_cad                   ;multipla a quantidade de nomes cadastrados por 30 (num de colunas na matriz nomes) para não sobreescrever os nomes ja cadastrados

    mov bx,ax
    mov ah,01

    @while:
        int 21h
        cmp al,13                                   ;al,13?
        je fora                                     ;sim, pula para 'fora'

        cmp al,08h
        jne diferente

        inc cx
        dec bx
        jmp @while

        diferente:
        mov alunos[bx],al
        inc bx
    loop @while

    fora:
    xor bx,bx
    mov di,n_cad

    mov ah,09
    lea dx, notas_p1_insert
    int 21h

    mov cx,2

    @for1:
        mov ah,01
        int 21h
        sub al,30h
        xor ah,ah
        push ax
        mov ax,10
        mul bx
        pop bx
        add bl,al
    loop @for1
    
    mov notas_p1[di],bl
    
    call pulalinha

    mov ah,09
    lea dx, notas_p2_insert
    int 21h

    xor bx,bx
    mov cx,2

    @for2:
        mov ah,01
        int 21h
        sub al,30h
        xor ah,ah
        push ax
        mov ax,10
        mul bx
        pop bx
        add bl,al
    loop @for2

    mov notas_p2[di],bl

    call pulalinha

    mov ah,09
    lea dx, notas_p3_insert
    int 21h

    xor bx,bx
    mov cx,2

    @for3:
        mov ah,01
        int 21h
        sub al,30h
        xor ah,ah
        push ax
        mov ax,10
        mul bx
        pop bx
        add bl,al
    loop @for3

    mov notas_p3[di],bl

    xor ax,ax
    mov al,notas_p1[di]
    add al,notas_p2[di]
    add al,notas_p3[di]
    xor bx,bx
    mov bl,3
    div bl
    mov medias[di],al

    add n_cad,1


    retorna:
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

    

    pop cx
    pop bx
    pop ax

    ret
editt ENDP


edit_nome PROC
;procedimento que edita o nome cadastrado
    push ax
    push bx
    push cx

    

    pop cx
    pop bx
    pop ax

    ret
edit_nome ENDP


edit_nota PROC
;procedimento que edita a nota de um aluno
    push ax
    push bx
    push cx

    

    pop cx
    pop bx
    pop ax

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

    call busca

    
    

    pop cx
    pop bx
    pop ax

    ret
delete ENDP

print_nomes PROC
;printa todos os nomes cadastrados com 10,13

    push ax
    push bx
    push cx
    push dx

    call pulalinha

    mov ah,09
    lea dx,planilha_msg
    int 21h

    mov cx,n_cad

    mov ah,09
    lea dx, alunos
    xor bx,bx

    @for:
        call pulalinha
        int 21h
        add dx,30
        push dx
        push cx
        push ax

        call print_notas
        
        inc bx
        pop ax
        pop cx
        pop dx
    loop @for   

    pop dx
    pop cx
    pop bx
    pop ax

    ret
print_nomes ENDP
print_notas proc

        mov si,10
        xor ax,ax
        mov al,notas_p1[bx]
        mov cx,2
        @loop1:
            xor dx,dx
            div si
            push dx
        loop @loop1

        mov ah,02
        mov cx,2
        @print:
            pop dx
            add dl,30h
            int 21h
        loop @print

        mov dl,20h
        int 21h

        xor ax,ax
        mov al,notas_p2[bx]
        mov cx,2
        @loop2:
            xor dx,dx
            div si
            push dx
        loop @loop2

        mov ah,02
        mov cx,2
        @print2:
            pop dx
            add dl,30h
            int 21h
        loop @print2

        mov dl,20h
        int 21h

        xor ax,ax
        mov al,notas_p3[bx]
        mov cx,2
        @loop3:
            xor dx,dx
            div si
            push dx
        loop @loop3

        mov ah,02
        mov cx,2
        @print3:
            pop dx
            add dl,30h
            int 21h
        loop @print3
        mov dl,20h
        int 21h

        xor ax,ax
        mov al,medias[bx]
        mov cx,2
        @loop4:
            xor dx,dx
            div si
            push dx
        loop @loop4

        mov ah,02
        mov cx,2
        @print4:
            pop dx
            add dl,30h
            int 21h
        loop @print4

        ret
print_notas endp

busca PROC
;procedimento que exibe a planilha com os dados
    push ax
    push bx
    push cx

    ; lea dx,busca_msg
    ; mov ah,09
    ; int 21h

    mov indice_busc,0
    xor bx,bx
    mov cx,30
    mov ah,01

@busca_while:
    int 21h
    cmp al, 13
    je @busc_sai
    mov str_busca[bx],al
    inc bx

    loop @busca_while

@busc_sai:
    xor bx,bx

@busc_cmp:
    mov ax,30
    mul indice_busc

    mov bx,ax

    cld
    mov cx,29                            ;cx com numero de caracteres
    mov dx, n_cad                        ;dx com o numero de cadastros

    lea si, alunos[bx]
    lea di, str_busca
 
    repe cmpsb
    jz @igual

    mov ah,02
    mov dl,'N'
    int 21h

    inc indice_busc

    mov dx,n_cad
    cmp indice_busc,dx
    jne @busc_cmp
    
    jmp @sai_cmp

@igual:
    mov ah,02
    mov dx,indice_busc
    add dx,30h
    int 21h


@sai_cmp:


    pop cx
    pop bx
    pop ax

    ret
busca ENDP
end main