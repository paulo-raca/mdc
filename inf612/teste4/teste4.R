########################################
# Teste 4 - INF-0612          
# Nome(s): Paulo Roberto de Almeida Costa
########################################

names <- c("Horario", "Temperatura", "Vento", "Umidade", "Sensacao")
cepagri <- read.csv("cepagri.csv", header = FALSE, sep = ";", col.names = names)

library(ggplot2)

## 0A - Faz parse da coluna de horário
cepagri$Horario <- as.POSIXlt(strptime(cepagri$Horario, "%d/%m/%Y-%H:%M"))

## 0B Retuns a slice of cepagry dataframe between the days `from` and `to` (inclusive)
cepagry_date_range <- function(from, to) {
    cepagri[ is.element(cepagri$Horario$mday, from:to), ]
}

## 1 - Umidade Relativa do Ar

p <- ggplot(cepagry_date_range(1, 10), aes(x = Horario, y = Umidade))
p <- p + geom_line()
p

## 2 - Sensacao Termica da Segunda Quinzena do Mes

p <- ggplot(cepagry_date_range(15, 31), aes(x = Sensacao))
p <- p + geom_histogram(bins = 30)
p

## 3 - Temperatura dos Ultimos Sete Dias do Mes

p <- ggplot(cepagry_date_range(25, 31), aes(
    x = Horario$mday, 
    y = Temperatura, 
    group = Horario$mday))
p <- p + geom_boxplot()
p

## 4 - Ventos do Primeiro Dia do Mes


cepagry_jan_1 <- cepagry_date_range(1, 1)
max_wind_by_hour <- as.data.frame(tapply(cepagry_jan_1$Vento, cepagry_jan_1$Horario$hour, max))
colnames(max_wind_by_hour)[1] <- 'Vento'
max_wind_by_hour$Hora <- as.integer(row.names(max_wind_by_hour))

p <- ggplot(max_wind_by_hour, aes(x = Hora, y = Vento))
p <- p + geom_point()
p <- p + geom_smooth()
p
