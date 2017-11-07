library(sas7bdat)
library(R.matlab)

bigyvar = "GUPISUB"
smallyvar = "gupisub"

for(nClusters in 3:3){
  # Import wald clustering from SAS
  dataset <- read.sas7bdat(paste("Y:/Users/Jialin Yi/output/",bigyvar,"/wald/",
                                 toString(nClusters),
                                 "C/",
                                 smallyvar,"_wald.sas7bdat",
                                 sep = ""))
  # yvar_dif
  ## exclude visit 1 and visit 2
  yvar_dif <- dataset[,5][dataset$visit>2]
  ## convert into a matrix
  yvar_dif_mat <- matrix(yvar_dif, nrow = 397, ncol = 23, byrow = TRUE)
  
  # wald cluster id
  ## exclude visit 1 and visit 2
  wald <- dataset$CLUSTER[dataset$visit>2]
  wald_mat <- matrix(wald, nrow = 397, ncol = 23, byrow = TRUE)
  waldid <- wald_mat[,1]
  
  result_name = paste("Y:/Users/Jialin Yi/data/",bigyvar,"/",bigyvar,"_dif_",
                      toString(nClusters),
                      "C.mat", sep = "")
  writeMat(result_name,
           yvar_dif = yvar_dif_mat,
           WaldClusterID = waldid)
}

