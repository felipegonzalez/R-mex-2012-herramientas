Ejemplo de Manipulación de Datos
===
## Lectura de datos y estructura
Los datos se leen con la función **get** de **`ProjectTemplate`** y aleatoriamente se escogen cinco reglones y columnas.


```r
dat.0 <- get("SIMAT.2005")
set.seed(858764)
dat <- dat.0[sample(1:nrow(dat.0), 5), c(1:2, sample(3:ncol(dat.0), 5))]
dat
```

```
##           FECHA HORA NOXUIZ_.ppb. PM25UIZ_.µg.m3. SO2PED_.ppb. VVPED_.m.s.
## 7801 22/11/2005    1           60              39           56         1.1
## 7809 22/11/2005    9           93              42           95         0.7
## 3446 24/05/2005   14           42              44            3         1.4
## 7640 15/11/2005    8          304              31           12         0.4
## 1507 04/03/2005   19           31              13            0         2.4
##      VVSAG_.m.s.
## 7801         2.4
## 7809         3.0
## 3446         1.5
## 7640         1.1
## 1507        -9.9
```


Con la función **melt** de **`reshape2`** transponemos la base por mediciones y estaciones. 
La extracción de la base tiene dos variables: "_FECHA_" y "_HORA_". Esto funciona para tener la misma estructura en todos los años que se leyeron. 


```r
library(reshape2)
dat.m <- melt(dat, id.vars = c("FECHA", "HORA"))
dat.m
```

```
##         FECHA HORA        variable value
## 1  22/11/2005    1    NOXUIZ_.ppb.  60.0
## 2  22/11/2005    9    NOXUIZ_.ppb.  93.0
## 3  24/05/2005   14    NOXUIZ_.ppb.  42.0
## 4  15/11/2005    8    NOXUIZ_.ppb. 304.0
## 5  04/03/2005   19    NOXUIZ_.ppb.  31.0
## 6  22/11/2005    1 PM25UIZ_.µg.m3.  39.0
## 7  22/11/2005    9 PM25UIZ_.µg.m3.  42.0
## 8  24/05/2005   14 PM25UIZ_.µg.m3.  44.0
## 9  15/11/2005    8 PM25UIZ_.µg.m3.  31.0
## 10 04/03/2005   19 PM25UIZ_.µg.m3.  13.0
## 11 22/11/2005    1    SO2PED_.ppb.  56.0
## 12 22/11/2005    9    SO2PED_.ppb.  95.0
## 13 24/05/2005   14    SO2PED_.ppb.   3.0
## 14 15/11/2005    8    SO2PED_.ppb.  12.0
## 15 04/03/2005   19    SO2PED_.ppb.   0.0
## 16 22/11/2005    1     VVPED_.m.s.   1.1
## 17 22/11/2005    9     VVPED_.m.s.   0.7
## 18 24/05/2005   14     VVPED_.m.s.   1.4
## 19 15/11/2005    8     VVPED_.m.s.   0.4
## 20 04/03/2005   19     VVPED_.m.s.   2.4
## 21 22/11/2005    1     VVSAG_.m.s.   2.4
## 22 22/11/2005    9     VVSAG_.m.s.   3.0
## 23 24/05/2005   14     VVSAG_.m.s.   1.5
## 24 15/11/2005    8     VVSAG_.m.s.   1.1
## 25 04/03/2005   19     VVSAG_.m.s.  -9.9
```


Lo que ahora interesa es la columna "_variable_", cada nombre dice la medicion que se evalúa, la estación donde se evalúa y las unidades de la medición. En este caso los 5 valores de la columna "_variable_" son los siguientes.

<!-- html table generated in R 2.15.1 by xtable 1.7-0 package -->
<!-- Tue Aug 28 11:41:54 2012 -->
<TABLE align = 'center'>
<TR> <TH> codigos </TH>  </TR>
  <TR> <TD align="center"> NOXUIZ_.ppb. </TD> </TR>
  <TR> <TD align="center"> PM25UIZ_.µg.m3. </TD> </TR>
  <TR> <TD align="center"> SO2PED_.ppb. </TD> </TR>
  <TR> <TD align="center"> VVPED_.m.s. </TD> </TR>
  <TR> <TD align="center"> VVSAG_.m.s. </TD> </TR>
   </TABLE>


****

## Creación de variables
Con la librería **`stringr`** se manipulan los códigos para separarlos en las tres variables que interesan. 


```r
library(stringr)
codigos <- unique(as.character(dat.m$variable))
```


* **str_split_fixed** 

Separa una cadena en distintas partes siguiendo un patrón, en este caso ("_"), y devuelve las nuevas cadenas en una matriz que además se puede definir la dimensión


```r
codigos.sep <- str_split_fixed(codigos, "_", n = 2)
codigos.sep
```

```
##      [,1]      [,2]     
## [1,] "NOXUIZ"  ".ppb."  
## [2,] "PM25UIZ" ".µg.m3."
## [3,] "SO2PED"  ".ppb."  
## [4,] "VVPED"   ".m.s."  
## [5,] "VVSAG"   ".m.s."  
```


De la matríz que se obtiene sólo se extrae la segunda columna.


```r
unidades <- codigos.sep[, 2]
```


Sin embargo, en la primera columna todavía se necesita extraer subcadenas con un patrón determinado y obtener las dos varibles faltantes que dependen de las posiciones de los caracteres.
* **str_sub** _(equivale a *strsub*)_

Extrae una cadena de un vector siguiendo un patrón indicando las posiciones de inicio y final. Difiere en que regresa un vector de longitud cero si no existe el patrón y se puede usar signo negativo para indicar que las posiciones se invierten. 


```r
estacion <- str_sub(codigos.sep[, 1], start = -3, end = -1)
```


Como ninguna cadena del vector tiene más de 10 posiciones se indica este y tomar las posiciones restantes y en caso de no haber simplemente lo omite 


```r
medicion <- str_sub(codigos.sep[, 1], start = -10, end = -4)
```


Se crea un **data.frame** con las variables _estacion_, _medicion_ y _unidades_. 


```r
temp <- data.frame(variable = codigos, estacion = estacion, medicion = medicion, 
    unidades = unidades)
temp
```

```
##          variable estacion medicion unidades
## 1    NOXUIZ_.ppb.      UIZ      NOX    .ppb.
## 2 PM25UIZ_.µg.m3.      UIZ     PM25  .µg.m3.
## 3    SO2PED_.ppb.      PED      SO2    .ppb.
## 4     VVPED_.m.s.      PED       VV    .m.s.
## 5     VVSAG_.m.s.      SAG       VV    .m.s.
```


****

## Construcción de base
Para construir la base se agregan las variables construídas a la base de datos con la función **join** del paquete **`plyr`** que une dos data frames. 
En este caso a la base vertical (_dat.m_) le agrega las columnas de la base con las nuevas variables (_temp_) usando la columna común (_variable_) y sólo hay que especificar el tipo de union, el default es por la izquierda, es decir, para todos los valores de _dat.m_ agrega la columna.


```r
library(plyr)
dat.j <- join(dat.m, temp)
dat.j
```

```
##         FECHA HORA        variable value estacion medicion unidades
## 1  22/11/2005    1    NOXUIZ_.ppb.  60.0      UIZ      NOX    .ppb.
## 2  22/11/2005    9    NOXUIZ_.ppb.  93.0      UIZ      NOX    .ppb.
## 3  24/05/2005   14    NOXUIZ_.ppb.  42.0      UIZ      NOX    .ppb.
## 4  15/11/2005    8    NOXUIZ_.ppb. 304.0      UIZ      NOX    .ppb.
## 5  04/03/2005   19    NOXUIZ_.ppb.  31.0      UIZ      NOX    .ppb.
## 6  22/11/2005    1 PM25UIZ_.µg.m3.  39.0      UIZ     PM25  .µg.m3.
## 7  22/11/2005    9 PM25UIZ_.µg.m3.  42.0      UIZ     PM25  .µg.m3.
## 8  24/05/2005   14 PM25UIZ_.µg.m3.  44.0      UIZ     PM25  .µg.m3.
## 9  15/11/2005    8 PM25UIZ_.µg.m3.  31.0      UIZ     PM25  .µg.m3.
## 10 04/03/2005   19 PM25UIZ_.µg.m3.  13.0      UIZ     PM25  .µg.m3.
## 11 22/11/2005    1    SO2PED_.ppb.  56.0      PED      SO2    .ppb.
## 12 22/11/2005    9    SO2PED_.ppb.  95.0      PED      SO2    .ppb.
## 13 24/05/2005   14    SO2PED_.ppb.   3.0      PED      SO2    .ppb.
## 14 15/11/2005    8    SO2PED_.ppb.  12.0      PED      SO2    .ppb.
## 15 04/03/2005   19    SO2PED_.ppb.   0.0      PED      SO2    .ppb.
## 16 22/11/2005    1     VVPED_.m.s.   1.1      PED       VV    .m.s.
## 17 22/11/2005    9     VVPED_.m.s.   0.7      PED       VV    .m.s.
## 18 24/05/2005   14     VVPED_.m.s.   1.4      PED       VV    .m.s.
## 19 15/11/2005    8     VVPED_.m.s.   0.4      PED       VV    .m.s.
## 20 04/03/2005   19     VVPED_.m.s.   2.4      PED       VV    .m.s.
## 21 22/11/2005    1     VVSAG_.m.s.   2.4      SAG       VV    .m.s.
## 22 22/11/2005    9     VVSAG_.m.s.   3.0      SAG       VV    .m.s.
## 23 24/05/2005   14     VVSAG_.m.s.   1.5      SAG       VV    .m.s.
## 24 15/11/2005    8     VVSAG_.m.s.   1.1      SAG       VV    .m.s.
## 25 04/03/2005   19     VVSAG_.m.s.  -9.9      SAG       VV    .m.s.
```


****

## Formato fechas

Por ultimo se preparan las fechas y se convierten en formato "POSIXlt" and "POSIXct" y en esta nueva fecha se agrega la hora del día en la que fue tomada con la funcion **strptime**.
Una vez en este formato es muy sencillo extraer el año, mes, día y hora con la librería **`lubridate`** que tienen herramientas para manipular fechas. 


```r
library(lubridate)
dat.j$fecha.hora <- strptime(paste(dat.j$FECHA, dat.j$HORA - 1), format = "%d/%m/%Y %H")
dat.j$año <- year(dat.j$fecha.hora)
dat.j$mes <- month(dat.j$fecha.hora, label = TRUE)
dat.j$dia <- day(dat.j$fecha.hora)
dat.j$hora <- hour(dat.j$fecha.hora)
dat.j$FECHA <- NULL
head(dat.j)
```

```
##   HORA        variable value estacion medicion unidades
## 1    1    NOXUIZ_.ppb.    60      UIZ      NOX    .ppb.
## 2    9    NOXUIZ_.ppb.    93      UIZ      NOX    .ppb.
## 3   14    NOXUIZ_.ppb.    42      UIZ      NOX    .ppb.
## 4    8    NOXUIZ_.ppb.   304      UIZ      NOX    .ppb.
## 5   19    NOXUIZ_.ppb.    31      UIZ      NOX    .ppb.
## 6    1 PM25UIZ_.µg.m3.    39      UIZ     PM25  .µg.m3.
##            fecha.hora  año mes dia hora
## 1 2005-11-22 00:00:00 2005 Nov  22    0
## 2 2005-11-22 08:00:00 2005 Nov  22    8
## 3 2005-05-24 13:00:00 2005 May  24   13
## 4 2005-11-15 07:00:00 2005 Nov  15    7
## 5 2005-03-04 18:00:00 2005 Mar   4   18
## 6 2005-11-22 00:00:00 2005 Nov  22    0
```


****

## `Libraries`
- - - -

## Referencias
1. Grolemund G, Wickham H. *Dates and Times Made Easy with lubridate*. Rice University.
URL [http://www.jstatsoft.org/v40/i01/paper](http://www.jstatsoft.org/v40/i01/paper).
2. Wickham, Hadley. *The Split-Apply-Combine Strategy for Data Analysis*.
URL [http://www.jstatsoft.org/v40/i03/paper](http://www.jstatsoft.org/v40/i03/paper) 
3. Wickham, Hadley. *stringr: modern, consistent string processing*.
URL [http://journal.r-project.org/archive/2010-2/RJournal_2010-2_Wickham.pdf](http://journal.r-project.org/archive/2010-2/RJournal_2010-2_Wickham.pdf)
