
finishSimulation = function(iterationNumber)
{
  dat = read.csv(proposal$outFileName)
  I_star = processedData$I_star
  
  ## Do we need to estimate R0 for this chain?
  if (params[["estimateR0"]])
  {  
    R0 = array(0, dim = c(nrow(I_star), ncol(I_star), extraR0Iterations))
    effectiveR0 = array(0, dim = c(nrow(I_star), ncol(I_star), extraR0Iterations))
    empiricalR0 = array(0, dim = c(nrow(I_star), ncol(I_star), extraR0Iterations))
    for (i in 1:extraR0Iterations)
    {
      localModelObject$simulate(extraR0BatchSize)
      for (j in 0:(nrow(I_star)-1))
      {
        R0[j,,i] = localModelObject$estimateR0(j)
        effectiveR0[j,,i] = localModelObject$estimateEffectiveR0(j)
        empiricalR0[j,,i] = apply(localModelObject$getIntegratedGenerationMatrix(j), 1, sum)
      }
    }
    
    R0Mean = apply(R0, 1:2, mean)
    R0LB = apply(R0, 1:2, quantile, probs = 0.05)
    R0UB = apply(R0, 1:2, quantile, probs = 0.95)
    effectiveR0Mean = apply(effectiveR0, 1:2, mean)
    effectiveR0LB = apply(effectiveR0, 1:2, quantile, probs = 0.05)
    effectiveR0UB = apply(effectiveR0, 1:2, quantile, probs = 0.95)
    empiricalR0Mean = apply(empiricalR0, 1:2, mean)
    empiricalR0LB = apply(empiricalR0, 1:2, quantile, probs = 0.05)
    empiricalR0UB = apply(empiricalR0, 1:2, quantile, probs = 0.95)
    orig.R0 = R0
    R0 = list("R0" = list("mean"=R0Mean, "LB" = R0LB, "UB" = R0UB),
              "effectiveR0" = list("mean"=effectiveR0Mean, "LB" = effectiveR0LB, 
                                   "UB" = effectiveR0UB),
              "empiricalR0" = list("mean"=empiricalR0Mean, "LB" = empiricalR0LB, 
                                   "UB" = empiricalR0UB))
  } else
  {
    R0 = NULL
    orig.R0 = NULL
  }  
  
  return(list("chainOutput" = dat, "R0" = R0, "rawSamples" = orig.R0))
}
