import argparse
import re
def create_arg_parser():
    parser = argparse.ArgumentParser()
    # Input, output and signature files
    parser.add_argument("-i", "--input_file", required=True, type=str,
                        help="Input file with output of a Neural Language Generator")
    parser.add_argument("-o", "--output_file", required=True, type=str,
                        help="Output file with postprocess to normal sentence")
    args = parser.parse_args()
    return args

def postprocess(args):
    outfile=open(args.output_file,'w')
    with open(args.input_file,'r') as input:
        for line in input.readlines():
            line=line.strip('\n')
            sep=re.search(r'\|\|\|',line)
            # seq '|||' char-level sentences
            if sep:
                line = ''.join(line.split(' '))
                line = ' '.join(line.split('|||'))
                casing=re.search(r'\^\^\^',line)
                # casing '^^^' feature representation sentences
                if casing:
                # feature representation
                    sentence = ''
                    for word in line.split():
                        item = ''
                        if word[0] == '^':
                            print(word)
                            word = word.replace('^^^', '')
                            for i, char in enumerate(word):
                                if i == 0:
                                    char = char.upper()
                                item += char
                            word = item
                        sentence += ' ' + word + ' '
                    line = " ".join(sentence.strip().split())
                # not feature representation: normal or lowercase or tokenized representation               
            else:
                casing = re.search(r'\^\^\^', line)
                if casing:
                    sentence = ''
                    feature_list = []
                    for i, word in enumerate(line.split()):
                        if word == '^^^':
                            feature_list.append(i + 1)
                    for i, word in enumerate(line.split()):
                        item = ''
                        if word == '^^^':
                            word = word.replace('^^^', '')
                        if i in feature_list:
                            for f, char in enumerate(word):
                                if f == 0:
                                    char = char.upper()
                                item += char
                            word = item
                        sentence += ' ' + word + ' '
                    line = " ".join(sentence.strip().split())
            outfile.write(line+'\n')
                
                
if __name__ == "__main__":
    args = create_arg_parser()
    postprocess(args)