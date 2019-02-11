library(ggplot2)
library(dplyr)
library(magrittr)

eval.df = read.table('simerror-prcurve.tsv', as.is=TRUE, header=TRUE)

methods = c('toilvg', 'svtyper', 'delly')
eval.df$method = factor(eval.df$method, levels=methods, labels=c('vg', 'svtyper', 'delly'))

eval.df = eval.df %>% group_by(method, graph, depth, type, qual) %>%
    select(-sample) %>% summarize_all(sum)
eval.df$precision = eval.df$TP.baseline / (eval.df$TP.baseline + eval.df$FP)
eval.df$recall = eval.df$TP.baseline / (eval.df$TP.baseline + eval.df$FN)
eval.df$F1 = 2 * eval.df$precision * eval.df$recall / (eval.df$precision + eval.df$recall)

eval.df = eval.df %>% group_by(method, graph, depth, type) %>%
  arrange(desc(F1)) %>% do(head(.,1))

eval.df$type = factor(eval.df$type, levels=c('Total', 'INS', 'DEL'))
eval.df$method = factor(eval.df$method)
dp.lvls = paste(rep(unique(eval.df$depth), each=nlevels(eval.df$method)),
                levels(eval.df$method))
eval.df$dp = factor(paste(eval.df$depth, eval.df$method), levels=dp.lvls)

svg('simerror.svg', 8, 4)
ggplot(eval.df, aes(x=factor(depth), y=F1, colour=method, shape=graph)) +
  geom_point(aes(group=method), position=position_dodge(.5)) +
  geom_line(aes(group=dp), position=position_dodge(.5)) +
  scale_shape_manual(name='error in the input VCF', values=4:5, labels=c('yes', 'no')) +
  facet_grid(.~type, scales='free') + theme_bw() +
  xlab('depth') + theme(legend.position='bottom') + 
  scale_y_continuous(breaks=seq(0,1,.2), limits=0:1) +
  scale_colour_brewer(palette='Set1')
dev.off()
