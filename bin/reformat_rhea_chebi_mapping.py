#!/usr/bin/env python

import argparse
import gzip
import re
from pathlib import Path

def convert_to_tsv(gz_file_path: Path) -> Path:

    output_file_path = "rhea_chebi_mapping.tsv"

    # Process the .gz file and convert it to TSV
    with gzip.open(gz_file_path, "rt") as file_in, open(output_file_path, "w") as file_out:
        input_text = file_in.read()
        pattern = re.compile(
            r"ENTRY\s+(\S+)\nDEFINITION\s+(.+?)\nEQUATION\s+(.+?)(?:\nENZYME\s+(.+?))?\n///",
            re.DOTALL
        )
        matches = pattern.findall(input_text)
        file_out.write("ENTRY\tDEFINITION\tEQUATION\tENZYME\n")
        for match in matches:
            entry, definition, equation, enzyme = match
            enzyme = " ".join(enzyme.strip().split()) if enzyme else ""
            file_out.write(f"{entry}\t{definition}\t{equation}\t{enzyme}\n")

    # Clean up the downloaded .gz file
    gz_file_path.unlink()
    return output_file_path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert rhea-reactions.txt.gz to Rhea-CHEBI mapping in TSV format.')
    parser.add_argument('input_file', type=Path, help='Path to the rhea-reactions.txt.gz file')
    args = parser.parse_args()
    
    convert_to_tsv(args.input_file)
