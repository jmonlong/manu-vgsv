library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## CHM Pseudodiploid reads (SMRT-SV2 training data from Audano et. al 2019)
eval.df = readEval(files = c('chmpd-construct-prcurve.tsv',
                             'chmpd-construct-clip-prcurve.tsv',
                             'chmpd-smrtsv2-prcurve.tsv',									
                             'chmpd-smrtsv2-clip-prcurve.tsv'),
                   methods = rep(c('vg', 'SMRT-SV2'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))
eval.df$method = factor(eval.df$method, levels=names(pal.tools))

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/chmpd.pdf', 8, 4)

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

## Markdown table
label.df %>% select(region, method, everything()) %>%
  arrange(method, region, type) %>%
  select(method, region, type, everything(), -qual, -TP) %>% 
  kable(digits=3, format.args=list(big.mark=',')) %>% 
  cat(file='tables/chmpd.md', sep='\n')

## CHM Pseudodiploid reads (SMRT-SV2 training data from Audano et. al 2019) Genotype evaluation
eval.df = readEval(files = c('chmpd-construct-prcurve-geno.tsv',
                             'chmpd-construct-clip-prcurve-geno.tsv',
                             'chmpd-smrtsv2-prcurve-geno.tsv',									
                             'chmpd-smrtsv2-clip-prcurve-geno.tsv'),
                   methods = rep(c('vg', 'SMRT-SV2'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))
eval.df$method = factor(eval.df$method, levels=names(pal.tools))

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/chmpd-geno.pdf', 8, 4)

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

## Markdown table
label.df %>% select(region, method, everything()) %>%
  arrange(method, region, type) %>%
  select(method, region, type, everything(), -qual, -TP) %>% 
  kable(digits=3, format.args=list(big.mark=',')) %>% 
  cat(file='tables/chmpd-geno.md', sep='\n')


