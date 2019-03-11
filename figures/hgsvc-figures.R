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

## Print Markdown table
message('Simulated reads - Calling evaluation')
label.df %>% select(region, method, everything()) %>% arrange(region, method) %>%
  kable(digits=3, format.args=list(big.mark=','))


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

## Print Markdown table
message('Simulated reads - Genotyping evaluation')
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

## Print Markdown table
message('Real reads - Calling evaluation')
label.df %>% select(region, method, everything()) %>% arrange(region, method) %>%
  kable(digits=3, format.args=list(big.mark=','))


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

## Print Markdown table
message('Real reads - Genotyping evaluation')
label.df %>% select(region, method, everything()) %>% arrange(region, method) %>%
  kable(digits=3, format.args=list(big.mark=','))
