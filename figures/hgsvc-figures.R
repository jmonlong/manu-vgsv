library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## Method names and renaming vector to fit color palette
methods = c('vg','delly','svtyper','bayestyper')
methconv = c(vg='vg', delly='Delly', bayestyper='BayesTyper', svtyper='SVTyper', paragraph='Paragraph')

## Read evaluation results
pr.df = read.table('data/human-merged-prcurve.tsv', as.is=TRUE, header=TRUE)

## Keep HGSVC experiment only and polish data.frame
pr.df = pr.df %>% filter(grepl('hgsvc', exp), type!='INV', type!='Total') %>%
  arrange(qual)
pr.df$method = factor(methconv[pr.df$method], levels=names(pal.tools))
pr.df = relabel(pr.df)

## Simulated reads from HG00514
sim.pr.df = pr.df %>% filter(exp=='hgsvcsim')
label.df = sim.pr.df %>% group_by(region, method, type, eval) %>%
  arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/hgsvc-sim.pdf', 8, 8)
zoomgp(subset(sim.pr.df, eval=='presence'), subset(label.df, eval=='presence'),
       zoom.xy=.8, zoom.br=.05, annot=TRUE)
dev.off()

pdf('pdf/hgsvc-sim-geno.pdf', 8, 8)
zoomgp(subset(sim.pr.df, eval=='genotype'), subset(label.df, eval=='genotype'),
       zoom.xy=.7, zoom.br=.05, annot=TRUE)
dev.off()

## Real reads across three samples
real.pr.df = pr.df %>% filter(exp=='hgsvc')
  
## Merge samples
real.pr.df = real.pr.df %>% group_by(type, qual, method, region, eval) %>%
  select(TP, TP.baseline, FN, FP) %>% summarize_all(sum)
real.pr.df = prf(real.pr.df)
label.df = real.pr.df %>% group_by(region, method, type, eval) %>%
  arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/hgsvc-real.pdf', 8, 4)
zoomgp(subset(real.pr.df, eval=='presence'), subset(label.df, eval=='presence'),
       zoom.xy=.5, zoom.br=.1, annot=TRUE, zout.only=TRUE)
dev.off()

pdf('pdf/hgsvc-real-geno.pdf', 8, 4)
zoomgp(subset(real.pr.df, eval=='genotype'), subset(label.df, eval=='genotype'),
       zoom.xy=.5, zoom.br=.1, annot=TRUE, zout.only=TRUE)
dev.off()

## Bar plots with best F1
eval.f1 = rbind(
  real.pr.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='real reads'),
  sim.pr.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='simulated reads')
)

pdf('pdf/hgsvc-best-f1.pdf', 8, 4)

eval.f1 %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~experiment) +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method') + 
  theme(legend.position='top') +
  guides(fill=guide_legend(ncol=3))

dev.off()

eval.f1 %>% filter(eval=='genotype', !is.na(F1)) %>%
  select(experiment, method, region, type, precision, recall, F1) %>%
  arrange(experiment, method, region) %>%
  kable(digits=3) %>%
  cat(file='tables/hgsvc-geno-precision-recall-F1.md', sep='\n')
