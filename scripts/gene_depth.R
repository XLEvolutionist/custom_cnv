###
# Read Depth distribtion over gene models in wild maize
###

# Simon Renny-Byfield, Feb '15, UC Davis

# load some useful libraries
library(data.table)
library(ggplot2)
library(reshape2)

#calculate the gene sizes


# set the wd
setwd("/Users/simonrenny-byfield/GitHubRepos/custom_cnv/data/")
# first read in the data..
cov.df<-fread("coverage.per.gene.txt", header=TRUE)
gc.df<-fread("gene_GC.txt", header=TRUE, sep = "\t")

# get rid of duplicates and merge the two tables
setkey(cov.df, name)
cov.df<-unique(cov.df)
setkey(gc.df,name)
gc.df<-unique(gc.df)
cov.df<-merge(cov.df,subset(gc.df,select=c(pct_gc,pct_at,name)))

#remove plastid and mt genes
cov.df<-subset(cov.df,subset=cov.df$chr %in% seq(1,10,1))

# calculate teh size of the genes
size<-subset(cov.df,select=stop)-subset(cov.df,select=start)

# normalize by column total
norm.df<-sweep(subset(cov.df,select= -c(1:4,27,28)), 2, colSums(subset(cov.df,select= -c(1:4,27,28))), FUN="/")
norm.df<-sweep(norm.df, 2, 1e6, FUN="*")
norm.df<-sweep(norm.df, 1, (size$stop)/1000, FUN="/")
# bind the norm data to the old
norm.df<-cbind(subset(cov.df,select=c(1:4)),norm.df,subset(cov.df, select=c(27,28)))
write.table(norm.df,file="normDepth.txt", quote=FALSE)

# Draw some diagnostic plots

# remove any genes with count less that one in B73
norm.df<-subset(norm.df,subse=norm.df$B73.bam > 3)

#look ant the distribution of coverage in b73
hist(norm.df$B73.bam, breaks=50, col="grey")

#pick the indexes to drag out
idx<-floor(runif(50,1,dim(norm.df)[1]))
# pick a random subset of geens using some random numbers
random.df<-norm.df[idx,]

#now for each gene look at the sitribution of coverage

pdf("norm.pdf")
par(mfrow=c(3,2))
for ( i in 1:dim(random.df)[1] ) {
  hist(as.numeric(as.vector(random.df[i]))[-c(1:4)], breaks = 10, col="grey", main = random.df$name[i],
        xlab="depth (reads per kb per million)")
}#for
dev.off()

pdf("combined_coverage.pdf")
# what about the whole distribution
qplot(x=melt(subset(norm.df,select=-c(1:4)))$value, geom="histogram", 
      xlim=c(0,50), xlab="normalized coverage per kb",col="blue",cex.lab=1.6)
dev.off()

