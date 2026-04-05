		.data
		.align	0
	str0:	.asciz	"1. Adicionar vagao ao inicio\n2. Adicionar vagao ao final\n3. Remover vagao por ID\n4. Listar Trem\n5. Buscar vagao por ID\n6. Sair\n\n"	
	str_ID:	.asciz	"ID: "	
	str_tipo:	
		.asciz	"Tipo: "
	str_n:	.asciz	"\n"
	str_nao_encontrado:
		.asciz 	"ID nao encontrado.\n"
	str_encontrado:
		.asciz 	"ID encontrado.\n"
	str_erro_id:	
		.asciz 	"Erro: Vagao com mesmo ID ja existe.\n\n"
	str_erro_tipo:	
		.asciz 	"Erro: Tipo invalido. Escolha de 1 a 5.\n\n"	
	str_erro_rem_loc: 
		.asciz 	"Erro: Nao e permitido remover a locomotiva!\n\n"
	
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
		
		#Estrutura do vagao
		#Todos os tipos de dados ocupam uma word de mem√≥ria (em 32 bits, 4 bytes)
		#byte	informacao
		#0-3	ID (int)
		#4-7	Tipo do vag√£o (int)
		#8-11	Ponteiro pro pr√≥ximo vag√£o (ponteiro)
		
		#Observacoes:
		#s0 √© ponteiro de ponteiro
		#loc_proximo √© ponteiro
		
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
		
	menu_buscar_id:
		jal	buscar_id
		j	main
			
	menu_listar_trem:	
		jal	listar_trem
		j	main
		
	alocar_vagao:
		la	a0, str_ID	#"ID: "
		addi	a7, zero, 4
		ecall
		
		addi	a7, zero, 5	#[ID]
		ecall
		add	t0, zero, a0	#t0 <- ID digitado
		
		la	t2, loc_id	#verifica se o ID bate com a Locomotiva
		lw	t2, 0(t2)
		beq	t0, t2, erro_id
		
		la	t2, loc_prox	#verifica se o ID bate com algum vag„o dinamico
		lw	t2, 0(t2)	# t2 = endereco do primeiro vagao (ou -1)
		addi	t3, zero, -1	# criterio de parada
		
	loop_verificar_id:
		beq	t2, t3, id_ok	# se chegou no fim (-1), o ID esta livre
		lw	t4, 0(t2)	# t4 = ID do vag„o atual do loop
		beq	t0, t4, erro_id	# Se os IDs forem iguais, aborta
		lw	t2, 8(t2)	# AvanÁa para o prÛximo vag„o
		j	loop_verificar_id
		
	id_ok:
		la	a0, str_tipo	#"Tipo: "
		addi	a7, zero, 4
		ecall
		
		addi	a7, zero, 5	#[Tipo]
		ecall
		add	t1, zero, a0	#t1 <- Tipo digitado
		
		addi	t2, zero, 1
		blt	t1, t2, erro_tipo	# se tipo < 1, erro
		addi	t2, zero, 5
		bgt	t1, t2, erro_tipo	# se tipo > 5, erro
		
		la	a0, str_n	#"\n\n"
		addi	a7, zero, 4
		ecall
		ecall
	
		addi	a0, zero, 12	#Reserva de 12 bytes
		addi	a7, zero, 9
		ecall
		
		sw	t0, 0(a0)	#salva ID
		sw	t1, 4(a0)	#salva tipo
		
		jr 	ra		
		
	erro_id:
		la	a0, str_erro_id
		addi	a7, zero, 4
		ecall
		add	a0, zero, zero	# retorna a0 = 0
		jr	ra
		
	erro_tipo:
		la	a0, str_erro_tipo
		addi	a7, zero, 4
		ecall
		add	a0, zero, zero	# retorna a0 = 0
		jr	ra
		
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
		beq	a0, zero, erro_inicio
		
		lw	t2, 0(s0)	# (vagao*)t2 recebe o endereco do primeiro elemento da lista
		sw	t2, 8(a0)	# *(a0+2) (que √© a0.loc_prox) = t2 = *s0
		
		sw	a0, 0(s0)	# *s0 = a0, ou seja, loc_prox = a0
		
		lw	ra, 0(sp)	#recupera o ra_inicio
		addi	sp, sp, 4	#desaloca o topo da stack
		
		jr	ra
		
	erro_inicio:
		lw	ra, 0(sp)	
		addi	sp, sp, 4	
		jr	ra
		
	adicionar_fim:
		addi	sp, sp, -4
		sw	ra, 0(sp)
		
		jal	alocar_vagao
		
		beq	a0, zero, erro_fim
		
		addi	t2, zero, -1	#t2 <- -1 (para comparar com o ponteiro prox)
		
		sw	t2, 8(a0)	#[a0].prox = -1
	
		add	t0, zero, s0	#t0 <- endereco do proximo vagao
		
	loop_chegar_ao_fim:
		lw	t1, 0(t0)	#t1 <- *t0
		
		beq	t1, t2, chegou_fim
		addi	t0, t1, 8
		
		j	loop_chegar_ao_fim
		
	chegou_fim:
		sw	a0, 0(t0)
		
	erro_fim:
		lw	ra, 0(sp)
		addi	sp, sp, 4
		
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
		addi	sp, sp, -4
		sw	ra, 0(sp)
		
		la	a0, str_ID	#"ID: "
		addi	a7, zero, 4
		ecall
	
		addi	a7, zero, 5
		ecall
		
		add 	t3, zero, a0	# t3 = a0 = id procurado
		la 	t0, loc_id	# vagao* t0 = &loc_id
		addi	t4, zero, -1
		
	loop_buscar:
		beq	t0, t4, nao_encontrado	# Se t0 for -1 (elemento anterior de t0 era o ultimo da lista)
		lw 	t2, 0(t0)		# int t2 = *(t0+1)
		beq 	t2, t3, encontrado	# Se t2 (id atual) != t3 (id buscado) volte o loop
		lw 	t0, 8(t0)		# vagao* t0 = *(t0+2) (que √© (*t0).loc_prox)
		j	loop_buscar
		
	encontrado:
		la	a0, str_encontrado
		addi	a7, zero, 4
		ecall
		
		add	a1, zero, t0
		jal	listar_vagao
		
		j	fim_buscar
		
	nao_encontrado:
		la	a0, str_nao_encontrado
		addi 	a7, zero, 4
		ecall
		add	a0, zero, t0	#retornando -1 (informando q n foi achado)
		jr 	ra
		
	fim_buscar:
		lw	ra, 0(sp)
		addi	sp, sp, 4
		jr	ra
	
	sair:	addi	a7, zero, 10
		ecall
