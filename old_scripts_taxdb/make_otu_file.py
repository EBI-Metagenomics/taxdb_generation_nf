taxfile = open("ITSoneDB-tax.txt", "r")
taxidfile = open("itsonedb.taxid.final", "r")
otufile = open("itsonedb.otu", "w")
oust = ["sk__", "k__", "p__", "c__", "o__", "f__", "g__", "s__"]
taxids = {}
count = 1
otus = set()
otufile.write(str(count) + "\t" + "Unclassified" + "\n")
count +=1

for line in taxidfile:
    split_line = line.rstrip("\n").split("\t")
    id = split_line[0]
    if len(split_line) > 1:
        nums = split_line[1].split(";")
        nums.pop(0)
    taxids[id] = nums

for line in taxfile:
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
                print(ID)
                tax_id = tax_num[-1]
                tax_num.pop()
                otus.add(joint_lineage + "\t" + tax_id + "\n")

for item in otus:
    otufile.write(str(count) + "\t" + item)
    count += 1

taxfile.close()
taxidfile.close()
otufile.close()
