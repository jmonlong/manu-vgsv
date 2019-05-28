library(tidyverse)

########################
#SV genotyping SV reads#
########################

data_four <- read_tsv("data/yeast/four.strains.ids_and_mapqs.different.mean.tsv", col_names=c("strain", "cactus_id", "vcf_id", "linear_id", "cactus_mapq", "vcf_mapq", "linear_mapq"))
data_all <- read_tsv("data/yeast/all.strains.ids_and_mapqs.different.mean.tsv", col_names=c("strain", "cactus_id", "vcf_id", "linear_id", "cactus_mapq", "vcf_mapq", "linear_mapq"))

four <- data_four %>%
  mutate(clade=ifelse(strain %in% c("UWOPS919171","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  mutate(ingraph=ifelse(strain %in% c("UFRJ50816", "YPS128", "CBS432", "SK1", "S288c"), 'included', 'excluded')) %>%
  mutate(graph = "Five strains")

all <- data_all %>%
  mutate(clade=ifelse(strain %in% c("UWOPS919171","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  mutate(ingraph='included') %>%
  mutate(graph = "All strains")

total <- rbind(four, all) %>%
  mutate(diff_id = cactus_id - vcf_id) %>%
  mutate(diff_mapq = cactus_mapq - vcf_mapq)

# Mapping identity plot
pdf('pdf/yeast-genotyping-identity-SVregions.pdf', 6, 6)
total %>%
  ggplot(aes(x=strain, y=diff_id, fill=graph, alpha=ingraph)) +
  geom_col(position=position_dodge()) +
  scale_alpha_discrete(range=c(.4, 1)) +
  facet_grid(~clade, scales='free') +
  labs(fill="Graph type", alpha="During graph\nconstruction",
       x="Yeast strain",
       y="Average delta in mapping identity") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
dev.off()

pdf('pdf/yeast-genotyping-quality-SVregions.pdf', 6, 6)
total %>%
  ggplot(aes(x=strain, y=diff_mapq, fill=graph, alpha=ingraph)) +
  geom_col(position=position_dodge()) +
  scale_alpha_discrete(range=c(.4, 1)) +
  facet_grid(~clade, scales='free') +
  labs(fill="Graph type", alpha="During graph\nconstruction",
       x="Yeast strain",
       y="Average delta in mapping quality") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
dev.off()

mean(total[total$graph == "Five strains", ]$diff_id)
mean(total[total$graph == "All strains", ]$diff_id)

mean(total[total$graph == "Five strains" & total$clade == "cerevisiae", ]$diff_id)
mean(total[total$graph == "Five strains" & total$clade == "paradoxus", ]$diff_id)
mean(total[total$graph == "All strains" & total$clade == "cerevisiae", ]$diff_id)
mean(total[total$graph == "All strains" & total$clade == "paradoxus", ]$diff_id)

mean(total[total$graph == "Five strains", ]$diff_mapq)
mean(total[total$graph == "All strains", ]$diff_mapq)

#########################
#SV genotyping all reads#
#########################

data_four <- read_tsv("data/yeast/four.strains.ids_and_mapqs.mean.tsv", col_names=c("strain", "cactus_id", "vcf_id", "linear_id", "cactus_mapq", "vcf_mapq", "linear_mapq"))
data_all <- read_tsv("data/yeast/all.strains.ids_and_mapqs.mean.tsv", col_names=c("strain", "cactus_id", "vcf_id", "linear_id", "cactus_mapq", "vcf_mapq", "linear_mapq"))

four <- data_four %>%
  mutate(clade=ifelse(strain %in% c("UWOPS919171","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  mutate(ingraph=ifelse(strain %in% c("UFRJ50816", "YPS128", "CBS432", "SK1", "S288c"), 'included', 'excluded')) %>%
  mutate(graph = "Five strains")

all <- data_all %>%
  mutate(clade=ifelse(strain %in% c("UWOPS919171","UFRJ50816","YPS138","N44","CBS432"), 'paradoxus', 'cerevisiae')) %>%
  mutate(ingraph='included') %>%
  mutate(graph = "All strains")

total <- rbind(four, all) %>%
  mutate(diff_id = cactus_id - vcf_id) %>%
  mutate(diff_mapq = cactus_mapq - vcf_mapq)

# Mapping identity plot
pdf('pdf/yeast-genotyping-identity-allregions.pdf', 6, 6)
total %>%
  ggplot(aes(x=strain, y=diff_id, fill=graph, alpha=ingraph)) +
  geom_col(position=position_dodge()) +
  scale_alpha_discrete(range=c(.4, 1)) +
  facet_grid(~clade, scales='free') +
  labs(fill="Graph type", alpha="During graph\nconstruction",
       x="Yeast strain",
       y="Average delta in mapping identity") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
dev.off()

pdf('pdf/yeast-genotyping-quality-allregions.pdf', 6, 6)
total %>%
  ggplot(aes(x=strain, y=diff_mapq, fill=graph, alpha=ingraph)) +
  geom_col(position=position_dodge()) +
  scale_alpha_discrete(range=c(.4, 1)) +
  facet_grid(~clade, scales='free') +
  labs(fill="Graph type", alpha="During graph\nconstruction",
       x="Yeast strain",
       y="Average delta in mapping quality") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
dev.off()