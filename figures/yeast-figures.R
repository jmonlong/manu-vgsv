library(ggplot2)
library(dplyr)
library(tidyr)
library(magrittr)

df = read.table('yeast.accuracy.constructunion.all.tsv', as.is=TRUE)
colnames(df) = c('graph', 'strain', 'SVtype', 'TP', 'TP.baseline', 'FP', 'FN', 'precision', 'recall', 'F1')

## Clades
df %<>% mutate(clade=ifelse(strain %in% c("UWOPS919171","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae'))

## Figures
svg('yeast-recall.svg', 8, 8)
df %>% select(recall, graph, SVtype, strain, clade) %>%
  spread(graph, recall) %>%
  mutate(SVtype=factor(SVtype, levels=c('Total', 'INS', 'DEL'))) %>%
  ggplot(aes(x=construct, y=cactus, color=strain, shape=clade)) +
  geom_point(size=4) +
  facet_wrap(~SVtype, ncol=2) +
  geom_abline(linetype=2) +
  xlim(0,1) + ylim(0,1) + 
  theme_bw() +
  theme(legend.position='bottom',
        text=element_text(size=20),
        legend.text=element_text(size=10),
        legend.title=element_text(size=10),
        legend.position=c(.95,.05),
        legend.justification=c(1,0),
        legend.background=element_rect(colour='black')) + 
  guides(col = guide_legend(nrow = 6)) + 
  xlab('from VCF calls (recall)') +
  ylab('from assembly alignment (recall)')
dev.off()

svg('yeast-precision.svg', 8, 8)
df %>% select(precision, graph, SVtype, strain, clade) %>%
  spread(graph, precision) %>%
  mutate(SVtype=factor(SVtype, levels=c('Total', 'INS', 'DEL'))) %>%
  ggplot(aes(x=construct, y=cactus, color=strain, shape=clade)) +
  geom_point(size=4) +
  facet_wrap(~SVtype, ncol=2) +
  geom_abline(linetype=2) +
  xlim(0,1) + ylim(0,1) + 
  theme_bw() +
  theme(legend.position='bottom',
        text=element_text(size=20),
        legend.text=element_text(size=10),
        legend.title=element_text(size=10),
        legend.position=c(.95,.05),
        legend.justification=c(1,0),
        legend.background=element_rect(colour='black')) + 
  guides(col = guide_legend(nrow = 6)) + 
  xlab('from VCF calls (precision)') +
  ylab('from assembly alignment (precision)')
dev.off()
