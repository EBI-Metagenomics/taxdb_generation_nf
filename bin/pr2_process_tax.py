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

def parse_args():

    parser = argparse.ArgumentParser()

    parser.add_argument("-t", "--tax", required=True, type=str, help="Path to PR2 tax file")
    parser.add_argument("-o", "--out", required=True, type=str, help="Path to output file")

    args = parser.parse_args()
  
    _TAX = args.tax
    _OUT = args.out

    return _TAX, _OUT

def main():
    
    _TAX, _OUT = parse_args()

    # PR2 has 9 taxonomic ranks
    ranks = ["d__", "sg__", "dv__", "sdv__", "c__", "o__", "f__", "g__", "s__"]

    tax_df = pd.read_csv(_TAX, sep="\t", header=None)
    tax_df = tax_df.iloc[:, :10] # Remove last column which is only NaNs 
    tax_df.columns = ["id"] + ranks # Add column names

    for rank in ranks:
        tax_df[rank] = tax_df.apply(lambda row : f'{rank}{row[rank]}', axis=1)

    # combine the different rank columns into one ;-seperated column
    tax_df['combined'] = tax_df[ranks].apply(lambda row: ';'.join(row.values.astype(str)), axis=1)
    
    final_tax_df = tax_df.loc[:, ["id", "combined"]]
    final_tax_df.to_csv(_OUT, header=False, index=False, sep="\t")

if __name__ == "__main__":
    main()