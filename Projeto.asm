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
            db 10,13,'[4]- EDITAR os pesos'
            db 10,13,'[5]- ENCERRA PROGRAMA $'

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
                        db 10,13,'[2] Nome'
                        db 10,13,'$'

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

    peso_p1 dw 0
    peso_p2 dw 0
    peso_p3 dw 0

    ent_dec macro 
    ;entrada decimal retornando o valor em bl
        mov ah,01
        int 21h             ;recebe o digito

        sub al,30h          ;transforma em algarismo

        xor ah,ah           ;zera o registrador aH para que seja retirado o lixo e apenas vá para pilha o que está armazenado em ax
        push ax

        mov ax,10           ;guarda multiplicador em ax para fazer a operação

        mul bx              ;bx =  (bx X 10) + bx
        pop bx

        add bl,al
    endm


.code
main PROC
    mov ax,@data            ;move o conteúdo do .data para ds e es
    mov ds,ax
    mov es,ax

    call pesos

@MENU:
    mov ah,09               ;printa mensagem do menu principal
    lea dx, menu
    int 21h

    mov ah,01
@INVALID:
    call pulalinha          ;pula uma linha do prompt
    
    int 21h                 ;recebe um caracter

    cmp al,'1'              ;case, se '1' chama função de cadastrar novo usuário,
    je cad                  ;se '2' chama função de editar cadastro, 
                            ;se '3' chama função de printar planilha,
    cmp al,'2'              ;se '4' chama a função para editar os pesos
    je edit                 ;se '5' finaliza o programa

    cmp al,'3'
    je plani

    cmp al,'4'
    je @pesos

    cmp al,'5'
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
    
    @pesos:
        call pesos
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

    call pulalinha

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
        je @p1_insert                               ;sim, pula para 'fora'

        cmp al,08h              ;backspace? Se sim incrementa contador para desconsiderar o valor e decrementa bx para voltar no vetor
        jne diferente

        inc cx
        dec bx
        jmp @while

        diferente:
        mov alunos[bx],al       ;armazena valor na matriz
        inc bx                  ;passa para o próximo elemento
    loop @while

    @valor_inv_p1:
    mov ah,09
    lea dx,invalido             ;msg de valor inválido
    int 21h

    @p1_insert:
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
    jg @valor_inv_p1
    
    mov notas_p1[di],bl         ;salva o valor no vetor

    jmp @p2_insert

    @valor_inv_p2:
    mov ah,09
    lea dx,invalido             ;msg de valor inválido
    int 21h

    @p2_insert:
    mov ah,09
    lea dx, notas_p2_insert     ;msg de inserção
    int 21h

    xor bx,bx
    mov cx,2                    ;contador = 2 pois serão dois digitos

    @for2:
        ent_dec                 ;macro de entrada decimal
    loop @for2
    
    cmp bl,10                   ;se for maior do que 10 retorna o loop + msg erro
    ja @valor_inv_p2

    mov notas_p2[di],bl         ;salva valor no vetor

    jmp @p3_insert

    @valor_inv_p3:
    mov ah,09
    lea dx,invalido             ;msg de valor inválido
    int 21h

    @p3_insert:
    mov ah,09
    lea dx, notas_p3_insert     ;msg de inserção
    int 21h

    xor bx,bx
    mov cx,2                    ;contador = 2 pois serão 2 digitos

    @for3:
        ent_dec                 ;entrada decimal
    loop @for3

    cmp bl,10                   ;se valor maior que 10 = valor inválido (volta o loop)
    jg @valor_inv_p3

    mov notas_p3[di],bl         ;salva valor da nota no vetor

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

    call pulalinha

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

    cmp al,08h              ;compara al com o backspace
    jne @n_Backspace        ;se for continua, caso contrario pula para @n_Backspace

    dec si
    inc cx
    jmp @edita_nome

    @n_Backspace:
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
    pop di
    pop cx                  ;retorna valores no registrador
    pop bx
    pop ax

    ret
edit_nota ENDP

print_nomes PROC
;printa todos os nomes cadastrados com 10,13

    push ax
    push bx                 ;salva valores dos regs na pilha
    push cx
    push dx

    cmp n_cad,0             ;se nao tiver cadastros -> dá erro + volta
    jne @tem_cad

    mov ah,09
    lea dx,edit_erro        ;imprime mensagem de erro
    int 21h

    jmp @return

    @tem_cad:
    call pulalinha          ;pula uma linha no prompt

    mov ah,09
    lea dx,planilha_msg     ;imprime o cabeçalho
    int 21h

    mov cx,n_cad            ;guarda o número de cadastros no contador

    mov ah,09
    lea dx, alunos          ;move o offset do nome de um aluno da linha x para dx
    xor bx,bx               ;zera o índice que guia o cadastro em questão nos vetores de notas

    @for:
        call pulalinha
        int 21h             ;imprime um nome
        add dx,30           ;vai para a próxima linha da matriz dos nomes dos alunos (vai para o próximo nome)
        push dx
        push cx
        push ax

        call print_notas    ;chama a função para imprimir as notas
        
        inc bx              ;incrementa o bx para ir para o próximo cadastro
        pop ax
        pop cx
        pop dx
    loop @for               ;dá loop até que todos cadastros tenham sido impressos

    @return:
    pop dx
    pop cx                  ;retorna valores dos registradores
    pop bx
    pop ax

    ret
print_nomes ENDP

print_notas proc

        xor ax,ax           ;zera ax para garantir que não haja lixo em ah
        mov al,notas_p1[bx] ;move para al a nota da p1 de um aluno x

        call sai_dec        ;função de saída decimal

        mov dl,20h          ;imprime um ' ' (espaço)
        int 21h

        xor ax,ax           ;zera ax para garantir que não haja lixo em ah
        mov al,notas_p2[bx] ;move para al a nota da p2 de um aluno x

        call sai_dec        ;função de saída decimal

        mov dl,20h          ;imprime um ' ' (espaço)
        int 21h

        xor ax,ax           ;zera ax para garantir que não haja lixo em ah
        mov al,notas_p3[bx] ;move para al a nota da p3 de um aluno x

        call sai_dec        ;função de saída decimal

        mov dl,20h          ;imprime um ' ' (espaço)
        int 21h

        xor ax,ax           ;zera ax para garantir que não haja lixo em ah
        call calc_medias

        call sai_dec           ;imprime um ' ' (espaço)

        ret
print_notas endp

calc_medias proc
;calulca a media do aluno contido no indice bx
;retorna media em ax
    
    mov di,bx               ;move o endereçamento para di
    xor dx,dx               ;zera dx por conta das operações aritméticas
    mov al,notas_p1[di]     ;move a nota da p1 do aluno x para al para fazer a operação
    mov bx,peso_p1          ;move o peso para bx por conta do MUL
    mul bx                  ;multiplica a nota da p1 pelo peso da p1
    push ax                 ;guarda o resultado na pilha

    xor ax,ax               ;move o endereçamento para di
    xor dx,dx               ;zera dx por conta das operações aritméticas
    mov al,notas_p2[di]     ;move a nota da p2 do aluno x para al para fazer a operação
    mov bx,peso_p2          ;move o peso para bx por conta do MUL
    mul bx                  ;multiplica a nota da p2 pelo peso da p2
    push ax                 ;guarda o resultado na pilha

    xor ax,ax               ;move o endereçamento para di
    xor dx,dx               ;zera dx por conta das operações aritméticas
    mov al,notas_p3[di]     ;move a nota da p3 do aluno x para al para fazer a operação
    mov bx,peso_p3          ;move o peso para bx por conta do MUL
    mul bx                  ;multiplica a nota da p3 pelo peso da p3

    pop bx                  ;devolve os resultados da pilha em bx e cx para efetuar a soma de todos os valores
    pop cx
    add ax,bx
    add ax,cx
    
    mov bx,peso_p1
    add bx,peso_p2          ;soma todos os pesos
    add bx,peso_p3

    xor dx,dx
    div bx                  ;divide a soma de todas as notas multiplicadas pelos pesos pela soma de todos os pesos
    
    mov bx,di               ;restaura bx

    ret
calc_medias endp

busca PROC
;procedimento que exibe a planilha com os dados
    push ax
    push bx                 ;salva os valores dos registradores na pilha
    push cx
    
    call pulalinha          ;pula uma linha do prompt

    mov ah,09
    lea dx,busca_msg        ;msg de inserção do busca
    int 21h

    mov indice_busc,0       ;zera o índice busca pois pode conter índice de comparação anterior
    xor bx,bx               ;zera bx (usado para guardar string de busca)
    mov cx,30               ;contador de 30 (tamanho máximo do vetor)
    mov ah,01

@busca_while:
    int 21h                 ;recebe caracter
    cmp al, 13
    je @busc_sai            ;se for <enter>, sai

    cmp al,08h
    jne @nBackspace         ;se for <backspace>, decrementa o registrador de endereçamento para 'voltar' uma casa + incrementa contador para descontabilizar valor
    inc cx                      
    dec bx
    jmp @busca_while

    @nBackspace:
    mov str_busca[bx],al    ;armazena valor no vetor
    inc bx                  ;passa para o próximo item

    loop @busca_while

@busc_sai:
    xor bx,bx               ;zera bx para utilizar no endereçamento da matriz de nomes

@busc_cmp:
    mov ax,30               ;efetua a multiplicação do indice de busca (que no início é zero) pelo número de colunas para varrer a matriz
    mul indice_busc

    mov bx,ax               ;guarda o resultado em ax

    cld
    mov cx,29                            ;cx com numero de caracteres
    mov dx, n_cad                        ;dx com o numero de cadastros

    lea si, alunos[bx]      ;offset do nome x em si
    lea di, str_busca       ;offset do nome que está sendo buscado em str_busca
 
    repe cmpsb              ;faz a comparação, se for igual -> sai
    jz @igual

    inc indice_busc         ;caso não seja igual passa para a próxima linha

    mov dx,n_cad            ;compara o indice de busca com o número total de cadastros e caso seja igual significa que ja varreu todos nomes
    cmp indice_busc,dx      ;caso não tenha encontrado retorna mensagem de erro
    jne @busc_cmp
    
    lea dx, erro_busca
    mov ah,09               ;msg de erro do busca
    int 21h

    xor dx,dx               ;zera o booleano (se 0-> não encontrou)

    jmp @sai_cmp

@igual:
    mov dx,1                ;valor booleano que se for 1 demostra que encontrou um cadastro

@sai_cmp:
    xor bx,bx               ;zera o contador bx para ser utilizado no endereçamento da limpeza da string de busca
    mov cx,29               ;contador com o tamanho do vetor
    
@zerabusca:
    mov str_busca[bx],' '   ;limpa vetor para poder ser utilizado novamente
    inc bx

    loop @zerabusca

    pop cx
    pop bx                  ;retorna valores aos registradores
    pop ax

    ret
busca ENDP

sai_dec proc
;sai decimal no dispositivo padrão
;al deve conter o valor que sera impresso

    mov si,10               ;já que a saída é decimal, move 10 para o divisor
    mov cx,2                ;contador 2 pois o número tem 2 dígitos

    @loop1:
        xor dx,dx           ;zera o registrador do resto

        div si              ;realiza a divisão
        push dx             ;guarda o resto na pilha

    loop @loop1

    mov ah,02
    mov cx,2                ;como tem 2 dígitos seta o contador para 2

    @print:
        pop dx              ;puxa o resto da pilha e imprime como caracter
        
        add dl,30h
        int 21h
    loop @print

    ret
sai_dec endp

pesos PROC
;procedimento para inserir os respectivos pesos das provas(p1,p2,p3)

    push ax
    push bx                 ;salva valores dos registradores
    push cx

    mov ah,09
    lea dx,menu_pesos       ;msg dos pesos
    int 21h

    @erro_peso:
    mov ah,09
    lea dx,peso_p1_msg      ;msg de inserção do peso da p1
    int 21h

    mov cx,3                ;move 3 para cx pois o número pode conter 3 dígitos
    xor bx,bx               ;zera bx para armazenar os pesos

    @decimal:
        ent_dec             ;entrada decimal
    loop @decimal

    cmp bl,100              ;se o valor for maior que 100 volta o loop
    jg @erro_peso

    mov peso_p1,bx          ;armazena o valor na variável para peso da p1

    mov ah,09
    lea dx,peso_p2_msg      ;msg de inserção do peso da p2
    int 21h

    mov cx,3                ;move 3 para cx pois o número pode conter 3 dígitos
    xor bx,bx               ;zera bx para armazenar os pesos

    @decimal2:
        ent_dec             ;entrada decimal
    loop @decimal2

    cmp bl,100              ;se o valor for maior que 100 volta o loop
    jg @erro_peso
    
    mov peso_p2,bx          ;armazena o valor na variável para peso da p2

    mov ah,09
    lea dx,peso_p3_msg      ;msg de inserção do peso da p3
    int 21h

    mov cx,3                ;move 3 para cx pois o número pode conter 3 dígitos
    xor bx,bx               ;zera bx para armazenar os pesos

    @decimal3:
        ent_dec             ;entrada decimal
    loop @decimal3

    cmp bl,100              ;se o valor for maior que 100 volta o loop
    jg @erro_peso

    mov peso_p3,bx          ;armazena o valor na variável para peso da p3

    pop cx
    pop bx                  ;retorna os valores dos registradores
    pop ax

    ret
pesos ENDP
end main