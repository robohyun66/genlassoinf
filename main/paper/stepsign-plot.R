# working directory should be [genlassoinf]/code
source("settings.R")
source('funs.R')
source('testfuns.R')
source('dualPathSvd2.R')
library(genlasso)

###############################
### Fused Lasso example #######
###############################

  lev1=2; lev2=5; lev3=3;lev4=10; n = 20*4
  beta0 = rep(c(lev1,lev2,lev3,lev4),each=n/4)+5
  y0    = beta0 + rnorm(n, 0, sigma)

# Example of linear trend filtering    
  sigma = 1;    tf.order = 0;    consec = 2
  seed = 35;#32;33;35;37
  set.seed(seed)
  y0 = beta0 + rnorm(length(beta0),0,sigma)

#  set.seed(53)
  D = makeDmat(n,type="trend.filtering",order=tf.order)
  maxsteps = 37
  f0 = dualpathSvd2(y0, D, maxsteps = maxsteps)
  tf.order = 0
  consec=2
  bic = get.modelinfo(f0, y0, sigma,maxsteps=maxsteps,D=D)$ic
  stop.time = which.rise(bic,consec)-1
 
# No decluttering
  signs = f0$ss[[stop.time+1]]
  final.model = f0$states[[stop.time+1]]

    # Takes in the signs |signs| and the locations |final.model|
    step.sign.plot = function(signs, final.model,n){
      signs = signs[order(final.model)]
      signs = c(-signs[1], signs)
      cumul.signs = cumsum(signs)
      final.model = sort(final.model)
      nn = length(final.model)
      indices <- vector(mode = "list", length = nn+1)
        indices[2:nn] = Map(function(a,b){a:b},
                                final.model[1:(length(final.model)-1)]+1, 
                                final.model[2:length(final.model)])
        indices[[1]] = 1:final.model[1]
        indices[[nn+1]] = (final.model[length(final.model)]+1):n
      sign0 = do.call(c, 
               lapply(1:length(cumul.signs), 
                  function(ii){rep(cumul.signs[ii], length(indices[[ii]]))})
                  )
      return(sign0)
    }
    s0 = step.sign.plot(signs, final.model,n)
    plot(y0,ylim=c(-2,max(y0)))
    lines(beta0,col='red')
    lines(s0,type='l')
    lines(f0$beta[,stop.time+1],col='blue')

######################################
### Make fused lasso sign-set plot ###
######################################
    # plot parameters
  xlab = "Locations"
  ylab1 = ""#"Data and estimate"
  ylab2 = ""#"contrast(=v)"
  w = 6; h = 5 
  pch.dat = 16; 
  pch.lrt = 17
  pcol.dat = "gray50"
  pcol.lrt = "cyan"
  lcol.fit = "blue"
  lcol.adj.knot = lcol.hline = "lightgrey"
  lcol.test.knot = "blue"
  lty.fit = 1 ;   lwd.fit = 2
  lty.knot = 3 ; lwd.knot = 2
  ylim.stepsign=range(s0)+c(-3,3)
  lwd.est=2
  lwd.stepsign=2
  xlab = "Location"
  ######################################### 
  ### plot data and fitted final model ####
  #########################################
  pdf(file=file.path(outputdir, "1dfl-signpic-dat.pdf"), width=w,height=h)
    par(mar=c(5.3,4.1,3.1,2.1)-1.3)
    plot(y0, ylab = "Data and final model", xlab=xlab, pch=pch.dat, col = pcol.dat, axes=F) 
    #title(main = "Data and final model")
    axis(1); axis(2)
    legend("topleft", pch= c(NA,16), pt.cex=c(NA,1),lty=c(1,NA),
        lwd = c(lwd.est,NA),col = c("blue",pcol.dat),
        legend=c("Estimate","Data"))
    lines(f0$beta[,stop.time+1],col = 'blue', lwd=lwd.est)
    abline(v=final.model,col='lightgrey',lty=2)
    graphics.off()    
  ################################## 
  ### plot picture of the signs ####
  ##################################
  pdf(file=file.path(outputdir, "1dfl-signpic.pdf"), width=w,height=h)
    par(mar=c(5.3,4.1,3.1,2.1)-1.3)
    plot(s0,type='l', axes=F, xlab = xlab, ylim = ylim.stepsign, lwd=lwd.stepsign, ylab = "")
    axis(1)
    sign.chars = sapply(signs,function(mysign){if(mysign==+1)"+" else "-"})
    text(x=final.model, y = +2, label = sign.chars,cex=1.5)
    #title(main = "Step-sign plot")
    text(x=.3,y=-1,label=as.expression(bquote(eta~"'")))
    abline(v=final.model,col='lightgrey',lty=2)
    graphics.off()


##################################
## Trend Filtering visual aid ####
##################################
  beta1 = seq(from=1,to=10,by=1)
  beta2 = -0.5*seq(from=11,to=20,by=1) + 15
  beta3 = seq(from=21,to=30,by=1) - 15
  beta0 = c(beta1,beta2,beta3)
  n = length(beta0)
  
# Example of linear trend filtering    
  sigma = 1;    tf.order = 1;    consec = 2
  seed = 5;#32;33;35;37
#  for(seed in 1:30){
#  readline()
#  par(mfrow=c(1,2))
  set.seed(seed)
  y0 = beta0 + rnorm(n,0,sigma)

#  set.seed(53)
  D = makeDmat(n,type="trend.filtering",order=tf.order)
  maxsteps = 20
  f0 = dualpathSvd2(y0, D, maxsteps = maxsteps)
  consec=2
  bic = get.modelinfo(f0, y0, sigma,maxsteps=maxsteps,D=D)$ic
  stop.time = which.rise(bic,consec)-1
 
# No decluttering
  signs = f0$ss[[stop.time+1]]
  final.model = f0$states[[stop.time+1]]
  #final.model = declutter(final.model, 1)

    # Takes in the signs |signs| and the locations |final.model|
    step.sign.plot.linear = function(signs, final.model,n){
      signs = signs[order(final.model)]
      signs = c(-signs[1], signs)
      cumul.signs = cumsum(signs)
      final.model = sort(final.model)
      nn = length(final.model)
      indices <- vector(mode = "list", length = nn+1)
        indices[2:nn] = Map(function(a,b){a:b},
                                final.model[1:(length(final.model)-1)]+1, 
                                final.model[2:length(final.model)])
        indices[[1]] = 1:final.model[1]
        indices[[nn+1]] = (final.model[length(final.model)]+1):n
      sign0 = do.call(c, 
               lapply(1:length(cumul.signs), 
                  function(ii){rep(cumul.signs[ii], length(indices[[ii]]))})
                  )
      return(sign0)
    }
    s0 = step.sign.plot(signs, final.model,n)
    s1 = cumsum(s0)
#    plot(y0,ylim=c(-2,max(y0)))
#    lines(beta0,col='red')
#    lines(s0,type='l')
#    lines(s1,type='l',lwd=1.5)
#    lines(f0$beta[,stop.time+1],col='blue')

##########################################
### Make trend filtering sign-set plot ###
##########################################
    # plot parameters
  xlab = "Locations"
  ylab1 = ""#"Data and estimate"
  ylab2 = ""#"contrast(=v)"
  w = 5; h = 4
  pch.dat = 16; 
  pch.lrt = 17
  pcol.dat = "gray50"
  pcol.lrt = "cyan"
  lcol.fit = "blue"
  lcol.adj.knot = lcol.hline = "lightgrey"
  lcol.test.knot = "blue"
  lty.fit = 1 ;   lwd.fit = 2
  lty.knot = 3 ; lwd.knot = 2
  ylim.stepsign=range(s0)+c(-3,3)
  lwd.est=2
  lwd.stepsign=2
  
  pdf(file=file.path(outputdir, "tf-signpic-dat.pdf"), width=w,height=h)
    # plot data and fitted final model
    par(mar=c(5.2,4.1,3.1,2.1)-1.3)
    plot(y0, ylab = "Data and final model", xlab="", pch=pch.dat, col = pcol.dat, axes=F) 
    #title(main = "Data and final model")
    axis(1); axis(2)
    legend("topleft", pch= c(NA,16), pt.cex=c(NA,1),lty=c(1,NA), lwd = c(lwd.est,NA),col = c("blue",pcol.dat),legend=c("Model Estimate","Data"))
    lines(f0$beta[,stop.time+1],col = 'blue', lwd=lwd.est)
    abline(v=final.model,col='lightgrey',lty=2)
    text(x=0,y=.5,label=as.expression(bquote(eta)))
    graphics.off()    
    # plot sign pictures

  pdf(file=file.path(outputdir, "tf-signpic.pdf"), width=w,height=h)
    par(mar=c(5.2,4.1,3.1,2.1)-1.3)
    plot(s0+2,type='l', axes=F, xlab = "Coordinates", ylim = ylim.stepsign, lwd=lwd.stepsign, ylab = "")
    text(x=.5,y=3,label=as.expression(bquote(eta~"'")))
    lines((s1-mean(s1))/10-1.6, type = 'l',lwd=lwd.stepsign)
    axis(1)
    sign.chars = sapply(signs,function(mysign){if(mysign==+1)"+" else "-"})
    text(x=final.model, y = 0, label = sign.chars,cex=1.5)
    text(x=.5,y=-2.3,label=as.expression(bquote(eta~"''")))
    #title(main = "Step-sign plot")
    abline(v=final.model,col='lightgrey',lty=2)
    graphics.off()
#title(seed)
#}
