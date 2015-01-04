# keep snippets here while working with your notebook's cells
suppressPackageStartupMessages(library(episim))

epidemicData <- matrix(c(96,1,"L0",124,3,"L0",271,4,"L0",279,5,"L0",283,6,"L0",285,7,"L0",287,8,"L0",292,9,"L0",294,10,"L0",298,11,"L0",301,13,"L0",302,15,"L0",309,16,"L0",310,17,"L0",314,19,"L0",316,20,"L0",319,21,"L0",320,22,"L0",325,23,"L0",326,25,"L0",328,27,"L0",329,29,"L0",331,30,"L0",332,31,"L0",334,32,"L0",335,33,"L0",336,34,"L0",337,35,"L0",340,36,"L0",341,37,"L0",351,38,"L0",365,39,"L0",367,40,"L0",372,41,"L0",377,42,"L0",400,43,"L0",404,44,"L0",2,1,"L1",5,2,"L1",25,3,"L1",27,4,"L1",31,5,"L1",34,6,"L1",42,7,"L1",43,8,"L1",46,9,"L1",54,10,"L1",56,11,"L1",58,12,"L1",59,13,"L1",63,14,"L1",66,15,"L1",71,16,"L1",73,18,"L1",76,19,"L1",77,20,"L1",80,21,"L1",83,22,"L1",84,23,"L1",85,24,"L1",86,25,"L1",87,26,"L1",91,27,"L1",92,28,"L1",93,30,"L1",97,33,"L1",103,34,"L1",104,35,"L1",106,36,"L1",107,37,"L1",109,38,"L1",113,39,"L1",116,40,"L1",117,41,"L1",119,42,"L1",121,43,"L1",122,44,"L1",123,46,"L1",131,47,"L1",138,49,"L1",179,50,"L1",382,51,"L1",385,52,"L1",392,53,"L1",458,54,"L1",104,1,"L2",310,2,"L2",321,3,"L2",335,4,"L2",336,5,"L2",337,6,"L2",343,7,"L2",345,8,"L2",353,9,"L2",363,10,"L2",365,11,"L2",372,12,"L2",443,13,"L2",354,1,"L3",365,2,"L3",366,3,"L3",377,4,"L3",378,5,"L3",390,6,"L3",400,7,"L3",412,8,"L3"), ncol = 3, byrow=TRUE);epidemicData=data.frame(time=as.numeric(epidemicData[,1]),cases=as.numeric(epidemicData[,2]),location=as.factor(epidemicData[,3]));
processedData = reprocessData(epidemicData)

cl = makeCluster(3)
clusterExport(cl, c("proposeParameters"))
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


