#!/bin/bash

stage=0
nnet3_affix=_semi20k_80k
src_model_root=exp/ihm/semisup_20k/chain_semi20k_80k
exp_root=exp/ihm/semisup_20k
# score_comb 
# tdnn_hyp
# decode_{NULL, semisup_best_phn, semisup, oracle}_{eval, dev}_{NULL, lats}
# tdnn_fusion
# decode_{NULL, semisup_best_phn, semisup, oracle}_{eval, dev}
. ./cmd.sh
. ./path.sh 

set -euo pipefail
cmd=run.pl

. parse_options.sh || exit 1;

ivector_root_dir=$exp_root/nnet3${nnet3_affix}
decode_affix=_poco
dest_decode_affix=_oracle

if [ $stage -le 0 ]; then
  echo "$0, Hypothesis Combine without generate lattice"
  for decode_set in dev eval; do
    local/score_combine.sh --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           data/lang_ami.o3g.kn.pr1-7 \
                           $src_model_root/tdnn_1a_sp_bi/decode${decode_affix}_${decode_set}:1 \
                           $src_model_root/tdnn_1b_sp_bi/decode${decode_affix}_${decode_set}:1 \
                           $src_model_root/tdnn_1c_sp_bi/decode${decode_affix}_${decode_set}:1 \
                           $src_model_root/tdnn_1d_sp_bi/decode${decode_affix}_${decode_set}:1 \
                           $exp_root/ensemble/tdnn_hyp/decode_${decode_set}

    local/score_combine.sh --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           data/lang_ami.o3g.kn.pr1-7 \
                           $src_model_root/tdnn_1a_sp_bi_semisup_1b/decode${decode_affix}_${decode_set}:1 \
                           $src_model_root/tdnn_1b_sp_bi_semisup_1a/decode${decode_affix}_${decode_set}:1 \
                           $src_model_root/tdnn_1c_sp_bi_semisup_1c/decode${decode_affix}_${decode_set}:1 \
                           $src_model_root/tdnn_1d_sp_bi_semisup_1d/decode${decode_affix}_${decode_set}:1 \
                           $exp_root/ensemble/tdnn_hyp/decode_semisup_${decode_set}

    local/score_combine.sh --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           data/lang_ami.o3g.kn.pr1-7 \
                           $src_model_root/tdnn_1a_sp_bi_semisup_1b_best_phn/decode${decode_affix}_best_phn_${decode_set}:1 \
                           $src_model_root/tdnn_1b_sp_bi_semisup_1a_best_phn/decode${decode_affix}_best_phn_${decode_set}:1 \
                           $src_model_root/tdnn_1c_sp_bi_semisup_1c_best_phn/decode${decode_affix}_best_phn_${decode_set}:1 \
                           $src_model_root/tdnn_1d_sp_bi_semisup_1d_best_phn/decode${decode_affix}_best_phn_${decode_set}:1 \
                           $exp_root/ensemble/tdnn_hyp/decode_semisup_phn_${decode_set}

    local/score_combine.sh --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           data/lang_ami.o3g.kn.pr1-7 \
                           $src_model_root/tdnn_1a_oracle_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1b_oracle_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1c_oracle_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1d_oracle_sp_bi/decode_${decode_set}:1 \
                           $exp_root/ensemble/tdnn_hyp/decode_oracle_${decode_set}
  done
fi



if [ $stage -le 1 ]; then
  echo "$0, Hypothesis Combine and generate lattice"
  for decode_set in dev eval; do
    local/score_combine_lats.sh --cmd "$decode_cmd" --stage 0 \
			   data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_sp_bi/graph_poco \
                           $src_model_root/tdnn_1a_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1b_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1c_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1d_sp_bi/decode_${decode_set}:1 \
                           $exp_root/ensemble/tdnn_hyp/decode_${decode_set}_lats

    local/score_combine_lats.sh --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_sp_bi_semisup_1b/graph_poco \
                           $src_model_root/tdnn_1a_sp_bi_semisup_1b/decode_poco_${decode_set}:1 \
                           $src_model_root/tdnn_1b_sp_bi_semisup_1a/decode_poco_${decode_set}:1 \
                           $src_model_root/tdnn_1c_sp_bi_semisup_1c/decode_poco_${decode_set}:1 \
                           $src_model_root/tdnn_1d_sp_bi_semisup_1d/decode_poco_${decode_set}:1 \
                           $exp_root/ensemble/tdnn_hyp/decode_semisup_${decode_set}_lats

    local/score_combine_lats.sh --cmd "$decode_cmd" --stage 0 \
	                       data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_sp_bi_semisup_1b_best_phn/graph_poco_best_phn \
                           $src_model_root/tdnn_1a_sp_bi_semisup_1b_best_phn/decode_poco_best_phn_${decode_set}:1 \
                           $src_model_root/tdnn_1b_sp_bi_semisup_1a_best_phn/decode_poco_best_phn_${decode_set}:1 \
                           $src_model_root/tdnn_1c_sp_bi_semisup_1c_best_phn/decode_poco_best_phn_${decode_set}:1 \
                           $src_model_root/tdnn_1d_sp_bi_semisup_1d_best_phn/decode_poco_best_phn_${decode_set}:1 \
                           $exp_root/ensemble/tdnn_hyp/decode_semisup_phn_${decode_set}_lats

    local/score_combine_lats.sh --cmd "$decode_cmd" --stage 0 \
	                       data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_oracle_sp_bi/graph_poco \
                           $src_model_root/tdnn_1a_oracle_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1b_oracle_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1c_oracle_sp_bi/decode_${decode_set}:1 \
                           $src_model_root/tdnn_1d_oracle_sp_bi/decode_${decode_set}:1 \
                           $exp_root/ensemble/tdnn_hyp/decode_oracle_${decode_set}_lats
  done
fi



if [ $stage -le 2 ]; then
  echo "$0, Frame Level Combine and generate lattice"
  for decode_set in dev eval; do
    steps/nnet3/decode_score_fusion.sh --cmd "$decode_cmd" --stage 0 --acwt 1.0 --post-decode-acwt 10.0 \
	                   --online-ivector-dir $ivector_root_dir/ivectors_${decode_set}_hires \
			   --num-threads 5 \
                           --use-gpu true \
                           data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_sp_bi/graph_poco \
                           $src_model_root/tdnn_1a_sp_bi \
                           $src_model_root/tdnn_1b_sp_bi \
                           $src_model_root/tdnn_1c_sp_bi \
                           $src_model_root/tdnn_1d_sp_bi \
  done
fi  

if [ $stage -le 3 ]; then
  for decode_set in dev eval; do 
      local/score_rover.sh   --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_sp_bi/decode_${decode_set}:10 \
                           $src_model_root/tdnn_1b_sp_bi/decode_${decode_set}:10 \
                           $src_model_root/tdnn_1c_sp_bi/decode_${decode_set}:10 \
                           $src_model_root/tdnn_1d_sp_bi/decode_${decode_set}:10 \
                           $exp_root/ensemble/tdnn_rover/decode_${decode_set}

      local/score_rover.sh --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_sp_bi_semisup_1b/decode${decode_affix}_${decode_set}:10 \
                           $src_model_root/tdnn_1b_sp_bi_semisup_1a/decode${decode_affix}_${decode_set}:10 \
                           $src_model_root/tdnn_1c_sp_bi_semisup_1c/decode${decode_affix}_${decode_set}:10 \
                           $src_model_root/tdnn_1d_sp_bi_semisup_1d/decode${decode_affix}_${decode_set}:10 \
                           $exp_root/ensemble/tdnn_rover/decode_semisup_${decode_set}

      local/score_rover.sh --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_sp_bi_semisup_1b_best_phn/decode${decode_affix}_best_phn_${decode_set}:10 \
                           $src_model_root/tdnn_1b_sp_bi_semisup_1a_best_phn/decode${decode_affix}_best_phn_${decode_set}:10 \
                           $src_model_root/tdnn_1c_sp_bi_semisup_1c_best_phn/decode${decode_affix}_best_phn_${decode_set}:10 \
                           $src_model_root/tdnn_1d_sp_bi_semisup_1d_best_phn/decode${decode_affix}_best_phn_${decode_set}:10 \
                           $exp_root/ensemble/tdnn_rover/decode_semisup_phn_${decode_set}

      local/score_rover.sh --cmd "$decode_cmd" --stage 0 \
                           data/ihm/semisup/${decode_set}_hires \
                           $src_model_root/tdnn_1a_oracle_sp_bi/decode_${decode_set}:10 \
                           $src_model_root/tdnn_1b_oracle_sp_bi/decode_${decode_set}:10 \
                           $src_model_root/tdnn_1c_oracle_sp_bi/decode_${decode_set}:10 \
                           $src_model_root/tdnn_1d_oracle_sp_bi/decode_${decode_set}:10 \
                           $exp_root/ensemble/tdnn_rover/decode_oracle_${decode_set}
  done
  exit 0;
fi


if [ $stage -le 4 ]; then
  for decode_set in eval; do
    steps/nnet3/compute_output.sh  --stage 0 --nj 80 --use-gpu true --frame-subsampling-factor 3 \
                                   --apply-exp true --cmd "$decode_cmd" \
                                   --online-ivector-dir exp/ihm/semisup_20k/nnet3_semi20k_80k/ivectors_${decode_set}_hires \
                                   data/ihm/semisup/${decode_set}_hires \
                                   $src_model_root/tdnn_1b_sp_bi \
                                   $src_model_root/tdnn_1b_sp_bi/analysis_output

#    steps/nnet3/compute_score_fusion.sh --stage 2 --nj 80 --acwt 1.0 --post-decode-acwt 10.0 --use-gpu true \
#                                --apply-exp true --cmd "$decode_cmd --num-threads 3" \
#                                --online-ivector-dir exp/ihm/semisup_20k/nnet3_semi20k_80k/ivectors_${decode_set}_hires \
#                                data/ihm/semisup/${decode_set}_hires exp/ihm/semisup_20k/chain_semi20k_80k/tdnn_1a_sp_bi/graph_poco \
#                                $src_model_root/tdnn_1a_sp_bi \
#                                $src_model_root/tdnn_1b_sp_bi \
#                                $src_model_root/tdnn_1c_sp_bi \
#                                $src_model_root/tdnn_1d_sp_bi \
#                                $exp_root/ensemble/fusion_analysis/decode_${decode_set}
  done
fi

exit 0;

