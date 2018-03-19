########################################
# Teste 3 - INF-0612          
# Nome(s): 
########################################


## 1 - Maximo Divisor Comum

gcd2 <- function(x, y) {
  if (y == 0) {
    return(x)
  } else {
    return(gcd2(y, x %% y))
  }
}





## 2 - Moda da Idade da Turma

count <- function(vector, element) {
  count <- 0
  for (i in vector) {
    if (i == element) {
      count <- count + 1
    }
  }
  return(count)
}





## 3 - Binario para Decimal





## 4 - Ocorrencia de palavras





