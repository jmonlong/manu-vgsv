---
author-meta:
- Glenn Hickey
- David Heller
- Jean Monlong
- Benedict Paten
date-meta: '2019-02-13'
keywords:
- structural variation
- pangenome
- variant genotyping
lang: en-US
title: Genotyping structural variation in variation graphs with the vg toolkit
...







<small><em>
This manuscript
([permalink](https://jmonlong.github.io/manu-vgsv/v/e503b6a8105e2e9b81bd689aa91d22272b333a09/))
was automatically generated
from [jmonlong/manu-vgsv@e503b6a](https://github.com/jmonlong/manu-vgsv/tree/e503b6a8105e2e9b81bd689aa91d22272b333a09)
on February 13, 2019.
</em></small>

## Authors


[![ORCID icon](images/orcid.svg){height="11px" width="11px"}](https://orcid.org/XXXX-XXXX-XXXX-XXXX)
Glenn Hickey<sup>1,☯</sup>,
[![ORCID icon](images/orcid.svg){height="11px" width="11px"}](https://orcid.org/XXXX-XXXX-XXXX-XXXX)
David Heller<sup>1,☯</sup>,
[![ORCID icon](images/orcid.svg){height="11px" width="11px"}](https://orcid.org/XXXX-XXXX-XXXX-XXXX)
Jean Monlong<sup>1,☯</sup>,
[![ORCID icon](images/orcid.svg){height="11px" width="11px"}](https://orcid.org/XXXX-XXXX-XXXX-XXXX)
Benedict Paten<sup>1,†</sup>

<sup>☯</sup> --- These authors contributed equally to this work

<sup>†</sup> --- To whom correspondence should be addressed: bpaten@ucsc.edu
<small>


1. UC Santa Cruz Genomics Institute, University of California, Santa Cruz, California, USA

</small>


## Abstract {.page_break_before}




## Introduction {.page_break_before}

Structural variation (SV) represents genomic mutation involving 50 bp or more and can take several forms, such as for example deletions, insertions, inversions, or translocations.
Although whole-genome sequencing (WGS) made it possible to assess virtually any type of structural variation, many challenges remain.
In particular, SV-supporting reads are difficult to map to reference genomes.
Multi-mapping, caused by widespread repeated sequences in the genome, is another issue because it often resembles SV-supporting signal.
As a result, many SV detection algorithms have been developed and multiple methods must usually be combined to minimize false positives.
Several large-scale projects used this ensemble approach, cataloging tens of thousands of SV in humans[@qA6dWFP; @py6BC5kj].
SV detection from short-read sequencing remains laborious and of lower accuracy, explaining why these variants and their impact have been under-studied as compared to single-nucleotide variants (SNVs) and small insertions/deletions (indels).

Over the last few years, exciting developments in sequencing technologies and library preparation made it possible to produce long reads or retrieve long-range information over kilobases of sequence.
These approaches are maturing to the point were it is feasible to analyze the human genome.
This multi-kbp information is particularly useful for SV detection and de novo assembly.
In the last few years, several studies using long-read or linked-read sequencing have produced large catalogs of structural variation, the majority of which were novel and sequence-resolved[@z91V6jjU; @rs7e40wC; @PRx3qEIm; @121OWcTA4; @3NNFS6U2].
These technologies are also enabling high-quality de novo genome assemblies to be produced[@z91V6jjU; @6KbgcueR], as well as large blocks of haplotype-resolved sequences[@Pu6SY37C].
These technological advances promise to expand the amount of known genomic variation in humans in the near future.

In parallel, the reference genome is evolving from a linear reference to a graph-based reference that contains known genomic variation[@Qa8mx6Ll; @10jxt15v0; @11Jy8B61m].
By having variants in the graph, mapping rates are increased and variants are more uniformly covered, including indels and variants in complex regions[@10jxt15v0].
Both the mapping and variant calling become variant-aware and benefit in term of accuracy and sensitivity.
In addition, different variant types are called simultaneously by a unified framework.
Graphs have also been used locally, i.e. to call variants at the region level.
GraphTyper[@ohTIiqfV] and BayesTyper[@14Uxmwbxm] both construct variation graphs of small regions and use them for variant genotyping.
Here again, the graph-approach showed clear advantages over standard approaches that use the linear reference.
Other SV genotyping approaches compare read mapping in the reference genome and a sequence modified with the SV. 
For example SMRT-SV was designed to genotype SVs identified on PacBio reads[@rs7e40wC], SVTyper uses paired-end mapping and split-read mapping information[@AltPnocw], and Delly provides a genotyping feature in addition to its discovery mode[@nLvQCjXU].




## Results

### Structural variation in vg

In addition to SNV and short indels, vg can handle large deletions and insertions (and inversion?) (Figure {@fig:cartoon}).
As a proof-of-concept we simulated genomes and SVs of varying sizes.
Some errors were added at the breakpoints to investigate their effect on genotyping.
In all simulations, vg performed better than SVtyper[@AltPnocw] and Delly[@nLvQCjXU] (Figure {@fig:sim}).
The recall was particularly higher than other methods at low sequencing depth.
vg was also more robust to errors around the breakpoints, performing almost as well as in the absence of errors.

![**Large deletions and insertions in variation graphs**](images/VGSVcartoon.jpg){#fig:cartoon}

![**Simulation experiment**. For each experiment (method, depth and input VCF with/without erros), the deciles of the call qualities were used as threshold and the maximum F1 is reported on the y-axis.](images/simerror.svg){#fig:sim width=80%}

### HGSVC

Chaisson et al.[@vQTymKCj] provide a high-quality SV catalog of three samples, obtained using a consensus from different sequencing, phasing and variant caling technologies. 



#### (Whole-genome) Simulation

The phasing information in the HGSVC VCF was used to extract two haplotypes for sample HG00514, and 30X pairend-end reads were simulated using vg sim.  The reads were used to call VCFs then compared back to the original HGSVC calls (Figure {@fig:hgsvc-sim} and Table {@tbl:hgsvc-sim}).

When restricting the comparisons to regions not identified as tandem repeats or segmental duplications in the Genome Browser (Table {@tbl:hgsvc-sim-nonrepeat}).


![**HGSVC simulated reads**. ](images/hgsvc-sim.svg){#fig:hgsvc-sim width=80%}

![**HGSVC real reads**. ](images/hgsvc-real.svg){#fig:hgsvc-real width=80%}

#### (Whole-genome) Real reads

Figure {@fig:hgsvc-real}. 
Tables {@tbl:hgsvc-real} and {@tbl:hgsvc-real-nonrepeat} for results over the genome or when restricting the comparisons to regions not identified as tandem repeats or segmental duplications in the Genome Browser.


 
### Genotyping SV using vg and de novo assemblies

We investigated whether genome graphs derived from genome-genome alignments yield advantages for SV genotyping.
To this end, we analyzed public sequencing datasets for 12 yeast strains from two clades (S. cerevisiae and S. paradoxus) [@7f5OKa5O].
From these datasets, we generated two different types of genome graphs.
The first graph type (in the following called *construct graph*) was created from a linear reference genome of the S.c. S288C strain and a set of SVs relative to this reference strain in VCF format.
We compiled the SV set using the output of three methods for SV detection from genome assemblies: Assemblytics [@krO7WgVi], AsmVar [@oVaXIwl5] and paftools [@172cJaw4Q].
All three methods were run to detect SVs between the reference strain S.c. S288C and each of the other 11 strains.
Merging the results from the three methods and the 11 strains provided us with a high-sensitivity set of SVs occuring in the two yeast clades.
We used this set to construct the *construct graph*.
The second graph (in the following called *cactus graph*) was derived from a multiple genome alignment of all 12 strains using our Cactus tool [@1FgS53pXi].
While the *construct graph* is still mainly linear and highly dependent on the reference genome, the cactus graph is completely unbiased in that regard.

![**Mapping quality comparison.** The fraction of reads mapped (with different mapping quality thresholds) to the cactus graph (y-axis) and the construct graph (x-axis) are compared](images/yeast-mapping-quality.svg){#fig:mapping-qual-comp width=80%}

![**Mapping identity comparison.** The fraction of reads mapped (with different percent identity thresholds) to the cactus graph (y-axis) and the construct graph (x-axis) are compared](images/yeast-mapping-identity.svg){#fig:mapping-id-comp width=80%}

In a first step, we tested our hypothesis that the *cactus graph* has higher mappability due to its better representation of sequence diversity among the yeast strains.
When mapping short Illumina reads from the 12 strains to both graphs, we indeed observed a higher fraction of reads mapped to the *cactus graph* than to the *construct graph* (see Fig. @fig:mapping-qual-comp).
Only for the reference strain S.c. S288C, both graphs exhibited similar mappability.
This suggests that not the higher sequence content in the *cactus graph*  alone (XX Mb compared to XX Mb in the *construct graph*) drives the improvement in mappability.
Instead, our measurements suggest that genetic distance to the reference strain increases the advantage of the *cactus graph* over the *construct graph*.
Consequently. the gap is largest for strains in the S. paradoxus clade and smaller for reads from strains in the S. cerevisiae clade.


![**SV genotyping comparison.** SV genotype recall from the *cactus graph* (y-axis) and *construct graph* (x-axis) are compared. Colors and shapes represent the 12 strains and two clades, respectively](images/yeast-recall.svg){#fig:geno-comp-recall width=80%}

![**SV genotyping comparison.** SV genotype precision from the *cactus graph* (y-axis) and *construct graph* (x-axis) are compared. Colors and shapes represent the 12 strains and two clades, respectively](images/yeast-precision.svg){#fig:geno-comp-precision width=80%}

Next, we compared the SV genotype performance of both graphs.
To facilitate a fair evaluation of genotype performance, we combined all SVs that were detected by at least two of the three SV callers (Assemblytics, AsmVar and paftools) into a truth set.
This truth set is a subset of the SV set used for construction of the *construct graph* which is important because only variants already present in the graph can be genotyped.

Figure {@fig:geno-comp-recall} and {@fig:geno-comp-precision} shows the results of our analysis. Depending on the clade, the *cactus graph* reaches either a substantially higher SV genotyping recall than the *construct graph* (S. paradoxus) or a substantially lower recall (S. cerevisiae).




## Methods



## Discussion



## Supplementary Material

| Graph               | type  | TP    | TP.baseline | FP    | FN    | precision | recall | F1     |
| -----               | ----- | ----- | -----       | ----- | ----- | -----     | -----  | ---    |
| HGSVC-Construct     | Total | 24451 | 24089       | 3119  | 2617  | 0.8854    | 0.902  | 0.8936 |
|                     | INS   | 14596 | 14264       | 775   | 1421  | 0.9485    | 0.9094 | 0.9285 |
|                     | DEL   | 9855  | 9825        | 2344  | 1196  | 0.8074    | 0.8915 | 0.8474 |
|                     |       |       |             |       |       |           |        |        |
| HGSVC-1KG-Construct | Total | 24172 | 23815       | 3236  | 2891  | 0.8804    | 0.8917 | 0.886  |
|                     | INS   | 14540 | 14111       | 836   | 1574  | 0.9441    | 0.8996 | 0.9213 |
|                     | DEL   | 9632  | 9704        | 2400  | 1317  | 0.8017    | 0.8805 | 0.8393 |
|                     |       |       |             |       |       |           |        |        |
|HGSVC-Bayestyper     | Total | 13895 | 14362       | 123   | 12344 | 0.9915    | 0.5378 | 0.6974 |
|                     | INS   | 8473  | 8757        | 102   | 6928  | 0.9885    | 0.5583 | 0.7136 |
|                     | DEL   | 5422  | 5605        | 21    | 5416  | 0.9963    | 0.5086 | 0.6734|
|                     |       |       |             |       |       |           |        |        |
| SVPOP-Construct     | Total | 10548 | 11559       | 5990  | 15147 | 0.6587    | 0.4328 | 0.5224 |
|                     | INS   | 7733  | 8223        | 2266  | 7462  | 0.784     | 0.5243 | 0.6284 |
|                     | DEL   | 2815  | 3336        | 3724  | 7685  | 0.4725    | 0.3027 | 0.369  |
|                     |       |       |             |       |       |           |        |        |
| SVPOP-1KG-Construct | Total | 10403 | 11369       | 6750  | 15337 | 0.6275    | 0.4257 | 0.5073 |
|                     | INS   | 7497  | 7934        | 2198  | 7751  | 0.7831    | 0.5058 | 0.6146 |
|                     | DEL   | 2906  | 3435        | 4552  | 7586  | 0.4301    | 0.3117 | 0.3615 |

Table: HGSVC experiment using simulated reads. {#tbl:hgsvc-sim}

---

| Graph               | type  | TP    | TP.baseline | FP    | FN    | precision | recall | F1     |
| -----               | ----- | ----- | -----       | ----- | ----- | -----     | -----  | ---    |
| HGSVC-Construct     | Total | 5901  | 5822        | 452   | 253   | 0.928     | 0.9584 | 0.943  |
|                     | INS   | 4026  | 3952        | 98    | 172   | 0.9758    | 0.9583 | 0.967  |
|                     | DEL   | 1875  | 1870        | 354   | 81    | 0.8408    | 0.9585 | 0.8958 |
|                     |       |       |             |       |       |           |        |        |
| HGSVC-1KG-Construct | Total | 5880  | 5785        | 486   | 290   | 0.9225    | 0.9523 | 0.9372 |
|                     | INS   | 4024  | 3922        | 123   | 202   | 0.9696    | 0.951  | 0.9602 |
|                     | DEL   | 1856  | 1863        | 363   | 88    | 0.8369    | 0.9549 | 0.892  |
|                     |       |       |             |       |       |           |        |        |
| HGSVC-Bayestyper    | Total | 3805  | 3863        | 8     | 2212  | 0.9979    | 0.6359 | 0.7768 |
|                     | INS   | 2401  | 2430        | 6     | 1694  | 0.9975    | 0.5892 | 0.7408 |
|                     | DEL   | 1404  | 1433        | 2     | 518   | 0.9986    | 0.7345 | 0.846  |
|                     |       |       |             |       |       |           |        |        |
| SVPOP-Construct     | Total | 3565  | 3856        | 390   | 2219  | 0.9081    | 0.6347 | 0.7472 |
|                     | INS   | 3091  | 3246        | 239   | 878   | 0.9314    | 0.7871 | 0.8532 |
|                     | DEL   | 474   | 610         | 151   | 1341  | 0.8016    | 0.3127 | 0.4499 |
|                     |       |       |             |       |       |           |        |        |
| SVPOP-1KG-Construct | Total | 3574  | 3817        | 562   | 2258  | 0.8717    | 0.6283 | 0.7303 |
|                     | INS   | 3066  | 3180        | 253   | 944   | 0.9263    | 0.7711 | 0.8416 |
|                     | DEL   | 508   | 637         | 309   | 1314  | 0.6734    | 0.3265 | 0.4398 |

Table: HGSVC experiment using simulated reads and restricting the comparisons to non-repeat regions. {#tbl:hgsvc-sim-nonrepeat}

---

| Graph               | type  | TP    | TP.baseline | FP    | FN    | precision | recall | F1     |
| -----               | ----- | ----- | -----       | ----- | ----- | -----     | -----  | ---    |
| HGSVC-Construct     | Total | 18436 | 18500       | 6575  | 8206  | 0.7378    | 0.6927 | 0.7145 |
|                     | INS   | 10984 | 10600       | 3542  | 5085  | 0.7495    | 0.6758 | 0.7107 |
|                     | DEL   | 7452  | 7900        | 3033  | 3121  | 0.7226    | 0.7168 | 0.7197 |
|                     |       |       |             |       |       |           |        |        |
| HGSVC-1KG-Construct | Total | 17802 | 17946       | 6221  | 8760  | 0.7426    | 0.672  | 0.7055 |
|                     | INS   | 10647 | 10262       | 3304  | 5423  | 0.7564    | 0.6543 | 0.7017 |
|                     | DEL   | 7155  | 7684        | 2917  | 3337  | 0.7248    | 0.6972 | 0.7107 |
|                     |       |       |             |       |       |           |        |        |
| HGSVC-Bayestyper    | Total | 4342  | 4840        | 1048  | 21866 | 0.822     | 0.1812 | 0.2969 |
|                     | INS   | 1786  | 1883        | 309   | 13802 | 0.859     | 0.1201 | 0.2107 |
|                     | DEL   | 2556  | 2957        | 739   | 8064  | 0.8001    | 0.2683 | 0.4018 |
|                     |       |       |             |       |       |           |        |        |
| SVPOP-Construct     | Total | 9091  | 9931        | 10235 | 16775 | 0.4925    | 0.3719 | 0.4238 |
|                     | INS   | 6972  | 7420        | 6706  | 8265  | 0.5253    | 0.4731 | 0.4978 |
|                     | DEL   | 2119  | 2511        | 3529  | 8510  | 0.4157    | 0.2278 | 0.2943 |

Table: HGSVC experiment using real reads. {#tbl:hgsvc-real}

---

| Graph               | type  | TP    | TP.baseline | FP    | FN    | precision | recall | F1     |
| -----               | ----- | ----- | -----       | ----- | ----- | -----     | -----  | ---    |
| HGSVC-Construct     | Total | 5197  | 5244        | 854   | 831   | 0.86      | 0.8632 | 0.8616 |
|                     | INS   | 3708  | 3626        | 459   | 498   | 0.8876    | 0.8792 | 0.8834 |
|                     | DEL   | 1489  | 1618        | 395   | 333   | 0.8038    | 0.8293 | 0.8164 |
|                     |       |       |             |       |       |           |        |        |
| HGSVC-1KG-Construct | Total | 5103  | 5155        | 865   | 920   | 0.8563    | 0.8486 | 0.8524 |
|                     | INS   | 3642  | 3555        | 464   | 569   | 0.8845    | 0.862  | 0.8731 |
|                     | DEL   | 1461  | 1600        | 401   | 351   | 0.7996    | 0.8201 | 0.8097 |
|                     |       |       |             |       |       |           |        |        |
| HGSVC-Bayestyper    | Total | 1560  | 1731        | 274   | 4344  | 0.8633    | 0.2849 | 0.4284 |
|                     | INS   | 883   | 901         | 69    | 3223  | 0.9289    | 0.2185 | 0.3538 |
|                     | DEL   | 677   | 830         | 205   | 1121  | 0.8019    | 0.4254 | 0.5559 |
|                     |       |       |             |       |       |           |        |        |
| SVPOP-Construct     | Total | 3251  | 3480        | 941   | 2595  | 0.7872    | 0.5728 | 0.6631 |
|                     | INS   | 2859  | 3009        | 780   | 1115  | 0.7941    | 0.7296 | 0.7605 |
|                     | DEL   | 392   | 471         | 161   | 1480  | 0.7453    | 0.2414 | 0.3647 |

Table: HGSVC experiment using real reads and restricting the comparisons to non-repeat regions. {#tbl:hgsvc-real-nonrepeat}


## References {.page_break_before}

<!-- Explicitly insert bibliography here -->
<div id="refs"></div>
