#!/bin/bash

# Copyright 2017  Vimal Manohar
# Apache 2.0

# This script demonstrates semi-supervised training using 50 hours of 
# supervised data and 250 hours of unsupervised data.
# We assume the supervised data is in data/train_sup and unsupervised data
# is in data/train_unsup100k_250k. 
# For LM training, we assume there is data/train/text, from which
# we will exclude the utterances contained in the unsupervised set.
# We use all 300 hours of semi-supervised data for i-vector extractor training.

# This differs from run_100k.sh, which uses only 100 hours supervised data for 
# both i-vector extractor training and LM training.

. ./cmd.sh
. ./path.sh 

set -euo pipefail


stage=0
nj=30 # number of parallel jobs,
mic=ihm
train_sup_dir=train_sup
train_unsup_dir=train_unsup80k
semi_dir=semisup
exp_root=exp/$mic/semisup_20k
data_root=data/$mic/$semi_dir

final_lm=`cat data/local/lm/final_lm`
LM=$final_lm.pr1-7

. utils/parse_options.sh

for f in $data_root/$train_sup_dir/utt2spk $data_root/$train_unsup_dir/utt2spk \
  data/$mic/train/text; do
  if [ ! -f $f ]; then
    echo "$0: Could not find $f"
    exit 1
  fi
done

###############################################################################
# Semi-supervised training using 50 hours supervised data and 
# 250 hours unsupervised data. We use i-vector extractor, tree, lattices 
# and seed chain system from the previous stage.
###############################################################################

if [ $stage -le 10 ]; then
   local/fusion_ts/chain/tuning/run_tdnn_20k_semisupervised_semits_1a.sh \
     --mic $mic \
     --supervised-set ${train_sup_dir} \
     --unsupervised-set semisup20k_80k \
     --sup-chain-dir $exp_root/chain_semi20k_80k/tdnn_${tuning_affix}_sp_bi_semisup_1a \
     --sup-lat-dir $exp_root/chain_semi20k_80k/${gmm}_${train_sup_dir}_sp_comb_lats \
     --sup-tree-dir $exp_root/chain_semi20k_80k/tree_bi_a \
     --ivector-root-dir $exp_root/nnet3_semi20k_80k \
     --chain-affix _semi20k_80k \
     --data-root $data_root \
     --exp-root $exp_root/../comb_adapt --stage 4
fi
