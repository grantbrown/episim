# keep snippets here while working with your notebook's cells
suppressPackageStartupMessages(library(episim))
epidemicData <- matrix(c(8,1,"L0",26,2,"L0",31,4,"L0",45,5,"L0",47,6,"L0",50,8,"L0",53,9,"L0",54,10,"L0",56,11,"L0",61,12,"L0",63,13,"L0",65,15,"L0",66,16,"L0",67,17,"L0",69,18,"L0",70,19,"L0",72,20,"L0",73,21,"L0",76,22,"L0",77,26,"L0",79,27,"L0",80,29,"L0",81,31,"L0",82,32,"L0",87,33,"L0",88,35,"L0",91,36,"L0",93,37,"L0",95,38,"L0",98,39,"L0",99,40,"L0",100,41,"L0",102,42,"L0",104,43,"L0",106,44,"L0",107,46,"L0",109,47,"L0",115,49,"L0",127,50,"L0",119,1,"L1",160,2,"L1",170,3,"L1",178,4,"L1",184,5,"L1",188,7,"L1",193,8,"L1",195,9,"L1",205,10,"L1",208,11,"L1",211,12,"L1",213,13,"L1",216,15,"L1",217,16,"L1",221,17,"L1",222,18,"L1",224,19,"L1",226,20,"L1",227,23,"L1",232,24,"L1",233,26,"L1",235,27,"L1",237,29,"L1",241,30,"L1",243,31,"L1",244,33,"L1",247,35,"L1",248,36,"L1",252,37,"L1",254,38,"L1",255,41,"L1",256,42,"L1",258,43,"L1",260,45,"L1",261,46,"L1",262,48,"L1",265,49,"L1",270,50,"L1",272,51,"L1",274,52,"L1",275,53,"L1",282,54,"L1",286,55,"L1",95,1,"L2",278,2,"L2",289,3,"L2",291,4,"L2",297,5,"L2",300,6,"L2",301,7,"L2",304,8,"L2",309,9,"L2",310,11,"L2",312,12,"L2",316,13,"L2",317,14,"L2",320,15,"L2",327,16,"L2",328,17,"L2",329,18,"L2",330,20,"L2",333,21,"L2",337,22,"L2",355,23,"L2"), ncol = 3, byrow=TRUE);epidemicData=data.frame(time=as.numeric(epidemicData[,1]),cases=as.numeric(epidemicData[,2]),location=as.factor(epidemicData[,3]));p_ei=0.08; p_ir=0.006692850924284856;L0=c(291.5,89.5);L1=c(874.5,268.5);L2=c(777.3333333333333,89.5);L3=c(291.5,298.3333333333333);
processedData = reprocessData(epidemicData)

cl = makeCluster(3)
clusterExport(cl, c("proposeParameters", "p_ei", "p_ir"))
paramsList = list(list("estimateR0"=FALSE, 
                       "traceCompartments"=TRUE, 
                       "seedVal"=133,
                       "chainNumber"=1,
                       "processedData"=processedData),
                  list("estimateR0"=TRUE, 
                       "traceCompartments"=FALSE, 
                       "seedVal"=1224,
                       "chainNumber"=2,
                       "processedData"=processedData),
                  list("estimateR0"=FALSE,
                       "traceCompartments"=FALSE, 
                       "seedVal"=12325,
                       "chainNumber"=3,
                       "processedData"=processedData))
chains = parLapply(cl, paramsList, buildAndBurnInModel)

iterationParams = list(convergenceSampleSize=10000, 
                       targetAcceptanceRatio=0.2,   
                       tolerance=0.05,
                       proportionChange = 0.1,
                       updateSamplingParams = FALSE)
iterationParams = list(iterationParams, iterationParams, iterationParams)

fileNames = c("chain_output_sim_1.txt", "chain_output_sim_2.txt", "chain_output_sim_3.txt")
simulationLoop(fileNames, iterationParams, 1.2)
chains = parLapply(cl, 1:3, finishSimulation)
save("chains", file="./chainOutput.Robj")
stopCluster(cl)

chain1 = chains[[1]]$chainOutput 
chain2 = chains[[2]]$chainOutput 
chain3 = chains[[3]]$chainOutput 
combinedChains = rbind(chain1[floor(nrow(chain1)/2):nrow(chain1),1:9],
                       chain2[floor(nrow(chain2)/2):nrow(chain2),1:9],
                       chain3[floor(nrow(chain3)/2):nrow(chain3),1:9])

spatialParameters = select(combinedChans, rho_0, rho_1, rho_2, rho_3, rho_4, rho_5)
spatialMeans = apply(spatialParameters, 2, mean)
barplot(spatialMeans/min(spatialMeans), main = "Relative Magnitudes of Spatial Parameters")




