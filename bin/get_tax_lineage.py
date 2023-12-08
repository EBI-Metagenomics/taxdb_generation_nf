#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2023 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import argparse

import pandas as pd
import numpy as np

def parse_args():

    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--taxid", required=True, type=str, help="Path to taxids file")
    parser.add_argument("-d", "--taxdmp", required=True, type=str, help="Path to taxdump file from ENA (https://ftp.ebi.ac.uk/pub/databases/ena/taxonomy/)")
    parser.add_argument("-o", "--output", required=True, type=str, help="Output")

    args = parser.parse_args()

    _TAXID = args.taxid
    _TAXDMP = args.taxdmp
    _OUTPUT = args.output

    return _TAXID, _TAXDMP, _OUTPUT


def main():

    _INPUT, _TAXDMP, _OUTPUT = parse_args()
    
    taxids = [ line.strip() for line in list(open(_INPUT, 'r')) ]
    taxdmp_df = pd.read_csv(_TAXDMP, sep="\t", usecols=[0, 4], dtype=str)

    taxdmp_df_slice = taxdmp_df.loc[ taxdmp_df["taxonID"].isin(taxids) ]
    formatted_taxa = [ taxon.replace(';', '; ') for taxon in taxdmp_df_slice.higherClassification.to_list() ]
    taxdmp_df_slice.loc[:, "higherClassification"] = formatted_taxa

    final_taxids = pd.Index(taxids)
    final_taxids = final_taxids[final_taxids.isin(taxdmp_df_slice.taxonID)]

    taxdmp_df_slice = taxdmp_df_slice.set_index("taxonID").loc[final_taxids].reset_index()
    taxdmp_df_slice.to_csv(_OUTPUT, sep='\t', header=False, index=False)


if __name__ == "__main__":
    main()