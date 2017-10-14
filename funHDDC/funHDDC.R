# Loading packages
library(funHDDC)
library(R.matlab)
library(dplyr)

# Simulation Scenario
nSim = 100
Group_size = 20
var_random = 900
var_noise = 9

# Data I/O
path_data <- "Y:/Users/Jialin Yi/output/paper simulation/FixNClusters/data/"
path_out <- "Y:/Users/Jialin Yi/output/paper simulation/FunHDDC/data/"
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random), toString(var_noise), sep = "-")

# Functions
EncapFunHDDC <- function(dataset, n_cl, n_b, n_o, modeltype, init_cl){
  T = nrow(dataset)
  basis <- create.bspline.basis(c(0, T), nbasis=n_b, norder=n_o)
  fdobj <- smooth.basis(1:T, dataset,basis,
                        fdnames=list("Time", "Subject", "Score"))$fd
  res = funHDDC(fdobj,n_cl,model=modeltype,init=init_cl, thd = 0.01)
  
  return(list(res, fdobj))
}

CRate <- function(ClusterMatrix){
  ClassRate = 0
  for(i in 1:ncol(ClusterMatrix)){
    MostFreqNum <- tail(names(sort(table(ClusterMatrix[,i]))), 1)
    Freq <- sum(ClusterMatrix[,i] == as.numeric(MostFreqNum))
    ClassRate = ClassRate + (Freq/nrow(ClusterMatrix))/ncol(ClusterMatrix)
  }
  return(ClassRate)
}

FixSimulation <- function(data_nSim, nbasis = 18, norder = 2){
  CR = 1:ncol(data_nSim)
  for(i in 1:ncol(data_nSim)){
    dataset <- matrix(pull(data_nSim, i), ncol = 60, byrow = TRUE)
    modeltype='ABQkDk'
    out <- EncapFunHDDC(dataset, 3, nbasis, norder, modeltype, 'kmeans')
    
    res <- out[[1]]
    #fdobj <- out[[2]]
    
    mat_cl <- matrix(res$cls, nrow = Group_size)
    
    CR[i] <- CRate(mat_cl) 
  }
  return(CR)
}

# Loading data
All <- readMat(paste(path_data, name_file, ".mat", sep = ""))

data_set <- split(All$data, 
                   as.factor(rep(1:nSim, each = length(All$data)/nSim)))
data_set <- bind_rows(data_set)

# FunHDDC on simulated data
CRFunHDDC = FixSimulation(data_set)

# Save classification rate
save(CRFunHDDC, file = paste(path_out, name_file, ".Rdata", sep = " "))


