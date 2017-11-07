library(sas7bdat)

pathname <- "gupisub"
filepath <- paste("Y:/Users/Jialin Yi/data/imputation/",
                  pathname,"/",sep = "")

blup <- read.sas7bdat(paste(filepath,pathname,
                            "_pred.sas7bdat",
                            sep = ""))
yvar <- blup[,3]
pred <- blup$Pred
# nomiss
yvar_nomiss <- yvar
yvar_nomiss[is.nan(yvar)] <- pred[is.nan(yvar)]
# 3impu
yvar[(blup$vnum == 3) & is.nan(blup[,3])] <- 
  pred[(blup$vnum == 3) & is.nan(blup[,3])]
# dif
yvar_vnum3s <- rep(yvar[blup$vnum == 3], each = 25) 
yvar_dif <- yvar - yvar_vnum3s
# dif_nomiss
yvar_dif_nomiss <- yvar_dif
yvar_dif_nomiss[is.nan(yvar_dif)] <- 
  yvar_nomiss[is.nan(yvar_dif)] - yvar_vnum3s[is.nan(yvar_dif)]

# dataframe
pid <- blup$pid
visit <- blup$vnum
yvardt <- data.frame(pid, visit, 
                     yvar, yvar_dif,
                     yvar_nomiss, yvar_dif_nomiss)

colnames(yvardt) <- c("pid", "visit",
                      pathname, paste(pathname, "dif", sep = "_"),
                      paste(pathname, "nomiss", sep = "_"),
                      paste(pathname, "dif", "nomiss", sep = "_"))

# save as csv
write.csv(yvardt, 
          paste(filepath,pathname,
                ".csv",sep = ""),
          na = ".")