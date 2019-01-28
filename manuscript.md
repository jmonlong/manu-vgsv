---
author-meta:
- Glenn Hickey
- David Heller
- Jean Monlong
- Benedict Paten
date-meta: '2019-01-28'
keywords:
- structural variation
- pangenome
- variant genotyping
lang: en-US
title: Genotyping structural variation in variation graphs with the vg toolkit
...







<small><em>
This manuscript
([permalink](https://jmonlong.github.io/manu-vgsv/v/3cc1334d4a407c65d21fc7fcb63ba242322a23cc/))
was automatically generated
from [jmonlong/manu-vgsv@3cc1334](https://github.com/jmonlong/manu-vgsv/tree/3cc1334d4a407c65d21fc7fcb63ba242322a23cc)
on January 28, 2019.
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
In the last few years, several studies using long-read or linked-read sequencing have produced large catalogs of structural variation, the majority of which were novel and sequence-resolved[@z91V6jjU; @rs7e40wC; @PRx3qEIm; @121OWcTA4] (*REF_PETER_SOON*).
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

### HGSVC

Chaisson et al.[@vQTymKCj] provide a high-quality SV catalog of three samples, obtained using a consensus from different sequencing, phasing and variant caling technologies. 



#### (Whole-genome) Simulation

The phasing information in the HGSVC VCF was used to extract two haplotypes for sample HG00514, and 30X pairend-end reads were simulated using vg sim.  The reads were used to call VCFs then compared back to the original HGSVC calls.

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
| SVPOP-Construct     | Total | 10548 | 11559       | 5990  | 15147 | 0.6587    | 0.4328 | 0.5224 |
|                     | INS   | 7733  | 8223        | 2266  | 7462  | 0.784     | 0.5243 | 0.6284 |
|                     | DEL   | 2815  | 3336        | 3724  | 7685  | 0.4725    | 0.3027 | 0.369  |
|                     |       |       |             |       |       |           |        |        |
| SVPOP-1KG-Construct | Total | 10403 | 11369       | 6750  | 15337 | 0.6275    | 0.4257 | 0.5073 |
|                     | INS   | 7497  | 7934        | 2198  | 7751  | 0.7831    | 0.5058 | 0.6146 |
|                     | DEL   | 2906  | 3435        | 4552  | 7586  | 0.4301    | 0.3117 | 0.3615 |

When restricting the comparisons to regions not identified as tandem repeats or segmental duplications in the Genome Browser:

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
| SVPOP-Construct     | Total | 3565  | 3856        | 390   | 2219  | 0.9081    | 0.6347 | 0.7472 |
|                     | INS   | 3091  | 3246        | 239   | 878   | 0.9314    | 0.7871 | 0.8532 |
|                     | DEL   | 474   | 610         | 151   | 1341  | 0.8016    | 0.3127 | 0.4499 |
|                     |       |       |             |       |       |           |        |        |
| SVPOP-1KG-Construct | Total | 3574  | 3817        | 562   | 2258  | 0.8717    | 0.6283 | 0.7303 |
|                     | INS   | 3066  | 3180        | 253   | 944   | 0.9263    | 0.7711 | 0.8416 |
|                     | DEL   | 508   | 637         | 309   | 1314  | 0.6734    | 0.3265 | 0.4398 |

#### (Whole-genome) Real reads

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
| SVPOP-Construct     | Total | 9091  | 9931        | 10235 | 16775 | 0.4925    | 0.3719 | 0.4238 |
|                     | INS   | 6972  | 7420        | 6706  | 8265  | 0.5253    | 0.4731 | 0.4978 |
|                     | DEL   | 2119  | 2511        | 3529  | 8510  | 0.4157    | 0.2278 | 0.2943 |

When restricting the comparisons to regions not identified as tandem repeats or segmental duplications in the Genome Browser:

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
| SVPOP-Construct     | Total | 3251  | 3480        | 941   | 2595  | 0.7872    | 0.5728 | 0.6631 |
|                     | INS   | 2859  | 3009        | 780   | 1115  | 0.7941    | 0.7296 | 0.7605 |
|                     | DEL   | 392   | 471         | 161   | 1480  | 0.7453    | 0.2414 | 0.3647 |
 









## Methods



## Discussion



## References {.page_break_before}

<!-- Explicitly insert bibliography here -->
<div id="refs"></div>
