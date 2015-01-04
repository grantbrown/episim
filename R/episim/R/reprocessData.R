reprocessData <- function(epidemicData){
  pred.tpts = 120
  targetTptsPerRecord = 7
  
  uncumulate = function(x)
  {
    out = c(x[2:length(x)]-x[1:(length(x)-1)])
    ifelse(out >= 0, out, 0)
  }
  rptDate = unique(epidemicData$time); rptDate=rptDate[order(rptDate)]
  numDays = max(rptDate) - min(rptDate)
  numDays.pred = numDays + pred.tpts
  
  wideData = data.frame(time=rptDate)
  for (loc in unique(epidemicData$location)){
    dataSub = select(filter(epidemicData, location==loc), time, cases)
    wideData = (left_join(wideData, dataSub, by=c("time")))
    colnames(wideData)[ncol(wideData)] = loc;
  }
  wideData[1,is.na(wideData[1,])] = 0
  for (i in 2:nrow(wideData))
  {
    wideData[i,is.na(wideData[i,])] = wideData[i-1,is.na(wideData[i,])]
  }
  
  nDays = uncumulate(rptDate)
  thinIndices = function(minDays, weights)
  {
    keepIdx = c(length(weights))
    currentWeight = 0
    lastIdx = -1
    for (i in seq(length(weights)-1, 1))
    {
      currentWeight = currentWeight + weights[i]
      if (currentWeight >= minDays)
      {
        currentWeight = 0
        keepIdx = c(keepIdx, i)
        lastIdx = i
      }
    }
    if (currentWeight != 0)
    {
      keepIdx = c(keepIdx, lastIdx-1)
    }
    keepIdx
  }
  
  keepIdx = thinIndices(targetTptsPerRecord, c(nDays,1))
  keepIdx = keepIdx[order(keepIdx)]
  wideData = wideData[keepIdx,]
  
  
  # The "I_star" name will make more sense in a bit
  I_star = cbind(uncumulate(wideData[,2]), 
                 uncumulate(wideData[,3]), 
                 uncumulate(wideData[,4]),
                 uncumulate(wideData[,5]))
  
  I0 = wideData[1,2:5]
  N = matrix(c(50,55,23,10), nrow = nrow(I_star), ncol =4, byrow=TRUE)
  offsets = c(1, uncumulate(rptDate[keepIdx])[1:(nrow(I_star)-1)])
  
  
  return(list(I_star=I_star,
              N=N,
              I0=I0,
              offsets=offsets,
              rptDate=rptDate))
}
