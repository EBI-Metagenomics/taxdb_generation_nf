import urllib.request
import re

IDlist = list(open("ITSoneDB.sliced_taxids", "r"))
taxonomy = open("itsone_tax.txt", "w")
length = 0



for line in IDlist:
    try:
        req = urllib.request.Request('http://www.ebi.ac.uk/ena/data/taxonomy/v1/taxon/tax-id/'+ line)
        with urllib.request.urlopen(req) as response:
            the_page = response.read()
    except:
        continue
    #write output to file.
    # taxonomy.write(str(the_page) + "\n")

    #regex lineage and write to file in tax format
    #hashed out regex to trial only get above
    lineage = re.search(r'lineage\W+(.+?)\"', str(the_page))
    taxonomy.write(line.strip("\n") + "\t" + lineage.group(1) + "\n")

    #count no lineages
    countlineage = (lineage.group(1)).split(";")
    length2 = len(countlineage)
    if length2 > length:
        length = length2
        

# #print longest lineage
# print (length)'''
# IDlist.close()
taxonomy.close()
