library(R.matlab)
path_data <- "Y:/Users/Jialin Yi/output/paper simulation/JASA/data/"


expriment = 5
colors <- c("red", "blue", "black")
line.types <- c("solid", "dashed", "longdash")
plot.order <- c(3,2,1)
## low random effect, low noise
nSim = 10
Group_size = 100
var_random1 = 200
var_random2 = 100
var_random3 = 100
var_noise = 1
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3)
                   ,toString(var_noise), sep = "-")
LRLN <- readMat(paste(path_data, name_file, ".mat", sep = ""))
## low random effect, high noise
nSim = 10
Group_size = 100
var_random1 = 200
var_random2 = 100
var_random3 = 100
var_noise = 2
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3)
                   ,toString(var_noise), sep = "-")
LRHN <- readMat(paste(path_data, name_file, ".mat", sep = ""))


## Heterogeneous RF, low noise
nSim = 10
Group_size = 100
var_random1 = 200
var_random2 = 200
var_random3 = 200
var_noise = 1
name_file <- paste(toString(nSim), toString(Group_size), 
                   toString(var_random1), toString(var_random2), toString(var_random3)
                   ,toString(var_noise), sep = "-")
HRLN <- readMat(paste(path_data, name_file, ".mat", sep = ""))

## Heterogeneous RF, high noise
# nSim = 10
# Group_size = 100
# var_random1 = 200
# var_random2 = 200
# var_random3 = 200
# var_noise = 2
# name_file <- paste(toString(nSim), toString(Group_size), 
#                    toString(var_random1), toString(var_random2), toString(var_random3)
#                    ,toString(var_noise), sep = "-")
# load(paste(path_rda,name_file,".Rdata",sep = ""))
# HRHN <- CRates.Data

## 2-by-2 panel
op <- par(mfrow = c(1,3),
          oma = c(5,4,0,0) + 0.1,
          mar = c(0,0,1,1) + 0.1)
lims <- c(-9, 6)
tick <- -9:6
margin <- 0.05

# Upper Left
LRLN.experiment <- data.frame(LRLN$data[,,expriment])
plot(1:23, seq(-10,10,length=23),
     ylab = "Simulated scores",
     type = "n", 
     axes = FALSE)
for( j in plot.order){
  selected.rows <- ((j-1)*Group_size+1):(j*Group_size)
  for(s in 1:Group_size){
    subj <- as.numeric(LRLN.experiment[selected.rows,][s,])
    lines(1:ncol(LRLN.experiment), subj,
          ylim = lims,
          col = colors[j],
          lty = line.types[j])
  }
}
axis(1, at=1:23)
axis(2, at=tick, lwd = margin)
text("(1)", x = 12, y = 6)

# Upper Right
LRHN.experiment <- data.frame(LRHN$data[,,expriment])
plot(1:23, seq(-10,10,length=23),
     ylab = "",
     type = "n", 
     axes = FALSE)
for( j in plot.order){
  selected.rows <- ((j-1)*Group_size+1):(j*Group_size)
  for(s in 1:Group_size){
    subj <- as.numeric(LRHN.experiment[selected.rows,][s,])
    lines(1:ncol(LRHN.experiment), subj,
          ylim = lims,
          col = colors[j],
          lty = line.types[j])
  }
}
axis(1, at=1:23)
axis(2, at=tick, labels = FALSE)
text("(2)", x = 12, y = 6)

# Lower Left
HRLN.experiment <- data.frame(HRLN$data[,,expriment])
plot(1:23, seq(-10,10,length=23),
     ylab = "",
     type = "n", 
     axes = FALSE)
for( j in plot.order){
  selected.rows <- ((j-1)*Group_size+1):(j*Group_size)
  for(s in 1:Group_size){
    subj <- as.numeric(HRLN.experiment[selected.rows,][s,])
    lines(1:ncol(HRLN.experiment), subj,
          ylim = lims,
          col = colors[j],
          lty = line.types[j])
  }
}
axis(1, at=1:23)
axis(2, at=tick, labels = FALSE)
text("(3)", x = 12, y = 6)
# # Lower Right
# plot(HRHN$Method, HRHN$CRate, lims=lims, axes=FALSE)
# axis(1, at=0:4, labels=c(" ", "FTSC", "FunHDDC", "k-means", " "))
# axis(2, at=c(0.6, 0.7, 0.8, 0.9, 1.0), labels=FALSE)
# mtext("(4)", line = margin )
par(op)