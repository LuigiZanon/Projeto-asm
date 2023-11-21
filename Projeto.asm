.model small
.stack 100h
.data
    alunos  db 29 dup(' '),'$'  ;vetor que armazena os cadastros dos nomes dos alunos
            db 29 dup(' '),'$'
            db 29 dup(' '),'$'
            db 29 dup(' '),'$'
            db 29 dup(' '),'$'

    notas_p1  db 5 dup(?)       ;3 vetores que armazenam  as notas dos alunos pelas provas
    notas_p2  db 5 dup(?)
    notas_p3  db 5 dup(?)
    medias  db 5 dup(?)         ;vetor que armazena as médias de cada cadastro

    n_cad   dw 0                ;local da memória que armazena o número de cadastros

    menu    db 10,13,'Selecione a opcao desejada:'  ;mensagem do menu
            db 10,13,'[1]- CADASTRAR um aluno'
            db 10,13,'[2]- CORRIGIR um cadastro'
            db 10,13,'[3]- GERAR planilha'
            db 10,13,'[4]- ENCERRA PROGRAMA $'

    pula_linha  db 10,13,'$'                        ;pula uma linha do prompt

    cadastro_insert db 'Diga o nome do aluno (max 29 caracteres):$' ;mensagem para inserir cadastro

    notas_p1_insert db 10,13,'Diga a nota da p1: $'                 ;mensagens para inserir as nostas
    notas_p2_insert db 10,13,'Diga a nota da p2: $'
    notas_p3_insert db 10,13,'Diga a nota da p3: $'

    busca_msg   db 'Insira o nome para busca: $'    ;mensagem para inserir nome que será buscado
    str_busca   db 29 dup(' ')                      ;string que armazena o nome que será buscado
    indice_busc dw 0                                ;'indice' no nome buscado na matriz
    erro_busca  db 'Cadastro nao encontrado! $'     ;mensagem de erro caso não tenha encontrado
    
    planilha_msg db 'Nome do aluno                P1 P2 P3 media$'  ;cabeçalho na planilha

    erro db 'Nao eh possivel realizar outro cadastro pois ja ha 5 cadastros $'  ;caso tente cadastrar mais
                                                                                ;de 5 usuários
    edit_msg            db 10,13, 'O que voce deseja editar?'       ;menu de edição
                        db 10,13,'[1] Nota'                         
                        db 10,13,'[2] Nome $'
    edit_nome_msg       db 10,13,'Qual nome voce deseja editar? $'  ;mensagem para inserir o nome que será editado
    edit_nome_novo_msg  db 10,13,'Insira o nome novo: $'            ;nome editado
    edit_erro           db 'Nao ha cadastros! $'                    ;mensagem de erro caso não haja cadastros

    edit_provas db 'Digite qual prova voce gostariade editar'       ;menu da edição de notas
                db 10,13,'[1]-p1'
                db 10,13,'[2]-p2'
                db 10,13,'[3]-p3$'

    invalido    db 10,13,'valor invalido$'

    menu_pesos  db 'Digite os pesos da provas(em porcentagem %):$'
    peso_p1_msg db 10,13,'Peso da P1: $'
    peso_p2_msg db 10,13,'Peso da P2: $'
    peso_p3_msg db 10,13,'Peso da P3: $'

    peso_p1 db 0
    peso_p2 db 0
    peso_p3 db 0

    ent_dec macro 
    ;entrada decimal retornando o valor em bl
        mov ah,01
        int 21h
        sub al,30h
        xor ah,ah
        push ax
        mov ax,10
        mul bx
        pop bx
        add bl,al
    endm

    calc_media macro
    ;calcula a media e retorna o valor em al
        xor ax,ax
        mov al,notas_p1[di]
        add al,notas_p2[di]
        add al,notas_p3[di]
        xor bx,bx
        mov bl,3
        div bl
    endm


.code
main PROC
    mov ax,@data            ;move o conteúdo do .data para ds e es
    mov ds,ax
    mov es,ax

@MENU:
    mov ah,09               ;printa mensagem do menu principal
    lea dx, menu
    int 21h

    mov ah,01
@INVALID:
    call pulalinha          ;pula uma linha do prompt
    
    int 21h                 ;recebe um caracter

    cmp al,'1'              ;case, se '1' chama função de cadastrar novo usuário, se '2' chama função de editar cadastro, se '3' chama função de printar planilha, se '4' e 
    je cad

    cmp al,'2'
    je edit

    cmp al,'3'
    je plani

    cmp al,'4'
    je encerra_prog
    jmp @INVALID

    cad:
        call cadastro       ;função de add cadastros
        jmp @MENU

    edit:
        call editt          ;função de editar cadastros
        jmp @MENU

    plani:
        call print_nomes    ;função de imprimir planilha
        jmp @MENU

        
encerra_prog:
    mov ah,4ch              ;encerra programa
    int 21h
main ENDP

pulalinha PROC
;procedimento que pula para linha de baixo juntamente com o cr

    push ax                 ;salva registradores
    push dx
    push cx

    mov ah,09
    lea dx, pula_linha          ;10,13 (LF,CR)
    int 21h

    pop cx                  ;retorna valores aos registradores
    pop dx
    pop ax

    ret
    
pulalinha ENDP

cadastro PROC
;procedimento que adiciona um aluno ao banco de dados
    push ax
    push bx
    push cx

    cmp n_cad,5             ;se já houver 5 cadastros retorna erro
    jnge @cad

    mov ah,09
    lea dx,erro             ;msg de erro
    int 21h

    jmp retorna

    @cad:
    mov ah,09
    lea dx, cadastro_insert     ;msg para inserção de cadastros
    int 21h
    
    mov cx,30                   ;número maximo de caracteres que o nome pode ter +1 (max 29)
    
    mov ax,30                   ;
    mul n_cad                   ;multipla a quantidade de nomes cadastrados por 30 (num de colunas na matriz nomes) para não sobreescrever os nomes ja cadastrados

    mov bx,ax                   ;move o resultado para bx (sendo bx a linha de cadastro correspondente a próxima linha livre para não sobreescrever)
    mov ah,01

    @while:
        int 21h
        cmp al,13                                   ;al,13?
        je fora                                     ;sim, pula para 'fora'

        cmp al,08h              ;backspace? Se sim incrementa contador para desconsiderar o valor e decrementa bx para voltar no vetor
        jne diferente

        inc cx
        dec bx
        jmp @while

        diferente:
        mov alunos[bx],al       ;armazena valor na matriz
        inc bx                  ;passa para o próximo elemento
    loop @while

    @valor_inv:
    mov ah,09
    lea dx,invalido             ;msg de valor inválido
    int 21h

    fora:
    xor bx,bx
    mov di,n_cad                ;move o número de cadastros 

    mov ah,09
    lea dx, notas_p1_insert
    int 21h

    mov cx,2

    @for1:
        ent_dec
    loop @for1

    cmp bl,10
    jg @valor_inv
    
    mov notas_p1[di],bl

    mov ah,09
    lea dx, notas_p2_insert
    int 21h

    xor bx,bx
    mov cx,2

    @for2:
        ent_dec
    loop @for2
    
    cmp bl,10
    ja @valor_inv

    mov notas_p2[di],bl

    mov ah,09
    lea dx, notas_p3_insert
    int 21h

    xor bx,bx
    mov cx,2

    @for3:
        ent_dec
    loop @for3

    cmp bl,10
    jg @valor_inv

    mov notas_p3[di],bl

    calc_media
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


    mov ah,09
    lea dx,edit_msg
    

    cmp n_cad, 0
    jne @valida_edit_n

    mov ah,09
    lea dx,edit_erro
    int 21h

    jmp @sai_edit

@valida_edit_n:
    int 21h
    mov ah,01

@valida_edit:
    int 21h

    cmp al, '1'
    je @nota

    cmp al, '2'
    je @nome
    jmp @valida_edit
    
@nota:

    call busca
    call edit_nota
    jmp @sai_edit

@nome:
    lea dx,edit_nome_msg
    mov ah,09
    int 21h

    call busca
    cmp dx,1
    jne @nome

    lea dx,edit_nome_novo_msg
    mov ah,09
    int 21h

    call edit_nome

@sai_edit:
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

    mov bx,indice_busc
    mov ax,30

    mul bx

    mov si,ax
    mov cx,29
    push si

@zera_nome:
    mov alunos[si], ' '
    inc si
    loop @zera_nome

    pop si
    mov ah,01
    mov cx,29

@edita_nome:
    int 21h
    cmp al,13
    je @sai_nome

    mov alunos[si],al
    inc si
    loop @edita_nome

@sai_nome:

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
    push di

    jmp @msg_editProvas

    @input_invalido:
    mov ah,09
    lea dx, invalido
    int 21h

    call pulalinha

    @msg_editProvas:
    mov ah,09
    lea dx,edit_provas
    int 21h

    mov di,indice_busc

    mov ah,01
    int 21h

    cmp al,'3'
    je @p3

    cmp al,'2'
    je @p2

    cmp al,'1'
    jne @input_invalido

    @p1:
    xor bx,bx
    mov ah,09
    lea dx,notas_p1_insert
    int 21h

    mov cx,2
    call pulalinha
    
        @for_nota:
            ent_dec
        loop @for_nota
        
        cmp bl,10
        jg @p1
        
        mov notas_p1[di],bl

        jmp @voltaProg
    
    @p2:
    xor bx,bx
    mov ah,09
    lea dx,notas_p2_insert
    int 21h

    mov cx,2
    call pulalinha
    
        @for_nota2:
            ent_dec
        loop @for_nota2

        cmp bl,10
        jg @p2
        
        mov notas_p2[di],bl

        jmp @voltaProg

    @p3:
    xor bx,bx
    mov ah,09
    lea dx,notas_p3_insert
    int 21h

    mov cx,2
    call pulalinha
    
        @for_nota3:
            ent_dec
        loop @for_nota3

        cmp bl,10
        jg @p3
        
        mov notas_p3[di],bl
    
    @voltaProg:
    calc_media
    mov medias[di],al

    pop di
    pop cx
    pop bx
    pop ax

    ret
edit_nota ENDP

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

        xor ax,ax
        mov al,notas_p1[bx]

        call sai_dec

        mov dl,20h
        int 21h

        xor ax,ax
        mov al,notas_p2[bx]

        call sai_dec

        mov dl,20h
        int 21h

        xor ax,ax
        mov al,notas_p3[bx]

        call sai_dec

        mov dl,20h
        int 21h

        xor ax,ax
        mov al,medias[bx]

        call sai_dec 

        ret
print_notas endp

busca PROC
;procedimento que exibe a planilha com os dados
    push ax
    push bx
    push cx
    
    call pulalinha

    mov ah,09
    lea dx,busca_msg
    int 21h

    mov indice_busc,0
    xor bx,bx
    mov cx,30
    mov ah,01
@busca_while:
    int 21h
    cmp al, 13
    je @busc_sai

    cmp al,08h
    jne @nBackspace
    inc cx
    dec bx
    jmp @busca_while

    @nBackspace:
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

    inc indice_busc

    mov dx,n_cad
    cmp indice_busc,dx
    jne @busc_cmp
    
    lea dx, erro_busca
    mov ah,09
    int 21h

    xor dx,dx

    jmp @sai_cmp

@igual:
    mov dx,1

@sai_cmp:
    xor bx,bx
    mov cx,29
    
@zerabusca:
    mov str_busca[bx],' '
    inc bx

    loop @zerabusca

    pop cx
    pop bx
    pop ax

    ret
busca ENDP
sai_dec proc
;sai decimal no dispositivo padrão
;al deve conter o valor que sera impresso

    mov si,10
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

    ret
sai_dec endp
end main