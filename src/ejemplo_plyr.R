library(plyr)

month.abbr <- months(dmy("01/01/01") + months(0:11), abbreviate= TRUE)
month <- factor(rep(month.abbr, length = 72), levels = month.abbr)
year <- rep(1:6, each = 12)

deseasf <- function(value) lm(value ~ month - 1)

models <- alply(ozone, 1:2, deseasf)
coefs <- ldply(models, coef)
deseas <- ldply(models, resid) 

head(coefs[, 1:5])
head(deseas[, 1:5])