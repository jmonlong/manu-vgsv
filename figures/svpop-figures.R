library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## HG00514 reads, but processed with 15-sample graph of SMRT-SV2 discovery data from Audano et. al 2019
## There are no genotypes for this data, but there are a few inversions

## Method names and renaming vector to fit color palette
methods = c('vg','smrtsv')
methconv = c(vg='vg', smrtsv='SMRT-SV2')

samples = c('HG00514', 'HG00733', 'NA19240')
svpop.df = readEval4(methods, samples, prefix='data/svpop/svpop', eval='call')
svpop.df$method = factor(methconv[svpop.df$method], levels=names(pal.tools))

## Merge samples
svpop.df = svpop.df %>% group_by(type, qual, method, region, eval) %>%
  select(-sample) %>% summarize_all(sum)
svpop.df$precision = svpop.df$TP.baseline / (svpop.df$TP.baseline + svpop.df$FP)
svpop.df$recall = svpop.df$TP.baseline / (svpop.df$TP.baseline + svpop.df$FN)
svpop.df$F1 = 2 * svpop.df$precision * svpop.df$recall / (svpop.df$precision + svpop.df$recall)
svpop.df$F1 = ifelse(svpop.df$recall==0, 0, svpop.df$F1)

svpop.df = svpop.df %>% filter(type!='Total') %>% arrange(qual)
label.df = svpop.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/svpop.pdf', 8, 4)

svpop.df %>% filter(eval=='call') %>% 
  ggplot(aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(size=3, data=subset(label.df, eval=='call')) + 
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  ## scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  ## scale_y_continuous(breaks=seq(0,1,.1), limits=c(.6,1)) +
  scale_linetype_manual(values=c(4,1)) + 
  scale_colour_manual(values=pal.tools)

dev.off()



## Bar plots with best F1
eval.f1 = label.df %>% ungroup %>%
  mutate(F1=ifelse(is.infinite(F1), NA, F1),
         eval=factor(eval, levels=c('call','geno'),
                     labels=c('absence/presence', 'genotype')))
  

pdf('pdf/svpop-best-f1.pdf', 8, 4)

eval.f1 %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~.) +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() +
  ylab('best F1') +  xlab('genomic regions') + 
  theme()

dev.off()

eval.f1 %>% filter(!is.na(F1)) %>%
  select(method, region, type, TP.baseline, FP, FN, precision, recall, F1) %>%
  arrange(method, region) %>%
  kable(digits=3) %>%
  cat(file='tables/svpop.md', sep='\n')
