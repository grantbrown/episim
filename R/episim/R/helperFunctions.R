readData = function(filenames){
    dat1 <<- read.csv(filenames[1])
    dat2 <<- read.csv(filenames[2])
    dat3 <<- read.csv(filenames[3])
}

plotChains = function(variableName,...){
    alpha=0.6
    col1 = rgb(245/255, 61/255,0,alpha)
    col2 = rgb(184/255, 245/255,0, alpha)
    col3 = rgb(0,61/255,245/255, alpha)

    cex = 0.8
    lwd = 1.2
    plot(dat1[[variableName]], main = variableName, pch = 16, cex = cex, col =col1, type = "n", ylab="Variable Value",...) 
    ylims = par("yaxp")[1:2]
    yrange = ylims[2] - ylims[1]
    abline(h = seq(min(ylims) - yrange, max(ylims) + yrange, length = 20), col = "lightgrey", lty =2)
    points(dat1[[variableName]], pch = 16, cex = cex, col =col1) 
    lines(dat1[[variableName]], col = col1, lwd =lwd)
    points(dat2[[variableName]], pch = 16, cex = cex, col = col2)
    lines(dat2[[variableName]], col = col2, lwd = lwd)
    points(dat3[[variableName]], pch = 16, cex = cex, col = col3)
    lines(dat3[[variableName]], col = col3, lwd = lwd)
}
