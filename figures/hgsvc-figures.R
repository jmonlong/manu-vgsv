library(ggplot2)

## Function to read PR files and merge data adding a 'label' column
readEval <- function(files, methods, regions=NULL){
  if(is.null(regions)){
    regions = rep('', length(methods))
  }
  eval.df = lapply(1:length(files), function(ii){
    df = read.table(files[ii], as.is=TRUE, header=TRUE)
    df$method = methods[ii]
    df$region = regions[ii]
    df
  })
  df = do.call(rbind, eval.df)
  ## order by quality to make sure the lines/paths are correctly drawn
  df = df[order(df$qual),]
  df = subset(df, type!='INV' & TP.baseline>5)
  df$type = factor(df$type, levels=c('Total', 'INS', 'DEL'))
  df
}

## Simulated reads, all regions
eval.df = readEval(files = c('sim-hgsvc-construct-prcurve.tsv',
                             'sim-hgsvc-construct-clip-prcurve.tsv',
                             'sim-hgsvc-bayestyper-prcurve.tsv',
                             'sim-hgsvc-bayestyper-clip-prcurve.tsv'),
                   methods = c('vg-construct', 'vg-construct',
                              'BayesTyper', 'BayesTyper'),
                   regions=c('all', 'non-repeat', 'all', 'non-repeat'))

svg('hgsvc-sim.svg', 8, 4)
ggplot(eval.df, aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  geom_point(size=.8) +
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  scale_y_continuous(breaks=seq(0,1,.2), limits=0:1) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_brewer(palette='Set1')
dev.off()


## Real reads, all regions
eval.df = readEval(files = c('real-hgsvc-construct-prcurve.tsv',
                             'real-hgsvc-construct-clip-prcurve.tsv',
                             'real-hgsvc-bayestyper-prcurve.tsv',
                             'real-hgsvc-bayestyper-clip-prcurve.tsv'),
                   methods = c('vg-construct', 'vg-construct',
                              'BayesTyper', 'BayesTyper'),
                   regions=c('all', 'non-repeat', 'all', 'non-repeat'))

svg('hgsvc-real.svg', 8, 4)
ggplot(eval.df, aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  geom_point(size=.8) +
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  scale_y_continuous(breaks=seq(0,1,.2), limits=0:1) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_brewer(palette='Set1')
dev.off()


## Same for non-repeat regions
