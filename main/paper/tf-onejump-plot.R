# Make sure you're working from [dropboxfolder]/code
  source('funs.R')
  source('testfuns.R')
  source('dualPathSvd2.R')
  source('selectinf/selectiveInference/R/funs.inf.R')
  library(genlasso)
  library(RColorBrewer)
  outputdir = "output"
  codedir = "."
  verbose = F

#####################
## make QQ plot #####
#####################
    w = 5; h = 5.3
    mar = c(4.5,4.5,2.6,0.5)
    pch.qq=16
    pcols = brewer.pal(5,"Set1")
    loc = 19 # the 19th dual variable picks out the 20th gap
    subname="none"
    load(file=file.path(outputdir,
                        paste0("tf-simple-",subname,".Rdata")))
    pvals.none = pvals[,loc]

    subname="low"
    load(file=file.path(outputdir,
                        paste0("tf-simple-",subname,".Rdata")))
    pvals.low = pvals[,loc]

    subname="med"
    load(file=file.path(outputdir,
                        paste0("tf-simple-",subname,".Rdata")))
    pvals.med = pvals[,loc]

    subname="high"
    load(file=file.path(outputdir,
                        paste0("tf-simple-",subname,".Rdata")))
    pvals.high = pvals[,loc]

    pvals.list = list(pvals.none,
                    pvals.low,
                    pvals.med,
                    pvals.high)#list(pvals[,loc],pvals.decluttered[,loc])#,unif.p)
#  pvals.list = list(pvals[,loc],pvals.decluttered[,loc])

  lcol.diag="lightgrey" 
  pdf(file=file.path(outputdir,"tf-simple-qqplot.pdf"),width=w,height=h)
  par(mar=mar)
    for(ii in 1:length(pvals.list)){
      if(ii>1) par(new=T)
      mypvals = pvals.list[[ii]]
      unif.p = runif(sum(!is.na(mypvals)),0,1)
      a = qqplot(x=unif.p, y=mypvals, plot.it=FALSE)
      myfun = (if(ii==1) plot else points)
      myfun(x=a$y, y=a$x, axes=F, xlab="", ylab="", col = pcols[ii], pch=pch.qq)
    }
    axis(2);axis(1)
    mtext("Observed",2,padj=-4)
    mtext("Expected",1,padj=4)
    abline(0,1,col=lcol.diag)
    deltas = c(0,1,2,5)
    legend("bottomright", col=pcols, pch=rep(pch.qq,2), legend =     sapply(c(bquote(delta == .(deltas[1])), 
           bquote(delta == .(deltas[2])),
           bquote(delta == .(deltas[3])),
           bquote(delta == .(deltas[4]))), as.expression))#c("low","medium","high noise"))#c("original", "after decluttering"))
    myloc = loc+1 # The linear trend filter detected location is ( boundary set element + 1 )
    title(main=bquote(atop(Segment~test~p-values)))
  graphics.off()


#######################
## make data plot #####
#######################
  ## w = h = 5
  w=5; h=5.3
  mar = c(4.5,4.5,2.6,0.5)
  pdf(file.path(outputdir, "tf-singlenoise-simple-data.pdf"), width=w, height=h)  
  par(mar=mar)
  lcol.sig = "red"
  lwd.sig = 2
  lty.sig = 1
  col.arrow="black"
  lwd.arrow=2
  sigma=1
  pch.dat = 16
  pcol.dat = "grey50"
  ylab = ""
  xlab = "Location"
  col.hline='lightgrey'
  beta1 = rep(0,20)
  beta2.none = rep(0,20)
  fac = .1
  beta2.low = .5*fac*seq(from=21,to=40) - 10*fac
  fac = .2
  beta2.med = .5*fac*seq(from=21,to=40) - 10*fac
  fac = .5
  beta2.high = .5*fac*seq(from=21,to=40) - 10*fac
  beta2s = list(beta2.low,beta2.med,beta2.high)
  beta0s = lapply(beta2s,function(beta2)c(beta1,beta2))
  xlim = c(0,length(beta0s[[1]])+7)
  ylim = range(beta0s[[3]]) + c(-2.5,2)
## Make blank plot
  plot(NA,xlim=xlim, ylim = ylim, axes=F, ylab = ylab, xlab = xlab)
  abline(h=0,col=col.hline)
  lines(rep(0,length(beta0s[[1]])), col=lcol.sig, lwd=lwd.sig, lty=2)
  for(ii in c(1:3)){
    lines(beta0s[[ii]], col=lcol.sig, lwd=lwd.sig, lty=ifelse(ii==3,2,1))
    my.offset = c(1,2,5)[ii]
    arrows(x0=44-ii, y0=0, x1 = 44-ii, y1 = my.offset, col=col.arrow, length=.1, angle=20, lwd=lwd.arrow)
  }

  text(x=41+5, y = 0, labels = expression(delta==0))
  text(x=41+5, y = 1, labels = expression(delta==1))
  text(x=41+4, y = 2, labels = expression(delta==2))
  text(x=41+3, y = 5, labels = expression(delta==5))
  set.seed(1)

  y0 = beta0s[[3]] + rnorm(length(beta0s[[1]]),0,sigma)
  points(y0,pch=pch.dat, col = pcol.dat)
  axis(2);axis(1);
  title(main=  expression(atop("Data example")))
  legend("topleft", pch = c(pch.dat, NA), lty=c(NA,lty.sig), lwd = c(NA,lwd.sig), col = c(pcol.dat, lcol.sig),legend = c("Data", "Mean"))
graphics.off()
