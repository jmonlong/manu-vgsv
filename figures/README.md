A place to put the data and scripts for figures.

For now the figures are copied to the `content/images` folder. 

```sh
Rscript hgsvc-figures.R
Rscript yeast-figures.R

rsync -v *.svg ../content/images/
```
