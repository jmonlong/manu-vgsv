library(ggplot2)
library(dplyr)
library(magrittr)
library(tidyr)
library(knitr)
library(gridExtra)

source('colors-functions.R')

methods.rename = c('toilvg-symb'='vg', 'svtyper'='SVTyper', 'delly'='Delly', 'bayestyper'='BayesTyper')


##
## Calling evaluation
##
eval.pr = read.table('data/simerror-prcurve.tsv', as.is=TRUE, header=TRUE)
eval.pr$method = factor(methods.rename[eval.pr$method], levels=names(pal.tools))
eval.pr = subset(eval.pr, !is.na(method))

## Merge results across the three samples picking the qual threshold with best F1
## Not very elegant but otherwise I have make sure the same qual thresholds are used
eval.pr = eval.pr %>% group_by(method, graph, depth, type, sample) %>%
  arrange(desc(F1)) %>% do(head(., 1)) %>%
  group_by(method, graph, depth, type) %>%
  select(-sample, -qual) %>% summarize_all(sum)
eval.pr$precision = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FP)
eval.pr$recall = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FN)
eval.pr$F1 = 2 * eval.pr$precision * eval.pr$recall / (eval.pr$precision + eval.pr$recall)
eval.pr$F1 = ifelse(eval.pr$recall==0, 0, eval.pr$F1)

eval.df = eval.pr %>% filter(type!='Total', !(type=='INS' & method=='SVTyper')) %>%
  mutate(type = factor(type, levels=c('INS', 'DEL', 'INV')),
         method2=factor(method, levels=rev(levels(method))))

pdf('pdf/simerror.pdf', 6, 4)
eval.df %>% ungroup %>%
  mutate(graph=ifelse(graph=='truth', 'True SVs in VCF', 'Errors in VCF'),
         graph=factor(graph, levels=c('True SVs in VCF', 'Errors in VCF'))) %>% 
  ggplot(aes(x=factor(depth), y=F1, colour=method)) +
  geom_line(aes(group=method2), size=1, alpha=.8) +
  facet_grid(type~graph, scales='free') + theme_bw() +
  labs(x='Depth', color='Method') +
  theme(legend.position='right') + 
  scale_y_continuous(limits=0:1) +
  scale_colour_manual(values=pal.tools)
dev.off()

##
## Genotype evaluation
##
eval.pr = read.table('data/simerror-geno-prcurve.tsv', as.is=TRUE, header=TRUE)
eval.pr$method = factor(methods.rename[eval.pr$method], levels=names(pal.tools))
eval.pr = subset(eval.pr, !is.na(method))

## Merge results across the three samples picking the qual threshold with best F1
## Not very elegant but otherwise I have make sure the same qual thresholds are used
eval.pr = eval.pr %>% group_by(method, graph, depth, type, sample) %>%
  arrange(desc(F1)) %>% do(head(., 1)) %>%
  group_by(method, graph, depth, type) %>%
  select(-sample, -qual) %>% summarize_all(sum)
eval.pr$precision = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FP)
eval.pr$recall = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FN)
eval.pr$F1 = 2 * eval.pr$precision * eval.pr$recall / (eval.pr$precision + eval.pr$recall)
eval.pr$F1 = ifelse(eval.pr$recall==0, 0, eval.pr$F1)

eval.df = eval.pr %>% filter(type!='Total', !(type=='INS' & method=='SVTyper')) %>%
  mutate(type = factor(type, levels=c('INS', 'DEL', 'INV')),
         method2=factor(method, levels=rev(levels(method))))

pdf('pdf/simerror-geno.pdf', 6, 4)

eval.df %>% ungroup %>%
  mutate(graph=ifelse(graph=='truth', 'True SVs in VCF', 'Errors in VCF'),
         graph=factor(graph, levels=c('True SVs in VCF', 'Errors in VCF'))) %>% 
  ggplot(aes(x=factor(depth), y=F1, colour=method)) +
  geom_line(aes(group=method2), size=1, alpha=.8) +
  facet_grid(type~graph, scales='free') + theme_bw() +
  labs(x='Depth', color='Method', y='Best F1') +
  theme(legend.position='right') + 
  scale_y_continuous(limits=0:1) +
  scale_colour_manual(values=pal.tools)

dev.off()

## Drop due to errors
eval.df %>% select(method, depth, F1, type, graph) %>% spread(graph, F1) %>%
  group_by(method, type) %>%
  summarize(F1.mean.diff=mean(truth-calls), F1.max.diff=max(truth-calls)) %>%
  filter(!is.na(F1.mean.diff)) %>%
  kable(digits=3) %>%
  cat(file='tables/simerror-geno-F1-mean-diff-truthVsErrors.md', sep='\n')

##
## Small SVs (<200bp)
##
eval.pr = read.table('data/simerror-max200bp-geno-prcurve.tsv', as.is=TRUE, header=TRUE)
eval.pr$method = factor(methods.rename[eval.pr$method], levels=names(pal.tools))
eval.pr = subset(eval.pr, !is.na(method))

## Merge results across the three samples picking the qual threshold with best F1
## Not very elegant but otherwise I have make sure the same qual thresholds are used
eval.pr = eval.pr %>% group_by(method, graph, depth, type, sample) %>%
  arrange(desc(F1)) %>% do(head(., 1)) %>%
  group_by(method, graph, depth, type) %>%
  select(-sample, -qual) %>% summarize_all(sum)
eval.pr$precision = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FP)
eval.pr$recall = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FN)
eval.pr$F1 = 2 * eval.pr$precision * eval.pr$recall / (eval.pr$precision + eval.pr$recall)
eval.pr$F1 = ifelse(eval.pr$recall==0, 0, eval.pr$F1)

eval.df = eval.pr %>% filter(type!='Total', !(type=='INS' & method=='SVTyper')) %>%
  mutate(type = factor(type, levels=c('INS', 'DEL', 'INV')),
         method2=factor(method, levels=rev(levels(method))))

pdf('pdf/simerror-max200bp-geno.pdf', 6, 4)
eval.df %>% ungroup %>%
  mutate(graph=ifelse(graph=='truth', 'True SVs in VCF', 'Errors in VCF'),
         graph=factor(graph, levels=c('True SVs in VCF', 'Errors in VCF'))) %>% 
  ggplot(aes(x=factor(depth), y=F1, colour=method)) +
  geom_line(aes(group=method2), size=1, alpha=.8) +
  facet_grid(type~graph, scales='free') + theme_bw() +
  labs(x='Depth', color='Method', y='Best F1') +
  theme(legend.position='right') + 
  scale_y_continuous(limits=0:1) +
  scale_colour_manual(values=pal.tools)
dev.off()



##
## vg call (augmentation) to fine-tune breakpoints
##
df = read.table('data/simerror-bkpt-finetuning-vgcall.tsv', as.is=TRUE, header=TRUE)
df = df %>% mutate(etype=factor(etype, levels=c("location/seq","start","both"),
                                labels=c('location/seq', 'one end', 'both ends')))

## Table
df %>% group_by(type, correct.bkpt, etype) %>%
  summarize(n=n(), mean.size=mean(size), mean.error=mean(error)) %>%
  group_by(type, etype) %>%
  mutate(prop=n/sum(n)) %>%
  arrange(type, etype, correct.bkpt) %>% 
  kable(digits=3) %>%
  cat(file='tables/simerror-bkpt-finetuning-vgcall.md', sep='\n')

ggp.l = list()

ggp.l$prop = ggplot(df, aes(x=etype, fill=correct.bkpt)) + geom_bar(position='fill') +
  theme_bw() + facet_grid(.~type, scales='free', space='free') +
  scale_fill_brewer(name='Breakpoint', palette='Set1', labels=c('incorrect', 'fine-tuned')) +
  ylab('Variant proportion') + xlab('Error type') + ggtitle('a)')

ggp.l$error = df %>% mutate(type.etype=paste(type, etype)) %>% 
  ggplot(aes(x=error, fill=correct.bkpt)) + geom_histogram(binwidth=1) +
  theme_bw() + facet_wrap(~type.etype, scales='free') +
  scale_fill_brewer(name='Breakpoint', palette='Set1', labels=c('incorrect', 'fine-tuned')) +
  ylab('Variant') + ggtitle('b)') +
  xlab('Error (bp)') + scale_x_continuous(breaks=seq(0,20,2)) +
  guides(fill=FALSE)

ggp.l$size = df %>% mutate(type.etype=paste(type, etype)) %>% 
  ggplot(aes(x=size, fill=correct.bkpt)) + geom_histogram() +
  theme_bw() + facet_wrap(~type.etype, scales='free') +
  scale_fill_brewer(name='Breakpoint', palette='Set1', labels=c('incorrect', 'fine-tuned')) +
  scale_x_log10() + xlab('Size (bp)') + ylab('Variant') + ggtitle('c)') + 
  guides(fill=FALSE)


pdf('pdf/simerror-bkpt-finetuning-vgcall.pdf', 8, 8)
grid.arrange(grobs=ggp.l, heights=c(2,3,3))
dev.off()
