

```r
library(plyr)

month.abbr <- months(dmy("01/01/01") + months(0:11), abbreviate = TRUE)
```

```
## Multiple format matches with 1 successes: %d/%m/%y, %d/%m/%Y.
```

```r
month <- factor(rep(month.abbr, length = 72), levels = month.abbr)
year <- rep(1:6, each = 12)

deseasf <- function(value) lm(value ~ month - 1)

models <- alply(ozone, 1:2, deseasf)
coefs <- ldply(models, coef)
deseas <- ldply(models, resid)

head(coefs[, 1:5])
```

```
##     lat   long monthJan monthFeb monthMar
## 1 -21.2 -113.8    264.7    257.7    255.0
## 2 -18.7 -113.8    261.7    259.0    254.7
## 3 -16.2 -113.8    260.3    258.3    253.7
## 4 -13.7 -113.8    258.0    257.3    252.0
## 5 -11.2 -113.8    255.3    255.7    250.3
## 6  -8.7 -113.8    254.0    253.3    248.3
```

```r
head(deseas[, 1:5])
```

```
##     lat   long      1      2          3
## 1 -21.2 -113.8 -4.667 -3.667 -1.000e+00
## 2 -18.7 -113.8 -3.667 -1.000 -6.667e-01
## 3 -16.2 -113.8 -2.333 -4.333  3.333e-01
## 4 -13.7 -113.8 -4.000 -5.333  1.741e-13
## 5 -11.2 -113.8 -3.333 -5.667 -3.333e-01
## 6  -8.7 -113.8 -2.000 -5.333  1.667e+00
```


