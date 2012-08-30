
#' Ejemplo de Manipulación de Datos
#' ===

#' ## Lectura de datos y estructura
#' Los datos se leen con la función **get** de **`ProjectTemplate`**.
#+ getfunction
datos <- get('SIMAT.2005')

#' Los datos están desorganizados: los nombres de las columnas incluyen información acerca de las unidades de medición (estaciones), de las mediciones y de las unidades de medición:
head(datos)

#' Con la función **melt** de **`reshape2`** transponemos la base por mediciones y estaciones. Con esto podemos crear fácilmente identificadores de mediciones y estaciones y extraer las unidades de cada medición. Adicionalmente, podremos pegar de manera segura a las tablas de otros años.  
#+ meltfunction
library(reshape2)
dat.m <- melt(datos, id.vars = c('FECHA', 'HORA'))
head(dat.m)

#' Lo que ahora interesa es la columna '_variable_', cada nombre dice la medicion que se evalúa, la estación donde se evalúa y las unidades de la medición. En este caso los valores de la columna '_variable_' son los siguientes.
# # tablecodigos, results='asis', echo = FALSE, message = FALSE
# library(xtable)
# codigos <- as.character(dat.m$variable)
# tab.df <- data.frame(codigos)
# tab <- xtable(tab.df, align = 'cc')
# print(tab, type='html', html.table.attributes = 'align = 'center'', include.rownames=FALSE)



#' ****
#' 
#' ## Creación de variables
#' Con la librería **`stringr`** se manipulan los códigos para separarlos en las tres variables que interesan. 
#+ codigos
library(stringr)
codigos <- dat.m$variable

#' * **str_split_fixed** 
#' 
#' Separa una cadena en distintas partes siguiendo un patrón, en este caso ('_'), y devuelve las nuevas cadenas en una matriz que además se puede definir la dimensión
#+ str_split_fixed
codigos.sep <- str_split_fixed(dat.m$variable, '_', n = 2)
head(codigos.sep)

#' De la matríz que se obtiene sólo se extrae la segunda columna.
dat.m$unidades <- codigos.sep[ , 2]

#' Sin embargo, en la primera columna todavía se necesita extraer subcadenas con un patrón determinado y obtener las dos varibles faltantes que dependen de las posiciones de los caracteres.
#' * **str_sub** _(equivale a *strsub*)_
#' 
#' Extrae una subcadena indicando las posiciones (número de caracteres) de inicio y final. Las posiciones pueden ser negativas indicando que se cuenta del final hacia el principio de la cadena, y regresa una cadena vacía si no las posiciones no aparecen en la cadena.
dat.m$estacion <- str_sub(codigos.sep[, 1], start = -3, end = -1)

#' Como ninguna cadena del vector tiene más de 10 posiciones las siguientes subcadenas comienzan en su primer caracter:
dat.m$medicion <- str_sub(codigos.sep[ ,1], start = -10, end = -4)
head(dat.m)



#' ****
#' 
#' ## Formato fechas
#' 
#' Por ultimo se preparan las fechas y se convierten en formato 'POSIXlt'.
#' Una vez en este formato es muy sencillo extraer el año, mes, día con la librería **`lubridate`** que tienen herramientas para manipular fechas. 
#+ joinfechas, message=FALSE
library(lubridate)
dat.m$fecha <- dmy(dat.m$FECHA)
dat.m$año <- year(dat.m$fecha)
dat.m$mes <- month(dat.m$fecha, label = TRUE)
dat.m$dia <- day(dat.m$fecha) 
dat.m$FECHA <- NULL
head(dat.m)

#' Finalmente, falta recodificar mediciones faltantes, que en la base original están indicados de varias maneras (-999,-9.9, etc.)):
#+ recodificar, message=FALSE
faltantes <- c('-9.9', '-99', '-99.9', '-999', 'NR')
dat.m$value[dat.m$value %in% faltantes] <- NA
dat.m$value <- as.numeric(dat.m$value)



#' - - - -
#' 
#' ## Referencias
#' 1. John Myles. *Project Template*.
#' URL [http://www.johnmyleswhite.com/notebook/2010/08/26/projecttemplate/](http://www.johnmyleswhite.com/notebook/2010/08/26/projecttemplate/)
#' 2. Hadley Wickham. *Reshape2*.
#' URL [http://had.co.nz/reshape/](http://had.co.nz/reshape/)
#' 3. Hadley Wickham. *Reshaping Data with the reshape Package*.
#' URL [http://www.jstatsoft.org/v21/i12/paper](http://www.jstatsoft.org/v21/i12/paper)
#' 4. Hadley Wickham. *stringr: modern, consistent string processing*.
#' URL [http://journal.r-project.org/archive/2010-2/RJournal_2010-2_Wickham.pdf](http://journal.r-project.org/archive/2010-2/RJournal_2010-2_Wickham.pdf)
#' 5. Grolemund G, Wickham H. *Dates and Times Made Easy with lubridate*. Rice University.
#' URL [http://www.jstatsoft.org/v40/i03/paper](http://www.jstatsoft.org/v40/i03/paper)
#' 6. Hadley Wickham. *The Split-Apply-Combine Strategy for Data Analysis*.
#' URL [http://www.jstatsoft.org/v40/i01/paper](http://www.jstatsoft.org/v40/i01/paper)
#' 7. Hadley Wickham. *Plyr*.
#' URL [http://plyr.had.co.nz/](http://plyr.had.co.nz/)
