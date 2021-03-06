# Exploratory Analysis of Graph Data by Leveraging Domain Knowledge

**This is the code repository for the paper: [Exploratory Analysis of Graph Data by Leveraging Domain Knowledge](http://web.eecs.umich.edu/~dkoutra/papers/17_EAGLE_ICDM.pdf)**

By [Di Jin](http://www-personal.umich.edu/~dijin/), [Danai Koutra](http://web.eecs.umich.edu/~dkoutra/).

"Summarize an unknown graph from known ones."

## Table of Contents
- [DATA](#DATA)
- [analysis](#analysis)
- [extra_Features](#extra_Features)
- [lib](#lib)
- [processed](#processed)
- [records](#records)
- [src](#src)


## DATA
The data directory contains "real_train", the directory containing raw files of the domain knowledge (known graphs) and "real_test", the directory containing the input unknown graph file.

## analysis (and supplementary results to the paper)
The directory with experiments conducted in the paper. To run the experiments, run "exp_effectiveness", "exp_scalability_1", "exp_scalability_2" and "exp_sensitivity". For example, the evaluation of the diversity and domain-specificity of the graph invariant distributions selected by EAGLE and the baselines is conducted with the command
```shell
$ exp_effectiveness
``` 

The supplementary results of `Satisfaction of Desired Properties` (Section V, part D) from the paper can be obtained by running the same script with different correlation metrics. To be specific, the first figure shows the evaluation based on correlation using Pearson correlation ![Pearson](imgs/pearson.png) which is the figure in the paper. The second figure shows the evaluation based on correlation using Kendall's tau. ![Kendall's tau](imgs/Kendall.png) The third figure shows the evaluation based on correlation using Spearman's rank correlation. ![Spearman](imgs/spearman.png) As stated in the paper, in all three cases we observe that EAGLE outperforms the baseline methods.

## extra_Features
The directory contains the extra graph invariants computed through [SNAP](http://snap.stanford.edu/snap/index.html). 

## lib
- matlab_bgl: This library is adopted from the Internet written by David Gleich (https://www.cs.purdue.edu/homes/dgleich/packages/matlab_bgl/).
- util: This library contains several toolkits used in this project.

## processed
This directory contains the processed raw graphs in the format to run EAGLE. 

## records
This directory contains the stored experimental results in the paper conducted with scripts in [analysis](#analysis).

## src

This code is built in MATLAB 2016a. The preprocessing procedure is time-consuming, the command to run without preprocessing the raw data files is:
```shell
$ main
``` 



