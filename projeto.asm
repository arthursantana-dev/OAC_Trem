			.data
		 	.align	0
	str0:	 	.asciz	"1. Adicionar vagão ao início\n2. Adicionar vagão ao final\n3. Remover vagão por ID\n4. Remover vagão por ID\n5. Buscar vagão por ID\n6. Sair\n\n"	
	loc_id:	 	.word	0
	loc_prox:	.word		#Endereço do próximo vagão
			.text
			
			#Tipos de vagões:
			#1: locomotiva
			#2: carga
			#3: passageiro
			#4: combustível
			#5: corta-fogo
			
			#Convensões (quais registradores usar para cada finalidade):
			
			
			.globl 	main
			
			addi	s6, zero, 6
			#Início (laço principal):
	main:		addi	a7, zero, 4	#Texto de início
			la	a0, str0
			ecall
			
			addi	a7, zero, 5	#Leitura da operação
			ecall
			
			beq	a0, s6, sair
			
			j	main
			
	sair:		addi	a7, zero, 10
			ecall