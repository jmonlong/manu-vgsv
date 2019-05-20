## Color palette
library(RColorBrewer)
tools = c('vg', 'BayesTyper', 'SVTyper', 'Delly', 'SMRT-SV v2')
pal.tools = brewer.pal(length(tools), 'Set1')
names(pal.tools) = tools


## Function to read PR files and merge data adding a 'label' column
readEval <- function(files, methods, regions=NULL, folder='data'){
  if(is.null(regions)){
    regions = rep('', length(methods))
  }
  eval.df = lapply(1:length(files), function(ii){
    df = read.table(paste0(folder, '/', files[ii]), as.is=TRUE, header=TRUE)
    df$method = methods[ii]
    df$region = regions[ii]
    df
  })
  df = do.call(rbind, eval.df)
  ## order by quality to make sure the lines/paths are correctly drawn
  df = df[order(df$qual),]
  df$type = factor(df$type, levels=c('Total', 'INS', 'DEL', 'INV'))
  df
}


## Read 4 evaluation files (call/geno x all/nonrep) for each method-sample pair
## tsv files must be named: {prefix}-{method}-{sample}-{all|nonrep}-{call|geno}-prcurve.tsv
readEval4 <- function(methods, samples, prefix, regions=c('all','nonrep'), eval=c('call', 'geno')){
  res = lapply(methods, function(meth){
    res = lapply(samples, function(samp){
      res = lapply(regions, function(reg){
        res = lapply(eval, function(ev){
          df = read.table(paste(prefix, meth, samp, reg, ev, 'prcurve.tsv', sep='-'), as.is=TRUE, header=TRUE)
          df$method = meth
          df$region = reg
          df$sample = samp
          df$eval = ev
          df
        })
        do.call(rbind, res)
      })
      do.call(rbind, res)
    })
    do.call(rbind, res)
  })
  res = do.call(rbind, res)
  res$type = factor(res$type, levels=c('Total', 'INS', 'DEL', 'INV'))
  res$region = factor(res$region, levels=c('all','rep', 'nonrep', 'called', 'nocalls'),
                      labels=c('all','repeat', 'non-repeat', 'called', 'not called'))
  res
}



library(gridExtra)
zoomgp = function(curve.df, labels.df, zoom.xy=.9, zoom.br=.02, heights=c(1,1.1), annot=FALSE){
  zout = ggplot(curve.df, aes(x=recall, y=precision, colour=method))
  if(annot){
    zout = zout +
      annotate('rect', xmin=zoom.xy, xmax=1, ymin=zoom.xy, ymax=1, alpha=0, colour='black',
               linetype=2, size=.3)
  }
  zout = zout + 
    geom_path(aes(linetype=region), size=1, alpha=.8) + 
    ## geom_point(size=.8) +
    ## geom_label_repel(aes(label=method), data=label.df) + 
    geom_point(aes(shape=region), size=3, data=label.df) + 
    theme_bw() +
    facet_grid(.~type) +
    theme(legend.position='bottom') +
    labs(x='Recall', y='Precision', color='Method', shape='Genomic regions', linetype='Genomic regions') + 
    scale_x_continuous(breaks=seq(0,1,.2), limits=c(0,1)) + 
    scale_y_continuous(breaks=seq(0,1,.2), limits=c(0,1)) +
    scale_linetype_manual(values=c(3,1)) + 
    scale_colour_manual(values=pal.tools) +
    guides(colour=FALSE, linetype=FALSE, shape=FALSE)
  if(annot){
    ## One arrow
    ## zout = zout + annotate('segment', x=zoom.xy+(1-zoom.xy)/2, xend=zoom.xy,
    ##                        y=zoom.xy, yend=0, linetype=2,
    ##                        arrow=arrow(length=unit(0.2,"cm")))
    ## two lines
    ## zout = zout +
    ##   annotate('segment', x=zoom.xy, xend=0,
    ##            y=zoom.xy, yend=.1, linetype=2) + 
    ##   annotate('segment', x=1, xend=1,
    ##            y=zoom.xy, yend=.1, linetype=2)
  }
  zin = ggplot(curve.df, aes(x=recall, y=precision, colour=method))
  if(annot){
    zin = zin +
      annotate('rect', xmin=zoom.xy, xmax=1, ymin=zoom.xy, ymax=1, alpha=0, colour='black',
               linetype=2, size=.3)
  }
  zin = zin + 
    geom_path(aes(linetype=region), size=1, alpha=.8) + 
    ## geom_point(size=.8) +
    ## geom_label_repel(aes(label=method), data=label.df) + 
    geom_point(aes(shape=region), size=3, data=label.df) + 
    theme_bw() +
    facet_grid(.~type) +
    theme(legend.position='bottom') +
    labs(x='Recall', y='Precision', color='Method', shape='Genomic regions', linetype='Genomic regions') + 
    scale_x_continuous(breaks=seq(0,1,zoom.br), limits=c(zoom.xy,1)) + 
    scale_y_continuous(breaks=seq(0,1,zoom.br), limits=c(zoom.xy,1)) +
    scale_linetype_manual(values=c(3,1)) + 
    scale_colour_manual(values=pal.tools)
  grid.arrange(zout, zin, ncol=1, nrow=2, heights=heights)
}
