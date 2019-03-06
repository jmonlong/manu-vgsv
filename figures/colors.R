library(RColorBrewer)

tools = c('vg-construct', 'BayesTyper', 'svtyper', 'Delly', 'SMRT-SV2')
pal.tools = brewer.pal(length(tools), 'Set1')
names(pal.tools) = tools
