#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2025 EMBL - European Bioinformatics Institute
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

import argparse
import csv
import gzip
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


GA_THRESHOLD = 25.00


def create_desc_line(knum: str, ko_data: dict[str, dict[str, str]]) -> str:
    """Generate DESC line for the given KO id."""
    return f"DESC  {ko_data[knum]['definition']}\n"


def create_ga_line(knum: str, ko_data: dict[str, dict[str, str]]) -> str:
    """Generate GA line based on profile type for the given KO id."""
    threshold = ko_data[knum]['threshold']
    score_type = ko_data[knum]['score_type']
    
    if score_type == 'domain':
        return f"GA    {threshold} {threshold}\n"
    elif score_type == 'full':
        return f"GA    {threshold} {GA_THRESHOLD}\n"
    else:
        raise ValueError(f"Unknown profile type {score_type} for KO {knum}.")


def modify_hmm_profile(hmm_file: Path, ko_data: dict[str, dict[str, str]]):
    """
    Modifies an HMM profile by adding DESC and GA lines and writes to a new file.
    """
    logging.info(f"Modifying HMM profile: {hmm_file}")

    # Read the content of the HMM profile
    with hmm_file.open('r') as f:
        lines = f.readlines()

    # Find the KO id from the 'NAME' line
    name_line = next((line for line in lines if line.startswith('NAME')), None)
    if not name_line:
        raise ValueError(f"HMM {hmm_file} is missing the 'NAME' line")
    ko_id = name_line.split()[1]
    if ko_id not in ko_data:
        logging.warning(f"KO {ko_id} not found in KO list, skipping.")
        return
    
    desc_line = create_desc_line(ko_id, ko_data)
    ga_line = create_ga_line(ko_id, ko_data)

    # Insert DESC line between NAME and LENG
    for i, line in enumerate(lines):
        if line.startswith('LENG'):
            lines.insert(i, desc_line)
            break
    
    # Insert GA line between CKSUM and STATS
    for i, line in enumerate(lines):
        if line.startswith('STATS'):
            lines.insert(i, ga_line)
            break

    # Write the modified content to the new output file
    output_file = Path(hmm_file.stem + '.modified.hmm')
    with output_file.open('w') as f:
        f.writelines(lines)

    logging.info(f"Successfully modified and saved to: {output_file}")



def process_hmm_files(hmm_input: Path, ko_data: dict[str, dict[str, str]]):
    """
    Processes a directory or a single HMM file and modifies them according to the KO data.
    """
    if hmm_input.is_dir():
        logging.info(f"Processing HMM files in directory: {hmm_input}")
        for hmm_file in hmm_input.glob('*.hmm'):
            modify_hmm_profile(hmm_file, ko_data)
    elif hmm_input.is_file() and hmm_input.suffix == '.hmm':
        logging.info(f"Processing single HMM file: {hmm_input}")
        modify_hmm_profile(hmm_input, ko_data)
    else:
        logging.error(f"Invalid input: {hmm_input} is not a directory or a .hmm file")


def main():
    parser = argparse.ArgumentParser(description="Add metadata (description and threshold) from ko_list file to the given HMM profiles")
    parser.add_argument('ko_list', type=Path, help='Path to the ko_list or ko_list.gz file')
    parser.add_argument('hmm_input', type=Path, help='Path to a directory of HMM profiles or a single HMM profile (expected *.hmm file(s))')
    args = parser.parse_args()

    # Step 1: Parse the KO list
    logging.info(f"Parsing KO list file: {args.ko_list}")
    open_func = gzip.open if args.ko_list.suffix == '.gz' else open
    ko_data = {}
    with open_func(args.ko_list, 'rt') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            knum = row['knum']
            threshold = row['threshold']
            score_type = row['score_type']
            definition = row['definition']
            # Only include entries that have valid 'domain' or 'full' profile type
            if score_type in ['domain', 'full']:
                ko_data[knum] = {
                    'threshold': threshold,
                    'score_type': score_type,
                    'definition': definition
                }
    logging.info(f"Parsed {len(ko_data)} KO entries.")
    
    # Step 2: Modify HMM profiles
    process_hmm_files(args.hmm_input, ko_data)
    
    logging.info("Processing complete!")


if __name__ == '__main__':
    main()
