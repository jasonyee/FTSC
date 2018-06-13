library(R.matlab)
dataset <- readMat("MATLAB/FTSC/JASA/plots/dataset.mat")

ylim <- c(-8, 8)
ylab <- -8:8
title_pos <- -1
margin <- 0.1

lwd <- 2
op <- par(mfrow = c(1,3),
          oma = c(5,4,0,0) + margin,
          mar = c(0,0,1,1) + margin)

for(n in 1:3){
  
  plot.new( )
  plot.window( xlim=c(1,23), ylim=ylim)
  
  if(n == 1){
    for(k in 1:nrow(dataset$Improved)){
      lines(dataset$Improved[k,], 
            col = "grey")
    }
  } else if(n == 2){
    for(k in 1:nrow(dataset$Stable)){
      lines(dataset$Stable[k,], 
            col = "grey")
    }
  } else {
    for(k in 1:nrow(dataset$Worse)){
      lines(dataset$Worse[k,], 
            col = "grey")
    }
  }
  
  lines(dataset$AllSmoothed[n,], type = "l", 
        col = rgb(0, 0, 156, maxColorValue = 255), 
        lwd = lwd,
        ylim = ylim, axes=FALSE)
  lines(dataset$AllSmoothed95Upper[n, ], 
        col = rgb(192, 0, 0, maxColorValue = 255),
        lwd = lwd,
        lty="dashed")
  lines(dataset$AllSmoothed95Lower[n, ], 
        col = rgb(192, 0, 0, maxColorValue = 255),
        lwd = lwd,
        lty="dashed")
  lines(rep(0, 23), lty = "dashed")
  
  axis(1, at=1:23)

  if (n == 1){
    axis(2, at=ylab, labels=TRUE)
  } else {
    axis(2, at=ylab, labels=FALSE)
  }
  
  mtext(paste("(", n, ")"), line = title_pos)
}