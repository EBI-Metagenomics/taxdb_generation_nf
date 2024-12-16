#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2024 EMBL - European Bioinformatics Institute
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
import gzip
import re
from pathlib import Path


def convert_to_tsv(gz_file_path: Path, output_file_name: Path) -> Path:
    with gzip.open(gz_file_path, "rt") as file_in, open(output_file_name, "w") as file_out:
        input_text = file_in.read()
        pattern = re.compile(
            r"ENTRY\s+(\S+)\nDEFINITION\s+(.+?)\nEQUATION\s+(.+?)(?:\nENZYME\s+(.+?))?\n///",
            re.DOTALL
        )
        matches = pattern.findall(input_text)
          writer = csv.writer(file_out, delimiter='\t')
          writer.writerow(['ENTRY', 'DEFINITION', 'EQUATION', 'ENZYME'])
          for match in matches:
              entry, definition, equation, enzyme = match
              enzyme = " ".join(enzyme.strip().split()) if enzyme else ""
              writer.writerow([entry, definition, equation, enzyme])

    return output_file_name

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert rhea-reactions.txt.gz to Rhea-CHEBI mapping in TSV format.')
    parser.add_argument('input_file', type=Path, help='Path to the rhea-reactions.txt.gz file')
    parser.add_argument('output_file', type=Path, help='Name of the output TSV file')
    args = parser.parse_args()
    
    convert_to_tsv(args.input_file, args.output_file)

