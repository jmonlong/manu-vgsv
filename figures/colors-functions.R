## Color palette
library(RColorBrewer)
tools = c('vg', 'BayesTyper', 'SVTyper', 'Delly', 'SMRT-SV v2')
pal.tools = brewer.pal(length(tools), 'Set1')
names(pal.tools) = tools

## Relabels columns and set an order
relabel <- function(df, nonrep=c('nonrep', 'hc')){
  ## Types
  if('type' %in% colnames(df)){
    df$type = factor(df$type, levels=c('Total', 'INS', 'DEL', 'INV'))
  }
  ## Region
  if('region' %in% colnames(df)){
    reg.l = c('all','repeat', 'non-repeat', 'called in SMRT-SV v2',
              'not called in SMRT-SV v2')
    if(nonrep[1] == 'nonrep'){
      reg.l[3] = 'non-repeat'
    } else if(nonrep[1] == 'hc'){
      reg.l[3] = 'high-confidence'
    }
    df$region = factor(df$region, levels=c('all','rep', 'nonrep', 'called', 'nocalls'),
                       labels=reg.l)
  }
  ## Evaluation metric
  if('eval' %in% colnames(df)){
    df$eval=factor(df$eval, levels=c('call','geno'),
                   labels=c('presence', 'genotype'))
  }
  ## Experiment
  if('exp' %in% colnames(df)){
    df$experiment = factor(df$exp,
                           levels=c('hgsvcsim', 'hgsvc', 'giab5',
                                    'chmpd', 'svpop'),
                           labels=c('HGSVC simulated reads', 'HGSVC real reads',
                             'GIAB', 'CHM-PD', 'SVPOP'))
  }
  ## Sizes
  if('size' %in% colnames(df)){
    sizes = unique(df$size)
    sizes = sizes[order(as.numeric(gsub('.*,(.*)]', '\\1', sizes)))]
    sizes.l = gsub('\\((.*),Inf]', '>\\1', sizes)
    sizes.l = gsub('e\\+03', 'K', sizes.l)
    sizes.l = gsub('e\\+04', '0K', sizes.l)
    sizes.l = gsub('e\\+05', '00K', sizes.l)
    df$size = factor(df$size, levels=sizes, labels=sizes.l)
  }
  return(df)
}

## (Re)-compute precision, recall and F1 score (e.g. when merging samples)
prf <- function(eval.df){
  eval.df$precision = eval.df$TP / (eval.df$TP + eval.df$FP)
  eval.df$precision = round(eval.df$precision, 4)
  eval.df$recall = eval.df$TP.baseline / (eval.df$TP.baseline + eval.df$FN)
  eval.df$recall = round(eval.df$recall, 4)
  eval.df$F1 = 2 * eval.df$precision * eval.df$recall /
    (eval.df$precision + eval.df$recall)
  eval.df$F1 = round(eval.df$F1, 4)
  return(eval.df)
}
