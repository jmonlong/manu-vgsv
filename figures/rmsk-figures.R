library(ggplot2)
source('colors-functions.R')

eval.df = read.table('data/eval-rmsk-hgsvc-vg-HG00514-call-geno.tsv', header=TRUE, as.is=TRUE)
eval.df = relabel(eval.df)

pdf('pdf/rmsk-hgsvc-vg-HG00514-call-geno.pdf', 8, 4)
ggplot(eval.df, aes(x=precision, y=recall, shape=type, color=rep)) +
  geom_point(size=3) + theme_bw() +
  scale_color_brewer(palette='Set2', name='repeat class/family') +
  scale_shape_discrete(name='SV type') + 
  xlim(0,1) + ylim(0,1) + facet_grid(.~eval) 
dev.off()
