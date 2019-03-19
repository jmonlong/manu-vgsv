library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## Method names and renaming vector to fit color palette
methods = c('vg','delly','svtyper','bayestyper')
methconv = c(vg='vg', delly='Delly', bayestyper='BayesTyper', svtyper='svtyper')

## Simulated reads from HG00514
samples = 'HG00514'
hgsvcsim.df = readEval4(methods, samples, prefix='data/hgsvc/hgsvcsim')
hgsvcsim.df$method = factor(methconv[hgsvcsim.df$method], levels=names(pal.tools))

hgsvcsim.df = hgsvcsim.df %>% filter(type!='INV', type!='Total') %>% arrange(qual)
label.df = hgsvcsim.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/hgsvc-sim.pdf', 8, 4)

hgsvcsim.df %>% filter(eval=='call') %>% 
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

pdf('pdf/hgsvc-sim-geno.pdf', 8, 4)

hgsvcsim.df %>% filter(eval=='geno') %>% 
  ggplot(aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(size=3, data=subset(label.df, eval=='geno')) + 
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  ## scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  ## scale_y_continuous(breaks=seq(0,1,.1), limits=c(.6,1)) +
  scale_linetype_manual(values=c(4,1)) + 
  scale_colour_manual(values=pal.tools)

dev.off()


## Real reads across three samples
methods = c('vg','delly','svtyper','bayestyper')
methconv = c(vg='vg', delly='Delly', bayestyper='BayesTyper', svtyper='svtyper')
samples = c('HG00514', 'HG00733', 'NA19240')
hgsvc.df = readEval4(methods, samples, prefix='data/hgsvc/hgsvc')
hgsvc.df$method = factor(methconv[hgsvc.df$method], levels=names(pal.tools))

## Merge samples
hgsvc.df = hgsvc.df %>% group_by(type, qual, method, region, eval) %>%
  select(-sample) %>% summarize_all(sum)
hgsvc.df$precision = hgsvc.df$TP.baseline / (hgsvc.df$TP.baseline + hgsvc.df$FP)
hgsvc.df$recall = hgsvc.df$TP.baseline / (hgsvc.df$TP.baseline + hgsvc.df$FN)
hgsvc.df$F1 = 2 * hgsvc.df$precision * hgsvc.df$recall / (hgsvc.df$precision + hgsvc.df$recall)
hgsvc.df$F1 = ifelse(hgsvc.df$recall==0, 0, hgsvc.df$F1)

hgsvc.df = hgsvc.df %>% filter(type!='INV', type!='Total') %>% arrange(qual)
label.df = hgsvc.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/hgsvc-real.pdf', 8, 4)

hgsvc.df %>% filter(eval=='call') %>% 
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

pdf('pdf/hgsvc-real-geno.pdf', 8, 4)

hgsvc.df %>% filter(eval=='geno') %>% 
  ggplot(aes(x=recall, y=precision, colour=method)) +
  geom_path(aes(linetype=region), size=1, alpha=.8) + 
  geom_point(size=.8) +
  ## geom_label_repel(aes(label=method), data=label.df) + 
  geom_point(size=3, data=subset(label.df, eval=='geno')) + 
  theme_bw() +
  facet_grid(.~type) +
  theme(legend.position='bottom') +
  ## scale_x_continuous(breaks=seq(0,1,.2), limits=0:1) + 
  ## scale_y_continuous(breaks=seq(0,1,.1), limits=c(.6,1)) +
  scale_linetype_manual(values=c(4,1)) + 
  scale_colour_manual(values=pal.tools)

dev.off()


## Bar plots with best F1
eval.f1 = rbind(
  hgsvc.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='real reads'),
  hgsvcsim.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='simulated reads')
)

eval.f1 = eval.f1 %>% ungroup %>%
  mutate(F1=ifelse(is.infinite(F1), NA, F1),
         eval=factor(eval, levels=c('call','geno'),
                     labels=c('absence/presence', 'genotype')),
         ## method=factor(method, levels=names(pal.tools)),
         experiment=factor(experiment, levels=c('simulated reads', 'real reads')))
  

pdf('pdf/hgsvc-best-f1.pdf', 8, 4)

eval.f1 %>% 
  ggplot(aes(x=method, y=F1, fill=region, alpha=eval, group=region)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~experiment) +
  scale_fill_brewer(name='genomic regions', palette='Set1') +
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() +
  ylab('best F1') + 
  theme(axis.text.x=element_text(angle=30, hjust=1),
        axis.title.x=element_blank())

dev.off()

eval.f1 %>% filter(eval=='genotype', !is.na(F1)) %>%
  select(experiment, method, region, type, precision, recall, F1) %>%
  arrange(experiment, method, region) %>%
  kable(digits=3) %>%
  cat(file='tables/hgsvc-geno-precision-recall-F1.md', sep='\n')
