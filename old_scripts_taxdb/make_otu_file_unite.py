taxfile = open("UNITE_public_all_29.11.2022.fasta.subset.taxid.rm_sedis", "r")
otufile = open("UNITE_v8_all.otu", "w")
oust = ["sk__", "k__", "p__", "c__", "o__", "f__", "g__", "s__"]
taxids = {}
count = 1
otus = set()
otufile.write(str(count) + "\t" + "Unclassified" + "\n")
count +=1

for line in taxfile:
    if line.startswith("#"):
        continue
    else:
        line = line.split("\t")
        lineage = line[1].rstrip().split(";")
        for i in range(1,9):
            joint_lineage = ";".join(lineage[0:i])
            last_lineage = joint_lineage.split(";")[-1]
            if last_lineage not in oust:
                otus.add(joint_lineage + "\n")

for item in otus:
    otufile.write(str(count) + "\t" + item)
    count += 1

taxfile.close()
otufile.close()
