# Loading packages
library(funHDDC)
library(R.matlab)
library(dplyr)

# Simulation Scenario
nSim = 100
Group_size = 20
var_random1 = 50
var_random2 = 200
var_random3 = 100
var_noise = 1

# High SNR, Group_size = 20
# basisSNR = 7
# orderSNR = 3

# Low SNR, Group_size = 20
basisSNR = 7
orderSNR = 3

# Low SNR, Group_size = 100
# basisSNR = 7
# orderSNR = 2

# Data I/O
path_data <- "Y:/Users/Jialin Yi/output/paper simulation/VaryClusters/data/"
path_out_data <- "Y:/Users/Jialin Yi/output/paper simulation/FunHDDC/data/"
path_out_plot <- "Y:/Users/Jialin Yi/output/paper simulation/FunHDDC/plot/"
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3),
                   toString(var_noise), sep = "-")

# Functions
EncapFunHDDC <- function(dataset, n_cl, n_b, n_o, modeltype, init_cl){
  T = nrow(dataset)
  basis <- create.bspline.basis(c(0, T), nbasis=n_b, norder=n_o)
  fdobj <- smooth.basis(1:T, dataset,basis,
                        fdnames=list("Time", "Subject", "Score"))$fd
  res = funHDDC(fdobj,n_cl,model=modeltype,init=init_cl)
  
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

FixSimulation <- function(data_nSim, nbasis = 18, norder = 3){
  CR = 1:ncol(data_nSim)
  for(i in 1:ncol(data_nSim)){
    dataset <- matrix(pull(data_nSim, i), ncol = 60, byrow = TRUE)
    modeltype='ABQkDk'
    out <- EncapFunHDDC(dataset, 3, nbasis, norder, modeltype, 'kmeans')
    
    res <- out[[1]]
    #fdobj <- out[[2]]
    
    mat_cl <- matrix(res$class, nrow = Group_size)
    
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
CRFunHDDC = FixSimulation(data_set, nbasis = basisSNR, norder = orderSNR)

# FTSC on simulation data
CRFTSC = as.vector(All$FTSC.CRate)

# K-means on simulation data
CRKmeans = as.vector(All$kmeans.CRate)

# Save classification rate
CRates.Data <- data.frame(rep(c("FTSC", "FunHDDC", "Kmeans"), each=nSim),
                          c(CRFTSC, CRFunHDDC, CRKmeans)) 
colnames(CRates.Data) <- c("Method", "CRate")
save(CRates.Data, file = paste(path_out_data, name_file, ".Rdata", sep = ""))


# Plots
pdf(paste(path_out_plot, name_file, ".pdf", sep = ""),
    width = 8.05, height = 5.76)

par(mfrow = c(1,2), oma = c(0, 0, 2, 0))
yRange = c(min(CRates.Data$CRate), max(CRates.Data$CRate))
## plot like time series
ts.plot(cbind(CRFTSC, CRFunHDDC, CRKmeans),
        gpars = list(
          xlab = "",
          col=c("blue", "red", "black"),
          ylim = yRange
        ))
legend("topright", legend=c("FTSC", "FunHDDC", "K-means"),
       col=c("blue", "red", "black"), lty=c(1,1,1), cex=0.8)
# box plot
boxplot(CRate ~ Method, data = CRates.Data, ylim = yRange)

mtext(paste("Var of noise =", toString(var_noise), ",",
            "Heterogeneous random effect =", 
            toString(c(var_random1,var_random2,var_random3)), 
            outer = TRUE, cex = 1.5))

dev.off()

