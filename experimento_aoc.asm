# ==============================================================================
# UNIVERSIDADE FEDERAL DE ALAGOAS (UFAL) - CAMPUS PENEDO
# CURSO: Sistemas de Informação - 4º Período
# DISCIPLINA: Arquitetura e Organização de Computadores (Profa. Nathália Alves)
# ALUNO: Marcos Alexandre Braz do Nascimento
# PROJETO: Análise de Desempenho (CPI, Hazards e Pipeline) em Arquitetura RISC-V
# ==============================================================================

.data
    # Vetor de 16 inteiros (64 bytes) alinhado em palavra de 4 bytes
    .align 2
    vetor_dados: .word 12, 45, 7, 89, 23, 56, 91, 34, 67, 10, 82, 19, 41, 73, 28, 64
    tamanho:     .word 16
    
    msg_v1:      .asciz "\n[Versao 1 - Padrao / Com Hazards] Soma Total: "
    msg_v2:      .asciz "\n[Versao 2 - Otimizada / Loop Unrolling] Soma Total: "
    msg_ciclos:  .asciz " | Ciclos estimados (RARS): "

.text
.globl main

main:
    # --------------------------------------------------------------------------
    # EXPERIMENTO 1: Laço Convencional (Alta incidência de Load-Use Hazards e Branches)
    # --------------------------------------------------------------------------
    la   s0, vetor_dados      # Endereço base do vetor
    lw   s1, tamanho          # N = 16 elementos
    li   t0, 0                # Índice i = 0
    li   t1, 0                # Acumulador soma = 0

    # Leitura inicial de ciclos (CSR cycle)
    csrr s2, cycle            

loop_padrao:
    bge  t0, s1, fim_v1       # Hazard de Controle: desvio condicional testado a cada iteração
    slli t2, t0, 2            # Deslocamento: i * 4 bytes
    add  t3, s0, t2           # Endereço efetivo: base + (i * 4)
    lw   t4, 0(t3)            # LOAD da memória para t4
    add  t1, t1, t4           # LOAD-USE HAZARD (RAW): usa t4 imediatamente após lw!
    addi t0, t0, 1            # Incremento do contador
    j    loop_padrao          # Salto incondicional (custo extra de pipeline)

fim_v1:
    csrr s3, cycle            # Leitura final de ciclos V1
    sub  s4, s3, s2           # Total de ciclos V1

    # Exibe resultado V1
    li   a7, 4
    la   a0, msg_v1
    ecall
    li   a7, 1
    mv   a0, t1
    ecall
    li   a7, 4
    la   a0, msg_ciclos
    ecall
    li   a7, 1
    mv   a0, s4
    ecall

    # --------------------------------------------------------------------------
    # EXPERIMENTO 2: Laço Otimizado (Escalonamento de Instruções + Loop Unrolling 4x)
    # Reduz dependências RAW imediatas e diminui em 75% os desvios de controle
    # --------------------------------------------------------------------------
    la   s0, vetor_dados      # Endereço base do vetor
    lw   s1, tamanho          # N = 16
    li   t0, 0                # i = 0
    li   t1, 0                # Acumulador 1
    li   t6, 0                # Acumulador 2 (quebra dependência WAW/RAW no acumulador)

    csrr s5, cycle            # Leitura inicial de ciclos V2

loop_otimizado:
    bge  t0, s1, fim_v2       # Desvio executado apenas 4 vezes (em vez de 16)
    
    # Cargas antecipadas (Escalonamento estático para evitar Load-Use Stall)
    lw   t2, 0(s0)            # Carrega elemento [i]
    lw   t3, 4(s0)            # Carrega elemento [i+1]
    lw   t4, 8(s0)            # Carrega elemento [i+2]
    lw   t5, 12(s0)           # Carrega elemento [i+3]

    # Enquanto t4 e t5 terminam de chegar da memória, t2 e t3 já estão prontos na ULA
    add  t1, t1, t2           # Soma [i] sem bolha
    add  t6, t6, t3           # Soma [i+1] em registrador paralelo
    add  t1, t1, t4           # Soma [i+2]
    add  t6, t6, t5           # Soma [i+3]

    addi s0, s0, 16           # Avança ponteiro em 16 bytes (endereçamento indexado direto)
    addi t0, t0, 4            # Incrementa contador em 4
    j    loop_otimizado

fim_v2:
    add  t1, t1, t6           # Consolida acumuladores parciais
    csrr s6, cycle            # Leitura final de ciclos V2
    sub  s7, s6, s5           # Total de ciclos V2

    # Exibe resultado V2
    li   a7, 4
    la   a0, msg_v2
    ecall
    li   a7, 1
    mv   a0, t1
    ecall
    li   a7, 4
    la   a0, msg_ciclos
    ecall
    li   a7, 1
    mv   a0, s7
    ecall

    # Encerra o programa (Syscall 10 - Nível OSM)
    li   a7, 10
    ecall