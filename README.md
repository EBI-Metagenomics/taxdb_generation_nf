# taxdb_generation_nf

Nextflow workflow used to generate various taxonomic reference database files in use by MGnify analysis pipelines.

## Databases included

- [SILVA](https://www.arb-silva.de/) (SSU + LSU)
- [PR2](https://pr2-database.org/) (SSU)
- [UNITE](https://unite.ut.ee/) (ITS)
- [ITSoneDB](https://itsonedb.cloud.ba.infn.it/) (ITS)
- [Rfam](https://rfam.org/) (rRNA covariance models)

## How to run

Simply run this command:

`nextflow run -main.nf`

The script will generate output like this, one subdirectory for each database:

```
├── ITSone
│   └── 1.141
│       ├── ITSone.fasta
│       ├── ITSone.otu
│       └── ITSone-tax.txt
├── PR2
│   └── 5.0.0
│       ├── PR2.fasta
│       ├── PR2.otu
│       └── PR2-tax.txt
├── RFAM
│   └── 14.10
│       ├── ribo.clan_info
│       └── ribo.cm
├── SILVA-LSU
│   └── 138.1
│       ├── SILVA-LSU.fasta
│       ├── SILVA-LSU.otu
│       └── SILVA-LSU-tax.txt
├── SILVA-SSU
│   └── 138.1
│       ├── SILVA-SSU.fasta
│       ├── SILVA-SSU.otu
│       └── SILVA-SSU-tax.txt
└── UNITE
    └── 9.0
        ├── UNITE.fasta
        ├── UNITE.otu
        └── UNITE-tax.txt
```

You may need to modify some values in the `nextflow.config` file to update a new version of the database, change output directory, etc. 