proposeParameters = function(seedVal, chainNumber, processedData)
{
  # Model structure
  pred.tpts = 120
  #X = diag(ncol(processedData$N))
  X = matrix(1, ncol=1, nrow = ncol(processedData$N))
  X.predict = X
  splineBasis = c()
  splineBasis.predict = c()
  Z = NA
  Z.predict = NA
  X.pred = cbind(X.predict[rep(1:nrow(X.predict), each = length(pred.tpts)),])
  
  
  DM1 = matrix(c(0,1,0,0,
                 1,0,0,0,
                 0,0,0,0,
                 0,0,0,0), nrow = 4, ncol = 4, byrow = TRUE)
  DM2 = matrix(c(0,0,1,0,
                 0,0,0,0,
                 1,0,0,0,
                 0,0,0,0), nrow = 4, ncol = 4, byrow = TRUE)
  DM3 = matrix(c(0,0,0,1,
                 0,0,0,0,
                 0,0,0,0,
                 1,0,0,0), nrow = 4, ncol = 4, byrow = TRUE)
  DM4 = matrix(c(0,0,0,0,
                 0,0,1,0,
                 0,1,0,0,
                 0,0,0,0), nrow = 4, ncol = 4, byrow = TRUE)
  DM5 = matrix(c(0,0,0,0,
                 0,0,0,1,
                 0,0,0,0,
                 0,1,0,0), nrow = 4, ncol = 4, byrow = TRUE)
  DM6 = matrix(c(0,0,0,0,
                 0,0,0,0,
                 0,0,0,1,
                 0,0,1,0), nrow = 4, ncol = 4, byrow = TRUE)
  dmList = list(DM1, DM2, DM3, DM4, DM5, DM6)
  
  
  X_p_rs = matrix(0)
  
  # Dummy value for reinfection params
  beta_p_rs = rep(0, ncol(X_p_rs))
  # Dummy value for reinfection params prior precision
  betaPrsPriorPrecision = 0.5
  
  gamma_ei = -log(1-p_ei)
  gamma_ir = -log(1-p_ir)
  eiEffectiveSampleSize = 10000
  irEffectiveSampleSize = 10000
  betaPriorPrecision = 0.1
  betaPriorMean = 0
  
  # Params
  
  
  set.seed(seedVal) 
  

  beta = rnorm(1,0,1)
  
  outFileName = paste("./chain_output_sim_", chainNumber ,".txt", sep = "")
  
  DataModel = buildDataModel(processedData$I_star, type = "identity")
  ExposureModel = buildExposureModel(X, Z, beta, betaPriorPrecision,
                                     betaPriorMean,
                                     processedData$offsets, 
                                     nTpt = nrow(processedData$I_star))
  ReinfectionModel = buildReinfectionModel("SEIR")
  SamplingControl = buildSamplingControl(iterationStride=1000,
                                         sliceWidths=c(1, # S_star
                                                       1, # E_star
                                                       1,  # R_star
                                                       1,  # S_0
                                                       1,  # I_0
                                                       0.05,  # beta
                                                       0.0,  # beta_p_rs, fixed in this case
                                                       0.01, # rho
                                                       0.01, # gamma_ei
                                                       0.01,  # gamma_ir
                                                       0.01)) # phi)
  
  InitContainer = buildInitialValueContainer(processedData$I_star, processedData$N, 
                                             S0 = processedData$N[1,]-processedData$I0 -processedData$I_star[1,],
                                             E0 = processedData$I_star[1,],
                                             I0 = processedData$I0)
  DistanceModel = buildDistanceModel(dmList, priorAlpha = 1, priorBeta = 500)
  TransitionPriors = buildTransitionPriorsFromProbabilities(1-exp(-gamma_ei), 1-exp(-gamma_ir),
                                                            eiEffectiveSampleSize, irEffectiveSampleSize)
  return(list(DataModel=DataModel,
              ExposureModel=ExposureModel,
              ReinfectionModel=ReinfectionModel,
              SamplingControl=SamplingControl,
              InitContainer=InitContainer,
              DistanceModel=DistanceModel,
              TransitionPriors=TransitionPriors,
              outFileName=outFileName))
}
