# Jinliang Yang
# Purpose: quick plot of GWAS results
# start: 2.11.2012
# updated: 7/14/2014
# Jinliang Yang

quickMHTplot <- function(res=res, cex=.9, pch=16, col=rep(c("slateblue", "cyan4"), 5), clfile,
                         GAP=5e+06, yaxis=NULL,
                         col2plot="qval", ... ){
  
  #res: a data.frame; must has chr, pos, and a col to plot

  #source("~/Documents/Rcodes/newpos.R")
  res <- newpos(res, GAP = GAP, cl=clfile)
  chrtick <- chrline_tick(GAP = GAP, cl=clfile)
  
  #### setup the cavon
  if(is.null(yaxis)){
    plot(x=-1000, y=-1000,  type="p", xaxt="n", xlab="", 
         xlim=c(0, max(chrtick$chrlines)), ylim=c(0, max(res[, col2plot], na.rm=TRUE)*1.3 ),
         ...)
  }else{
    plot(x=-1000, y=-1000,  type="p", xaxt="n", yaxt="n", xlab="",
         xlim=c(0, max(chrtick$chrlines)),
         ...)
    axis(side=2, at=yaxis, labels=yaxis)
  }
  axis(side=1, at=chrtick$ticks, labels=c("chr1", "chr2", "chr3", "chr4", "chr5", 
                                          "chr6", "chr7", "chr8", "chr9", "chr10"))
  abline(v=chrtick$chrlines, col="grey")
  
  for(i in 1:10){
    points(x=subset(res, chr==i)$newpos, y=res[res$chr==i, col2plot],
         pch = pch, col=col[i], cex=cex);
  }  
}



newpos <- function (dataframe, GAP = 5e+06, cl) 
{
  d <- dataframe
  if (!("chr" %in% names(d) & "pos" %in% names(d))){
    stop("Make sure your data frame contains columns chr and pos")
  }
  cl$accumpos <- cl$BP
  #cl <- cl[order(cl$CHR), ]
  d$newpos <- d$pos;
  for (i in 2:10) {
    cl[cl$CHR == i, ]$accumpos <- cl[cl$CHR == (i - 1), ]$accumpos + cl[cl$CHR == i, ]$accumpos + GAP
    d[d$chr == i, ]$newpos <- d[d$chr == i, ]$pos + cl[cl$CHR == (i - 1), ]$accumpos + GAP
  }
  return(d)
}

chrline_tick <- function(GAP=5e+06, cl){
  #xscale:
  colnames(cl) <- c("chr", "snp", "pos")
  cl <- newpos(dataframe=res,cl=cl, GAP=GAP)
    
  cl$ticks <- cl$pos[1]/2
  cl$chrlines <- cl$pos[1]+GAP/2
  for(i in 2:10){
    cl$ticks[i] <- cl$newpos[i-1] + (cl$newpos[i]-cl$newpos[i-1])/2;
    cl$chrlines[i] <- cl$newpos[i]+ GAP/2;  
  }
  return(cl)
}

