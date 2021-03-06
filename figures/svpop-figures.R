library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## HG00514/HG00733/NA19240 reads, but processed with 15-sample graph of SMRT-SV v2 discovery data from Audano et. al 2019
## There are no genotypes for this data, but there are a few inversions

## Method names and renaming vector to fit color palette
methods = c('vg','smrtsv')
methconv = c(vg='vg', smrtsv='SMRT-SV v2 Genotyper', paragraph='Paragraph')

## Read evaluation results
pr.df = read.table('data/human-merged-prcurve.tsv', as.is=TRUE, header=TRUE)

## Keep SVPOP experiment only and polish data.frame
pr.df$method = factor(methconv[pr.df$method], levels=names(pal.tools))
pr.df = pr.df %>% filter(grepl('svpop', exp), type!='Total', !is.na(method), min.cov==.5,
                         region%in%c('all', 'nonrep')) %>% arrange(qual)
pr.df = relabel(pr.df)

## Merge samples
pr.df = pr.df %>% group_by(type, qual, method, region, eval) %>%
  select(TP, TP.baseline, FN, FP) %>% summarize_all(sum)
pr.df = prf(pr.df)
label.df = pr.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/svpop.pdf', 8, 4)
zoomgp(subset(pr.df, eval=='presence'), subset(label.df, eval=='presence'),
       zoom.xy=.6, zoom.br=.1, annot=TRUE, zout.only=TRUE)
dev.off()


## Bar plots with best F1
pdf('pdf/svpop-best-f1.pdf', 8, 4)
label.df %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~.) +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method') + 
  theme()
dev.off()

label.df %>% filter(!is.na(F1)) %>%
  ungroup %>% 
  select(method, region, type, TP.baseline, FP, FN, precision, recall, F1) %>%
  arrange(method, region, type) %>%
  kable(digits=3) %>%
    cat(file='tables/svpop.md', sep='\n')


##
## Regional analysis analysis
## Regions: all, repeats, non-repeats, called in SMRT-SV v2, not called in SMRT-SV
##
pr.df = read.table('data/human-merged-prcurve.tsv', as.is=TRUE, header=TRUE)

## Keep SVPOP experiment only and polish data.frame
pr.df$method = factor(methconv[pr.df$method], levels=names(pal.tools))
pr.df = pr.df %>% filter(exp=='svpop', type!='Total', sample=='HG00514', !is.na(method),
                         method!='Paragraph', min.cov==.5) %>%
  arrange(qual)
pr.df = relabel(pr.df)
label.df = pr.df %>% group_by(region, method, type, eval) %>% arrange(desc(F1)) %>% do(head(.,1))

pdf('pdf/svpop-regions.pdf', 8, 5)
pr.df %>% filter(type!='INV', eval=='presence') %>%
  ggplot(aes(x=recall, y=precision, colour=region)) +
  geom_path(size=1, alpha=.9) + 
  theme_bw() +
  labs(x='Recall', y='Precision', color='Genomic regions') + 
  facet_grid(method~type) +
  scale_colour_brewer(palette='Set1')
dev.off()

## Bar plots with best F1
label.df %>% filter(!is.na(F1)) %>%
  ungroup %>% 
  select(method, region, type, TP.baseline, FP, FN, precision, recall, F1) %>%
  arrange(method, region, type) %>%
  kable(digits=3) %>%
  cat(file='tables/svpop-regions.md', sep='\n')
