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
tab.faltantes.1 <- subset(tab.faltantes, medicion %in% c("NO2", "NOX", "O3", 
    "CO"))
ggplot(tab.faltantes.1, aes(x = hora, y = prop.faltantes, colour = año, group = año)) + 
    geom_line() + facet_grid(estacion ~ medicion)
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.png) 


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

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 


Podemos mejorar la gráfica haciendo modificaciones al *default* anterior:


```r
ggplot(dat.c.sub, aes(x = TMP, y = O3, colour = estacion)) + facet_grid(hora ~ 
    mes, scales = "free") + geom_point(alpha = 0.2, size = 2) + geom_smooth(method = "loess", 
    span = 1.2, size = 0.7)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 


Modelo por estacion y medicion


```r
library(gtools)
library(arm)
```

```
## Loading required package: MASS
```

```
## Loading required package: Matrix
```

```
## Loading required package: lattice
```

```
## Loading required package: lme4
```

```
## Attaching package: 'lme4'
```

```
## The following object(s) are masked from 'package:stats':
## 
## AIC, BIC
```

```
## Loading required package: R2WinBUGS
```

```
## Loading required package: coda
```

```
## Attaching package: 'coda'
```

```
## The following object(s) are masked from 'package:lme4':
## 
## HPDinterval
```

```
## Loading required package: abind
```

```
## Loading required package: foreign
```

```
## arm (Version 1.5-05, built: 2012-6-6)
```

```
## Working directory is /Users/sonia/Repositorios/R-mex-2012-herramientas/src
```

```
## Attaching package: 'arm'
```

```
## The following object(s) are masked from 'package:coda':
## 
## traceplot
```

```r
library(splines)


ggplot(subset(dat, año = 2005), aes(x = fecha.hora, y = value, group = estacion, 
    colour = estacion)) + geom_line() + facet_wrap(~medicion)
```

```
## Warning: Removed 2871 rows containing missing values (geom_path).
```

```
## Warning: Removed 6295 rows containing missing values (geom_path).
```

```
## Warning: Removed 84 rows containing missing values (geom_path).
```

```
## Warning: Removed 2873 rows containing missing values (geom_path).
```

```
## Warning: Removed 2871 rows containing missing values (geom_path).
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-71.png) 

```r

table(dat$estacion, dat$medicion)
```

```
##      
##          CO    DV    HR   NO2   NOX    O3  PM10  PM25   SO2   TMP    VV
##   MER 43824 43824 43824 43824 43824 43824 43824 43824 43824 43824 43824
##   PED 43824 43824 43824 43824 43824 43824 43824     0 43824 43824 43824
##   SAG 43824 43824 43824 43824 43824 43824 43824 43824 43824 43824 43824
##   TLA 43824 43824 43824 43824 43824 43824 43824 43824 43824 43824 43824
##   UIZ 43824     0     0 43824 43824 43824     0 43824 43824     0     0
```

```r
modelos <- dlply(dat, c("medicion", "estacion"), function(df) {
    if (nrow(df) > 1) {
        mod.1 <- bayesglm(value ~ mes + hora + año, data = df)
        mod.1
    }
}, .progress = "text")
```

```
## 
```

```r
class(modelos)
```

```
## [1] "list"
```

```r
length(modelos)
```

```
## [1] 49
```

```r
coeficientes <- ldply(modelos, coef)
head(coeficientes)
```

```
##   medicion estacion (Intercept)  mesFeb  mesMar  mesApr  mesMay  mesJun
## 1       CO      MER       175.1 -0.1838 -0.5194 -0.4017 -0.5019 -0.6860
## 2       CO      PED       477.1 -0.1314 -0.2715 -0.3445 -0.3219 -0.4461
## 3       CO      SAG       209.2 -0.1022 -0.2264 -0.4680 -0.6413 -0.6667
## 4       CO      TLA       328.2 -0.1177 -0.2507 -0.4005 -0.4970 -0.6824
## 5       CO      UIZ       160.2 -0.2008 -0.4599 -0.4800 -0.4882 -0.4439
## 6       DV      MER    -18949.1 -6.1100 -5.0785 -3.6535 -6.3814 -1.0535
##    mesJul  mesAug  mesSep  mesOct  mesNov    mesDec      hora      año
## 1 -0.4552 -0.6562 -0.7424 -0.6042 -0.2844  0.037604 -0.005655 -0.08635
## 2 -0.4761 -0.4838 -0.4721 -0.4465 -0.3346 -0.036599  0.006220 -0.23722
## 3 -0.7990 -0.6539 -0.7046 -0.6189 -0.3350  0.105360 -0.005648 -0.10352
## 4 -0.7495 -0.7162 -0.6694 -0.6302 -0.4410 -0.008167 -0.001005 -0.16279
## 5 -0.5157 -0.3675 -0.4630 -0.4746 -0.2077  0.047445 -0.009927 -0.07905
## 6  6.6997 15.9228 32.3072 27.0609 18.4355 -3.258801  0.253034  9.52664
```

```r


promedio.mediana <- ddply(dat, c("estacion", "medicion"), summarise, prom = mean(value, 
    na.rm = T), median = median(value, na.rm = T))
ggplot(promedio.mediana, aes(x = prom, y = median, label = estacion, colour = estacion)) + 
    geom_point(alpha = 0.5) + geom_text() + facet_wrap(~medicion, scales = "free") + 
    geom_smooth(aes(group = 1), method = "lm")
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-72.png) 

```r


# Un mes
promedios.mes <- ddply(dat, c("estacion", "medicion", "mes"), summarise, prom = mean(value, 
    na.rm = T), median = median(value, na.rm = T), .progress = "text")
```

```
## 
```

```r
tt <- join(coeficientes, subset(promedios.mes, mes == "Jan"))
```

```
## Joining by: medicion, estacion
```

```r
tt.2 <- ddply(tt, "medicion", transform, med.coef = median(mesJan), med.prom = median(prom))
```

```
## Error: object 'mesJan' not found
```

```r

ggplot(tt.2, aes(x = mesJan, y = prom, label = estacion)) + geom_point(alpha = 0.3) + 
    geom_text(size = 3) + facet_wrap(~medicion, scales = "free") + geom_vline(aes(xintercept = med.coef), 
    linetype = 2) + geom_hline(aes(yintercept = med.prom), linetype = 2)
```

```
## Error: object 'tt.2' not found
```

```r

ggplot(tt, aes(x = año, y = hora, label = estacion)) + geom_point(alpha = 0.3) + 
    geom_text(size = 3) + facet_wrap(~medicion, scales = "free")
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-73.png) 


- - - -

## Referencias
* Hadley Wickham. *The Split-Apply-Combine Strategy for Data Analysis*.
URL [http://www.jstatsoft.org/v40/i03/paper](http://www.jstatsoft.org/v40/i03/paper) 
* Hadley Wickham. *ggplot2: Elegant Graphics for Data Analysis (Use R!)*.
Springer. 2009.