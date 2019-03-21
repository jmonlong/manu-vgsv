library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## Method names and renaming vector to fit color palette
methods = c('vg','delly','svtyper','bayestyper', 'smrtsv')
methconv = c(vg='vg', delly='Delly', bayestyper='BayesTyper', svtyper='svtyper', smrtsv='SMRT-SV2')


## HGSVC Simulated reads from HG00514
methods = c('vg','delly','svtyper','bayestyper')
samples = 'HG00514'
hgsvcsim.df = readEval4(methods, samples, prefix='data/hgsvc/hgsvcsim')
hgsvcsim.df$method = factor(methconv[hgsvcsim.df$method], levels=names(pal.tools))
hgsvcsim.df = hgsvcsim.df %>% filter(type!='INV', type!='Total') %>% arrange(qual)

## HGSVC real reads across three samples
methods = c('vg','delly','svtyper','bayestyper')
samples = c('HG00514', 'HG00733', 'NA19240')
hgsvc.df = readEval4(methods, samples, prefix='data/hgsvc/hgsvc')
hgsvc.df$method = factor(methconv[hgsvc.df$method], levels=names(pal.tools))
hgsvc.df = hgsvc.df %>% group_by(type, qual, method, region, eval) %>%
  select(-sample) %>% summarize_all(sum)
hgsvc.df$precision = hgsvc.df$TP.baseline / (hgsvc.df$TP.baseline + hgsvc.df$FP)
hgsvc.df$recall = hgsvc.df$TP.baseline / (hgsvc.df$TP.baseline + hgsvc.df$FN)
hgsvc.df$F1 = 2 * hgsvc.df$precision * hgsvc.df$recall / (hgsvc.df$precision + hgsvc.df$recall)
hgsvc.df$F1 = ifelse(hgsvc.df$recall==0, 0, hgsvc.df$F1)
hgsvc.df = hgsvc.df %>% filter(type!='INV', type!='Total') %>% arrange(qual)

## GiaB real reads from HG002
methods = c('vg','delly','svtyper', 'bayestyper')
samples = 'HG002'
giab5.df = readEval4(methods, samples, prefix='data/giab/giab5')
giab5.df$method = factor(methconv[giab5.df$method], levels=names(pal.tools))
giab5.df = giab5.df %>% filter(type!='INV', type!='Total') %>% arrange(qual)

## SVPOP real reads across three samples
methods = c('vg','smrtsv')
samples = c('HG00514', 'HG00733', 'NA19240')
svpop.df = readEval4(methods, samples, prefix='data/svpop/svpop', eval='call')
svpop.df$method = factor(methconv[svpop.df$method], levels=names(pal.tools))
svpop.df = svpop.df %>% group_by(type, qual, method, region, eval) %>%
  select(-sample) %>% summarize_all(sum)
svpop.df$precision = svpop.df$TP.baseline / (svpop.df$TP.baseline + svpop.df$FP)
svpop.df$recall = svpop.df$TP.baseline / (svpop.df$TP.baseline + svpop.df$FN)
svpop.df$F1 = 2 * svpop.df$precision * svpop.df$recall / (svpop.df$precision + svpop.df$recall)
svpop.df$F1 = ifelse(svpop.df$recall==0, 0, svpop.df$F1)
svpop.df = svpop.df %>% filter(type!='INV', type!='Total') %>% arrange(qual)

## CHM pseudo-diploid
methods = c('vg','smrtsv')
samples = 'chmpd'
chmpd.df = readEval4(methods, samples, prefix='data/chmpd/chmpd')
chmpd.df$method = factor(methconv[chmpd.df$method], levels=names(pal.tools))
chmpd.df = chmpd.df %>% filter(type!='INV', type!='Total') %>% arrange(qual)


## Bar plots with best F1
eval.f1 = rbind(
  hgsvcsim.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='HGSVC simulated reads'),
  hgsvc.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='HGSVC real reads'),
  giab5.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='GiaB'),
  chmpd.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='CHM-PD'),
  svpop.df %>% group_by(method, type, region, eval) %>% arrange(desc(F1)) %>% do(head(., 1)) %>% mutate(experiment='SVPOP')
)

eval.f1 = eval.f1 %>% ungroup %>%
  mutate(F1=ifelse(is.infinite(F1), NA, F1),
         eval=factor(eval, levels=c('call','geno'),
                     labels=c('absence/presence', 'genotype')),
         experiment=factor(experiment, levels=unique(experiment)))

pdf('pdf/hgsvc-giab-chmpd-svpop-best-f1.pdf', 8, 4)
eval.f1 %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~experiment, scales='free', space='free') +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() +
  ylab('best F1') +  xlab('genomic regions') + 
  theme(legend.position='top') +
  guides(fill=guide_legend(ncol=3))
dev.off()

pdf('pdf/hgsvc-giab-best-f1.pdf', 8, 4)
eval.f1 %>%
  filter(experiment %in% c('HGSVC simulated reads',
                           'HGSVC real reads',
                           'GiaB')) %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~experiment, scales='free', space='free') +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() +
  ylab('best F1') +  xlab('genomic regions') + 
  theme(legend.position='top') +
  guides(fill=guide_legend(ncol=3))
dev.off()

pdf('pdf/chmpd-svpop-best-f1.pdf', 8, 4)
eval.f1 %>%
  filter(experiment %in% c('CHM-PD',
                           'SVPOP')) %>% 
  mutate(experiment=as.character(experiment),
         experiment=ifelse(experiment=='CHM-PD', 'CHM pseudo diploid', experiment)) %>%
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~experiment, scales='free', space='free') +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() +
  ylab('best F1') +  xlab('genomic regions') + 
  theme()
dev.off()


eval.f1 %>% filter(eval=='genotype', !is.na(F1)) %>%
  select(experiment, method, region, type, precision, recall, F1) %>%
  arrange(experiment, method, region, type) %>%
  kable(digits=3) %>%
  cat(file='tables/hgsvc-giab-chmpd-svpop-geno-precision-recall-F1.md', sep='\n')
