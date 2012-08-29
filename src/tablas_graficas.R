
#' # Exploración de datos de SIMAT 2000-2009
#' 
head(dat)

#' Análisis de datos faltantes por hora, año y estación. Obsérvese que hay más faltantes alrededor de la mitad del día en varias mediciones.
#+ cache = T
tab.faltantes <- ddply(dat, c('hora', 'estacion', 'medicion' ,'año'), 
	summarise,
	no.faltantes = sum(is.na(value)),
	prop.faltantes = sum(is.na(value))/length(value))
tab.faltantes.1 <- subset(tab.faltantes, 
	medicion %in% c('NO2','NOX','O3','CO') )
ggplot(tab.faltantes.1, 
	aes(x=hora, y=prop.faltantes, colour= año, group=año)) +
	geom_line() + facet_grid(estacion~medicion)


#' Usar dcast para trasponer mediciones en columnas, como es más usual.
dat.c <- dcast(dat, estacion + año + mes + dia + hora ~ medicion, value.var='value')
#' Filtramos 4 meses y 3 horas del día para nuestro análisis.
dat.c.sub <- subset(dat.c, 
	hora %in% c(12,15,18) & mes %in% c('Jan','Mar','Jul','Oct'))


#' Relación de temperatura y ozono en cada estación, mes y hora del día:

#+ warning = F
ggplot(dat.c.sub, aes(x = TMP, y = O3, colour=estacion)) + 
	facet_grid(hora~mes) +
	geom_point() + 
	geom_smooth(method = 'loess')


#' Podemos mejorar la gráfica haciendo modificaciones al *default* anterior:

#+ warning = F
ggplot(dat.c.sub, aes(x = TMP, y = O3, colour=estacion)) + 
	facet_grid(hora~mes, scales = "free") +
	geom_point(alpha=0.2, size=2) + 
	geom_smooth(method='loess', span=1.2, size=0.7)




#' Modelo por estacion y medicion
library(gtools)
library(arm)
library(splines)


ggplot(subset(dat, año = 2005), aes(x = fecha.hora, y = value, group = estacion, colour = estacion)) + 
  geom_line()+
  facet_wrap(~medicion)

table(dat$estacion, dat$medicion)
modelos <- dlply(dat, c('medicion', 'estacion'), 
    function(df){
       if(nrow(df) > 1){
           mod.1 <- bayesglm(value ~ mes + hora + año, data = df)
           mod.1
       }    
    }, .progress = "text")   
class(modelos)
length(modelos)
coeficientes <- ldply(modelos, coef)
head(coeficientes)


promedio.mediana <- ddply(dat, c('estacion','medicion'), summarise,
      prom = mean(value, na.rm = T), 
      median = median(value, na.rm = T))
ggplot(promedio.mediana, aes(x = prom, y = median, label = estacion, colour = estacion)) +
  geom_point(alpha = .5) + 
  geom_text() + 
  facet_wrap(~medicion, scales = "free") + 
  geom_smooth(aes(group = 1), method = "lm")


# Un mes
promedios.mes <- ddply(dat, c('estacion','medicion', 'mes'), summarise,
                       prom = mean(value, na.rm = T), 
                       median = median(value, na.rm = T), .progress = "text")
tt <- join(coeficientes, subset(promedios.mes, mes == 'Jan') )
tt.2 <- ddply(tt, 'medicion', transform, med.coef = median(mesJan),  med.prom = median(prom))

ggplot(tt.2, aes(x = mesJan, y = prom, label = estacion)) +
  geom_point(alpha = .3) + 
  geom_text(size = 3) + 
  facet_wrap(~medicion,  scales = 'free') +
  geom_vline( aes(xintercept = med.coef), linetype = 2) +
  geom_hline( aes(yintercept = med.prom), linetype = 2)

ggplot(tt, aes(x = año, y = hora, label = estacion)) +
  geom_point(alpha = .3) + 
  geom_text(size = 3) + 
  facet_wrap(~medicion,  scales = 'free')


#' - - - -
#' 
#' ## Referencias
#' * Hadley Wickham. *The Split-Apply-Combine Strategy for Data Analysis*.
#' URL [http://www.jstatsoft.org/v40/i03/paper](http://www.jstatsoft.org/v40/i03/paper) 
#' * Hadley Wickham. *ggplot2: Elegant Graphics for Data Analysis (Use R!)*.
#' Springer. 2009.
