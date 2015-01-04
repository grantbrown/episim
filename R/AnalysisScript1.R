# keep snippets here while working with your notebook's cells
suppressPackageStartupMessages(library(episim))

epidemicData <- matrix(c(143,1,"L0",164,2,"L0",244,3,"L0",303,4,"L0",306,5,"L0",312,6,"L0",319,7,"L0",320,8,"L0",323,9,"L0",326,10,"L0",327,11,"L0",330,12,"L0",331,13,"L0",332,14,"L0",338,18,"L0",339,19,"L0",342,20,"L0",344,21,"L0",345,22,"L0",347,24,"L0",348,25,"L0",352,26,"L0",353,27,"L0",357,30,"L0",359,31,"L0",360,32,"L0",361,33,"L0",363,34,"L0",365,36,"L0",366,38,"L0",369,39,"L0",371,40,"L0",379,43,"L0",382,44,"L0",383,45,"L0",384,46,"L0",385,47,"L0",387,48,"L0",412,49,"L0",416,50,"L0",283,1,"L1",317,2,"L1",325,3,"L1",331,4,"L1",336,5,"L1",338,7,"L1",342,8,"L1",343,9,"L1",344,10,"L1",345,11,"L1",347,12,"L1",354,13,"L1",355,14,"L1",358,15,"L1",361,16,"L1",363,17,"L1",364,18,"L1",365,19,"L1",366,23,"L1",367,24,"L1",369,26,"L1",371,28,"L1",376,30,"L1",378,31,"L1",379,33,"L1",381,34,"L1",382,37,"L1",383,38,"L1",384,39,"L1",386,41,"L1",387,42,"L1",392,45,"L1",394,46,"L1",396,47,"L1",400,48,"L1",404,50,"L1",405,52,"L1",413,53,"L1",417,54,"L1",424,55,"L1",200,1,"L2",236,2,"L2",318,3,"L2",321,4,"L2",334,5,"L2",336,6,"L2",343,7,"L2",344,8,"L2",345,10,"L2",353,11,"L2",354,12,"L2",358,13,"L2",359,14,"L2",362,15,"L2",364,16,"L2",378,17,"L2",382,18,"L2",386,19,"L2",391,20,"L2",392,21,"L2",394,22,"L2",398,23,"L2",115,1,"L3",125,2,"L3",132,3,"L3",145,4,"L3",168,5,"L3",171,6,"L3",194,7,"L3",199,8,"L3",287,9,"L3",330,10,"L3"), ncol = 3, byrow=TRUE);epidemicData=data.frame(time=as.numeric(epidemicData[,1]),cases=as.numeric(epidemicData[,2]),location=as.factor(epidemicData[,3]));p_ei=0.08; p_ir=0.004496273160941178
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


