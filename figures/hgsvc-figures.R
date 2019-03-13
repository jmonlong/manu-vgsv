library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

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
eval.df$method = factor(eval.df$method, levels=names(pal.tools))

eval.df = subset(eval.df, type!='INV' & TP.baseline>5)
## Remove svtyper from "Total" because it's being penalized by not genotyping insertions
eval.df = subset(eval.df, type!='Total')

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/hgsvc-sim.pdf', 8, 4)

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

## Simulated reads - Genotype evaluation
eval.df = readEval(files = c('sim-hgsvc-construct-prcurve-geno.tsv',
                             'sim-hgsvc-construct-clip-prcurve-geno.tsv',
                             'sim-hgsvc-bayestyper-prcurve-geno.tsv',
                             'sim-hgsvc-bayestyper-clip-prcurve-geno.tsv',
                             'sim-hgsvc-svtyper-prcurve-geno.tsv',
                             'sim-hgsvc-svtyper-clip-prcurve-geno.tsv',
                             'sim-hgsvc-delly-prcurve-geno.tsv',
                             'sim-hgsvc-delly-clip-prcurve-geno.tsv'),
                   methods = rep(c('vg-construct', 'BayesTyper', 'svtyper', 'Delly'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))
eval.df$method = factor(eval.df$method, levels=names(pal.tools))

eval.df = subset(eval.df, type!='INV' & TP.baseline>5)
## Remove svtyper from "Total" because it's being penalized by not genotyping insertions
eval.df = subset(eval.df, type!='Total')

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/hgsvc-sim-geno.pdf', 8, 4)

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
eval.df$method = factor(eval.df$method, levels=names(pal.tools))

eval.df = subset(eval.df, type!='INV' & TP.baseline>5)
## Remove svtyper from "Total" because it's being penalized by not genotyping insertions
eval.df = subset(eval.df, type!='Total')

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/hgsvc-real.pdf', 8, 4)

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


## Real reads - Genotype evaluation
eval.df = readEval(files = c('real-hgsvc-construct-prcurve-geno.tsv',
                             'real-hgsvc-construct-clip-prcurve-geno.tsv',
                             'real-hgsvc-bayestyper-prcurve-geno.tsv',
                             'real-hgsvc-bayestyper-clip-prcurve-geno.tsv',
                             'real-hgsvc-svtyper-prcurve-geno.tsv',
                             'real-hgsvc-svtyper-clip-prcurve-geno.tsv',
                             'real-hgsvc-delly-prcurve-geno.tsv',
                             'real-hgsvc-delly-clip-prcurve-geno.tsv'),
                   methods = rep(c('vg-construct', 'BayesTyper', 'svtyper', 'Delly'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))
eval.df$method = factor(eval.df$method, levels=names(pal.tools))

eval.df = subset(eval.df, type!='INV' & TP.baseline>5)
## Remove svtyper from "Total" because it's being penalized by not genotyping insertions
eval.df = subset(eval.df, type!='Total')

label.df = eval.df %>% group_by(region, method, type) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/hgsvc-real-geno.pdf', 8, 4)

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



## Bar plots with best F1
## Compares all results: real/sim, calling/genotyping
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
eval.geno.df = readEval(files = c('real-hgsvc-construct-prcurve-geno.tsv',
                             'real-hgsvc-construct-clip-prcurve-geno.tsv',
                             'real-hgsvc-bayestyper-prcurve-geno.tsv',
                             'real-hgsvc-bayestyper-clip-prcurve-geno.tsv',
                             'real-hgsvc-svtyper-prcurve-geno.tsv',
                             'real-hgsvc-svtyper-clip-prcurve-geno.tsv',
                             'real-hgsvc-delly-prcurve-geno.tsv',
                             'real-hgsvc-delly-clip-prcurve-geno.tsv'),
                   methods = rep(c('vg-construct', 'BayesTyper', 'svtyper', 'Delly'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))
eval.sim.df = readEval(files = c('sim-hgsvc-construct-prcurve.tsv',
                             'sim-hgsvc-construct-clip-prcurve.tsv',
                             'sim-hgsvc-bayestyper-prcurve.tsv',
                             'sim-hgsvc-bayestyper-clip-prcurve.tsv',
                             'sim-hgsvc-svtyper-prcurve.tsv',
                             'sim-hgsvc-svtyper-clip-prcurve.tsv',
                             'sim-hgsvc-delly-prcurve.tsv',
                             'sim-hgsvc-delly-clip-prcurve.tsv'),
                   methods = rep(c('vg-construct', 'BayesTyper', 'svtyper', 'Delly'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))
eval.sim.geno.df = readEval(files = c('sim-hgsvc-construct-prcurve-geno.tsv',
                             'sim-hgsvc-construct-clip-prcurve-geno.tsv',
                             'sim-hgsvc-bayestyper-prcurve-geno.tsv',
                             'sim-hgsvc-bayestyper-clip-prcurve-geno.tsv',
                             'sim-hgsvc-svtyper-prcurve-geno.tsv',
                             'sim-hgsvc-svtyper-clip-prcurve-geno.tsv',
                             'sim-hgsvc-delly-prcurve-geno.tsv',
                             'sim-hgsvc-delly-clip-prcurve-geno.tsv'),
                   methods = rep(c('vg-construct', 'BayesTyper', 'svtyper', 'Delly'), each=2),
                   regions=rep(c('all', 'non-repeat'), 4))


eval.f1 = eval.df %>% filter(type!='INV', type!='Total') %>% group_by(method, type, region) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(eval='absence/presence', experiment='real reads')
eval.f1 = eval.geno.df %>% filter(type!='INV', type!='Total') %>% group_by(method, type, region) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(eval='genotype', experiment='real reads') %>% rbind(eval.f1)
eval.f1 = eval.sim.df %>% filter(type!='INV', type!='Total') %>% group_by(method, type, region) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(eval='absence/presence', experiment='simulated reads') %>% rbind(eval.f1)
eval.f1 = eval.sim.geno.df %>% filter(type!='INV', type!='Total') %>% group_by(method, type, region) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(eval='genotype', experiment='simulated reads') %>% rbind(eval.f1)

eval.f1 = eval.f1 %>% ungroup %>%
  mutate(F1=ifelse(is.infinite(F1), NA, F1),
         method=factor(method, levels=names(pal.tools)),
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
