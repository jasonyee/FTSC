# Loading packages
library(funHDDC)
library(R.matlab)
library(dplyr)

# Simulation Scenario
nSim = 10
Group_size = 100
var_random1 = 100
var_random2 = 100
var_random3 = 100
var_noise = 1

basisSNR = 7
thrd = 0.8
itermax = 200

set.seed(1)

# Data I/O
path_data <- "Y:/Users/Jialin Yi/output/paper simulation/JASA/data/"
path_out_data <- "Y:/Users/Jialin Yi/output/paper simulation/JASA/data/"
path_out_plot <- "Y:/Users/Jialin Yi/output/paper simulation/JASA/plot/"
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3),
                   toString(var_noise), sep = "-")

ndivs <- 0
# Functions

CRate <- function(ClusterMatrix){
  ClassRate = 0
  for(i in 1:ncol(ClusterMatrix)){
    MostFreqNum <- tail(names(sort(table(ClusterMatrix[,i]))), 1)
    Freq <- sum(ClusterMatrix[,i] == as.numeric(MostFreqNum))
    ClassRate = ClassRate + (Freq/nrow(ClusterMatrix))/ncol(ClusterMatrix)
  }
  return(ClassRate)
}

FixSimulation <- function(data_nSim, nbasis = 13){
  CR = rep(NA, ncol(data_nSim))
  basis<- create.bspline.basis(c(0,1), nbasis=nbasis)
  for(i in 1:ncol(data_nSim)){
    dataset <- matrix(pull(data_nSim, i), ncol = 300, byrow = TRUE)
    T = nrow(dataset)
    var1<-smooth.basis(argvals=seq(0,1,length.out = T),
                       y=dataset,fdParobj=basis)$fd
    tryCatch({
      res<-funHDDC(var1,K=3,init="vector",
                   init.vector = All$IniClusterIDs.simu[,i],
                   threshold=thrd, itermax = itermax)
      mat_cl <- matrix(res$class, nrow = Group_size)
      CR[i] <- CRate(mat_cl)
    }, warning=function(w){
      ndivs <<- ndivs + 1})
  }
  return(CR)
}

# Loading data
All <- readMat(paste(path_data, name_file, ".mat", sep = ""))

data_set <- split(All$data, 
                  as.factor(rep(1:nSim, each = length(All$data)/nSim)))
data_set <- bind_rows(data_set)

# K-means on simulation data
CRKmeans = as.vector(All$kmeans.CRate)

# FunHDDC on simulated data
CRFunHDDC = FixSimulation(data_set, nbasis = basisSNR)

# # FTSC on simulation data
# CRFTSC = as.vector(All$FTSC.CRate)
# 


# Save classification rate
CRates.Data <- data.frame(rep(c("FunHDDC", "Kmeans"), each=nSim),
                          c(CRFunHDDC, CRKmeans))
colnames(CRates.Data) <- c("Method", "CRate")
#save(CRates.Data, file = paste(path_out_data, name_file, ".Rdata", sep = ""))

plot(CRates.Data$Method, CRates.Data$CRate)



