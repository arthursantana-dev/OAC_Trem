		.data
		.align	0
	str0:	.asciz	"1. Adicionar vagao ao inicio\n2. Adicionar vagao ao final\n3. Remover vagao por ID\n4. Listar Trem.\n5. Buscar vagao por ID\n6. Sair\n\n"	
	str_ID:	.asciz	"ID: "	
	str_tipo:	
		.asciz	"Tipo: "
		
	str_n:	.asciz	"\n"
	
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
			
		#Convensoes (quais registradores usar para cada finalidade):
		#s0 : inicio da lista (ponteiro loc_prox)
		#s1 : endereco do ultimo vagao
		#t0-2 : iteradores (funcoes listar e remover por ID)
		
		.globl 	main
		
		#Inicio (laco principal):
	main:	addi	a7, zero, 4	#Texto de inicio
		la	a0, str0
		ecall
		
		addi	a7, zero, 5	#Leitura da operacao
		ecall
		
		addi	t0, zero, 4
		beq	a0, t0, menu_listar_trem
		
		addi	t0, zero, 6
		beq	a0, t0, sair
		
		j	main
			
	menu_listar_trem:	
		jal	listar_trem
		j	main
		
	listar_trem:
		la	a0, str_ID	#"ID: "
		addi	a7, zero, 4
		ecall
	
		la	t0, loc_id	#[ID]
		lw	a0, 0(t0)
		addi	a7, zero, 1
		ecall
		
		la	a0, str_n	#\n"
		addi	a7, zero, 4
		ecall
		
		la	a0, str_tipo	#"Tipo: "
		addi	a7, zero, 4
		ecall
		
		la	t0, loc_tipo	#[Tipo]
		lw	a0, 0(t0)
		addi	a7, zero, 1
		ecall
		
		la	a0, str_n	#\n\n"
		addi	a7, zero, 4
		ecall
		ecall
		
		la	t1, loc_prox
		lw	t0, 0(t1)	#t0 <- endereco do proximo vagao
		
		addi	t2, zero, -1
		
	loop_listar:
		
		beq	t0, t2, fim_listar
		
		la	a0, str_ID	#"ID: "
		addi	a7, zero, 4
		ecall
		
		lw	a0, 0(t0)	#[ID]
		addi	a7, zero, 1
		ecall
		
		la	a0, str_n	#\n"
		addi	a7, zero, 4
		ecall
		
		la	a0, str_tipo	#"Tipo: "
		addi	a7, zero, 4
		ecall
		
		lw	a0, 4(t0)	#[Tipo]
		addi	a7, zero, 1
		ecall
		
		la	a0, str_n	#\n\n"
		addi	a7, zero, 4
		ecall
		ecall
		
		lw	t0, 8(t0)
		j	loop_listar
		
	fim_listar:
		jr 	ra
	
	sair:	addi	a7, zero, 10
		ecall
