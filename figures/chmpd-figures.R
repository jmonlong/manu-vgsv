library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## CHM Pseudodiploid reads (SMRT-SV v2 training data from Audano et. al 2019)

## Method names and renaming vector to fit color palette
methods = c('vg','smrtsv')
methconv = c(vg='vg', smrtsv='SMRT-SV v2')

## Read evaluation results
pr.df = read.table('data/human-merged-prcurve.tsv', as.is=TRUE, header=TRUE)

## Keep CHMPD experiment only and polish data.frame
pr.df = pr.df %>% filter(grepl('chmpd', exp), type!='INV', type!='Total') %>%
  arrange(qual)
pr.df$method = factor(methconv[pr.df$method], levels=names(pal.tools))
pr.df = relabel(pr.df)

label.df = pr.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/chmpd.pdf', 8, 4)

pr.df %>% filter(eval=='presence') %>% 
  ggplot(aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  ## geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(aes(shape=region), size=3, data=subset(label.df, eval=='presence')) + 
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

pr.df %>% filter(eval=='genotype') %>% 
  ggplot(aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  ## geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(aes(shape=region), size=3, data=subset(label.df, eval=='genotype')) + 
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
pdf('pdf/chmpd-best-f1.pdf', 8, 4)

label.df %>%
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~.) +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method')

dev.off()

label.df %>% filter(eval=='genotype', !is.na(F1)) %>%
  select(method, region, type, precision, recall, F1) %>%
  arrange(method, region) %>%
  kable(digits=3) %>%
  cat(file='tables/chmpd-geno-precision-recall-F1.md', sep='\n')
