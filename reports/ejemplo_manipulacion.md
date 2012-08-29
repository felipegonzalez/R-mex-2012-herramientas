Ejemplo de Manipulación de Datos
===
## Lectura de datos y estructura
Los datos se leen con la función **get** de **`ProjectTemplate`**.


```r
dat <- get("SIMAT.2005")
```


Los datos están desorganizados: los nombres de las columnas incluyen información acerca de las unidades de medición (estaciones), de las mediciones y de las unidades de medición:


```r
head(dat)
```

```
##        FECHA HORA COTLA_.ppm. COMER_.ppm. COPED_.ppm. COUIZ_.ppm.
## 1 01/01/2005    1         5.0         6.4         1.7         2.6
## 2 01/01/2005    2         3.8         4.2         1.9         2.9
## 3 01/01/2005    3         3.0         3.7         2.0         3.5
## 4 01/01/2005    4         3.2         3.5         2.2         4.0
## 5 01/01/2005    5         3.0         3.6         3.1         4.8
## 6 01/01/2005    6         2.7         6.5         4.3         5.4
##   COSAG_.ppm. NO2SAG_.ppb. NO2TLA_.ppb. NO2MER_.ppb. NO2PED_.ppb.
## 1         2.7           65           90           95           38
## 2         2.3           59           71           85           44
## 3         3.9           59           61           77           43
## 4         4.2           61           61           68           53
## 5         3.7           61           60           67           54
## 6         2.2           42           55           67           62
##   NO2UIZ_.ppb. NOXSAG_.ppb. NOXTLA_.ppb. NOXMER_.ppb. NOXPED_.ppb.
## 1           70          117          197          277           40
## 2           65           84          157          193           48
## 3           64          168          117          156           49
## 4           65          178          124          148           66
## 5           61          132          113          143           97
## 6           60           79          101          258          134
##   NOXUIZ_.ppb. O3SAG_.ppb. O3TLA_.ppb. O3MER_.ppb. O3PED_.ppb. O3UIZ_.ppb.
## 1           84           3           1           0          29           8
## 2           94           3           1           0          21           8
## 3          122           3           1           0          25           8
## 4          130           4           1           0          12          10
## 5          158           4           1           1          10           8
## 6          188           3           1           1          10           5
##   SO2SAG_.ppb. SO2TLA_.ppb. SO2MER_.ppb. SO2PED_.ppb. SO2UIZ_.ppb.
## 1           15           53           20           10           19
## 2           17           60           20           13           24
## 3           19           52           18           16           23
## 4           20           41           17           13           24
## 5           22           34           17           12           23
## 6           20           28           20           19           23
##   PM10TLA_.µg.m3. PM10MER_.µg.m3. PM10PED_.µg.m3. PM10SAG_.µg.m3.
## 1             225             136              91             174
## 2             179             158             112             232
## 3             136             169             107             264
## 4             138             161             103             359
## 5             119             182             130             396
## 6             110             274             206             238
##   PM25MER_.µg.m3. PM25TLA_.µg.m3. PM25UIZ_.µg.m3. PM25SAG_.µg.m3.
## 1              99            -999             106             103
## 2             114            -999             120             139
## 3             140            -999             194             186
## 4             137            -999             182             235
## 5             142            -999             265             308
## 6             179            -999             300             371
##   TMPSAG_.gradosC. TMPTLA_.gradosC. TMPMER_.gradosC. TMPPED_.gradosC.
## 1              7.8             11.3             11.2              9.6
## 2              7.1             10.1             10.4              8.5
## 3              6.7              8.9              9.6              8.4
## 4              6.1              8.5              8.9              7.5
## 5              6.3              8.2              8.4              6.7
## 6              5.1              7.8              7.9              7.0
##   HRSAG_... HRTLA_... HRMER_... HRPED_... VVSAG_.m.s. VVTLA_.m.s.
## 1        46        55        55        43         0.5         1.0
## 2        48        58        55        48         0.5         0.7
## 3        50        59        57        49         0.7         0.1
## 4        53        62        58        53         0.7         1.3
## 5        54        63        60        56         1.1         0.4
## 6        51        64        65        57         0.7         0.6
##   VVMER_.m.s. VVPED_.m.s. DVSAG_.grados. DVTLA_.grados. DVMER_.grados.
## 1         0.4         0.7             40            176            134
## 2        -9.9         0.7             20            259           -999
## 3        -9.9         0.6             40            197           -999
## 4        -9.9         0.6             26            266           -999
## 5         0.4         0.9             12            240             56
## 6         0.7         0.8             62            288             83
##   DVPED_.grados.
## 1            214
## 2            247
## 3            267
## 4            278
## 5            274
## 6            274
```


Con la función **melt** de **`reshape2`** transponemos la base por mediciones y estaciones. Con esto podemos crear fácilmente identificadores de mediciones y estaciones y extraer las unidades de cada medición. Adicionalmente, podremos pegar de manera segura a las tablas de otros años.  


```r
library(reshape2)
dat.m <- melt(dat, id.vars = c("FECHA", "HORA"))
head(dat.m)
```

```
##        FECHA HORA    variable value
## 1 01/01/2005    1 COTLA_.ppm.   5.0
## 2 01/01/2005    2 COTLA_.ppm.   3.8
## 3 01/01/2005    3 COTLA_.ppm.   3.0
## 4 01/01/2005    4 COTLA_.ppm.   3.2
## 5 01/01/2005    5 COTLA_.ppm.   3.0
## 6 01/01/2005    6 COTLA_.ppm.   2.7
```


Lo que ahora interesa es la columna '_variable_', cada nombre dice la medicion que se evalúa, la estación donde se evalúa y las unidades de la medición. En este caso los valores de la columna '_variable_' son los siguientes.


```r
# # tablecodigos, results='asis', echo = F library(xtable) codigos <-# as.character(dat.m$variable) tab.df <- data.frame(codigos) tab <-# xtable(tab.df, align = 'cc') print(tab, type='html',# html.table.attributes = 'align = 'center'', include.rownames=FALSE)
```


****

## Creación de variables
Con la librería **`stringr`** se manipulan los códigos para separarlos en las tres variables que interesan. 


```r
library(stringr)
codigos <- dat.m$variable
```


* **str_split_fixed** 

Separa una cadena en distintas partes siguiendo un patrón, en este caso ('_'), y devuelve las nuevas cadenas en una matriz que además se puede definir la dimensión


```r
codigos.sep <- str_split_fixed(dat.m$variable, "_", n = 2)
head(codigos.sep)
```

```
##      [,1]    [,2]   
## [1,] "COTLA" ".ppm."
## [2,] "COTLA" ".ppm."
## [3,] "COTLA" ".ppm."
## [4,] "COTLA" ".ppm."
## [5,] "COTLA" ".ppm."
## [6,] "COTLA" ".ppm."
```


De la matríz que se obtiene sólo se extrae la segunda columna.


```r
dat.m$unidades <- codigos.sep[, 2]
```


Sin embargo, en la primera columna todavía se necesita extraer subcadenas con un patrón determinado y obtener las dos varibles faltantes que dependen de las posiciones de los caracteres.
* **str_sub** _(equivale a *strsub*)_

Extrae una subcadena indicando las posiciones (número de caracteres) de inicio y final. Las posiciones pueden ser negativas indicando que se cuenta del final hacia el principio de la cadena, y regresa una cadena vacía si no las posiciones no aparecen en la cadena.


```r
dat.m$estacion <- str_sub(codigos.sep[, 1], start = -3, end = -1)
```


Como ninguna cadena del vector tiene más de 10 posiciones las siguientes subcadenas comienzan en su primer caracter:


```r
dat.m$medicion <- str_sub(codigos.sep[, 1], start = -10, end = -4)
head(dat.m)
```

```
##        FECHA HORA    variable value unidades estacion medicion
## 1 01/01/2005    1 COTLA_.ppm.   5.0    .ppm.      TLA       CO
## 2 01/01/2005    2 COTLA_.ppm.   3.8    .ppm.      TLA       CO
## 3 01/01/2005    3 COTLA_.ppm.   3.0    .ppm.      TLA       CO
## 4 01/01/2005    4 COTLA_.ppm.   3.2    .ppm.      TLA       CO
## 5 01/01/2005    5 COTLA_.ppm.   3.0    .ppm.      TLA       CO
## 6 01/01/2005    6 COTLA_.ppm.   2.7    .ppm.      TLA       CO
```


****

## Formato fechas

Por ultimo se preparan las fechas y se convierten en formato 'POSIXlt'.
Una vez en este formato es muy sencillo extraer el año, mes, día con la librería **`lubridate`** que tienen herramientas para manipular fechas. 


```r
library(lubridate)
dat.m$fecha <- dmy(dat.m$FECHA)
dat.m$año <- year(dat.m$fecha)
dat.m$mes <- month(dat.m$fecha, label = TRUE)
dat.m$dia <- day(dat.m$fecha)
dat.m$FECHA <- NULL
head(dat.m)
```

```
##   HORA    variable value unidades estacion medicion      fecha  año mes
## 1    1 COTLA_.ppm.   5.0    .ppm.      TLA       CO 2005-01-01 2005 Jan
## 2    2 COTLA_.ppm.   3.8    .ppm.      TLA       CO 2005-01-01 2005 Jan
## 3    3 COTLA_.ppm.   3.0    .ppm.      TLA       CO 2005-01-01 2005 Jan
## 4    4 COTLA_.ppm.   3.2    .ppm.      TLA       CO 2005-01-01 2005 Jan
## 5    5 COTLA_.ppm.   3.0    .ppm.      TLA       CO 2005-01-01 2005 Jan
## 6    6 COTLA_.ppm.   2.7    .ppm.      TLA       CO 2005-01-01 2005 Jan
##   dia
## 1   1
## 2   1
## 3   1
## 4   1
## 5   1
## 6   1
```


Finalmente, falta recodificar mediciones faltantes, que en la base original están indicados de varias maneras (-999,-9.9, etc.)):


```r
faltantes <- c("-9.9", "-99", "-99.9", "-999", "NR")
dat.m$value[dat.m$value %in% faltantes] <- NA
dat.m$value <- as.numeric(dat.m$value)
```


- - - -

## Referencias
1. Myles, John. *Project Template*.
URL [http://www.johnmyleswhite.com/notebook/2010/08/26/projecttemplate/](http://www.johnmyleswhite.com/notebook/2010/08/26/projecttemplate/)
2. Grolemund G, Wickham H. *Dates and Times Made Easy with lubridate*. Rice University.
URL [http://www.jstatsoft.org/v40/i01/paper](http://www.jstatsoft.org/v40/i01/paper).
3. Wickham, Hadley. *stringr: modern, consistent string processing*.
URL [http://journal.r-project.org/archive/2010-2/RJournal_2010-2_Wickham.pdf](http://journal.r-project.org/archive/2010-2/RJournal_2010-2_Wickham.pdf)
