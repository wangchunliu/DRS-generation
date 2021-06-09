#
/bin/bash
set -eu -o pipefail

# Use a pretrained Marian model to parse raw text
# Note that in the config file $VOCAB_FOR_PARSE should be set to your vocab(s)

# Arguments:
#		$1 : config file of the pretrained model
#       $2 : actual pretrained model to use for parsing
#       $3 : output file
#   $4 - $n: input file(s) - should be multiple for multi-src models

# Always load default settings from config file here
source config/marian/default_config.sh
#export PYTHONPATH=${GIT_HOME}DRS_parsing/evaluation/:${PYTHONPATH}

# First command line argument is the config file with specific settings -- it overrides settings in default_config.sh if added
source $1

# Set better variable names
model="$2"
output_file="$3"

set_vocabs(){
	# Set the vocabs correctly
	# For multi-src encoding we have an extra vocab
	extra_vocab_src=""
	if [[ -n "$multi_src_ext" ]]; then
		for mul_ext in $multi_src_ext; do
			extra_vocab_src="$extra_vocab_src $MAIN_FOLDER$WORKING$PRETRAINED$TRAIN$pretrained_train${mul_ext}.yml"
		done
	fi

	# Then set the vocab
	vocab_tgt="$MAIN_FOLDER$WORKING$PRETRAINED$TRAIN$pretrained_train$sent_ext${char_sent_ext}.yml"
	vocab_src="$MAIN_FOLDER$WORKING$PRETRAINED$TRAIN$pretrained_train${char_tgt_ext}.yml"
	extra_vocab="-v $vocab_src $extra_vocab_src $vocab_tgt"
}


# The first input we preprocess to the desired representation that we read from the config files
# The other representations should already be in right format! ($5 and after)
set_vocabs
python $PREPROCESS_PYTHON -do --input_file $4 --casing $casing --representation $representation --variables $var_rewrite --char_drs_ext $char_tgt_ext --char_sent_ext $char_sent_ext --var_drs_ext $var_drs_ext
drs_char="${4}$char_tgt_ext"
input_files="$drs_char"

# Do actual parsing here
${MARIAN_HOME}marian-decoder $extra_vocab -w $workspace --log ${output_file}.log --log-level $log_level --seed $RANDOM -m $model --type $model_type -i $input_files -b $beam_size -n $norm $allow_unk $n_best --max-length $max_length --max-length-factor $max_length_factor -d $gpuid --mini-batch $mini_batch > $output_file

# Postprocess the DRS
output_pp="${output_file}.res"
python $POSTPROCESS_PY -i $output_file -o $output_pp

#perl /data/p289796/mosesdecoder/scripts/tokenizer/detokenizer.perl -l en < ${output_file}.res > ${output_file}.res.raw 
#perl $BLEU ${4}$char_sent_ext < $output_pp
