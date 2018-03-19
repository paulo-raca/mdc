########################################
# Teste 3 - INF-0612          
# Nome(s): Paulo Roberto de Almeida Costa
########################################


## 1 - Maximo Divisor Comum

gcd2 <- function(x, y) {
  if (y == 0) {
    return(x)
  } else {
    return(gcd2(y, x %% y))
  }
}

gcd <- function(...) {
    values <- c(...)
    result <- values[1]
    for (v in values) {
        # The first iteration is always gcd2(v[1], v[1]) -> v[1], which is Ok ¯\_(ツ)_/¯
        result <- gcd2(result, v)
    }
    result
}
# gcd (15, 21, 36)
# gcd (4, 8, 16, 17)





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

mode <- function(...) {
    values <- c(...)
    modes <- c()
    mode_count <- 0
    
    for (v in unique(values)) {
        c <- count(values, v)
        if (c > mode_count) {
            mode_count <- c
            mode <- v
        } else if (c == mode_count) {
            mode <- c(mode, v)
        }
    }
    return (mode)
}

# mode (sample(5))
# mode (c(18, 19, 21, 19, 18, 19, 18))
# mode (c (18, 19, 17, 19, 17, 17))





## 3 - Binario para Decimal

binToDec <- function(...) {
    result <- c()
    for (bin in list(...)) {
        dec <- sum(bin * 2^((length(bin)-1):0))
        result <- c(result, dec)
    }
    result
}
# binToDec(c(1, 0))
# binToDec(c(0, 0, 1), c(1, 1))
# binToDec(rep(1, 3), rep(0, 2), rep(c(1, 0), 2))





## 4 - Ocorrencia de palavras
tokenize <- function(text) {
    tokens <- strsplit(text, split="[ .,!?]+")[[1]]  # Split text around spaces and punctuation
    return (tokens[ tokens != "" ]) # Remove empty words, probably caused by leading/trailing spaces on the text
}

wordCount <- function(word, text) {
    return (count(tokenize(tolower(text)), tolower(word)))
}
# text <- " O rAto roeu a roupa do Rei de Roma ! RainhA raivosa rasgou o resto."
# wordCount("rato", text)
# wordCount("roma", text)

# text <- "A vaca malHada foi molhADA por outra VACA, MOLhada e MALhaDa."
# wordCount("outra", text)
# wordCount("vaca" , text)
# wordCount("malhada" , text)

# text <- "Se a liga me ligasse, eu tambem ligava a liga. Mas a liga nao me liga, eu tambem nao ligo a liga."
# wordCount("liga", text)
# wordCount("ligasse", text)

