taxfile = open("pr2-tax.txt", "r")
otufile = open("pr2.otu", "w")
oust = ["d__", "sg__", "dv__", "sdv__", "c__", "o__", "f__", "g__", "s__"]
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
        for i in range(1,10):
            joint_lineage = ";".join(lineage[0:i])
            last_lineage = joint_lineage.split(";")[-1]
            if last_lineage not in oust:
                otus.add(joint_lineage + "\n")

for item in otus:
    otufile.write(str(count) + "\t" + item)
    count += 1

taxfile.close()
otufile.close()
