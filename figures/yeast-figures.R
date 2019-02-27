library(tidyverse)
library(magrittr)

##############
#Read mapping#
##############

construct <- read_tsv("data/yeast.mapping.constructunion.all.tsv", col_names = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", "all", "graph", "sample"))
cactus <- read_tsv("data/yeast.mapping.cactus.all.tsv", col_names = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", "all", "graph", "sample"))

construct_new <- construct %>%
  gather("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", key="filter", value="construct_number") %>%
  mutate(construct_fraction = construct_number / all) %>%
  select(sample, filter, construct_fraction)

cactus_new <- cactus %>%
  gather("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", key="filter", value="cactus_number") %>%
  mutate(cactus_fraction = cactus_number / all) %>%
  select(sample, filter, cactus_fraction)

# Mapping quality plot
pdf('pdf/yeast-mapping-quality.pdf', 6, 6)
construct_new %>%
  inner_join(cactus_new, by=c("sample", "filter")) %>%
  filter(filter %in% c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60")) %>%
  mutate(filter = factor(filter, levels = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60"), labels = c("0", "10", "20", "30", "40", "50", "60"))) %>%
  ggplot(aes(construct_fraction, cactus_fraction, color=sample)) +
  geom_point(aes(size=filter)) +
  geom_line() +
  labs(color="Strain", size="Mapping quality\nthreshold", x="Mapped read fraction on construct graph", y="Mapped read fraction on cactus graph") +
  coord_cartesian(xlim=c(0.6,1), ylim=c(0.6,1)) +
  geom_abline(intercept=0) +
  scale_size_discrete(range=c(.5,3)) +
  theme_bw() +
  theme(legend.position=c(.99,.01), legend.justification=c(1, 0),
        legend.box.just='right',
        legend.background=element_rect(colour='black', size=.1)) +
  guides(size=guide_legend(ncol=2), color=guide_legend(ncol=2))
dev.off()

# Mapping percent identity plot
pdf('pdf/yeast-mapping-identity.pdf', 6, 6)
construct_new %>%
  inner_join(cactus_new, by=c("sample", "filter")) %>%
  filter(filter %in% c("id_ge100", "id_ge90", "id_ge50")) %>%
  mutate(filter = factor(filter, levels = c("id_ge50", "id_ge90", "id_ge100"), labels = c("50", "90", "100"))) %>%
  ggplot(aes(construct_fraction, cactus_fraction, color=sample)) +
  geom_point(aes(size=filter)) +
  geom_line() +
  labs(color="Strain", size="Percent identity\nthreshold", x="Mapped read fraction on construct graph", y="Mapped read fraction on cactus graph") +
  coord_cartesian(xlim=c(0,1), ylim=c(0,1)) +
  geom_abline(intercept=0) +
  scale_size_discrete(range=c(.5,3)) +
  theme_bw() +
  theme(legend.position=c(.99,.01), legend.justification=c(1, 0),
        legend.box.just='right',
        legend.background=element_rect(colour='black', size=.1)) +
  guides(color=guide_legend(ncol=2, order=2), size=guide_legend(order=1))
dev.off()

###############
#SV genotyping#
###############

identity <- read_tsv("data/constructunion.all.reads.identity.tsv", col_names = c("graph", "strain", "identity"))
quality <- read_tsv("data/constructunion.all.reads.mapq.tsv", col_names = c("graph", "strain", "quality"))
score <- read_tsv("data/constructunion.all.reads.score.tsv", col_names = c("graph", "strain", "score"))

# Mapping identity plot
pdf('pdf/yeast-genotyping-identity.pdf', 6, 6)
identity %>%
  spread(graph, identity) %>%
  mutate(clade=ifelse(strain %in% c("UWOPS919171","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  ggplot(aes(construct, cactus, color=strain, shape=clade)) +
  geom_point(size=4) +
  labs(color="Strain", shape="Clade", x="Average mapping identity of short reads on construct graph", y="Average mapping identity of short reads on cactus graph") +
  coord_cartesian(xlim=c(0.6,1), ylim=c(0.6,1)) +
  geom_abline(intercept=0) +
  theme_bw() +
  theme(legend.position=c(.99,.01), legend.justification=c(1, 0),
        legend.box.just='right',
        legend.background=element_rect(colour='black', size=.1)) +
  guides(color=guide_legend(ncol=2, order=2), shape=guide_legend(order=1))
dev.off()

# Mapping quality plot
pdf('pdf/yeast-genotyping-quality.pdf', 6, 6)
quality %>%
  spread(graph, quality) %>%
  mutate(clade=ifelse(strain %in% c("UWOPS919171","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  ggplot(aes(construct, cactus, color=strain, shape=clade)) +
  geom_point(size=4) +
  labs(color="Strain", shape="Clade", x="Average mapping quality of short reads on construct graph", y="Average mapping quality of short reads on cactus graph") +
  coord_cartesian(xlim=c(42,55), ylim=c(42,55)) +
  geom_abline(intercept=0) +
  theme_bw() +
  theme(legend.position=c(.99,.01), legend.justification=c(1, 0),
        legend.box.just='right',
        legend.background=element_rect(colour='black', size=.1)) +
  guides(color=guide_legend(ncol=2, order=2), shape=guide_legend(order=1))
dev.off()

# Mapping score plot
pdf('pdf/yeast-genotyping-score.pdf', 8, 7)
score %>%
  spread(graph, score) %>%
  mutate(clade=ifelse(strain %in% c("UWOPS919171","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  ggplot(aes(construct, cactus, color=strain, shape=clade)) +
  geom_point(size=4) +
  labs(color="Strain", shape="Clade", x="Average alignment score of short reads on construct graph", y="Average alignment score of short reads on cactus graph") +
  coord_cartesian(xlim=c(90,150), ylim=c(90,150)) +
  geom_abline(intercept=0) +
  theme_bw() +
  theme(legend.position=c(.99,.01), legend.justification=c(1, 0),
        legend.box.just='right',
        legend.background=element_rect(colour='black', size=.1)) +
  guides(color=guide_legend(ncol=2, order=2), shape=guide_legend(order=1))
dev.off()
