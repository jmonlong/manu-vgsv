A place to put the data and scripts for figures.

For now the figures are copied to the `content/images` folder. 
Depends on R, LaTeX and the following bash commands:  `pdftoppm`, `pdfcrop`

```sh
## Create PDF in pdf/
Rscript simerror-figures.R
Rscript hgsvc-figures.R
Rscript giab-figures.R
Rscript chmpd-figures.R
Rscript svpop-figures.R
Rscript hgsvc-giab-svpop-chmpd-combined.R
Rscript yeast-figures-all.R
Rscript yeast-figures-four.R
Rscript yeast-figures-genotyping.R

## Panels defined using LaTeX subfigures in panels.tex
pdflatex panels.tex
pdfcrop --margins 10 panels.pdf pdf/panels.pdf
rm panels.pdf panels.aux panels.log
for PAN in `seq 1 6`
do
    pdftoppm -png -f $PAN pdf/panels.pdf -r 300 > png/panel${PAN}.png
done

## Copy and convert to PNG only the files that we want
## (listed in 'includeInManuscript.txt), if more recent
make
```
