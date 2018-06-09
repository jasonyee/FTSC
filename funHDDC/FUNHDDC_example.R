# Loading packages
library(funHDDC)
library(R.matlab)
library(dplyr)
library(fda)

set.seed(1)

# Simulation Scenario
nSim = 10
Group_size = 100
var_random1 = 200
var_random2 = 200
var_random3 = 200
var_noise = 2
basis_num <- 7:20
K=3

# Data I/O
path_data <- "Y:/Users/Jialin Yi/output/paper simulation/JASA/data/"
path_out_data <- "Y:/Users/Jialin Yi/output/paper simulation/JASA/data/"
path_out_plot <- "Y:/Users/Jialin Yi/output/paper simulation/JASA/FunHDDC/"
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3),
                   toString(var_noise), sep = "-")

All <- readMat(paste(path_data, name_file, ".mat", sep = ""))

diverge_rate <- basis_num
for(j in 1:length(basis_num)){
  basis<- create.bspline.basis(c(0,1), nbasis=basis_num[j])
  ndiv = 0
  
  for(experiment in 1:dim(All$data)[3]){
    data_set <- All$data[,,experiment]
    var1<-smooth.basis(argvals=seq(0,1,length.out = ncol(data_set)),
                       y=t(data_set),fdParobj=basis)$fd
    tryCatch({
      res.uni<-funHDDC(var1,K=K,init="kmeans")
    }, warning=function(w){
      ndiv <<- ndiv + 1})
  }
  diverge_rate[j] <- ndiv / dim(All$data)[3]
}

# Plots
plot(diverge_rate, xaxt = "n", xlab = "nbasis")
lines(diverge_rate, xaxt = "n", xlab = "nbasis")
axis(1, at = 1:length(diverge_rate), labels = basis_num)
title(paste("FunHDDC", name_file, sep=": "))


