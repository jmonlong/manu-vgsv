## Color palette
library(RColorBrewer)
tools = c('vg', 'Paragraph', 'BayesTyper', 'SVTyper', 'Delly', 'SMRT-SV v2')
pal.tools = brewer.pal(9, 'Set1')[-6]
pal.tools = pal.tools[1:length(tools)]
names(pal.tools) = tools

## Relabels columns and set an order
relabel <- function(df, nonrep=c('nonrep', 'hc')){
  ## Types
  if('type' %in% colnames(df)){
    df$type = factor(df$type, levels=c('Total', 'INS', 'DEL', 'INV'))
  }
  ## Region
  if('region' %in% colnames(df)){
    reg.l = c('all','repeat', 'non-repeat', 'called in SMRT-SV v2',
              'not called in SMRT-SV v2')
    if(nonrep[1] == 'nonrep'){
      reg.l[3] = 'non-repeat'
    } else if(nonrep[1] == 'hc'){
      reg.l[3] = 'high-confidence'
    }
    df$region = factor(df$region, levels=c('all','rep', 'nonrep', 'called', 'nocalls'),
                       labels=reg.l)
  }
  ## Evaluation metric
  if('eval' %in% colnames(df)){
    df$eval=factor(df$eval, levels=c('call','geno'),
                   labels=c('presence', 'genotype'))
  }
  ## Experiment
  if('exp' %in% colnames(df)){
    df$experiment = factor(df$exp,
                           levels=c('hgsvcsim', 'hgsvc', 'giab5',
                                    'chmpd', 'svpop'),
                           labels=c('HGSVC simulated reads', 'HGSVC real reads',
                             'GIAB', 'CHM-PD', 'SVPOP'))
  }
  ## Sizes
  if('size' %in% colnames(df)){
    sizes = unique(df$size)
    sizes = sizes[order(as.numeric(gsub('.*,(.*)]', '\\1', sizes)))]
    sizes.l = gsub('\\((.*),Inf]', '>\\1', sizes)
    sizes.l = gsub('e\\+03', 'K', sizes.l)
    sizes.l = gsub('e\\+04', '0K', sizes.l)
    sizes.l = gsub('e\\+05', '00K', sizes.l)
    df$size = factor(df$size, levels=sizes, labels=sizes.l)
  }
  return(df)
}

## (Re)-compute precision, recall and F1 score (e.g. when merging samples)
prf <- function(eval.df){
  eval.df$precision = eval.df$TP / (eval.df$TP + eval.df$FP)
  eval.df$precision = round(eval.df$precision, 4)
  eval.df$recall = eval.df$TP.baseline / (eval.df$TP.baseline + eval.df$FN)
  eval.df$recall = round(eval.df$recall, 4)
  eval.df$F1 = 2 * eval.df$precision * eval.df$recall /
    (eval.df$precision + eval.df$recall)
  eval.df$F1 = round(eval.df$F1, 4)
  return(eval.df)
}

library(gridExtra)
##' Makes two PR curves: top with (0,1) scale, bottom zoomed to (zoom.xy, 1)
##' @param curve.df data.frame with PR stats
##' @param labels.df data.frame with point to highlight
##' @param zoom.xy scale for the zoomed graph
##' @param zoom.br step for the breaks in the zommed graph
##' @param heights height for each graph (bottom larger because of legend)
##' @param annot should the zoomed region be annotated with dotted rectangle.
##' @param zout.only only returns the zoomed out version
##' @return a graph
zoomgp <- function(curve.df, labels.df, zoom.xy=.9, zoom.br=.02,
                   heights=c(1,1.1), annot=FALSE, zout.only=FALSE){
  ## Zoomed out graph
  zout = ggplot(curve.df, aes(x=recall, y=precision, colour=method))
  if(annot & !zout.only){
    zout = zout +
      annotate('rect', xmin=zoom.xy, xmax=1, ymin=zoom.xy, ymax=1, alpha=0, colour='black',
               linetype=2, size=.3)
  }
  zout = zout + 
    geom_path(aes(linetype=region), size=1, alpha=.8) + 
    geom_point(aes(shape=region), size=3, data=labels.df) + 
    theme_bw() +
    facet_grid(.~type) +
    theme(legend.position='bottom') +
    labs(x='Recall', y='Precision', color='Method', shape='Genomic regions', linetype='Genomic regions') + 
    scale_x_continuous(breaks=seq(0,1,.2), limits=c(0,1)) + 
    scale_y_continuous(breaks=seq(0,1,.2), limits=c(0,1)) +
    scale_linetype_manual(values=c(3,1)) + 
    scale_colour_manual(values=pal.tools) +
    guides(colour=FALSE, linetype=FALSE, shape=FALSE)
  if(zout.only){
    return(zout)
  }
  ## Zoomed in graph
  zin = ggplot(curve.df, aes(x=recall, y=precision, colour=method))
  if(annot){
    zin = zin +
      annotate('rect', xmin=zoom.xy, xmax=1, ymin=zoom.xy, ymax=1, alpha=0, colour='black',
               linetype=2, size=.3)
  }
  zin = zin + 
    geom_path(aes(linetype=region), size=1, alpha=.8) + 
    geom_point(aes(shape=region), size=3, data=labels.df) + 
    theme_bw() +
    facet_grid(.~type) +
    theme(legend.position='bottom') +
    labs(x='Recall', y='Precision', color='Method', shape='Genomic regions', linetype='Genomic regions') + 
    scale_x_continuous(breaks=seq(0,1,zoom.br), limits=c(zoom.xy,1)) + 
    scale_y_continuous(breaks=seq(0,1,zoom.br), limits=c(zoom.xy,1)) +
    scale_linetype_manual(values=c(3,1)) + 
    scale_colour_manual(values=pal.tools) +
    guides(color=guide_legend(ncol=4))
  grid.arrange(zout, zin, ncol=1, nrow=2, heights=heights)
}
