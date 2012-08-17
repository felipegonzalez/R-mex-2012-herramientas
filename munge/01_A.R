# Melt de archivos
archivos.nom <- grep("SIMAT", ls(), value = T)
dat.l <- lapply(archivos.nom, function(nom){ print(nom)
    dat <- eval( parse(text = nom) )
    dat.m <- melt(dat, id.vars = c("FECHA", "HORA"))
    dat.m
})
dat <- Reduce("rbind", dat.l)

# Separar codigo en 3 variables
etiquetas <- as.character(dat$variable)
etiquetas.l <- strsplit(etiquetas ,'_') 
# más lento:  etiquetas.l <- str_split(etiquetas, '_')

# Recodificar valores faltantes
value.2 <- as.numeric(car::recode(dat$value,
    "c(-9.9, -99, -99.9, -999, 'NR')= NA"))
dat$value <- value.2



dat$unidades <- sapply(etiquetas.l, '[', 2)
dat$estacion <- str_sub( sapply(etiquetas.l, '[', 1), -3, -1)
dat$medicion <- str_sub( sapply(etiquetas.l, '[', 1), -10, -4)
dat$medicion.u <- paste(dat$medicion, dat$unidades, sep="_")
dat$variable <- NULL

# Fechas
class(dat$FECHA)
datos$fecha.hora <- strptime(paste(dat$FECHA, dat$HORA), format='%d/%m/%Y %H')
dat$año <- year(datos$fecha.hora)
dat$mes <- month(datos$fecha.hora)
dat$dia <- wday(datos$fecha.hora) # Primer día de la semana es domingo
dat$hora <- hour(datos$fecha.hora)
dat$FECHA <- NULL
cache("datos")