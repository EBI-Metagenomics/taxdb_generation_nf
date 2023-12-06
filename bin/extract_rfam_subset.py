
import argparse

def parse_args():

    parser = argparse.ArgumentParser()

    parser.add_argument("-ci", "--clan_info", required=True, type=str, help="Path to claninfo file")
    parser.add_argument("-cm", "--covar_model", required=True, type=str, help="Path to covariance model file")
    parser.add_argument("-o", "--output", required=True, type=str, help="Output path")
    
    args = parser.parse_args()
  
    _CLAN_INFO = args.clan_info
    _COVAR_MODEL = args.covar_model
    _OUTPUT = args.output

    return _CLAN_INFO, _COVAR_MODEL, _OUTPUT

def parse_clan_info(_CLAN_INFO):

    fr = open(_CLAN_INFO, 'r')
    cm_names = []

    for line in fr:
        line = line.strip()
        line = line.replace(' ', '\t')
        temp_lst = line.split('\t')[1:]
        cm_names.extend(temp_lst)

    fr.close()

    return cm_names

def extract_cm(cm_names, _COVAR_MODEL, _OUTPUT):

    fw = open(_OUTPUT, "w")
    fr = open(_COVAR_MODEL, "r")

    curr_header = ''
    write_bool = False

    for line in fr:
        tabbed_line = line.strip().replace(' ', '\t')

        if "INFERNAL1/a" in tabbed_line or "HMMER3/f" in tabbed_line:
            curr_header = line

        elif "NAME" in tabbed_line:
            curr_name = tabbed_line.split("\t")[-1]
            if curr_name in cm_names:
                write_bool = True
                fw.write(curr_header)
                fw.write(line)
                continue
        
        if write_bool:
            fw.write(line)

        if line == "//\n":
            write_bool = False
            curr_header = ''

    fw.close()


def main():
    
    _CLAN_INFO, _COVAR_MODEL, _OUTPUT = parse_args()

    cm_names = parse_clan_info(_CLAN_INFO)
    extract_cm(cm_names, _COVAR_MODEL, _OUTPUT)

if __name__ == "__main__":
    main()