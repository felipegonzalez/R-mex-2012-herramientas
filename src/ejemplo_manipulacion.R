#' Ejemplo de Manipulación de Datos
#' ===

#' ## Lectura de datos y estructura
#' Los datos se leen con la función **get** de **_ProjectTemplate_** y aleatoriamente se escogen algunos reglones y columnas.
#+ getfunction
dat.0 <- get("SIMAT.2005")
set.seed(858764)
dat <- dat.0[ sample(1:nrow(dat.0), 5), c(1:2, sample(3:ncol(dat.0), 5))]
dat

#' Con la función **melt** de **_reshape2_** trasponemos la base por mediciones y estaciones. En total existen 5 bases con las variables: "_FECHA_" y "_HORA_" iguales entre ellas, por lo que la idea es hacerlas horizontales y tener la misma estructura.
#+ meltfunction
library(reshape2)
dat.m <- melt(dat, id.vars = c("FECHA", "HORA"))
dat.m

#' Lo que ahora interesa es la columna "_variable_", cada nombre dice la medicion que se evalúa, la estación donde se evalúa y las unidades de la medición. En este caso los 5 valores de la columna "_variable_" son los siguientes.
#+ tablecodigos, results='asis', echo = F
library(xtable)
codigos <- unique( as.character(dat.m$variable) )
tab.df <- data.frame(codigos)
tab <- xtable(tab.df, align = "cc")
print(tab, type="html", html.table.attributes = "align = 'center'", include.rownames=FALSE)

#' ## Creación de variables
#' Con la librería **_stringr_** se manipulan los códigos para separarlos en las tres variables que interesan. 
library(stringr)
codigos <- unique( as.character(dat.m$variable) )

#' * **str_split_fixed**: separa cada elemento de un vector en cadenas dependiendo del caracter que se indique, lo interesante es que se puede agregar un numero específico de output.
codigos.sep <- str_split_fixed(codigos, '_', n = 2)
codigos.sep

#' De la matríz que se obtiene sólo se extrae la segunda columna.
unidades <- codigos.sep[ , 2]

#' Sin embargo, en la primera columna todavía se necesita extraer subcadenas con un patrón determinado y obtener las dos varibles faltantes, y usamos la función **str_sub**:
#' * **str_sub**: extrae una cadena de un vector siguiendo un patrón indicando las posiciones de inicio y final. El signo negativo indica que las posiciones se invierten. 
estacion <- str_sub(codigos.sep[, 1], start = -3, end = -1)

#' Como ninguna cadena del vector tiene más de 10 posiciones se indica este y tomar las posiciones restantes y en caso de no haber simplemente omitirlo. 
medicion <- str_sub(codigos.sep[ ,1], start = -10, end = -4)

#' Se crea un **data.frame** con las variables _estacion_, _medicion_ y _unidades_. 
temp <- data.frame(variable = codigos,
  estacion = estacion,
  medicion = medicion,
  unidades = unidades )
temp

#' ## Construcción de base
#' Para construir la base se agregan las variables construídas a la base de datos con la función **join** del paquete **_plyr_** que une dos data frames. 
#' En este caso a la base vertical (_dat.m_) le agrega las columnas de la base con las nuevas variables (_temp_) usando la columna común (_variable_) y sólo hay que especificar el tipo de union, el default es por la izquierda, es decir, para todos los valores de _dat.m_ agrega la columna.
#+ joinfunction, message=FALSE
library(plyr)
dat.j <- join(dat.m, temp)
dat.j

#' ## Formato fechas
#' 
#' Por ultimo se preparan las fechas y se convierten en formato "POSIXlt" and "POSIXct" y en esta nueva fecha se agrega la hora del día en la que fue tomada con la funcion **strptime**.
#' Una vez en este formato es muy sencillo extraer el año, mes, día y hora con la librería **_lubridate_** que tienen herramientas para manipular fechas. 
#+ joinfechas, message=FALSE
library(lubridate)
dat.j$fecha.hora <- strptime(paste(dat.j$FECHA, dat.j$HORA - 1), format='%d/%m/%Y %H')
dat.j$año <- year(dat.j$fecha.hora)
dat.j$mes <- month(dat.j$fecha.hora, label = TRUE)
dat.j$dia <- day(dat.j$fecha.hora) 
dat.j$hora <- hour(dat.j$fecha.hora)
dat.j$FECHA <- NULL
head(dat.j)
