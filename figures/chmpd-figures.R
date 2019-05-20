library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## CHM Pseudodiploid reads (SMRT-SV v2 training data from Audano et. al 2019)

## Method names and renaming vector to fit color palette
methods = c('vg','smrtsv')
methconv = c(vg='vg', smrtsv='SMRT-SV v2')

samples = 'chmpd'
chmpd.df = readEval4(methods, samples, prefix='data/chmpd/chmpd')
chmpd.df$method = factor(methconv[chmpd.df$method], levels=names(pal.tools))

chmpd.df = chmpd.df %>% filter(type!='INV', type!='Total') %>% arrange(qual)
label.df = chmpd.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/chmpd.pdf', 8, 4)

chmpd.df %>% filter(eval=='call') %>% 
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

pdf('pdf/chmpd-geno.pdf', 8, 4)

chmpd.df %>% filter(eval=='geno') %>% 
  ggplot(aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  ## geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(aes(shape=region), size=3, data=subset(label.df, eval=='geno')) + 
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
  

pdf('pdf/chmpd-best-f1.pdf', 8, 4)

eval.f1 %>%
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~.) +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method')

dev.off()

eval.f1 %>% filter(eval=='genotype', !is.na(F1)) %>%
  select(method, region, type, precision, recall, F1) %>%
  arrange(method, region) %>%
  kable(digits=3) %>%
  cat(file='tables/chmpd-geno-precision-recall-F1.md', sep='\n')
