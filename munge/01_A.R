## Nombres de tablas:
archivos.nom <- paste("SIMAT", 2005:2009, sep = '.')
## también se puede escribir:
## archivos.nom <- c('SIMAT.2000','SIMAT.2001','SIMAT.2002')
## y así sucesivamente.

## Poner las tablas que nos intersan en una lista,
## una vez que trasponemos mediciones y estaciones:
dat.l <- lapply(archivos.nom, function(nom){ 
	print(nom)
    dat <- get(nom)
    dat.m <- melt(dat, id.vars = c("FECHA", "HORA"))
    codigos <- unique(dat.m$variable)
    codigos.sep <- str_split_fixed(codigos, '_', n = 2)
    estacion <- str_sub(codigos.sep[, 1], -3, -1)
    medicion <- str_sub(codigos.sep[ ,1], -10, -4)
    unidades <- codigos.sep[ , 2]
    temp <- data.frame(variable = codigos,
    	estacion = estacion,
    	medicion = medicion,
    	unidades = unidades )
    join(dat.m, temp)
})

## Pegar los archivos en una sola tabla: Reduce es
## recursivo.
print('Pegar tablas')
dat <- Reduce("rbind", dat.l)

print('Codificar valores faltantes')
#value.2 <- as.numeric(car::recode(dat$value,
#    "c(-9.9, -99, -99.9, -999, 'NR')= NA"))
#dat$value <- value.2
faltantes <- c('-9.9', '-99', '-99.9', '-999', 'NR')
dat$value[dat$value %in% faltantes] <- NA
dat$value <- as.numeric(dat$value)

print('Preparar fechas')
dat$fecha.hora <- dmy(dat$FECHA)
dat$año <- year(dat$fecha.hora)
dat$mes <- month(dat$fecha.hora, label = TRUE)
dat$dia <- day(dat$fecha.hora) 
dat$FECHA <- NULL
cache('dat')