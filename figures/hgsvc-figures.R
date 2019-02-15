library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)

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

## Simulated reads
eval.df = readEval(files = c('sim-hgsvc-construct-prcurve.tsv',
                             'sim-hgsvc-construct-clip-prcurve.tsv',
                             'sim-hgsvc-bayestyper-prcurve.tsv',
                             'sim-hgsvc-bayestyper-clip-prcurve.tsv',
                             'sim-hgsvc-svtyper-prcurve.tsv',
                             'sim-hgsvc-svtyper-clip-prcurve.tsv',
                             'sim-hgsvc-delly-prcurve.tsv',
                             'sim-hgsvc-delly-clip-prcurve.tsv'),
                   methods = rep(c('vg-construct', 'BayesTyper', 'svtyper', 'Delly'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

svg('hgsvc-sim.svg', 8, 4)

ggplot(eval.df, aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(size=3, data=label.df) + 
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  scale_y_continuous(breaks=seq(0,1,.1), limits=c(.6,1)) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_brewer(palette='Set1')

dev.off()

## Print Markdown table
label.df %>% select(region, method, everything()) %>% arrange(region, method) %>%
  kable(digits=3, format.args=list(big.mark=','))

## Real reads
eval.df = readEval(files = c('real-hgsvc-construct-prcurve.tsv',
                             'real-hgsvc-construct-clip-prcurve.tsv',
                             'real-hgsvc-bayestyper-prcurve.tsv',
                             'real-hgsvc-bayestyper-clip-prcurve.tsv',
                             'real-hgsvc-svtyper-prcurve.tsv',
                             'real-hgsvc-svtyper-clip-prcurve.tsv',
                             'real-hgsvc-delly-prcurve.tsv',
                             'real-hgsvc-delly-clip-prcurve.tsv'),
                   methods = rep(c('vg-construct', 'BayesTyper', 'svtyper', 'Delly'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

svg('hgsvc-real.svg', 8, 4)

ggplot(eval.df, aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(size=3, data=label.df) + 
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  scale_y_continuous(breaks=seq(0,1,.1), limits=c(.6,1)) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_brewer(palette='Set1')

dev.off()

## Print Markdown table
label.df %>% select(region, method, everything()) %>% arrange(region, method) %>%
  kable(digits=3, format.args=list(big.mark=','))
