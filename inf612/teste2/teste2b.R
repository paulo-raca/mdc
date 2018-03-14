########################################
# Teste 2b - INF-0612          
# Nome(s): Paulo Roberto de Almeida Costa
########################################

ids <- c(172742, 172773, 172825, 172839, 172967, 173149, 173204, 173370, 174096, 174355, 174437, 174487, 174488, 174928, 175380, 175832, 176859, 176914, 176940, 177388, 177554, 177609, 177643, 177825, 177925, 178085, 178137, 178377, 178397, 178525, 178664, 178674, 178740, 178779, 181987, 182039, 182049, 182901, 183024, 183143, 183517, 183984, 184400, 185247, 185820, 186218, 187014, 187217, 188078, 188494, 188548)

p1 <- c(6, 5.1, 7, 3.9, 8.9, 2.6, 0, 0.5, 3.3, 8, 4.8, 4.4, 3.1, 8.3, 1.4, 0.5, 1.1, 5.8, 9.5, 5.1, 4.3, 7.5, 4.8, 1.8, 5.4, 9.5, 4.8, 4.8, 3.3, 8.4, 4.4, 7.8, 8.8, 8.9, 0, 7, 6.9, 5.8, 6.3, 8.8, 6.3, 8.6, 6.1, 5, 3.8, 4.5, 5.4, 8, 1.9, 1.6, 1.6)

p2 <- c(8.6, 8.5, 6.8, 9.1, 5.3, 4.8, 0, 0, 0, 8.9, 6.2, 6.5, 2.9, 6.8, 3.5, 4.8, 6.1, 7.8, 8.9, 8, 5.6, 7.2, 8.9, 0, 7.6, 9.8, 3.3, 8.2, 7.6, 8.8, 0, 9.4, 9.3, 8.1, 0, 8, 9.6, 0, 8.9, 9, 4.5, 5.5, 6.8, 8.6, 0, 9.6, 6.8, 7.8, 5.9, 2.9, 2.3)

p3 <- c(7.6, 7.1, 6.9, 7, 6.7, 3.9, 0, 0.2, 1.3, 8.5, 5.6, 5.6, 3, 7.4, 2.7, 3.1, 4.1, 7, 9.1, 6.9, 5.1, 7.3, 7.2, 0.7, 6.7, 9.6, 3.9, 6.8, 5.9, 8.6, 1.8, 8.7, 9.1, 8.4, 0, 7.6, 8.5, 2.3, 7.8, 8.9, 5.2, 6.8, 6.5, 7.2, 1.5, 7.6, 6.2, 7.9, 4.3, 2.4, 2)

p4 <- c(9.9, 2.3, 10, 7.3, 8.6, 8.9, 0, 9.5, 4.5, 7.9, 8.9, 8.6, 8.2, 6.4, 2.7, 10, 8.6, 8.3, 9.4, 9.5, 8.6, 9.5, 9.1, 0, 10, 7.8, 9.9, 8.2, 6.8, 8.7, 3.2, 6.9, 6.3, 8.9, 3.2, 10, 5.3, 6.4, 7.9, 7.8, 8.2, 8.6, 7.3, 7.5, 5, 8.3, 10, 4.8, 10, 6.4, 7.9)

## DICA: a funcao abaixo retorna, dada uma matriz (ou estrutura tabular), 
## o menor elemento linha a linha. Por exemplo, dada uma matriz m, para 
## obter o menor elemento linha a linha entre as colunas 2 e 3, devemos 
## utilizar o comando rowMins(m[,c(2:3)]).
rowMins <- function(m) {
 apply(m, 1, min)
}


## Você deve criar um data frame utilizando os vetores fornecidos e
## sempre que utilizar algum dado já existente no arquivo referir-se
## a este data frame (ou seja, você só pode utilizar os vetores 
## fornecidos para criar este data frame).
notas <- data.frame(row.names = ids, p1 = p1, p2 = p2, p3 = p3, p4 = p4)

# Dado de exemplo
#notas <- data.frame(row.names = 'Joãozinho', p1 = 8.3, p2 = 9, p3 = 5.2, p4 = 6.7)


## Você deve salvar no vetor “medquad” a média final de cada aluno
## (média quadrática das provas, desconsiderando a menor nota obtida), 
## com duas casas decimais.
notas$pmin <- rowMins(notas)
notas$medquad <- round(
    x = sqrt(1/3 * (notas$p1^2 + notas$p2^2 + notas$p3^2 + notas$p4^2 - notas$pmin^2)),
    digits=2)
notas
medquad = notas$medquad
medquad

## Você deve salvar nas variáveis “mp1”, “mp2”, “mp3” e “mp4” 
## a média aritmética das notas das provas 1, 2, 3 e 4, respectivamente.
mp1 = mean(notas$p1)
mp2 = mean(notas$p2)
mp3 = mean(notas$p3)
mp4 = mean(notas$p4)

## Você deve salvar nas variáveis “dp1”, “dp2”, “dp3” e “dp4”
## o desvio padrão das notas das provas 1, 2, 3 e 4, respectivamente.
dp1 = sd(notas$p1)
dp2 = sd(notas$p2)
dp3 = sd(notas$p3)
dp4 = sd(notas$p4)

# Exibe média e desvio de cada prova
data.frame(
  row.names = c("P1", "P2", "P3", "P4"),
  media = c(mp1, mp2, mp3, mp4), 
  desvio.padrão = c(dp1, dp2, dp3, dp4))


## Você deve salvar na variável “notasrank” os registros acadêmicos dos 
## alunos tal que na primeira posição conste o registro acadêmico do
## aluno com a maior média final, na segunda posição conste o registro
## acadêmico do aluno com a segunda maior média final, e assim por diante.
notasrank <- row.names(notas)[order(x=notas$medquad, decreasing=T)]
notasrank