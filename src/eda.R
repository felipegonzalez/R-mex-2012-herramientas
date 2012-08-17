library('ProjectTemplate')
load.project()

summary(datos)
head(datos)

df <- ddply(datos, c("medicion", "estacion", "FECHA"), summarise, promedio = mean(value), .progress = "text")