library(tidyverse)
library(magrittr)
library(ggrepel)

##############
#Read mapping#
##############

#Four strains
#############

construct <- read_tsv("data/yeast/yeast.mapping.constructunion.four.tsv", col_names = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", "all", "graph", "sample"))
cactus <- read_tsv("data/yeast/yeast.mapping.cactus.four.tsv", col_names = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", "all", "graph", "sample"))

construct_new <- construct %>%
  gather("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", key="filter", value="construct_number") %>%
  mutate(construct_fraction = construct_number / all) %>%
  select(sample, filter, construct_fraction)

cactus_new <- cactus %>%
  gather("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60", "id_ge100", "id_ge90", "id_ge50", key="filter", value="cactus_number") %>%
  mutate(cactus_fraction = cactus_number / all) %>%
  select(sample, filter, cactus_fraction)

## Mapping quality plot
pdf('pdf/yeast-mapping-quality-four.pdf', 6, 6)
construct_new %>%
  inner_join(cactus_new, by=c("sample", "filter")) %>%
  filter(filter %in% c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60")) %>%
  mutate(filter = factor(filter, levels = c("mapq_gt0", "mapq_ge10", "mapq_ge20", "mapq_ge30", "mapq_ge40", "mapq_ge50", "mapq_ge60"), labels = c("0", "10", "20", "30", "40", "50", "60"))) %>%
  mutate(clade=ifelse(sample %in% c("UWOPS91-917.1","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  mutate(ingraph=ifelse(sample %in% c("UFRJ50816", "YPS128", "CBS432", "SK1", "S288c"), 'included', 'excluded')) %>% 
  ggplot(aes(construct_fraction, cactus_fraction,
               color=sample, alpha=ingraph, pch=clade)) +
  geom_abline(intercept=0) +
  geom_point(aes(size=filter)) +
  geom_line() +
  geom_label_repel(aes(label=ifelse(filter==60, sample, '')),
                   point.padding=.5, box.padding=.5,
                   min.segment.length=0, size=3, seed=123,
                   alpha=1, segment.size=.5, label.size=.5,
                   arrow=arrow(length = unit(0.01, "npc"))) + 
  labs(color="Strain", size="Mapping quality threshold",
       x="Mapped read fraction on VCF graph",
       y="Mapped read fraction on cactus graph",
       alpha="during graph\nconstruction ", pch="Clade") +
  coord_cartesian(xlim=c(0.6,1), ylim=c(0.6,1)) +
  scale_size_discrete(range=c(.5,3)) +
  scale_alpha_discrete(range=c(1, .3)) +
  theme_bw() +
  theme(legend.position=c(.99,.01), legend.justification=c(1, 0),
        legend.box.just='right',
        legend.background=element_rect(colour='black', size=.1)) +
  guides(pch=guide_legend(order=1, title.hjust=1),
         size=guide_legend(ncol=4, order=3, title.hjust=1),
         alpha=guide_legend(order=2, title.hjust=1, title.position='bottom'),
         color=FALSE)
dev.off()

# Mapping percent identity plot
pdf('pdf/yeast-mapping-identity-four.pdf', 6, 6)
construct_new %>%
  inner_join(cactus_new, by=c("sample", "filter")) %>%
  filter(filter %in% c("id_ge100", "id_ge90", "id_ge50")) %>%
  mutate(filter = factor(filter, levels = c("id_ge50", "id_ge90", "id_ge100"), labels = c("50", "90", "100"))) %>%
  mutate(clade=ifelse(sample %in% c("UWOPS91-917.1","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  mutate(ingraph=ifelse(sample %in% c("UFRJ50816", "YPS128", "CBS432", "SK1", "S288c"), 'included', 'excluded')) %>%
  ggplot(aes(construct_fraction, cactus_fraction, color=sample,
             alpha=ingraph, pch=clade)) +
  geom_abline(intercept=0) +
  geom_point(aes(size=filter)) +
  geom_line() +
  geom_label_repel(aes(label=ifelse(filter==100, sample, '')),
                   point.padding=.25, box.padding=.25,
                   min.segment.length=Inf, size=3, seed=123,
                   nudge_y=-.01, nudge_x=.01,
                   alpha=1, label.size=.5) + 
  labs(color="Strain", size="Percent identity threshold",
       x="Mapped read fraction on VCF graph",
       y="Mapped read fraction on cactus graph",
       alpha="during graph\nconstruction ", pch="Clade") +
  coord_cartesian(xlim=c(0,1), ylim=c(0,1)) +
  scale_size_discrete(range=c(.5,3)) +
  scale_alpha_discrete(range=c(1, .3)) +
  theme_bw() +
  theme(legend.position=c(.99,.01), legend.justification=c(1, 0),
        legend.box.just='right',
        legend.background=element_rect(colour='black', size=.1)) +
  guides(pch=guide_legend(order=1, title.hjust=1),
         size=guide_legend(ncol=4, order=3, title.hjust=1),
         alpha=guide_legend(order=2, title.hjust=1, title.position='bottom'),
         color=FALSE)
dev.off()