library(ggplot2)
library(dplyr)
library(ggrepel)
library(knitr)
source('colors-functions.R')

## Method names and renaming vector to fit color palette
methconv = c(vg='vg', delly='Delly', bayestyper='BayesTyper', svtyper='SVTyper', paragraph='Paragraph', smrtsv='SMRT-SV v2')

## Read evaluation results
pr.df = read.table('data/human-merged-prcurve.tsv', as.is=TRUE, header=TRUE)
pr.df$method = factor(methconv[pr.df$method], levels=names(pal.tools))
pr.df = pr.df %>% filter(type!='INV', type!='Total', min.cov==0.5, !is.na(method),
                         region%in%c('all', 'nonrep')) %>% arrange(qual)
pr.df = relabel(pr.df)

pr.df = pr.df %>% group_by(exp, experiment, type, qual, method, region, eval) %>%
  select(TP, TP.baseline, FN, FP) %>% summarize_all(sum)
pr.df = prf(pr.df)

## Bar plots with best F1
eval.f1 = pr.df %>% group_by(exp, experiment, method, type, region, eval) %>%
  arrange(desc(F1)) %>% do(head(., 1))

pdf('pdf/hgsvc-giab-chmpd-svpop-best-f1.pdf', 8, 4)

eval.f1 %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~exp, scales='free', space='free') +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method') +
  theme(legend.position='top') +
  guides(fill=guide_legend(ncol=3))

dev.off()

pdf('pdf/hgsvc-giab-best-f1.pdf', 8, 3)
eval.f1 %>%
  filter(exp %in% c('hgsvcsim', 'hgsvc', 'giab5')) %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~experiment, scales='free', space='free') +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method') +
  theme(legend.position='left') +
  guides(fill=guide_legend(ncol=2))
dev.off()

pdf('pdf/chmpd-svpop-best-f1.pdf', 8, 4)
eval.f1 %>% ungroup %>% 
  filter(exp %in% c('chmpd', 'svpop')) %>% 
  mutate(experiment=as.character(experiment),
         experiment=ifelse(experiment=='CHM-PD',
                           'CHM pseudo diploid', experiment)) %>%
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~experiment, scales='free', space='free') +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method')
dev.off()


eval.f1 %>% filter(eval=='genotype', !is.na(F1)) %>% ungroup %>% 
  select(experiment, method, region, type, precision, recall, F1) %>%
  arrange(region) %>% select(-region) %>% 
  group_by(experiment, method, type) %>%
  summarize_all(function(x) {x=round(x,3); paste0(x[1], ' (', x[2], ')')}) %>%
  arrange(experiment, method, type) %>%
  kable() %>%
  cat(file='tables/hgsvc-giab-chmpd-svpop-geno-precision-recall-F1.md', sep='\n')



ps.df = read.table('data/human-merged-persize.tsv', as.is=TRUE, header=TRUE)
ps.df$method = factor(methconv[ps.df$method], levels=names(pal.tools))
ps.df = subset(ps.df, !is.na(method))
ps.df = relabel(ps.df)

ps.df = ps.df %>% group_by(experiment, type, size, method, region, eval, min.cov) %>%
  select(TP, TP.baseline, FN, FP) %>% summarize_all(sum)
ps.df = prf(ps.df)

pdf('pdf/hgsvc-giab-chmpd-svpop-call-persize.pdf', 9, 7)

ps.df %>% filter(eval=='presence', type!='INV', min.cov==.5) %>% ungroup %>% 
  ungroup %>% arrange(experiment, method) %>%
  mutate(experiment=gsub(' ', '\n', experiment),
         experiment=factor(experiment, levels=unique(experiment))) %>% 
  mutate(region=paste(region, 'regions')) %>% 
  ggplot(aes(x=size, y=F1, colour=method)) +
  geom_line(aes(group=paste(region, method)), size=1) + 
  theme_bw() +
  facet_grid(experiment~ type + region) +
  labs(x='Size (bp)', y='F1 score', color='Method',
       linetype='Genomic regions') + 
  theme(legend.position='bottom',
        axis.text.x=element_text(angle=30, hjust=1, size=6),
        strip.text.y=element_text(angle=0)) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_manual(values=pal.tools)

dev.off()

pdf('pdf/hgsvc-giab-chmpd-geno-persize.pdf', 9, 7)

ps.df %>% filter(eval=='genotype', type!='INV', min.cov==.5) %>% ungroup %>% 
  ungroup %>% arrange(experiment, method) %>%
  mutate(experiment=gsub(' ', '\n', experiment),
         experiment=factor(experiment, levels=unique(experiment))) %>% 
  mutate(region=paste(region, 'regions')) %>% 
  ggplot(aes(x=size, y=F1, colour=method)) +
  geom_line(aes(group=paste(region, method)), size=1) + 
  theme_bw() +
  facet_grid(experiment~ type + region) +
  labs(x='Size (bp)', y='F1 score', color='Method',
       linetype='Genomic regions') + 
  theme(legend.position='bottom',
        axis.text.x=element_text(angle=30, hjust=1, size=6),
        strip.text.y=element_text(angle=0)) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_manual(values=pal.tools)

dev.off()

pdf('pdf/hgsvc-giab-geno-persize.pdf', 8, 4)
ps.df %>% filter(eval=='genotype', type!='INV',
                 grepl("HGSVC|GIAB", experiment), min.cov==.5) %>%
  arrange(experiment, method) %>% ungroup %>% 
    mutate(experiment=gsub(' ', '\n', experiment),
           experiment=factor(experiment, levels=unique(experiment))) %>% 
  mutate(region=paste(region, 'regions')) %>% 
  ggplot(aes(x=size, y=F1, colour=method)) +
  geom_line(aes(group=paste(region, method)), size=1) + 
  theme_bw() +
  facet_grid(experiment~ type + region) +
  labs(x='Size (bp)', y='F1 score', color='Method', linetype='Genomic regions') + 
    theme(legend.position='bottom',
          axis.text.x=element_text(angle=30, hjust=1, size=6),
        strip.text.y=element_text(angle=0)) +
    scale_linetype_manual(values=c(3,1)) +
    guides(colour=FALSE) + 
  scale_colour_manual(values=pal.tools)
dev.off()

pdf('pdf/hgsvc-giab-call-persize.pdf', 8, 3.5)
ps.df %>% filter(eval=='presence', type!='INV', grepl("HGSVC|GIAB", experiment),
                 region=='all', min.cov==.5) %>%
  arrange(experiment, method) %>% ungroup %>% 
    mutate(experiment=gsub(' ', '\n', experiment),
           experiment=factor(experiment, levels=unique(experiment))) %>% 
  ggplot(aes(x=size, y=F1, colour=method)) +
  geom_line(aes(group=paste(region, method)), size=1) + 
  theme_bw() +
  facet_grid(experiment~ type) +
  labs(x='Size (bp)', y='F1 score', color='Method', linetype='Genomic regions') + 
    theme(legend.position='bottom',
          axis.text.x=element_text(angle=30, hjust=1, size=6),
        strip.text.y=element_text(angle=0)) +
    scale_linetype_manual(values=c(3,1)) +
    guides(colour=FALSE) + 
  scale_colour_manual(values=pal.tools)
dev.off()

refsize = read.table('data/human-ref-size.tsv', as.is=TRUE, header=TRUE)
refsize = refsize %>% filter(!is.na(size)) %>% relabel

pdf('pdf/hgsvc-giab-refsize.pdf', 8, 2)
refsize %>% filter(grepl('HGSVC|giab', vcf)) %>%
  group_by(type, size) %>% summarize(n=sum(n)) %>% 
  ggplot(aes(x=size, y=n)) + geom_bar(stat='identity') +
  labs(x='Size (bp)', y='Variant') + theme_bw() + 
  theme(legend.position='bottom', axis.text.x=element_text(angle=30, hjust=1),
        strip.text.y=element_text(angle=0)) +
  facet_grid(.~type)
dev.off()


## More stringent threshold when matching truth/called SVs
## Read evaluation results
pr.df = read.table('data/human-merged-prcurve.tsv', as.is=TRUE, header=TRUE)
pr.df$method = factor(methconv[pr.df$method], levels=names(pal.tools))
pr.df = pr.df %>% filter(type!='INV', type!='Total', min.cov==0.9, !is.na(method),
                         region%in%c('all', 'nonrep')) %>% arrange(qual)
pr.df = relabel(pr.df)

pr.df = pr.df %>% group_by(exp, experiment, type, qual, method, region, eval) %>%
  select(TP, TP.baseline, FN, FP) %>% summarize_all(sum)
pr.df = prf(pr.df)

## Bar plots with best F1
eval.f1 = pr.df %>% group_by(exp, experiment, method, type, region, eval) %>%
  arrange(desc(F1)) %>% do(head(., 1))

pdf('pdf/hgsvc-giab-chmpd-svpop-best-f1-mincov90.pdf', 8, 4)

eval.f1 %>% 
  ggplot(aes(x=region, y=F1, fill=method, alpha=eval, group=method)) +
  geom_bar(stat='identity', position=position_dodge()) +
  facet_grid(type~exp, scales='free', space='free') +
  scale_fill_manual(values=pal.tools) + 
  scale_alpha_manual(name='SV evaluation', values=c(.5,1)) + 
  theme_bw() + ylim(0,1) + 
  labs(x='Genomic regions', y='Best F1', fill='Method') +
  theme(legend.position='top') +
  guides(fill=guide_legend(ncol=3))

dev.off()

pdf('pdf/hgsvc-giab-chmpd-svpop-call-persize-mincov90.pdf', 9, 7)

ps.df %>% filter(eval=='presence', type!='INV', min.cov==.9) %>% ungroup %>% 
  ungroup %>% arrange(experiment, method) %>%
  mutate(experiment=gsub(' ', '\n', experiment),
         experiment=factor(experiment, levels=unique(experiment))) %>% 
  mutate(region=paste(region, 'regions')) %>% 
  ggplot(aes(x=size, y=F1, colour=method)) +
  geom_line(aes(group=paste(region, method)), size=1) + 
  theme_bw() +
  facet_grid(experiment~ type + region) +
  labs(x='Size (bp)', y='F1 score', color='Method',
       linetype='Genomic regions') + 
  theme(legend.position='bottom',
        axis.text.x=element_text(angle=30, hjust=1, size=6),
        strip.text.y=element_text(angle=0)) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_manual(values=pal.tools)

dev.off()

pdf('pdf/hgsvc-giab-chmpd-geno-persize-mincov90.pdf', 9, 7)

ps.df %>% filter(eval=='genotype', type!='INV', min.cov==.9) %>% ungroup %>% 
  ungroup %>% arrange(experiment, method) %>%
  mutate(experiment=gsub(' ', '\n', experiment),
         experiment=factor(experiment, levels=unique(experiment))) %>% 
  mutate(region=paste(region, 'regions')) %>% 
  ggplot(aes(x=size, y=F1, colour=method)) +
  geom_line(aes(group=paste(region, method)), size=1) + 
  theme_bw() +
  facet_grid(experiment~ type + region) +
  labs(x='Size (bp)', y='F1 score', color='Method',
       linetype='Genomic regions') + 
  theme(legend.position='bottom',
        axis.text.x=element_text(angle=30, hjust=1, size=6),
        strip.text.y=element_text(angle=0)) +
  scale_linetype_manual(values=c(3,1)) + 
  scale_colour_manual(values=pal.tools)

dev.off()
