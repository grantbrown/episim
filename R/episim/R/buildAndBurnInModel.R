buildAndBurnInModel = function(params)
{
  library(spatialSEIR)
  # save proposal and params to node workspace
  proposal <<- proposeParameters(params[["seedVal"]], params[["chainNumber"]],params[["processedData"]])
  params <<- params
  extraR0Iterations <<- 500
  extraR0BatchSize <<- 1000
  processedData <<- params[["processedData"]]
  
  SEIRmodel =  buildSEIRModel(proposal$outFileName,
                              proposal$DataModel,
                              proposal$ExposureModel,
                              proposal$ReinfectionModel,
                              proposal$DistanceModel,
                              proposal$TransitionPriors,
                              proposal$InitContainer,
                              proposal$SamplingControl)
  
  SEIRmodel$setRandomSeed(params[["seedVal"]])
  # Save model object to node workspace
  localModelObject <<- SEIRmodel
  
  # Do we need to keep track of compartment values for prediction? 
  # No sense doing this for all of the chains.
  if (params[["traceCompartments"]])
  {
    SEIRmodel$setTrace(0) 
    SEIRmodel$setTrace(1) 
    SEIRmodel$setTrace(2) 
    SEIRmodel$setTrace(3) 
  }
  
  # Make a helper function to run each chain, as well as update the metropolis 
  # tuning parameters. 
  runSimulation = function(modelObject,
                           numBatches=500, 
                           batchSize=20, 
                           targetAcceptanceRatio=0.2,
                           tolerance=0.05,
                           proportionChange = 0.1
  )
  {
    for (batch in 1:numBatches)
    {
      modelObject$simulate(batchSize)
      modelObject$updateSamplingParameters(targetAcceptanceRatio, 
                                           tolerance, 
                                           proportionChange)
    }
  }
  
  # Burn in tuning parameters
  runSimulation(SEIRmodel, numBatches = 1000)
  runSimulation(SEIRmodel, batchSize = 100, numBatches = 100)  
  SEIRmodel$compartmentSamplingMode = 17
  SEIRmodel$performHybridStep = 50
}
