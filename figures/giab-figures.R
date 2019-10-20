library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## Method names and renaming vector to fit color palette
methconv = c(vg='vg', delly='Delly', bayestyper='BayesTyper', svtyper='SVTyper', paragraph='Paragraph')

## Read evaluation results
pr.df = read.table('data/human-merged-prcurve.tsv', as.is=TRUE, header=TRUE)

## Keep GIAB experiment only and polish data.frame
pr.df$method = factor(methconv[pr.df$method], levels=names(pal.tools))
pr.df = pr.df %>% filter(grepl('giab', exp), type!='INV', type!='Total',
                         !is.na(method), min.cov==.5) %>%
  arrange(qual)
pr.df = relabel(pr.df, nonrep='hc')

label.df = pr.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/giab5.pdf', 8, 4)
zoomgp(subset(pr.df, eval=='presence'), subset(label.df, eval=='presence'),
       zoom.xy=.6, zoom.br=.1, annot=TRUE, zout.only=TRUE)
dev.off()

pdf('pdf/giab5-geno.pdf', 8, 4)
zoomgp(subset(pr.df, eval=='genotype'), subset(label.df, eval=='genotype'),
       zoom.xy=.6, zoom.br=.1, annot=TRUE, zout.only=TRUE)
dev.off()


## Bar plots with best F1
pdf('pdf/giab5-best-f1.pdf', 8, 4)

label.df %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~.) +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method')

dev.off()

label.df %>% filter(eval=='genotype', !is.na(F1)) %>%
  ungroup %>% 
  select(method, region, type, precision, recall, F1) %>%
  tableAllRep %>% 
  arrange(method, type) %>%
  kable(digits=3) %>%
  cat(file='tables/giab-geno-precision-recall-F1.md', sep='\n')
