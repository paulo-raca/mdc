########################################
# Teste 1 - INF-0612          
# Nome: Paulo Roberto de Almeida Costa
########################################

## Criamos um vetor "x" com 20 posicoes, com numeros de 1 ate 20, sem repeticoes.
x <- sample(20)

## Exibimos os elementos de "x" entre as posicoes 5 e 8
x[5:8]

## Exibimos os elementos de "x" nas posicoes 11, 10 e 9
x[11:9]

## Salve na variavel "y", o vetor "x" invertido, ou seja, o primeiro
## elemento de "x" deve ser o ultimo elemento de "y", o segundo
## elemento de "x" deve ser o penultimo elemento de "y", e assim por
## diante. Voce deve usar apenas conceitos vistos em sala em sala (ou
## seja, funcoes como sort() e rev() e length() nao devem ser utilizadas).
y <- x[20:1]

## Imprima os elementos impares de "y"
y[y %% 2 == 1]

## Imprima os elementos de "x" estritamente maiores que 8
x[x > 8]

## Criamos um vetor de nomes chamado "names"
names <- c("Joao", "Laura", "Carlos", "Bruna", "Pedro", "Joao", "Maria")

## Criamos um vetor de idades chamado "ages"
ages <- c(80, 19, 32, 73, 10, 44, 70)

## Criamos um vetor booleano chamado "student"
student <- c(F, T, F, T, F, T, T)

## Imprima as posicoes em "names" tal que estas posicoes sejam TRUE em
## "student".  Por exemplo, como a posicao 1 em "student" eh FALSE,
## "Joao", que esta na posicao 1 do vetor "names" nao deve ser
## impressa. Ja a posicao 2 de "student" eh TRUE, entao "Laura", que
## esta na posicao 2 do vetor "names", deve ser impressa
names[student]

## Crie (e exiba) um data frame chamado "dados" tal que:
##  -a primeira coluna, chamada "nome", seja o vetor "names" criado acima;
##  -a segunda coluna, chamada "idade", seja o vetor "ages" criado acima;
##  -a terceira coluna, chamada "matricula", seja o vetor "student" criado acima.
dados <- data.frame(nome=names, idade=ages, matricula=student, stringsAsFactors=F)

dados

## Modifique o data frame dados para que a coluna chamada "idade"
## seja nomeada como "nota".

names(dados)[names(dados) == 'idade'] <- "nota"

dados

## Imprima os nomes cuja a nota e maior ou igual a 70 pontos.
## Por exemplo, "Joao" obteve 80 pontos na nota, entao "Joao" 
## deve ser impresso. Por outro lado, "Laura" obteve 19 pontos 
## na nota, entao "Laura" nao deve ser impresso, e assim por
## diante.  

dados$nome[dados$nota >= 70]
