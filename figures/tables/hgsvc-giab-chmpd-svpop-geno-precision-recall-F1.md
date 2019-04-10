|experiment            |method     |type |precision     |recall        |F1            |
|:---------------------|:----------|:----|:-------------|:-------------|:-------------|
|HGSVC simulated reads |vg         |INS  |0.795 (0.885) |0.796 (0.883) |0.795 (0.884) |
|HGSVC simulated reads |vg         |DEL  |0.869 (0.971) |0.771 (0.92)  |0.817 (0.945) |
|HGSVC simulated reads |BayesTyper |INS  |0.91 (0.935)  |0.835 (0.9)   |0.871 (0.917) |
|HGSVC simulated reads |BayesTyper |DEL  |0.898 (0.981) |0.806 (0.929) |0.849 (0.954) |
|HGSVC simulated reads |SVTyper    |DEL  |0.809 (0.876) |0.328 (0.754) |0.467 (0.81)  |
|HGSVC simulated reads |Delly      |INS  |0.767 (0.866) |0.093 (0.225) |0.166 (0.358) |
|HGSVC simulated reads |Delly      |DEL  |0.696 (0.903) |0.707 (0.846) |0.701 (0.874) |
|HGSVC real reads      |vg         |INS  |0.431 (0.683) |0.541 (0.726) |0.48 (0.704)  |
|HGSVC real reads      |vg         |DEL  |0.65 (0.886)  |0.519 (0.708) |0.577 (0.787) |
|HGSVC real reads      |BayesTyper |INS  |0.601 (0.747) |0.254 (0.433) |0.357 (0.549) |
|HGSVC real reads      |BayesTyper |DEL  |0.627 (0.91)  |0.325 (0.381) |0.428 (0.537) |
|HGSVC real reads      |SVTyper    |INS  |NaN (NaN)     |0 (0)         |0 (0)         |
|HGSVC real reads      |SVTyper    |DEL  |0.661 (0.733) |0.236 (0.551) |0.348 (0.629) |
|HGSVC real reads      |Delly      |INS  |0.516 (0.621) |0.068 (0.176) |0.12 (0.275)  |
|HGSVC real reads      |Delly      |DEL  |0.55 (0.838)  |0.445 (0.547) |0.492 (0.662) |
|GiaB                  |vg         |INS  |0.658 (0.774) |0.646 (0.735) |0.652 (0.754) |
|GiaB                  |vg         |DEL  |0.68 (0.768)  |0.643 (0.735) |0.661 (0.751) |
|GiaB                  |BayesTyper |INS  |0.776 (0.879) |0.286 (0.379) |0.418 (0.53)  |
|GiaB                  |BayesTyper |DEL  |0.808 (0.886) |0.512 (0.696) |0.627 (0.779) |
|GiaB                  |SVTyper    |DEL  |0.742 (0.818) |0.342 (0.496) |0.468 (0.618) |
|GiaB                  |Delly      |INS  |0.822 (0.894) |0.177 (0.268) |0.291 (0.412) |
|GiaB                  |Delly      |DEL  |0.722 (0.822) |0.645 (0.768) |0.681 (0.794) |
|CHM-PD                |vg         |INS  |0.665 (0.806) |0.661 (0.784) |0.663 (0.795) |
|CHM-PD                |vg         |DEL  |0.688 (0.869) |0.5 (0.762)   |0.579 (0.812) |
|CHM-PD                |SMRT-SV2   |INS  |0.757 (0.88)  |0.536 (0.68)  |0.628 (0.767) |
|CHM-PD                |SMRT-SV2   |DEL  |0.848 (0.971) |0.63 (0.824)  |0.723 (0.891) |
