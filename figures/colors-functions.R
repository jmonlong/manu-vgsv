## Color palette
library(RColorBrewer)
tools = c('vg-construct', 'BayesTyper', 'svtyper', 'Delly', 'SMRT-SV2')
pal.tools = brewer.pal(length(tools), 'Set1')
names(pal.tools) = tools


## Function to read PR files and merge data adding a 'label' column
readEval <- function(files, methods, regions=NULL){
  if(is.null(regions)){
    regions = rep('', length(methods))
  }
  eval.df = lapply(1:length(files), function(ii){
    df = read.table(paste0('data/', files[ii]), as.is=TRUE, header=TRUE)
    df$method = methods[ii]
    df$region = regions[ii]
    df
  })
  df = do.call(rbind, eval.df)
  ## order by quality to make sure the lines/paths are correctly drawn
  df = df[order(df$qual),]
  df$type = factor(df$type, levels=c('Total', 'INS', 'DEL', 'INV'))
  df
}
