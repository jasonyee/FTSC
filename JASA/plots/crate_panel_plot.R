path_rda <- "Y:/Users/Jialin Yi/output/paper simulation/JASA/data/"

## low random effect, low noise
nSim = 10
Group_size = 100
var_random1 = 200
var_random2 = 100
var_random3 = 100
var_noise = 1
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3)
                   ,toString(var_noise), sep = "-")
load(paste(path_rda,name_file,".Rdata",sep = ""))
LRLN <- CRates.Data

## low random effect, high noise
nSim = 10
Group_size = 100
var_random1 = 200
var_random2 = 100
var_random3 = 100
var_noise = 2
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3)
                   ,toString(var_noise), sep = "-")
load(paste(path_rda,name_file,".Rdata",sep = ""))
LRHN <- CRates.Data


## Heterogeneous RF, low noise
nSim = 10
Group_size = 100
var_random1 = 200
var_random2 = 200
var_random3 = 200
var_noise = 1
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3)
                   ,toString(var_noise), sep = "-")
load(paste(path_rda,name_file,".Rdata",sep = ""))
HRLN <- CRates.Data

## Heterogeneous RF, high noise
# nSim = 10
# Group_size = 100
# var_random1 = 200
# var_random2 = 200
# var_random3 = 200
# var_noise = 2
# name_file <- paste(toString(nSim), toString(Group_size), 
#                    toString(var_random1), toString(var_random2), toString(var_random3)
#                    ,toString(var_noise), sep = "-")
# load(paste(path_rda,name_file,".Rdata",sep = ""))
# HRHN <- CRates.Data

## 2-by-2 panel
op <- par(mfrow = c(1,3),
          oma = c(5,4,0,0) + 0.1,
          mar = c(0,0,1,1) + 0.1)
lims <- c(0.6, 1)
margin <- -.6
# Upper Left
plot(LRLN$Method, LRLN$CRate, lims=lims, axes=FALSE)
axis(1, at=0:4, 
     labels=c(" ", "FTSC", "FunHDDC", "k-means", " "))
axis(2, at=c(0.6, 0.7, 0.8, 0.9, 1.0), labels=TRUE)
mtext("(1)", line = margin )
# Upper Right
plot(LRHN$Method, LRHN$CRate, lims=lims, axes=FALSE)
axis(1, at=0:4, 
     labels=c(" ", "FTSC", "FunHDDC", "k-means", " "))
axis(2, at=c(0.6, 0.7, 0.8, 0.9, 1.0), labels=FALSE)
mtext("(2)", line = margin )
# Lower Left
plot(HRLN$Method, HRLN$CRate, lims=lims, axes=FALSE)
axis(1, at=0:4,
     labels=c(" ", "FTSC", "FunHDDC", "k-means", " "))
axis(2, at=c(0.6, 0.7, 0.8, 0.9, 1.0), labels=FALSE)
mtext("(3)", line = margin )
# # Lower Right
# plot(HRHN$Method, HRHN$CRate, lims=lims, axes=FALSE)
# axis(1, at=0:4, labels=c(" ", "FTSC", "FunHDDC", "k-means", " "))
# axis(2, at=c(0.6, 0.7, 0.8, 0.9, 1.0), labels=FALSE)
# mtext("(4)", line = margin )
par(op)