#!/bin/bash
source config/marian/default_config.sh # get main folders from default settings

# Import to set every time, the folder in which we save all experiment results models, working files, output, logs, etc
MAIN_FOLDER="${WORKING_OUT}/silver_ci_lowercase/"
# Gold files - if you do not plan on changing these after you set them,  you can also move them to default_config.sh
PRETRAINED_FOLDER="${DATA}/en-data/gold-silver-tok/"
FINETUNED_FOLDER="${DATA}/en-data/gold-tok/"

# Important to set these for silver experiments
pretrained_train="train.txt"
pretrained_dev="dev.txt"
finetuned_train="train.txt"
finetuned_dev="dev.txt"

casing="lower"     	# options: {normal, lower, feature}

# Files that are used as input (sentences) are assumed to be in $file$sent_ext, i.e. dev.txt and dev.txt.raw
# Possibly overwrite default settings here:

representation="char"
model_type="s2s"

sent_ext=".raw"
epochs_pre="15"
epochs_fine="15"
num_runs_fine=1
num_runs_pre=1

mini_batch="48"
disp_freq="1000"
save_freq="10000"
valid_freq="10000"
# Set multi-src extension to add
#multi_src_ext=".charext"
#model_type="multi-s2s"

# For parsing from raw text this is already added in this config
# Note that this doesn't have to be in your config for your own
# experiments when retraining a model
# VOCAB_FOR_PARSE="-v ${GIT_HOME}vocabs/marian/best_gold_silver/train.txt.raw.char.sent.yml ${GIT_HOME}vocabs/marian/best_gold_silver/train.txt.clem.yml ${GIT_HOME}vocabs/marian/best_gold_silver/train.txt.char.tgt.yml"
