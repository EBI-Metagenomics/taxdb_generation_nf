
import argparse

def parse_args():

    parser = argparse.ArgumentParser()

    parser.add_argument("-u", "--uplift", required=True, type=str, help="Path to uplift file")
    parser.add_argument("-t", "--taxid", required=True, type=str, help="Path to taxid file")
    parser.add_argument("-l", "--label", required=True, type=str, help="Database label")
    

    args = parser.parse_args()
  
    _UPLIFT = args.uplift
    _TAXID = args.taxid
    _LABEL = args.label

    return _UPLIFT, _TAXID, _LABEL


def main():

    _UPLIFT, _TAXID, _LABEL = parse_args()

    uplift_fr = open(_UPLIFT, "r")
    taxid_fr = open(_TAXID, "r")
    otufile = open(f"{_LABEL}.otu", "w")
    
    oust = ["sk__", "k__", "p__", "c__", "o__", "f__", "g__", "s__"]
    taxids = {}
    count = 1
    otus = set()
    otufile.write(str(count) + "\t" + "Unclassified" + "\n")
    count +=1

    for line in taxid_fr:
        split_line = line.rstrip("\n").split("\t")
        id = split_line[0]
        if len(split_line) > 1:
            nums = split_line[1].split(";")
            nums.pop(0)
        taxids[id] = nums

    for line in uplift_fr:
        if line.startswith("#"):
            continue
        else:
            line = line.split("\t")
            lineage = line[1].rstrip().split(";")
            ID = line[0]
            tax_num = taxids[ID]
            for X in range(1,9):
                joint_lineage = ";".join(lineage[0:X])
                last_lineage = joint_lineage.split(";")[-1]
                if last_lineage not in oust:
                    tax_id = tax_num[-1]
                    tax_num.pop()
                    otus.add(joint_lineage + "\t" + tax_id + "\n")

    for item in otus:
        otufile.write(str(count) + "\t" + item)
        count += 1

    uplift_fr.close()
    taxid_fr.close()
    otufile.close()

if __name__ == "__main__":
    main()
