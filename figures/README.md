A place to put the data and scripts for figures.

For now the figures are copied to the `content/images` folder. 

```sh
Rscript simerror-figures.R
Rscript hgsvc-figures.R
Rscript yeast-figures.R

rsync -v *.svg ../content/images/
rsync -v figures/*.svg ../content/images/
```
