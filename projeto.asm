		.data
		.align	0
	str0:	.asciz	"1. Adicionar vagao ao inicio\n2. Adicionar vagao ao final\n3. Remover vagao por ID\n4. Listar Trem\n5. Buscar vagao por ID\n6. Sair\n\n"	
	str_ID:	.asciz	"ID: "	
	str_tipo:	
		.asciz	"Tipo: "
	str_n:	.asciz	"\n"
	str_nao_encontrado:
		.asciz "ID não encontrado.\n"
	str_encontrado:
		.asciz "ID encontrado.\n"
		.align	2
	loc_id:	 .word	0
	loc_tipo:.word	1
	loc_prox:.word	-1	#Endereco do proximo vagao
		.text
			
		#Tipos de vagoes:
		#1: locomotiva
		#2: carga
		#3: passageiro
		#4: combustivel
		#5: corta-fogo
			
		#Convencoes (quais registradores usar para cada finalidade):
		#s0 : inicio da lista (ponteiro loc_prox)
		#s1 : endereco do ultimo vagao
		#t0-2 : iteradores (funcoes listar e remover por ID)
		
		#Estrutura do vagão
		#Todos os tipos de dados ocupam uma word de memória (em 32 bits, 4 bytes)
		#byte	informacao
		#0-3	ID (int)
		#4-7	Tipo do vagão (int)
		#8-11	Ponteiro pro próximo vagão (ponteiro)
		
		#Observacoes:
		#No C, a seta -> é uma desreferencia + .
		#	ou seja, ponteiro->valor é igual (*ponteiro).valor
		#	ou seja, ponteiro.valor é um ponteiro
		#	e se valor for um ponteiro, ponteiro.valor é ponteiro de ponteiro
		#loc_proximo é ponteiro
		#s0 é ponteiro de ponteiro
		
		.globl 	main

		la	s0, loc_prox
				
		#Inicio (laco principal):
	main:	addi	a7, zero, 4	#Texto de inicio
		la	a0, str0
		ecall
		
		addi	a7, zero, 5	#Leitura da operacao
		ecall
		
		addi	t0, zero, 1
		beq	a0, t0, menu_adicionar_inicio
		
		addi	t0, zero, 2
		beq	a0, t0, menu_adicionar_fim
		
		addi	t0, zero, 3
		beq 	a0, t0, menu_remover_id
		
		addi	t0, zero, 4
		beq	a0, t0, menu_listar_trem
		
		addi	t0, zero, 5
		beq	a0, t0, menu_buscar_id
		
		addi	t0, zero, 6
		beq	a0, t0, sair
		
		j	main
	
	menu_adicionar_inicio:
		jal	adicionar_inicio
		j	main
		
	menu_adicionar_fim:
		jal	adicionar_fim
		j	main
	menu_remover_id:
		jal	remover_id
		j	main
			
	menu_listar_trem:	
		jal	listar_trem
		j	main
	menu_buscar_id:
		jal	buscar_id
		j	main
	alocar_vagao:
		la	a0, str_ID	#"ID: "
		addi	a7, zero, 4
		ecall
		
		addi	a7, zero, 5	#[ID]
		ecall
		
		add	t0, zero, a0	#t0 <- ID
		
		la	a0, str_tipo	#"Tipo: "
		addi	a7, zero, 4
		ecall
		
		addi	a7, zero, 5	#[Tipo]
		ecall
		
		add	t1, zero, a0	#t1 <- Tipo
		
		la	a0, str_n	#\n\n"
		addi	a7, zero, 4
		ecall
		ecall
	
		addi	a0, zero, 12	#Reserva de 12 bytes para a nova estacao
		addi	a7, zero, 9
		ecall
		
		sw	t0, 0(a0)	# *(a0+0) (que é a0.id) = id
		sw	t1, 4(a0)	# *(a0+1) (que é a0.tipo) = tipo
		
		jr 	ra
		
		#argumentos:
		#a1: endereco do vagao
	listar_vagao:
		la	a0, str_ID	#"ID: "
		addi	a7, zero, 4
		ecall
		
		lw	a0, 0(a1)	#[ID]
		addi	a7, zero, 1
		ecall
		
		la	a0, str_n	#\n"
		addi	a7, zero, 4
		ecall
		
		la	a0, str_tipo	#"Tipo: "
		addi	a7, zero, 4
		ecall
		
		lw	a0, 4(a1)	#[Tipo]
		addi	a7, zero, 1
		ecall
		
		la	a0, str_n	#\n\n"
		addi	a7, zero, 4
		ecall
		ecall
		
		jr	ra
		
	adicionar_inicio:
		addi	sp, sp, -4	#aloca 1 palavra na stack
		sw	ra, 0(sp)	#ra_inicio no topo da stack
		
		jal	alocar_vagao
					#a0 <- endereco do vagao alocado
		
		lw	t2, 0(s0)	# (vagao*)t2 recebe o endereco do primeiro elemento da lista
		sw	t2, 8(a0)	# *(a0+2 (que é a0.loc_prox))  = t2 = *s0
		
		sw	a0, 0(s0)	# *s0 = a0, ou seja, loc_prox = a0
		
		lw	ra, 0(sp)	#recupera o ra_inicio
		addi	sp, sp, 4	#desaloca o topo da stack
		
		jr	ra
		
	adicionar_fim:
		addi	sp, sp, -4	#Reservando uma word na stack
		sw	ra, 0(sp)	#Colocando o ra do menu_adicionar_fim na stack
		
		jal	alocar_vagao
		
		addi	t2, zero, -1	#t2 <- -1 (para comparar com o ponteiro prox)
		
		sw	t2, 8(a0)	#a0->prox = -1
	
		add	t0, zero, s0	#t0 <- endereco do proximo vagao
		
	loop_chegar_ao_fim:
		lw	t1, 0(t0)	#(tipo vagao*) t1 <- *t0
					#Agora t1 é o ponteiro pro (ou seja, o endereco do) prox_loc
		
		beq	t1, t2, chegou_fim	#Se o endereço do prox_loc do t1 da ultima iteracao for -1 (que signfica que o t1 da ultima iteracao é o último vagão)
		#else
		addi	t0, t1, 8 	#(tipo vagao**) t0 = (vagao*)t1.(vagao*)loc_prox. t0 é um ponteiro de ponteiro para o prox_loc do t1
					#Ou seja, t0 é um ponteiro pro endereço do prox_loc de t1
		
		j	loop_chegar_ao_fim
		
	chegou_fim:
		sw	a0, 0(t0)	#*t0 (t0 é o endereço do ponteiro prox_loc) = a0 (endereço do vagão alocado)
					#Ou seja, t1 antigo (último vagão)->prox_loc = a0 (vagão alocado)
		
		lw	ra, 0(sp)	#Recuperando ra da stack
		addi	sp, sp, 4	#Desreservando word
		
		jr	ra
		
	listar_trem:
		addi	sp, sp, -8
		sw	ra, 4(sp)
		sw	s1, 0(sp)
		
		la	s1, loc_id
		
		add	a1, zero, s1
		jal 	listar_vagao
		
		lw	s1, 8(s1)
		
		addi	t2, zero, -1
		
	loop_listar:
		beq	s1, t2, fim_listar
			
		add	a1, zero, s1
		jal	listar_vagao
		
		lw	s1, 8(s1)
		j	loop_listar
		
	fim_listar:
		lw	s1, 0(sp)
		lw	ra, 4(sp)
		
		addi	sp, sp, 8
		
		jr 	ra
	buscar_id:
		addi	a7, zero, 5
		ecall
		add 	t3, zero, a0	# t3 = a0 = id procurado
		la 	t1, loc_prox	# vagao** t1 = &loc_prox
		lw 	t0, 0(t1)	# vagao* t0 = *(t1)
		addi	t4, zero, -1	# t4=-1 (pra ter o valor de -1 num reg)
		addi	t1, zero, 0	# vou usar o t4 pra guardar o vagão anterior na iteração. vou deixar como 0 pra locomotiva
	loop_buscar:
		beq	t0, t4, nao_encontrado	# Se t0 for -1 (elemento anterior de t0 era o ultimo da lista)
		lw 	t2, 0(t0)		# int t2 = *(t0+1)
		beq 	t2, t3, encontrado	# Se t2 (id atual) != t3 (id buscado) volte o loop
		add	t1, zero, t0		# vagao* anterior = t0
		lw 	t0, 8(t0)		# vagao* t0 = *(t0+2) (que é (*t0).loc_prox)
		j	loop_buscar
	encontrado:
		la	a0, str_encontrado
		addi	a7, zero, 4
		ecall
		add	a0, zero, t0	#Retornando o endereço do encontrado
		add	a1, zero, t1	#Retornando o endereço do anterior do encontrado
		jr	ra
	nao_encontrado:
		la	a0, str_nao_encontrado
		addi 	a7, zero, 4
		ecall
		add	a0, zero, t0	#Retornando -1 (informando q n foi achado)
		jr 	ra
	remover_id:
		addi	sp, sp, -4	#Movendo sp 1 word pra trás para reservar 1 word
		sw	ra, 0(sp)	#Colocando o ra do menu_remover_id no sp (stack)
		jal	buscar_id	#ra = aqui
		lw	ra, 0(sp)	#Colocando de volta o ra do menu_remover_id nele
		addi	sp, sp, 4	#Movendo sp 1 word pra frente pra desreservar 1 word
		add	t0, zero, a0	#t0 = a0 (endereço do vagao buscado)
		add	t1, zero, a1	#t1 = a1 (endereço do vagao anterior ao t0)
		addi	t4, zero, -1	#t4=-1
		beq	t0, t4, fim_remover		#Se for -1, acabou
		beq	t1, zero, remover_primeiro 	#Se t1=0 significa que o t0 é o primeiro vagão (locomotiva)
		lw	t0, 8(t0)	#t0 = t0->loc_prox
		sw	t0, 8(t1)	#t1->loc_prox = t0
		jr	ra
	remover_primeiro:
		lw	t0, 8(t0)	#t0 = t0->loc_prox
		sw	t0, 0(s0)	#*s0 = t0
		jr ra
	fim_remover:
		jr ra
				
	
	sair:	addi	a7, zero, 10
		ecall
