# Exploración de datos de SIMAT 2000-2009


```r
head(dat)
```

```
##   HORA    variable value estacion medicion unidades          fecha.hora
## 1    1 COTLA_.ppm.   5.0      TLA       CO    .ppm. 2005-01-01 00:00:00
## 2    2 COTLA_.ppm.   3.8      TLA       CO    .ppm. 2005-01-01 01:00:00
## 3    3 COTLA_.ppm.   3.0      TLA       CO    .ppm. 2005-01-01 02:00:00
## 4    4 COTLA_.ppm.   3.2      TLA       CO    .ppm. 2005-01-01 03:00:00
## 5    5 COTLA_.ppm.   3.0      TLA       CO    .ppm. 2005-01-01 04:00:00
## 6    6 COTLA_.ppm.   2.7      TLA       CO    .ppm. 2005-01-01 05:00:00
##    año mes dia hora
## 1 2005 Jan   1    0
## 2 2005 Jan   1    1
## 3 2005 Jan   1    2
## 4 2005 Jan   1    3
## 5 2005 Jan   1    4
## 6 2005 Jan   1    5
```


Análisis de datos faltantes por hora, año y estación. Obsérvese que hay más faltantes alrededor de la mitad del día en varias mediciones.


```r
tab.faltantes <- ddply(dat, c("hora", "estacion", "medicion", "año"), summarise, 
    no.faltantes = sum(is.na(value)), prop.faltantes = sum(is.na(value))/length(value))
```


Gráficas 


```r
tab.faltantes.1 <- subset(tab.faltantes, medicion %in% c("NO2", "NOX", "O3", 
    "CO"))
ggplot(tab.faltantes.1, aes(x = hora, y = prop.faltantes, colour = año, group = año)) + 
    geom_line() + facet_grid(estacion ~ medicion)
```

![plot of chunk grafica](figure/grafica.png) 


Usar dcast para trasponer mediciones en columnas, como es más usual.


```r
dat.c <- dcast(dat, estacion + año + mes + dia + hora ~ medicion, value.var = "value")
```


Filtramos 4 meses y 3 horas del día para nuestro análisis.


```r
dat.c.sub <- subset(dat.c, hora %in% c(12, 15, 18) & mes %in% c("Jan", "Mar", 
    "Jul", "Oct"))
```


Relación de temperatura y ozono en cada estación, mes y hora del día:


```r
ggplot(dat.c.sub, aes(x = TMP, y = O3, colour = estacion)) + facet_grid(hora ~ 
    mes) + geom_point() + geom_smooth(method = "loess")
```

![plot of chunk graficatempozono](figure/graficatempozono.png) 


Podemos mejorar la gráfica haciendo modificaciones al *default* anterior:


```r
ggplot(dat.c.sub, aes(x = TMP, y = O3, colour = estacion)) + facet_grid(hora ~ 
    mes, scales = "free") + geom_point(alpha = 0.2, size = 2) + geom_smooth(method = "loess", 
    span = 1.2, size = 0.7)
```

![plot of chunk graficatempozonomod](figure/graficatempozonomod.png) 


- - - -

## Referencias
* Hadley Wickham. *The Split-Apply-Combine Strategy for Data Analysis*.
URL [http://www.jstatsoft.org/v40/i03/paper](http://www.jstatsoft.org/v40/i03/paper) 
* Hadley Wickham. *ggplot2: Elegant Graphics for Data Analysis (Use R!)*.
Springer. 2009.
