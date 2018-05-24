NewLabelpath <- "Y:/Users/Jialin Yi/output/Labels"

NewLabels <- read.csv(header = F,
                      file = paste(NewLabelpath, "Labels.csv", sep = "/"))

OldLabelpath <- "Y:/Users/Jialin Yi/Final results/Labels"

OldLabels <- read.csv(header = T,
                      file = paste(OldLabelpath, "Labels.csv", sep = "/"))

OldLabels$painsev4to24 <- NewLabels[,11]

OldLabels$urinsev4to24 <- NewLabels[,12]

save(OldLabels, file = paste(OldLabelpath, "Labels.RData", sep = "/"))
