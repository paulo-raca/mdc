########################################
# Trabalho Final - INF-0612          
# Nome(s): Paulo Roberto de Almeida Costa
########################################

#install.packages("lubridate")
library(ggplot2)     # For charts
library("lubridate") # For timezone (with_tz)

# Read the dataset
cepagri_columns <- c("Time", "Temperature", "Wind", "Humidity", "Apparent Temperature")
cepagri <- read.csv("cepagri.csv", header = FALSE, sep = ";", col.names = cepagri_columns, stringsAsFactors = F)

# Parse each column
cepagri$Time <- as.POSIXlt(strptime(cepagri$Time, "%d/%m/%Y-%H:%M", tz = 'America/Sao_Paulo'))
cepagri$Temperature <- as.numeric(cepagri$Temperature)
cepagri$Wind <- as.numeric(cepagri$Wind)
cepagri$Humidity <- as.numeric(cepagri$Humidity)
cepagri$Apparent.Temperature <- as.numeric(cepagri$Apparent.Temperature)

# I just care about 2015-2017
cepagri <- cepagri[ is.element(cepagri$Time$year, 115:117), ]


####################################################################################################

### Horário de Verão
### ----------------
###
### Os horários estão formatados no fuso horário local, o que é muito prático para humanos, 
### mas possivelmente problemático para máquinas.
### 
### Por exemplo, existem descontinuidades quando o horário de verão começa ou termina. 
### Em particular, o intervalo 23:00-23:59 ocorre 2 vezes no último dia de horário de verão, e é sempre problemático.
### 
### Vamos analisar esses momentos de mudança:

time_window <- function(dataframe, from, to) {
  dataframe[
    dataframe$Time >= strptime(from, "%d/%m/%Y-%H:%M", tz = 'America/Sao_Paulo') & dataframe$Time <= strptime(to, "%d/%m/%Y-%H:%M", tz = 'America/Sao_Paulo'), 
  ]
}

#time_window(cepagri, "21/02/2015-22:50", "22/02/2015-00:10")
time_window(cepagri, "17/10/2015-23:50", "18/10/2015-02:10")
time_window(cepagri, "20/02/2016-22:50", "21/02/2016-00:10")
#time_window(cepagri, "15/10/2016-23:50", "16/10/2016-02:10")
#time_window(cepagri, "18/02/2017-22:50", "19/02/2017-00:10")
#time_window(cepagri, "20/10/2017-23:50", "21/10/2017-02:10")


### Nas tabelas acima, podemos ver que ocorrem erros quando o horário de verão começa ou termina. 
### O problema se repete todos os anos! (As tabelas foram omitido para redução de espaço)
### 
### É consenso que trabalhar com fuso-horários é dificil e complica ainda mais quando entra o 
### horário  verão, mas estou assustado que causem problemas tão consistentemente neste dataset.
### 
### Quanto ao intervalo ambiguo das 23:00 a 23:59 que ocorre no último dia do horário de verão, 
### podemos resolver a ambiguidade adicionando 1h sempre que uma linha do dataframe "volta no tempo"
### em comparação à linha anterior.

fix.dst <- function(time) {
  for (i in 2:length(time)) {
    if (time[i] + 1800 < time[i - 1]) {
      time[i] <- time[i] + 3600
    }
  }
  time
}
cepagri$Time <- fix.dst(cepagri$Time)


####################################################################################################
### Limpeza dos dados
### -----------------
###
### O horário de verão foi uma análise interessante e, uma vez que causa tantos erros, 
### precisava ser feito antes da limpeza dos dados.
### 
### Daqui para frente, poderemos ignorar linhas com erro e remover duplicadas
### (Ficando apenas com a primeira ocorrencia)

cepagri <- cepagri[!apply(cepagri, 1, function(x) {any(is.na(x))}), ]

is.repeated.row <- function(df) {
  ret <- logical(nrow(df))
  for (i in 2:nrow(df)) {
    ret[i] <- all(df[i, ] == df[i-1, ])
  }
  ret
}
cepagri <- cepagri[!is.repeated.row(cepagri[2:5]), ]


####################################################################################################
### Distribuição de dados
### ---------------------
###
### Como primeira análise dos dados propriamente ditos, vamos visualizar as distribuições de cada
### variável, e procurar por problemas com outliers.

field_values <- rbind(
  data.frame(Attribute = 'Temperature',          Value = cepagri$Temperature),
  data.frame(Attribute = 'Humidity',             Value = cepagri$Humidity),
  data.frame(Attribute = 'Wind',                 Value = cepagri$Wind),
  data.frame(Attribute = 'Apparent Temperature', Value = cepagri$Apparent.Temperature)
)

p <- ggplot(field_values, aes(x = Value, fill = Attribute))
p <- p + facet_wrap(~ Attribute, scales = "free", ncol=1)
p <- p + geom_density()
p <- p + theme(legend.position="none")
p

### Tanto a temperatura quanto a umidade parecem bem comportadas e dentro dos intervalos esperados,
### mas o vento e a sensação térmica  possuem outliers muito grandes que merecem investigação.


####################################################################################################
### Outliers de Sensação Térmica
### ----------------------------
###
### Vamos ver uma amostra dos dias em que a _Sensação Térmica_ ultrapassou 40ºC

apparent.temperature.outliers <- cepagri[cepagri$Apparent.Temperature > 40, ]

#apparent.temperature.outliers
apparent.temperature.outliers[seq(1, nrow(apparent.temperature.outliers), 5), ]  #  (Sampled 1 out of every 5 outliers for brevity)

### Todos os outliers tem valor 99.9ºC e ocorram exatamente às 7:10, todos os dias entre Maio e 
### Outubro de 2016. Achei esse problema hilário 😂
###
### Não posso deixar de imaginar se isso foi um error real (Cuja causa deve ser muito 
### interessante...), ou uma pegadinha adicionada pelo professor para ser encontrada pelos alunos.
###
### Parece que o único campo afetado por este problema é a Sensação Térmica, e ele provavelmente 
### poderia ser obtido através de uma fórmula usando os outros campos. 
### Mas, por segurança e preguiça, vou simplesmente ignorar estas linhas nas análises seguintes.

cepagri <- cepagri[cepagri$Apparent.Temperature != 99.9, ]


####################################################################################################
### Outliers de Vento
### -----------------
###
### Vamos inspecionar os momentos em que o vento ultrapassou 100km/h, usando uma janela de +/- 2 horas.

wind.outliers <- cepagri[cepagri$Wind > 100, ]
wind.outliers.window <- 7200  # 2 hours
wind.outliers.date_ranges <- data.frame(min=wind.outliers$Time - wind.outliers.window, max=wind.outliers$Time + wind.outliers.window)
wind.outliers.expanded <- cepagri[sapply(as.POSIXct(cepagri$Time), function(x) {any(x >= wind.outliers.date_ranges$min & x <= wind.outliers.date_ranges$max)}), ]
wind.outliers.expanded$group <- NA

# Split each high-wind day into a separate group
wind.outliers.expanded$Group[1] <- 1
for (i in 2:nrow(wind.outliers.expanded)) {
  if (wind.outliers.expanded$Time[i] > 2*wind.outliers.window + wind.outliers.expanded$Time[i - 1]) {
    wind.outliers.expanded$Group[i] <- wind.outliers.expanded$Group[i-1] + 1
  } else {
    wind.outliers.expanded$Group[i] <- wind.outliers.expanded$Group[i-1]
  }
}

wind.outliers.group.time <- aggregate(as.POSIXct(wind.outliers.expanded$Time), list(Group = wind.outliers.expanded$Group), median)$x
wind.outliers.expanded$GroupTime <- wind.outliers.group.time[ wind.outliers.expanded$Group ]

p <- ggplot(wind.outliers.expanded, aes(y = Wind, x = Time, fill = as.factor(Group)))
p <- p + facet_wrap( ~ strftime(GroupTime, "%Y-%m-%d"), scales = "free_x")
p <- p + geom_line()
p <- p + theme(legend.position="none")
p

### Estes gráficos parecem normais, e eu acredito que estes foram simplesmente momentos de muito 
### vento, sem qualquer problema na coleta dos dados.
###
### Mas devo admitir que fiquei surpreso ao não encontrar a Microexplosão que ocorreu em 05/06/2016 
### nesta lista, a qual teve ventos fortíssimos de até 120km/h, capazes de destruir meu bairro e 
### várias outras partes da cidade.
###
### Vamos verificar:

cepagri.microexplosion <- time_window(cepagri, "04/06/2016-22:00", "05/06/2016-6:00")

p <- ggplot(cepagri.microexplosion, aes(y = Wind, x = Time))
p <- p + geom_line()
p <- p + theme(legend.position="none")
p

### De acordo com os dados do Cepagri, houve sim muito vento nesta data (88km/h), mas não
### o suficiente para atingir o limite de 100km/h definido (arbitrariamente) na análise anterior.
###
### Acredito que isso deva ter ocorrido porque a medição do Cepagri não foi realizada no centro
### da tempestade. (Onde ela é feita? No próprio prédio do Cepagri?)


####################################################################################################
### Correlações
### -----------
###
### Vamos visualizar como a Temperatura, Vento, Umidade e Sensação Térmica se correlacionam.

correlation.attributes <- c('Temperature', 'Apparent.Temperature', 'Wind', 'Humidity')

correlation.matrix <- matrix(ncol=length(correlation.attributes), nrow=length(correlation.attributes), dimnames=list(correlation.attributes, correlation.attributes))
for (i in 1:length(correlation.attributes)) {
  for (j in 1:length(correlation.attributes)) {
    correlation.matrix[i,j] <- cor(cepagri[[correlation.attributes[i]]], cepagri[[correlation.attributes[j]]])
  }
}
correlation.matrix

density.grid <- data.frame(var1=c(), value1=c(), var2=c(), value2=c())
for (var1 in correlation.attributes) {
  for (var2 in correlation.attributes) {
    df <- data.frame(var1=var1, value1=cepagri[[var1]], var2=var2, value2=cepagri[[var2]])
    density.grid <- rbind(density.grid, df)
  }
}

p <- ggplot(data=density.grid, aes(x=value1, y=value2))
p <- p + facet_grid(var1 ~ var2)
p <- p + stat_density2d(aes(alpha=..level..), geom="polygon")
p <- p + theme(legend.position="none",  axis.title = element_blank())
p

### Exceto pela diagonal principal, esses dados não mostram linhas ou mesmo elipses 
### bonitinhas como as que eu gostaria de ter encontrado, um sinal de que modelar o clima é um 
### problema complicado e que requer modelos bem mais complexos do correlações simples.
###
### Mas apesar disso, podemos notar que:
###  
### - Obviamente, Temperatura e Sensação Térmica são altamente correlacionados.
###   Eu não faço idéia de como se calcula a sensação térmica, mas um número muito próximo
###   de 1 já era esperado.
### - Temperatura e Vento possuem uma pequena correlação negativa. 
###   Acredito que o vento ajude a dispersar o calor.
### - Sensação Térmica também possui uma correlação negativa com Vento, mas muito mais significativa
###   do que a da Temperatura. 
###   Neste caso, acredito que o vento possui 2 efeitos aditivos: Ele baixa tanto a Temperatura real
###   quanto a Sensação Térmica para uma dada temperatura.
### - Umidade e Temperatura possuem uma correlação negativa muito alta. 
###   Acredito que isso seja explicado porque a umidade é mais alta em dias nublados e chuvosas, 
###   nos quais as nuvens bloqueiam o sol (Diminuindo a temperatura) e a chuva absorve calor 
###   do ar e do chão ao cair.
### - O efeito da Umidade na Sensação Térmica é menos acentuado do que na Temperatura. 
###   Achei isso interessante, e acredito que o aumento da umidade aumente a Sensação Térmica 
###   (pois diminui a capacidade do corpo de resfriar por transpiração), mas que este efeito
###   não seja suficiente para compensar a influencia da Umidade na Temperatura real.
### - Vento e Umidade não possuem correlação significativa. 
###   Isso me surpreendeu, uma vez que ambos parecem estar associados a dias de tempestades.
###
### É claro que as explicações dados acima são apenas palpites. 
### As análises foram superficiais, eu não possuo conhecimentos suficientes no assunto e, é claro, 
### correlação não implica causalidade -- https://xkcd.com/552/


####################################################################################################
### Tendencias sazonais e por horário
### ---------------------------------
###
### Vamos acompanhar como a Temperatura, Umidade e Vento variam em função das estações do ano e hora do dia.

cepagri.facet <- data.frame(Time=c(), Attribute=c(), Value=c())
for (i in correlation.attributes) {
  df <- data.frame(
    Time = cepagri$Time,
    Attribute = i,
    Value = cepagri[[i]])
  cepagri.facet = rbind(cepagri.facet, df)
}

# Recife is also on UTC-3 timezone, but doesn't have DST
cepagri.facet$Time <- as.POSIXlt(with_tz(cepagri.facet$Time, "America/Recife")) 
cepagri.facet$Year <- as.factor(cepagri.facet$Time$year + 1900)
cepagri.facet$Hour <- as.factor(cepagri.facet$Time$hour)
cepagri.facet$Time$year <- 116
cepagri.facet$Time$hour <- 0
cepagri.facet$Time$min <- 0
cepagri.facet$Time$sec <- 0
cepagri.facet$Time <- as.POSIXct(cepagri.facet$Time)
cepagri.facet$Attribute <- as.factor(cepagri.facet$Attribute)


####################################################################################################
### Tendencias Sazonais
###
### Vamos acompanhar como a Temperatura, Umidade e Vento variam em função das estações do ano, 
### em anos diferentes.

p <- ggplot(data=cepagri.facet, aes(x = Time, y = Value, color = Year, fill = Year, group = Year))
p <- p + facet_wrap(~ Attribute, ncol=2, scales = "free_y")
p <- p + geom_smooth(se = F, method = 'gam', formula = y ~ s(x, bs = "cs"))
p

### Através destes gráficos, podemos observar que as medições variam bastante durante o ano, mas
### possuem uma tendencia clara que é consistente entre anos diferentes.
### 
### Como esperávamos, a Temperatura e Sensação Térmica são bem mais altas nos primeiros e últimos 
### meses do ano devido ao verão, e mais baixa nos meses do meio, devido ao inverno.
### 
### Outra medida que não surpreendeu foi a umidade, caindo consideravelmente a partir da metade do 
### ano, quando começa nossa época de estiagem.
### 
### Quanto ao vento, seu padrão de comportamente sazonal não está tão claro quanto os demais
### parâmetros, mas parece que outubro é a melhor época para empinar pipas, seguido de maio ;)


####################################################################################################
### Tendencias de horário
###
### Vamos comparar também como a hora do dia influencia as diferentes medidas.
###
### (Para evitar problemas com o horário de verão, os horários estão sempre em UTC-3)

p <- ggplot(data=cepagri.facet, aes(x = as.numeric(Hour)-0.5, y = Value, group = Hour))
p <- p + facet_wrap(~ Attribute, ncol = 2, scales = "free_y")
p <- p + geom_violin(aes(x = as.numeric(Hour)-0.5, color = Hour, fill = Hour))
p <- p + geom_boxplot(width=0.2, outlier.shape = NA, lwd=0.2)
p <- p + theme(legend.position="none")
p <- p + labs(x = "Hour")
p <- p + scale_x_continuous(breaks=seq(0, 24, 4), limits=c(0,24))
p

### Neste gráfico, podemos ver claramente que a temperatura (Tanto real quanto a sensação térmica) 
### começa a subir logo após o nascer do sol, cerca de 6h, atinge o máximo aproximadamente às 14h, 
### e volta a cair rapidamente no fim da tarde e mais lentamente durante a madrugada, chegando ao 
### mínimo por volta das 5h.
###
### A Umidade é influenciada de forma oposta: Começa a cair ao nascer do sol e continua caindo até
### as 15h, quando atinge seu minimo e começa a aumentar novamente. Note que este compartamento é 
### consistente com a correlação negativa que obtivemos antes entre temperatura e umidade, mas não 
### apoia a hipótese de causa criada naquele momento.
### 
### Quanto ao vento, o horário parece ter uma influência muito menor nele do que nos outros 
### parâmetros. Apesar da influência relativamente pequena, fica claro que venta mais na parte da
### noite, especialmente por volta das 22h.

####################################################################################################
### Tendencias sazonais e por horário simultaneamente
### 
### Podemos também visualizar a influência da Sazonalidade e do Horário simultaneamente.

p <- ggplot(data=cepagri.facet, aes(x = Time, y = Value, color = Hour, fill = Hour, group = Hour))
p <- p + facet_wrap(~ Attribute, ncol=2, scales = "free_y")
p <- p + geom_smooth(se = F, method = 'gam', formula = y ~ s(x, bs = "cs"))
p

### Apesar de muito bonita, esta visualização é bem mais dificil de ler, uma vez que há muita 
### informação concentrada e sobreposta.
### 
### A influência da data e da horá são quase independentes na Temperatura (Real e sensação térmica)
### e na umidade, e podemos chegar nas mesma conclusões obtidas anteriormente.
### 
### Já o vento possui uma iteração mais complicadas: Confirmando as observações anteriores, as 
### épocas de maior ventania ocorrem por volta de Outubro e Maio, e os ventos mais fortes ocorrem
### sempre por volta das 22h.
### 
### Adicionalmente, neste gráfico é possível perceber que as primeiras horas do dia são de calmaria 
### durante o verão e de ventos moderados no inverno, enquanto que o crespúsculo possui vento 
### moderado no verão e calmaria no inverno. Achei essa inversão muito interessante, e consistente 
### com minha experiência pessoal: Durante o verão sempre preciso fechar as janelas no fim da 
### tarde devido à ventania.
