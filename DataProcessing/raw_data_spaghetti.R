library(sas7bdat)
library(R.matlab)

yvar = "sf12_pcs"

path <- paste("Y:/Users/Jialin Yi/data/imputation/", yvar, "/", sep = "")

name.sas <- paste(yvar, ".sas7bdat", sep = "")

raw <- read.sas7bdat(paste(path, name.sas,sep = ""))

yvar_dif <- raw[,4]

yvar_mat <- matrix(yvar_dif, nrow = 397, ncol = 25, byrow = TRUE)

result_name = paste(path, yvar, "_3dif.mat", sep = "")

writeMat(result_name, Threedif = yvar_mat)
