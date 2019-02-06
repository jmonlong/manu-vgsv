library(ggplot2)


## Read files and merge data adding a 'label' column
readEval <- function(files, labels){
  eval.df = lapply(1:length(files), function(ii){
    df = read.table(files[ii], as.is=TRUE, header=TRUE)
    df$label = labels[ii]
    df
  })
  df = do.call(rbind, eval.df)
  ## order by quality to make sure the lines/paths are correctly drawn
  df = df[order(df$qual),]
  df
}

## For example for simulations and all regions
eval.df = readEval(files = c('sim-hgsvc-construct-prcurve.tsv',
                             'sim-hgsvc-1kg-construct-prcurve.tsv',
                             'sim-hgsvc-bayestyper-prcurve.tsv'),
                   labels = c('HGSVC-construct',
                              'HGSVC-1KG-constuct',
                              'HGSVC-BayesTyper'))

svg('hgsvc-sim.svg', 9, 7)
ggplot(eval.df, aes(x=recall, y=precision, colour=label)) +
  geom_path() +
  ## geom_point(aes(size=qual)) +
  theme_bw() +
  facet_grid(.~label) +
  xlim(0,1) + ylim(0,1) +
  theme(legend.position='bottom')
dev.off()


## Same for non-repeat regions and real reads.
