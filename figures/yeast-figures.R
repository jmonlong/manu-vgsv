library(tidyverse)
library(magrittr)

##############
#Read mapping#
##############

construct <- read_tsv("yeast.mapping.constructunion.all.tsv", col_names = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", "all", "graph", "sample"))
cactus <- read_tsv("yeast.mapping.cactus.all.tsv", col_names = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", "all", "graph", "sample"))

construct_new <- construct %>%
  gather("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", key="filter", value="construct_number") %>%
  mutate(construct_fraction = construct_number / all) %>%
  select(sample, filter, construct_fraction)

cactus_new <- cactus %>%
  gather("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", key="filter", value="cactus_number") %>%
  mutate(cactus_fraction = cactus_number / all) %>%
  select(sample, filter, cactus_fraction)

# Mapping quality plot
svg('yeast-mapping-quality.svg', 8, 7)
construct_new %>%
  inner_join(cactus_new, by=c("sample", "filter")) %>%
  filter(filter %in% c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60")) %>%
  mutate(filter = factor(filter, levels = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60"), labels = c("0", "10", "20", "30", "40", "50", "60"))) %>%
  ggplot(aes(construct_fraction, cactus_fraction, color=sample)) +
  geom_point(aes(size=filter)) +
  geom_line() +
  labs(color="Strain", size="Mapping quality threshold", x="Mapped read fraction on construct graph", y="Mapped read fraction on cactus graph") +
  coord_cartesian(xlim=c(0.6,1), ylim=c(0.6,1)) +
  geom_abline(intercept=0) +
  theme_bw()
dev.off()

# Mapping percent identity plot
svg('yeast-mapping-identity.svg', 8, 7)
construct_new %>%
  inner_join(cactus_new, by=c("sample", "filter")) %>%
  filter(filter %in% c("id_ge100", "id_ge90", "id_ge50")) %>%
  mutate(filter = factor(filter, levels = c("id_ge100", "id_ge90", "id_ge50"), labels = c("100", "90", "50"))) %>%
  ggplot(aes(construct_fraction, cactus_fraction, color=sample)) +
  geom_point(aes(size=filter)) +
  geom_line() +
  labs(color="Strain", size="Percent identity threshold", x="Mapped read fraction on construct graph", y="Mapped read fraction on cactus graph") +
  coord_cartesian(xlim=c(0,1), ylim=c(0,1)) +
  geom_abline(intercept=0) +
  theme_bw()
dev.off()

###############
#SV genotyping#
###############

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
  theme(text=element_text(size=20),
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
  theme(text=element_text(size=20),
        legend.text=element_text(size=10),
        legend.title=element_text(size=10),
        legend.position=c(.95,.05),
        legend.justification=c(1,0),
        legend.background=element_rect(colour='black')) + 
  guides(col = guide_legend(nrow = 6)) + 
  xlab('from VCF calls (precision)') +
  ylab('from assembly alignment (precision)')
dev.off()
