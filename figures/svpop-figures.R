library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## HG00514 reads, but processed with 15-sample graph of SMRT-SV2 discovery data from Audano et. al 2019
## There are no genotypes for this data, but there are a few inversions
eval.df = readEval(files = c('svpop-construct-prcurve.tsv',
                             'svpop-construct-clip-prcurve.tsv'),
                   methods = rep(c('vg-construct'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))
eval.df$method = factor(eval.df$method, levels=names(pal.tools))

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/svpop.pdf', 8, 4)

ggplot(eval.df, aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(size=3, data=label.df) + 
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  ## scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  ## scale_y_continuous(breaks=seq(0,1,.1), limits=c(.6,1)) +
  scale_linetype_manual(values=c(4,1)) + 
  scale_colour_manual(values=pal.tools)

dev.off()

## Print Markdown table
label.df %>% select(region, method, everything()) %>% arrange(region, method) %>%
  kable(digits=3, format.args=list(big.mark=','))


