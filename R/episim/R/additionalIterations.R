additionalIterations = function(params)
{ 
  N = params[[1]]
  targetRatio = params[[2]]
  targetWidth=params[[3]]
  proportionChange = params[[4]]
  updateParameters = params[[5]]
  localModelObject$simulate(N)
  if (updateParameters)
  {
    localModelObject$updateSamplingParameters(targetRatio, targetWidth, proportionChange)
  }
}

simulationLoop = function(fileNames, iterationParams, convergenceCriterion)
{
    startDat = read.csv(fileNames[1])
    totalSamples = max(startDat$Iteration)
    minimumSamples = 1000000
    conv = FALSE
    while (!conv)
    {
      conv = checkConvergence(fileNames[1], fileNames[2], fileNames[3], 
                              maxVal = convergenceCriterion)
      conv = (conv && (minimumSamples < totalSamples))
      if (!conv){
        cat(paste("Not converged, adding iterations. Total so far: ", totalSamples, 
                  "\n", sep =""))
        parLapply(cl, iterationParams, additionalIterations)
        totalSamples = totalSamples + iterationParams[[1]][[1]]
      }
      else{
        cat("Samplers converged, performing final R0 estimation run.\n")
        return
      }
    }
}
  