## Color palette
library(RColorBrewer)
tools = c('vg', 'BayesTyper', 'svtyper', 'Delly', 'SMRT-SV2')
pal.tools = brewer.pal(length(tools), 'Set1')
names(pal.tools) = tools


## Function to read PR files and merge data adding a 'label' column
readEval <- function(files, methods, regions=NULL, folder='data'){
  if(is.null(regions)){
    regions = rep('', length(methods))
  }
  eval.df = lapply(1:length(files), function(ii){
    df = read.table(paste0(folder, '/', files[ii]), as.is=TRUE, header=TRUE)
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


## Read 4 evaluation files (call/geno x all/nonrep) for each method-sample pair
## tsv files must be named: {prefix}-{method}-{sample}-{all|nonrep}-{call|geno}-prcurve.tsv
readEval4 <- function(methods, samples, prefix, regions=c('all','nonrep')){
  res = lapply(methods, function(meth){
    res = lapply(samples, function(samp){
      res = lapply(regions, function(reg){
        res = lapply(c('call', 'geno'), function(ev){
          df = read.table(paste(prefix, meth, samp, reg, ev, 'prcurve.tsv', sep='-'), as.is=TRUE, header=TRUE)
          df$method = meth
          df$region = reg
          df$sample = samp
          df$eval = ev
          df
        })
        do.call(rbind, res)
      })
      do.call(rbind, res)
    })
    do.call(rbind, res)
  })
  res = do.call(rbind, res)
  res$type = factor(res$type, levels=c('Total', 'INS', 'DEL', 'INV'))
  res$region = factor(res$region, levels=c('all','nonrep'), labels=c('all','non-repeat'))
  res
}

