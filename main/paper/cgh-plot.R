# working directory should be [genlassoinf]/code
source("settings.R")
source('funs.R')
source('testfuns.R')
source('dualPathSvd2.R')
lapply(c("genlasso","pryr","xtable"), require, character.only = TRUE)
source('selectinf/selectiveInference/R/funs.inf.R')
outputdir = "output"

#####################
## Combine results ##
#####################
 
load(file=file.path(outputdir,"cgh-results.Rdata"))
resultmat = do.call(rbind,lapply(results, function(mylist)unlist(mylist[1:2])))
resultmat.declutter = do.call(rbind,lapply(results.decluttered, function(mylist)unlist(mylist[1:2]))) 
resultmat = cbind(resultmat,resultmat[,1]<0.05/nrow(resultmat))
colnames(resultmat)[3] = "verdict"
sparse.signal = f0
  
load(file=file.path(outputdir,"cgh-nonsparse-results.Rdata"))  
resultmat.nonsparse = do.call(rbind, lapply(results, function(mylist) unlist(mylist[1:2])))
resultmat.nonsparse = cbind(resultmat.nonsparse,resultmat.nonsparse[,1]<0.05/nrow(resultmat.nonsparse))
stop.time.sparse = stop.time
colnames(resultmat.nonsparse)[3] = "verdict"
  
  
#########################################################################
## Combine results to produce p-value table (run both scripts first) ####
##                          paper.cgh.R  ///  paper-cgh-nonsparse.R  ####
#########################################################################
resultlist = list(resultmat,resultmat.nonsparse)
result.table = merge(resultmat,resultmat.nonsparse,by="coord",all=T)
result.table = data.frame(result.table)
result.table[,2] = signif(result.table[,2],3)
result.table[,4] = signif(result.table[,4],3)
result.table = result.table[,c(1,2,4)]
result.table[,1] = as.integer(result.table[,1])
names(result.table) = c("Location", "p-value (sparse fused lasso)", "p-value (fused lasso)")

# make table to put into paper (figure 14)
xtable(t(result.table),include.rownames=F)
combined.locs = result.table[,1]
combined.letters = toupper(letters)[1:length(combined.locs)]

  


###################
## Main Plot ######
###################
pch.dat = 16
pcol.dat = "lightgrey"#"grey50"
w=12; h=6;
pdf(file=file.path(outputdir,"cgh-main.pdf"),width=w,height=h)
par(mar=c(3,2,2,2))
ylim=c(-3.5,max(y0))
plot(NA,xlim=c(0,n),ylim=ylim, cex=.2,xlab='Location',ylab='y',axes=F)
axis(1);axis(2)
points(y0, pch=pch.dat,col=pcol.dat)
title(xlab="Location")

    ## YES-sparse fused lasso
    load(file=file.path(outputdir,"cgh-results.Rdata"))
    lines(f0$beta[,stop.time+1],col='red',lwd=2)
    cuts = final.model.cluttered[final.model.cluttered<n]
    
    abline.vertical.segment =function(v,ylim,lty,col,lwd){
      if(length(col)==1) col = rep(col,length(v))
      if(length(lty)==1) lty = rep(lty,length(v))
      for(ii in 1:length(v)){
        my.v = v[ii]  
#        if(ii %in% which(show.cpts)) next()
        lines(x = rep(my.v,2), y = ylim, col = col[ii], lwd=lwd, lty=lty[ii])
      }
    }
    abline.vertical.segment(v = cuts, ylim = c(-2.5,-2.2), col='red',lty=1,lwd=1)    

    # step-sign plots   
    states = get.states(f0$action)
    final.model = states[[stop.time+1]]
    final.model.signs = f0$ss[[stop.time+1]] 
    ord = order(final.model)
    final.model.cluttered = final.model[ord]
    final.model.signs = final.model.signs[ord]
    s0 = step.sign.plot(final.model.signs, final.model.cluttered,n)
    s0 = s0[1:length(y0)]
    lines(s0/2-3.2,type='l', lwd=2)

    ## NON-sparse fused lasso
    load(file=file.path(outputdir,"cgh-nonsparse-results.Rdata"))
    lines(f0$beta[,stop.time+1],col='blue',lwd=2)
    cuts = final.model.cluttered[final.model.cluttered<n]
    abline.vertical.segment =function(v,ylim,lty,col,lwd){
      if(length(col)==1) col = rep(col,length(v))
      if(length(lty)==1) lty = rep(lty,length(v))
      for(ii in 1:length(v)){
        my.v = v[ii]  
#        if(ii %in% which(show.cpts)) next()
        lines(x = rep(my.v,2), y = ylim, col = col[ii], lwd=lwd, lty=lty[ii])
      }
    }

    abline.vertical.segment(v = cuts, ylim = c(-2.5,-2.2)+.5, col='blue',lty=1,lwd=1)


    
    
    y.text = rep(-1.5, length(combined.locs))#cuts))
    y.text[c(2,6,9,12)] = -1.3
#    sparse.letters = combined.letters[combined.locs %in% cuts]

    text(y=y.text, x=combined.locs, labels=toupper(combined.letters),cex=.7)#sparse.letters)[1:length(cuts)])

  #    abline.vertical.segment(v = cuts, ylim = c(-2.5,-2.2), col='salmon',lty=1,lwd=1)
  #    y.text = rep(-1.8, length(cuts))+.5
  #    y.text[c(2,4,6)] = -1.5+.5
  #    sparse.letters = combined.letters[combined.locs %in% cuts]
  #    text(y=y.text, x=cuts, labels=toupper(sparse.letters)[1:length(cuts)])


legend("topright",
       lty=c(NA,1,1,1),
       lwd=c(NA,2,2,2),
       pch=c(16,NA,NA,NA),
       col=c(pcol.dat,"blue","red","black"),
       legend = c("Data","Fused lasso estimate", "Sparse fused lasso estimate", "Step-sign plot"))
  graphics.off()


##########################################
## Examine the df of the two estimates ###
##########################################
load(file=file.path(outputdir,"cgh-results.Rdata"))
f.sp = f0
states.sp = get.states(f.sp$action)
stop.time.sp = stop.time
final.model.sp = states[[stop.time.sp+1]]
f.sp$lambda[stop.time]
load(file=file.path(outputdir,"cgh-nonsparse-results.Rdata"))
f.nonsp = f0
states.nonsp = get.states(f.nonsp$action)
stop.time.nonsp = stop.time
final.model.nonsp = states[[stop.time.nonsp+1]]

lam.sp = f.sp$lambda[stop.time.sp]
lam.nonsp = f.nonsp$lambda[stop.time.nonsp]

n = f.sp$y
objects(f.sp)
D.sp = rbind(makeDmat(n,order=0),diag(rep(1,n)))
D.nonsp = makeDmat(n,order=0)



rankMatrix(t(D.sp[-final.model.sp,]))
rankMatrix(t(D.nonsp[-final.model.nonsp,]))
B.sp =  f.sp$pathobj$B
B.nonsp = f.nonsp$pathobj$B
B.nonsp[B.nonsp<=n]
B.sp


#  
########################
### Step sign plot #####
########################
# # Takes in the signs |signs| and the locations |final.model|
#    step.sign.plot = function(signs, final.model,n){
#      signs = signs[order(final.model)]
#      signs = c(-signs[1], signs)
#      cumul.signs = cumsum(signs)
#      final.model = sort(final.model)
#      nn = length(final.model)
#      indices <- vector(mode = "list", length = nn+1)
#        indices[2:nn] = Map(function(a,b){a:b},
#                                final.model[1:(length(final.model)-1)]+1, 
#                                final.model[2:length(final.model)])
#        indices[[1]] = 1:final.model[1]
#        indices[[nn+1]] = (final.model[length(final.model)]+1):n
#      sign0 = do.call(c, 
#               lapply(1:length(cumul.signs), 
#                  function(ii){rep(cumul.signs[ii], length(indices[[ii]]))})
#                  )
#      return(sign0)
#    }
#    s0 = step.sign.plot(final.model.signs, final.model,n)
#    plot(y0,ylim=c(-2,max(y0)))
#    lines(s0,type='l', lwd=2, col )
#    lines(f0$beta[,stop.time+1],col='blue')
#abline(v=25*0:40, col='lightgrey')


#  
#  pdf(file=file.path(outputdir,"cgh-stepsign-main.pdf"),width=w,height=h)
#    plot(NA,xlim=c(0,n),ylim=range(y0), cex=.2,xlab='coordinate',ylab='y')
#    lines(f0$beta[,stop.time],col='red',lwd=2)
#    points(y0, pch=pch.dat,col=pcol.dat)
#    abline(v=final.model.decluttered[final.model.decluttered<n],col='salmon')
#  graphics.off()
#  
#  
#  
#  abline(v=path$pathobj$B[1:(algstep-1)],col='lightgrey',lty=3)
#  abline(v=path$pathobj$B[algstep],col='skyblue')
##    abline(v=path$pathobj$B[sigsteps],col='darkseagreen1')


#  legend("topright", lty = 1, col='skyblue', legend = "fl-detected jump",bg='white')
#  text(x=path$pathobj$B[algstep], y = 3, labels = paste('seg test p-value:\n',pvals.segment[algstep]))
#  text(x=path$pathobj$B[algstep], y = -2, labels = paste('spike test p-value:\n',pvals.spike[algstep]))
#  # title(paste0("spike pvalue: ", pvals.spike[algstep], "\n", "segment pvalue:",pvals.segment[algstep]))





## Plot some spike results
#  load(file=file.path(outputdir,"cgh.Rdata"))
#  pdf(file.path(outputdir,"cgh-spike-afew.pdf"),width=15,height=4)
#  par(mfrow=c(1,4))
#  for(algstep in spike.steplist){#
#    step = algstep+1
#    plot(NA,xlim=c(0,n),ylim=range(y0), cex=.2,xlab='coordinate',ylab='y')
#    abline(v=path$pathobj$B[1:(algstep-1)],col='lightgrey',lty=3)
#    abline(v=path$pathobj$B[algstep],col='skyblue')
##    abline(v=path$pathobj$B[sigsteps],col='darkseagreen1')
#    points(y0, cex=.2)
#    lines(path$beta[,step],col='red',lwd=2)
#    legend("topright", lty = 1, col='skyblue', legend = "fl-detected jump",bg='white')
#    text(x=path$pathobj$B[algstep], y = 3, labels = paste('seg test p-value:\n',pvals.segment[algstep]))
#    text(x=path$pathobj$B[algstep], y = -2, labels = paste('spike test p-value:\n',pvals.spike[algstep]))
#    # title(paste0("spike pvalue: ", pvals.spike[algstep], "\n", "segment pvalue:",pvals.segment[algstep]))
#  }
#  dev.off()

## plot some segment results
#  load(file=file.path(outputdir,"cgh.Rdata"))
#  pdf(file.path(outputdir,"cgh-segment-afew.pdf"),width=15,height=4)
#  par(mfrow=c(1,4))
#  for(algstep in seg.steplist){
#    step = algstep+1
#    
#    # Plot data and fused lasso estimate
#    plot(NA,xlim=c(0,n),ylim=range(y0), cex=.2,xlab='coordinate',ylab='y')
#    abline(v=path$pathobj$B[1:(algstep-1)],col='lightgrey',lty=3)
#    abline(v=path$pathobj$B[algstep],col='skyblue')
#    points(y0, cex=.2)
#    lines(path$beta[,step],col='red',lwd=2)
#    legend("topright", lty = 1, col='skyblue', legend = "fl-detected jump",bg='white')

#    # p-values
#    text(x=path$pathobj$B[algstep], y = 3, labels = paste('seg test p-value:\n',pvals.segment[algstep]))
#    text(x=path$pathobj$B[algstep], y = -2, labels = paste('spike test p-value:\n',pvals.spike[algstep]))
#    # title(paste0("spike pvalue: ", pvals.spike[algstep], "\n", "segment pvalue:",pvals.segment[algstep]))
#  }
#  dev.off()
#  
## plotting the results after about 15 steps, side by side
#  load(file=file.path(outputdir,"cgh.Rdata"))
#  pdf(file.path(outputdir,"cgh-compare.pdf"),width=14,height=7)
#    par(mfrow=c(2,1))
#    plot(NA,xlim=c(0,n),ylim=range(y0), cex=.2,xlab='coordinate',ylab='y')
#    abline(v=path$pathobj$B[spike.sigsteps],col='blue',lty=2)
#    points(y0, cex=.2)
#    lines(path$beta[,algstep],col='red',lwd=2)
#    legend("topright", lty = 1, col='blue', legend = "spike signif",bg='white')

#    plot(NA,xlim=c(0,n),ylim=range(y0), cex=.2,xlab='coordinate',ylab='y')
#    abline(v=path$pathobj$B[seg.sigsteps],col='pink',lty=2)
#    points(y0, cex=.2)
#    lines(path$beta[,step],col='red',lwd=2)
#    legend("topright", lty = 1, col='pink', legend = "segment signif",bg='white')
#  dev.off()
#  
#  
#  
#  
#  
### What happens when we condition on a further step, for segment?
## generate and save output
#  pvals.spike.further=pvals.segment.further=c()
##  seg.steplist = c(1,4,5,10)
##  spike.steplist=c(5,7,9,10)
#  steplist=1:16#seg.steplist#spike.steplist#c(1:16)
#  seg.sigsteps = spike.sigsteps = c()
#  for(algstep in steplist){
#    step = algstep+1
#    sigma = sd(y0-path$beta[,step])
#    d.spike   = getdvec(obj=path, y=y0, k=algstep, usage = "dualpathSvd", type="spike", matchstep=TRUE)
#    d.segment = getdvec(obj=path, y=y0, k=algstep, klater = step, usage = "dualpathSvd", type="segment", matchstep=F)
#    G = path$Gammat[1:path$nk[algstep+1],]
#    pvals.spike[algstep]   = signif(pval.fl1d(y=y0, G=G, dik=d.spike, sigma=sigma, approx=TRUE, threshold=TRUE, approxtype="rob"),2)
#    pvals.segment.further[algstep] = signif(pval.fl1d(y=y0, G=G, dik=d.segment, sigma=sigma, approx=TRUE, threshold=TRUE, approxtype="rob"),2)
#    if(pvals.spike[algstep] < alpha) spike.sigsteps = c(spike.sigsteps, step)
#    if(pvals.segment[algstep] < alpha) seg.sigsteps = c(seg.sigsteps, step)
#  }
#  save(file=file.path(outputdir,"cgh.Rdata"), list = ls())



## comparing the difference (doesn't do well; understandably so.)
#  pdf(file.path(outputdir,"cgh-segmentcompare.pdf"),width=15,height=4)
#  par(mfrow=c(1,4))
#  for(algstep in seg.steplist){
#    step = algstep+1
#    plot(NA,xlim=c(0,n),ylim=range(y0), cex=.2,xlab='coordinate',ylab='y')
#    abline(v=path$pathobj$B[1:(algstep-1)],col='lightgrey',lty=3)
#    abline(v=path$pathobj$B[algstep],col='skyblue')
#    points(y0, cex=.2)
#    lines(path$beta[,step],col='red',lwd=2)
#    legend("topright", lty = 1, col='skyblue', legend = "fl-detected jump",bg='white')
#    text(x=path$pathobj$B[algstep], y = 3, labels = paste('seg test p-value:\n',pvals.segment[algstep]))
#    text(x=path$pathobj$B[algstep], y = 2.5, labels = paste('1-more-condit p-value:\n',pvals.segment.further[algstep]))
#    # title(paste0("spike pvalue: ", pvals.spike[algstep], "\n", "segment pvalue:",pvals.segment[algstep]))
#  }
#  dev.off()


## what happens when we condition on step 16, and do everything? 

## The key question is now what exactly is step 16?


## Visualize fused lasso fits
  maxsteps = ncol(f0$beta)
  states = get.states(f0$action)
  par(mfrow=c(2,1))
  for(mytime in 1:100){
    readline()
    
    #plot
    plot(y0); 
    lines(f0$beta[,mytime],col='blue',lwd=2); 
    title(main=mytime);
    abline(v=(states[[mytime]])[states[[mytime]]<=n-1]);
    
    # bic
    plot(bic)
    points(y=bic[mytime],x=mytime, pch=16,col='blue')
    mytime=mytime+1;
  }
