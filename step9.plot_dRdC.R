#!/usr/bin/Rscript
rm(list=ls())

plotdat <- function(dat00){
  dat000 <- dat00
  if (nrow(dat00)>2){
  	dat000 <- dat00[(dat00$is_plotted==1),]
  }
  dat <- dat000[order(-dat000$is_target),]

  names <- dat$clade
  y0 <- dat$HON0_avg
  se0 <- dat$HON0_se
  y2 <- dat$HON2_avg
  se2 <-  dat$HON2_se
  y3 <- dat$HON3_avg
  se3 <- dat$HON3_se
  
  xmax <- length(dat$clade)
  ymin <- min(c(y0-se0,y2-se2,y3-se3))
  ymax <- max(c(y0+se0,y2+se2,y3+se3))
  main <- sprintf("%s", dat$classification[1])
  x <- 1:xmax
  if (main=="MY"){
	main <- "Volume and Polarity"
  }
  if (main=="charge"){
	main <- "Charge"
  }
     
  cex <- 4.5  ###Default 3
  cex2 <- 1.5 ###Default 1.5

  # HON0
  col0 <- "gray"
  pch0 <- 22
  plot(x, y0, pch=pch0, cex=cex, bg=col0, xlim=c(0.5, xmax+0.5), ylim=c(ymin-0.05, ymax+0.05), axes=F, ann=F)
  arrows(x, y0-se0, x, y0+se0, code=3, angle=90, length=0.05)  

  # HON2
  col2 <- "red"
  pch2 <- 22
  points(x, y2, pch=pch2, cex=cex, bg=col2)
  arrows(x, y2-se2, x, y2+se2, code=3, angle=90, length=0.05)
  
  # HON3
  col3 <- "deepskyblue"
  pch3 <- 22
  points(x, y3, pch=pch3, cex=cex, bg=col3)
  arrows(x, y3-se3, x, y3+se3, code=3, angle=90, length=0.05)

  # format
  axis(1, x, labels = FALSE, cex.axis=cex2)
  text(x-0.3, par("usr")[3] - 0.01, labels = names, pos=4, xpd=TRUE, cex=cex2, srt=-15)
  axis(2, las=0, cex.axis=cex2)
  title(ylab='dR/dC', main = main, cex.main=3, cex.lab=cex2)
  box() 
  if (main!="Charge"){
    legend("topright",  legend=c("uncorrected", "GC-corrected (AA frequency)", "GC-corrected (codon frequency)"),
	pch = c(pch0, pch2, pch3), pt.bg = c(col0, col2, col3), cex=cex2)
  }
}


# data input
args<-commandArgs(TRUE)
dat0 <- read.table(args[1], header = T, sep = '\t')

# make plots
width <- 10 ###Default 15
if (nrow(dat0)==4){
  width <- 5 
}
pdf(args[2], width=width, height=15)

par(mfrow=c(2,1))
plotdat(dat0[(dat0$classification=="charge"),])
plotdat(dat0[(dat0$classification=="MY"),])

