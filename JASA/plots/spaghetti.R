library(R.matlab)
dataset <- readMat("MATLAB/FTSC/JASA/plots/dataset.mat")

ylim <- c(-8, 8)
ylab <- -8:8
col <- "black"
plot.new()
plot.window( xlim=c(1,23), ylim=ylim)

for(k in 1:nrow(dataset$Improved)){
  lines(dataset$Improved[k,], 
        col = col)
}

for(k in 1:nrow(dataset$Stable)){
  lines(dataset$Stable[k,], 
        col = col)
}

for(k in 1:nrow(dataset$Worse)){
  lines(dataset$Worse[k,], 
        col = col)
}

axis(1, at=1:23)
axis(2, at=ylab)