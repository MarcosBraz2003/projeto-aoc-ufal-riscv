# Projeto Prático de Arquitetura e Organização de Computadores (UFAL)

**Aluno:** Marcos Alexandre Braz do Nascimento  
**Curso:** Bacharelado em Sistemas de Informação — Universidade Federal de Alagoas (UFAL - Campus Penedo)  
**Disciplina:** Arquitetura e Organização de Computadores (4º Período)  
**Professora:** Profa. Ma. Nathália de Meneses Alves  

## Sobre o Projeto
Este repositório contém o código-fonte, os parâmetros de simulação e o relatório técnico do experimento prático que investiga o impacto dos **Hazards de Pipeline (Dados e Controle)**, do **Escalonamento Estático de Instruções** e da **Localidade Espacial/Temporal em Memória Cache** no desempenho de software sobre a arquitetura **RISC-V (RV32I)**.

## Arquivos do Repositório
- `experimento_aoc.asm`: Código-fonte em Assembly RISC-V comparando a execução padrão (com *Load-Use Hazards*) e a execução otimizada (*Loop Unrolling 4x* + escalonamento de instruções e dois acumuladores).
- `Relatório Técnico de Arquitetura e Organização de Computadores.pdf`: Relatório técnico completo com fundamentação teórica, metodologia, métricas do RARS e análise crítica.
- `apresentacao_projeto_aoc.pdf`: Slides utilizados na apresentação e demonstração ao vivo.

## Resultados Obtidos no Simulador (RARS 1.6)
- **Validação da Soma (16 elementos):** `741` (idêntica em ambas as versões)
- **Versão 1 (Laço Padrão):** `114 ciclos` (`CSR cycle`)
- **Versão 2 (Otimizada - Loop Unrolling 4x):** `51 ciclos` (`CSR cycle`)
- **Ganho de Desempenho (Speedup):** **2,24× mais rápido** (redução de 55,26% nos ciclos)
- **Métricas Globais:** `212` instruções executadas e **88% de Cache Hit Rate** na Cache L1 (64 bytes, Mapeamento Direto, blocos de 4 palavras).

## Como Executar o Experimento
1. Abra o simulador **RARS 1.6** (requer Java JRE 8+).
2. Carregue o arquivo `experimento_aoc.asm` (`File -> Open`).
3. *(Opcional)* Para visualizar as métricas de hardware, acesse:
   - `Tools -> Instruction Statistics` -> clique em **Connect to Program**
   - `Tools -> Data Cache Simulator` -> configure *Direct Mapping*, *LRU*, *Set size: 1*, *Number of blocks: 4*, *Cache block size: 4 words* -> clique em **Connect to Program**
4. Pressione **F3** para montar (*Assemble*) e **F5** para executar (*Run*).
