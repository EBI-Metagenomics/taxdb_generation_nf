
import argparse

def parse_args():

    parser = argparse.ArgumentParser()

    parser.add_argument("-tx", "--tax", required=True, type=str, help="Path to uplift file")
    parser.add_argument("-l", "--label", required=True, type=str, help="Database label")
    parser.add_argument("-t", "--taxid", required=False, type=str, help="Path to taxid file")
    parser.add_argument("--ext_ranks", default=False, action='store_true', help="Boolean for using extended 9-rank taxonomy e.g. PR2")
    
    args = parser.parse_args()
  
    _TAX = args.tax
    _LABEL = args.label
    _TAXID = args.taxid
    _EXT_RANKS = args.ext_ranks

    return _TAX, _LABEL, _TAXID, _EXT_RANKS


def main():

    _TAX, _LABEL, _TAXID, _EXT_RANKS = parse_args()

    tax_fr = open(_TAX, "r")
    if _TAXID != None:
        taxid_fr = open(_TAXID, "r")
        taxids = {}

        for line in taxid_fr:
            split_line = line.rstrip("\n").split("\t")
            id = split_line[0]
            if len(split_line) > 1:
                nums = split_line[1].split(";")
                nums.pop(0)
            taxids[id] = nums

    otufile = open(f"{_LABEL}.otu", "w")
    
    if _EXT_RANKS:
        oust = ["d__", "sg__", "dv__", "sdv__", "c__", "o__", "f__", "g__", "s__"]
    else:
        oust = ["sk__", "k__", "p__", "c__", "o__", "f__", "g__", "s__"]
    count = 1
    otus = []
    otufile.write(str(count) + "\t" + "Unclassified" + "\n")
    count +=1

    for line in tax_fr:
        if line.startswith("#"):
            continue
        else:
            line = line.split("\t")
            lineage = line[1].rstrip().split(";")
            id = line[0]
            if _TAXID != None:
                tax_num = taxids[id]

            for i in range(1, len(oust) + 1):
                joint_lineage = ";".join(lineage[0:i])
                last_lineage = joint_lineage.split(";")[-1]

                if last_lineage not in oust:
                    if _TAXID != None:
                        print(last_lineage)
                        print(tax_num)
                        tax_id = tax_num[-1]
                        tax_num.pop()
                        otus.append(joint_lineage + "\t" + tax_id + "\n")
                    else:
                        otus.append(joint_lineage + "\n")

    otus = sorted(list(set(otus)))
    for item in otus:
        otufile.write(str(count) + "\t" + item)
        count += 1

    tax_fr.close()
    otufile.close()
    if _TAXID != None:
        taxid_fr.close()

if __name__ == "__main__":
    main()
