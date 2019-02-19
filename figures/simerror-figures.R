library(ggplot2)
library(dplyr)
library(magrittr)

eval.pr = read.table('simerror-prcurve.tsv', as.is=TRUE, header=TRUE)

methods = c('toilvg', 'svtyper', 'delly', 'bayestyper')
eval.pr$method = factor(eval.pr$method, levels=methods, labels=c('vg', 'svtyper', 'Delly', 'BayesTyper'))

## Merge results across the three samples picking the qual threshold with best F1
## Not very elegant but otherwise I have make sure the same qual thresholds are used
eval.pr = eval.pr %>% group_by(method, graph, depth, type, sample) %>%
  arrange(desc(F1)) %>% do(head(., 1)) %>%
  group_by(method, graph, depth, type) %>%
  select(-sample, -qual) %>% summarize_all(sum)
eval.pr$precision = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FP)
eval.pr$recall = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FN)
eval.pr$F1 = 2 * eval.pr$precision * eval.pr$recall / (eval.pr$precision + eval.pr$recall)

## Pick quality threshold with maximum F1 for each experiment
eval.df = eval.pr %>% group_by(method, graph, depth, type) %>%
  arrange(desc(F1)) %>% do(head(.,1))

eval.df$type = factor(eval.df$type, levels=c('Total', 'INS', 'DEL'))
eval.df$method = factor(eval.df$method)
dp.lvls = paste(rep(unique(eval.df$depth), each=nlevels(eval.df$method)),
                levels(eval.df$method))
eval.df$dp = factor(paste(eval.df$depth, eval.df$method), levels=dp.lvls)

svg('simerror.svg', 8, 4)

eval.df %>% ungroup %>%
  mutate(graph=ifelse(graph=='truth', 'true SVs in VCF', 'errors in VCF'),
         graph=factor(graph, levels=c('true SVs in VCF', 'errors in VCF'))) %>% 
  ggplot(aes(x=factor(depth), y=F1, colour=method)) +
  geom_line(aes(group=paste(method)), size=1, alpha=.8) +
  facet_grid(graph~type, scales='free') + theme_bw() +
  xlab('depth') + theme(legend.position='bottom') + 
  scale_y_continuous(breaks=seq(0,1,.2), limits=0:1) +
  scale_colour_brewer(palette='Set1')

## ggplot(eval.df, aes(x=factor(depth), y=F1, colour=method, shape=graph)) +
##   geom_point(aes(group=method), position=position_dodge(.5)) +
##   geom_line(aes(group=dp), position=position_dodge(.5)) +
##   scale_shape_manual(name='error in the input VCF', values=4:5, labels=c('yes', 'no')) +
##   facet_grid(.~type, scales='free') + theme_bw() +
##   xlab('depth') + theme(legend.position='bottom') + 
##   scale_y_continuous(breaks=seq(0,1,.2), limits=0:1) +
##   scale_colour_brewer(palette='Set1')

## ggplot(eval.df, aes(x=factor(depth), y=F1, colour=method)) +
##   geom_line(aes(group=paste(method, graph), linetype=graph), size=2, alpha=.8) +
##   facet_grid(.~type, scales='free') + theme_bw() +
##   xlab('depth') + theme(legend.position='bottom') +
##   scale_linetype_manual(values=c(3,1), name='error in the input VCF', labels=c('yes', 'no')) + 
##   scale_y_continuous(breaks=seq(0,1,.2), limits=0:1) +
##   scale_colour_brewer(palette='Set1')

dev.off()

## Precision recall curve for 3x
## eval.pr %>% filter(depth==1, graph=='truth') %>% arrange(qual) %>% 
##   ggplot(aes(x=recall, y=precision, color=method)) +
##   geom_path() +
##   geom_point() +
##   facet_grid(type~method) +
##   theme_bw()


## Small SVs (<200bp)
eval.pr = read.table('simerror-max200bp-prcurve.tsv', as.is=TRUE, header=TRUE)
methods = c('toilvg', 'svtyper', 'delly', 'bayestyper')
eval.pr$method = factor(eval.pr$method, levels=methods, labels=c('vg', 'svtyper', 'delly', 'bayestyper'))

## Merge results across the three samples picking the qual threshold with best F1
## Not very elegant but otherwise I have make sure the same qual thresholds are used
eval.pr = eval.pr %>% group_by(method, graph, depth, type, sample) %>%
  arrange(desc(F1)) %>% do(head(., 1)) %>%
  group_by(method, graph, depth, type) %>%
  select(-sample, -qual) %>% summarize_all(sum)
eval.pr$precision = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FP)
eval.pr$recall = eval.pr$TP.baseline / (eval.pr$TP.baseline + eval.pr$FN)
eval.pr$F1 = 2 * eval.pr$precision * eval.pr$recall / (eval.pr$precision + eval.pr$recall)

## Pick quality threshold with maximum F1 for each experiment
eval.df = eval.pr %>% group_by(method, graph, depth, type) %>%
  arrange(desc(F1)) %>% do(head(.,1))

eval.df$type = factor(eval.df$type, levels=c('Total', 'INS', 'DEL'))
eval.df$method = factor(eval.df$method)
dp.lvls = paste(rep(unique(eval.df$depth), each=nlevels(eval.df$method)),
                levels(eval.df$method))
eval.df$dp = factor(paste(eval.df$depth, eval.df$method), levels=dp.lvls)

svg('simerror-max200bp.svg', 8, 4)

eval.df %>% ungroup %>%
  mutate(graph=ifelse(graph=='truth', 'true SVs in VCF', 'errors in VCF'),
         graph=factor(graph, levels=c('true SVs in VCF', 'errors in VCF'))) %>% 
  ggplot(aes(x=factor(depth), y=F1, colour=method)) +
  geom_line(aes(group=paste(method)), size=1, alpha=.8) +
  facet_grid(graph~type, scales='free') + theme_bw() +
  xlab('depth') + theme(legend.position='bottom') + 
  scale_y_continuous(breaks=seq(0,1,.2), limits=0:1) +
  scale_colour_brewer(palette='Set1')

dev.off()
