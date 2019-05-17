library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## HG00514 reads, but processed with 15-sample graph of SMRT-SV v2 discovery data from Audano et. al 2019
## There are no genotypes for this data, but there are a few inversions

## Method names and renaming vector to fit color palette
methods = c('vg','smrtsv')
methconv = c(vg='vg', smrtsv='SMRT-SV v2')

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
  ## geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(aes(shape=region), size=3, data=subset(label.df, eval=='call')) + 
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  labs(x='Recall', y='Precision', color='Method', shape='Genomic regions', linetype='Genomic regions') + 
  ## scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  ## scale_y_continuous(breaks=seq(0,1,.1), limits=c(.6,1)) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_manual(values=pal.tools)
dev.off()


## Bar plots with best F1
eval.f1 = label.df %>% ungroup %>%
  mutate(F1=ifelse(is.infinite(F1), NA, F1),
         eval=factor(eval, levels=c('call','geno'),
                     labels=c('presence', 'genotype')))
  

pdf('pdf/svpop-best-f1.pdf', 8, 4)
eval.f1 %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~.) +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method') + 
  theme()
dev.off()

eval.f1 %>% filter(!is.na(F1)) %>%
  select(method, region, type, TP.baseline, FP, FN, precision, recall, F1) %>%
  arrange(method, region) %>%
  kable(digits=3) %>%
  cat(file='tables/svpop.md', sep='\n')



##
## Regional analysis analysis
## Regions: all, repeats, non-repeats, called in SMRT-SV v2, not called in SMRT-SV
##
samples = c('HG00514')
svpop.df = readEval4(methods, samples, prefix='data/svpop/svpop', eval='call',
                     regions=c('all','rep', 'nonrep', 'nocalls', 'called'))
svpop.df$method = factor(methconv[svpop.df$method], levels=names(pal.tools))

svpop.df = svpop.df %>% filter(type!='Total') %>% arrange(qual)
levels(svpop.df$region) = c('all','repeat', 'non-repeat','called in SMRT-SV v2','not called in SMRT-SV v2')
label.df = svpop.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/svpop-regions.pdf', 8, 5)
svpop.df %>% filter(type!='INV', eval=='call') %>%
  ggplot(aes(x=recall, y=precision, colour=region)) +
  geom_path(size=1, alpha=.9) + 
  theme_bw() +
  labs(x='Recall', y='Precision', color='Genomic regions') + 
  facet_grid(method~type) +
  scale_colour_brewer(palette='Set1')
dev.off()

## Bar plots with best F1
eval.f1 = label.df %>% ungroup %>%
  mutate(F1=ifelse(is.infinite(F1), NA, F1),
         eval=factor(eval, levels=c('call','geno'),
                     labels=c('presence', 'genotype')))
  

eval.f1 %>% filter(!is.na(F1)) %>%
  select(method, region, type, TP.baseline, FP, FN, precision, recall, F1) %>%
  arrange(method, region, type) %>%
  kable(digits=3) %>%
  cat(file='tables/svpop-regions.md', sep='\n')
