#!/bin/bash

python /home/p289796/project/NLG_test7/src/postprocess.py -i $1 -o /data/p289796/temp/dev.temp.out

cat /data/p289796/temp/dev.temp.out \
            | sed 's/\@\@ //g' \
            | /home/p289796/moses-scripts/scripts/recaser/detruecase.perl 2>/dev/null \
            | /home/p289796/moses-scripts/scripts/tokenizer/detokenizer.perl -l en 2>/dev/null \
            | /home/p289796/moses-scripts/scripts/generic/multi-bleu-detok.perl /data/p289796/corpus/en-data/gold-raw/dev.txt.raw \
            | sed -r 's/BLEU = ([0-9.]+),.*/\1/'
