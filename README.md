# 2018_minor_millets
Code for GBS and analysis of Kodo, Proso, and Little millets from Johnson et al 2019, Genome-wide Population Structure Analyses of Three Minor Millets

These scripts are for parsing the raw Illumina sequence data from Johnson et al 2019 into SNP calls using the TASSEL GBSv2 pipeline (https://bitbucket.org/tasseladmin/tassel-5-source/wiki/Tassel5GBSv2Pipeline). Keyfiles for each species are provided.

These scripts were last tested with TASSEL 5.2.26 and Python 3.5.2

**Note 1:** TASSEL version appears to have a minor impact on resulting Hapmap file and SNP calls. Sometimes the order of SNPs/samples is altered and a (very) small number of sites with ambiguous genotype calls get swapped. In our testing the resulting genetic distances among the samples always match out to 3-4 decimal places, so any changes appear extremely minor.

**Note: 2:** TASSEL version 5.2.26 is assumed to be the one used to originally generate the hapmap files from Johnson et al. (it had been upgraded several times by the time the paper was written up); it may have actually been a few versions earlier, but any versioning differences appear to be extremely minor, as explained above
