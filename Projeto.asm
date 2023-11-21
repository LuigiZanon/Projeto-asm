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

    menu_pesos  db 'Digite os pesos da provas(em porcentagem % 0-100):$'
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

    mov ah,09
    lea dx,menu_pesos
    int 21h

    @erro_peso:
    lea dx,peso_p1_msg
    int 21h

    mov cx,3
    xor bx,bx
    @decimal:
        ent_dec
    loop @decimal

    cmp bl,100
    jg @erro_peso

    mov peso_p1,bl

    mov ah,09
    lea dx,peso_p2_msg
    int 21h
    lea dx,peso_p3_msg
    int 21h

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
    push bx                 ;salva regs na pilha
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
    mov di,n_cad                ;move o número de cadastros para di (que também seria o "índice" do novo cadastro)

    mov ah,09
    lea dx, notas_p1_insert     ;msg de inserção
    int 21h

    mov cx,2                    ;move 2 para o contador (número com 2 digitos)

    @for1:
        ent_dec                 ;macro de entrada decimal
    loop @for1

    cmp bl,10                   ;se o valor é maior que 10 o valor é inválido (volta para o começo do loop)
    jg @valor_inv
    
    mov notas_p1[di],bl         ;salva o valor no vetor

    mov ah,09
    lea dx, notas_p2_insert     ;msg de inserção
    int 21h

    xor bx,bx
    mov cx,2                    ;contador = 2 pois serão dois digitos

    @for2:
        ent_dec                 ;macro de entrada decimal
    loop @for2
    
    cmp bl,10                   ;se for maior do que 10 retorna o loop + msg erro
    ja @valor_inv

    mov notas_p2[di],bl         ;salva valor no vetor

    mov ah,09
    lea dx, notas_p3_insert     ;msg de inserção
    int 21h

    xor bx,bx
    mov cx,2                    ;contador = 2 pois serão 2 digitos

    @for3:
        ent_dec                 ;entrada decimal
    loop @for3

    cmp bl,10                   ;se valor maior que 10 = valor inválido (volta o loop)
    jg @valor_inv

    mov notas_p3[di],bl         ;salva valor da nota no vetor

    calc_media                  ;chama macro de cálculo da média
    mov medias[di],al           ;salva no vetor das médias

    add n_cad,1                 ;por fim, já que o usuário foi cadastrado incrementa o n_cad que representa o número total de cadastros
    retorna:
    pop ax
    pop bx                      ;retorna valores aos regs
    pop cx

    ret
cadastro ENDP

editt PROC
;procedimento que edita o cadastro
    push ax
    push bx                     ;salva regs na pilha                 
    push cx

    cmp n_cad, 0                ;se não tiver cadastros retorna erro
    jne @valida_edit_n

    mov ah,09
    lea dx,edit_erro            ;msg de erro
    int 21h

    jmp @sai_edit               ;sai do procedimento

@valida_edit_n:
    mov ah,09
    lea dx,edit_msg          ;mensagem de inserção
    int 21h

    mov ah,01           

@valida_edit:
    int 21h                 ;recebe o valor do case, se '1' vai para a edição de nota, se '2' vai para a edição de nome

    cmp al, '1'
    je @nota

    cmp al, '2'
    je @nome
    jmp @valida_edit
    
@nota:

    call busca              ;chama a função de busca de string
    cmp dx,1                ;se o booleano for '1'-> achou cadastro, se '0'-> erro
    jne @nota

    call edit_nota          ;chama a função de edição da nota
    jmp @sai_edit           ;sai do procedimento

@nome:
    lea dx,edit_nome_msg
    mov ah,09               ;msg de inserção do nome 
    int 21h

    call busca              ;função de busca de string
    cmp dx,1                ;se o booleano for '1'-> achou cadastro, se '0'-> erro
    jne @nome

    lea dx,edit_nome_novo_msg
    mov ah,09               ;mensagem de inserção do novo nome
    int 21h

    call edit_nome          ;função para editar o nome

@sai_edit:
    pop cx
    pop bx                  ;devolve valor salvo da pilha
    pop ax

    ret
editt ENDP


edit_nome PROC
;procedimento que edita o nome cadastrado
    push ax
    push bx                 ;salva regs na pilha 
    push cx

    mov bx,indice_busc      ;pega o 'índice' do usuário buscado
    mov ax,30               

    mul bx                  ;faz a multiplicação do índice pelo número de colunas (o resultado indica a posição desejada para apontar o endereçamento

    mov si,ax               ;si -> aponta para o local da inserção 
    mov cx,29               ;contador tem o número máximo de caracteres
    push si                 ;salva si na pilha 

@zera_nome:
    mov alunos[si], ' '     ;loop que tem a função de limpar a linnha em que o nome será inserido
    inc si
    loop @zera_nome

    pop si                  ;retorna valor de si
    mov ah,01
    mov cx,29               ;máx de 29 caracteres

@edita_nome:
    int 21h                 ;recebe o caracter
    cmp al,13               ;<enter>? Se sim, sai
    je @sai_nome

    mov alunos[si],al       ;salva valor na matriz
    inc si                  ;vai passando para o próximo elemento
    loop @edita_nome

@sai_nome:

    pop cx
    pop bx                  ;retorna os valores dos registradores
    pop ax

    ret
edit_nome ENDP


edit_nota PROC
;procedimento que edita a nota de um aluno
    push ax
    push bx                 ;salva valores dos regs na pilha
    push cx
    push di

    jmp @msg_editProvas     ;pula a mensagem de erro

    @input_invalido:
    mov ah,09
    lea dx, invalido        ;msg de erro
    int 21h

    call pulalinha          ;pula linha no prompt

    @msg_editProvas:
    mov ah,09
    lea dx,edit_provas      ;msg de inserção
    int 21h

    mov di,indice_busc      ;pega o índice do nome buscado

    mov ah,01
    int 21h                 ;case: se '1'-> p1,'2'->p2,'3'->p3

    cmp al,'3'
    je @p3

    cmp al,'2'
    je @p2

    cmp al,'1'
    jne @input_invalido     ;se nenhum dos casos então é um valor inválido e volta para o início + msg_erro

    @p1:
    xor bx,bx               ;zera registrador para caso inserir valor inválido
    mov ah,09
    lea dx,notas_p1_insert  ;msg de inserção p1
    int 21h

    mov cx,2                ;2 digitos
    call pulalinha
    
        @for_nota:
            ent_dec         ;entrada decimal
        loop @for_nota
        
        cmp bl,10           ;se maior que 10-> erro + volta o loop
        jg @p1
        
        mov notas_p1[di],bl ;salva valor no vetor

        jmp @voltaProg
    
    @p2:
    xor bx,bx               ;zera registador oara caso inserir valor inválido
    mov ah,09
    lea dx,notas_p2_insert  ;msg inserção p2
    int 21h

    mov cx,2                ;2 digitos
    call pulalinha
    
        @for_nota2:
            ent_dec         ;entrada decimal
        loop @for_nota2

        cmp bl,10           ;se maior que 10 o valor é inválido-> volta loop + msg_erro
        jg @p2
        
        mov notas_p2[di],bl ;salva valor no vetor

        jmp @voltaProg

    @p3:
    xor bx,bx               ;caso inserir valor inválido zera o registrador
    mov ah,09
    lea dx,notas_p3_insert  ;msg de inserção p3
    int 21h

    mov cx,2                ;2 digitos
    call pulalinha
    
        @for_nota3:
            ent_dec         ;entrada decimal
        loop @for_nota3

        cmp bl,10           ;caso o valor seja maior que 10-> volta o loop + msg_erro
        jg @p3
        
        mov notas_p3[di],bl ;salva valor no vetor
    
    @voltaProg:
    calc_media
    mov medias[di],al

    pop di
    pop cx                  ;retorna valores no registrador
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