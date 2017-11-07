NewLabelpath <- "Y:/Users/Jialin Yi/output/Labels"

NewLabels <- read.csv(header = F,
                      file = paste(NewLabelpath, "Labels.csv", sep = "/"))

OldLabelpath <- "Y:/Users/Jialin Yi/Final results/Labels"

load(file = paste(OldLabelpath, "Labels.RData", sep = "/"))

Labels$gupisub <- NewLabels[,8]

save(Labels, file = paste(OldLabelpath, "Labels.RData", sep = "/"))