---
author-meta:
- Glenn Hickey
- David Heller
- Jean Monlong
- Benedict Paten
date-meta: '2019-01-22'
keywords:
- structural variation
- pangenome
- variant genotyping
lang: en-US
title: Genotyping structural variation in variation graphs with the vg toolkit
...







<small><em>
This manuscript
([permalink](https://jmonlong.github.io/manu-vgsv/v/2e0caef1fe69af1cc8232e14eb8a669880bc5fcd/))
was automatically generated
from [jmonlong/manu-vgsv@2e0caef](https://github.com/jmonlong/manu-vgsv/tree/2e0caef1fe69af1cc8232e14eb8a669880bc5fcd)
on January 22, 2019.
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



## Methods



## Discussion



## References {.page_break_before}

<!-- Explicitly insert bibliography here -->
<div id="refs"></div>
