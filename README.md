# DRS-generation
The datasets and codes for my ACL-IJCNLP 2021 GEM workshop paper --- " Evaluating Text Generation from Discourse Representation Structures ".
The codes were based on [the work of Rik van Noord](https://github.com/RikVN/Neural_DRS).
The English data used in paper come from [DRS_parsing respository](https://github.com/RikVN/DRS_parsing).
 
```
git clone https://github.com/wangchunliu/DRS-generation/
```

### Setup & Data

1. Install Marian:https://marian-nmt.github.io/docs/

```
cd DRS-generation
git clone https://github.com/marian-nmt/marian
cd marian
git checkout b2a945c
# Build
mkdir build
cd build
cmake ..
make -j
cd ../../
```

2. Install Evaluation metrics: https://github.com/tuetschek/e2e-metrics

```
git clone https://github.com/tuetschek/e2e-metrics
cd e2e-metrics
# Install the required Python packages
pip install -r requirements.txt
cd ..
```

3.By using follow commands, we can get English DRSs data.

```
mkdir -p corpus
cd corpus/
wget "https://pmb.let.rug.nl/releases/exp_data_3.0.0.zip"
## Unzip and rename
unzip exp_data_3.0.0.zip
mv pmb_exp_data_3.0.0 en-data
# Clean up zips
rm exp_data_3.0.0.zip
```

4. Get the data we used in paper.

```
# Combine them to files with gold + silver
cd en-data
mkdir gold-silver-raw
cat ./en/gold/train.txt ./en/silver/train.txt > gold-silver-raw/train.txt
cat ./en/gold/train.txt.raw ./en/silver/train.txt.raw > gold-silver-raw/train.txt.raw
mv ./en/gold/dev.txt gold-silver-raw/
mv ./en/gold/dev.txt.raw gold-silver-raw/
mv ./en/gold/test.txt gold-silver-raw/
mv ./en/gold/test.txt.raw gold-silver-raw/
# Get gold data in our corpus path, we can use it for Finetune experiments, but actually we did not use it in our paper's experiments.
cp -r ./en/gold gold-raw
# Delete other language data
rm -rf en it de nl

```

5. By using Moses tokenizer, we can get tokenised English sentences.

```
git clone https://github.com/moses-smt/mosesdecoder.git
# Tokenize English raw sentences when we need to run word-level experiments 
~/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < ./gold-silver-raw/train.txt.raw > ./gold-silver-tok/train.txt.raw
~/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < ./gold-silver-raw/test.txt.raw > ./gold-silver-tok/test.txt.raw
~/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < ./gold-silver-raw/dev.txt.raw > ./gold-silver-tok/dev.txt.raw
```


### Training and Generating

The script ``src/marian_scripts/pipeline.sh `` can be used to run our own experiments, note that each experiment needs its own config file.
In `` config/marian/default_config.sh `` we can see which settings can be overwritten to create different experiments.

1. Training model:
```
sh ./src/marian_scripts/pipeline.sh config/marian/silver_ci_normal.sh 
sh ./src/marian_scripts/pipeline.sh config/marian/silver_wi_tokenized.sh 
```

2. Genrating text from test DRSs data:
```
sh ./src/marian_scripts/generate_text.sh config/marian/silver_ci_normal.sh $PRETRAINED_MODEL $OUTPUT_FILE $SENT_FILE 
sh ./src/marian_scripts/generate_text.sh config/marian/silver_wi_tokenized.sh  $PRETRAINED_MODEL $OUTPUT_FILE $SENT_FILE 
# Eg. sh ./src/marian_scripts/generate_text.sh config/marian/silver_ci_normal.sh /path/to/DRS-generation-outfile/silver_ci_normal/models/pretrained/model1.npz ./outfile/test.out /path/to/corpus/en-data/gold-silver-raw/test.txt
```

3. Evaluation scores:

```
python ../measure_scores.py -f1 $CLF_OUTPUT -f2 $GOLD_TEST
# Eg. python /path/to/e2e-metrics/measure_scores.py /path/to/corpus/en-data/gold-silver-raw/test.txt.raw  /path/to/outfile/test.out.res.raw
```


