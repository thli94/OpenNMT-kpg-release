#!/usr/bin/env bash
#SBATCH --cluster=gpu
#SBATCH --gres=gpu:1
#SBATCH --partition=titanx
#SBATCH --job-name=train-verbatim_append-kp20k-rnn-DIM150-EMB100-LR005-DO01-TTTF-TFB1
#SBATCH --output=slurm_output/train-verbatim_append-kp20k-rnn-DIM150-EMB100-LR005-DO01-TTTF-TFB1.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64GB
#SBATCH --time=6-00:00:00 # 6 days walltime in dd-hh:mm format
#SBATCH --qos=long

# Load modules
#module restore
#module load cuda/10.0.130
#module load gcc/6.3.0
#module load python/anaconda3.6-5.2.0
#source activate py36
#module unload python/anaconda3.6-5.2.0

# Run the job
export DATA_NAME="kp20k"
export TOKEN_NAME="meng17"
export TARGET_TYPE="verbatim_append"
export MASTER_PORT=5000

export LAYER=1
export EMBED=100
export HIDDEN=150
export BatchSize=64
export ValidBatchSize=64
export TrainSteps=100000
export CheckpointSteps=10000

export Optimizer="adagrad"
export LearningRate="0.05"
export Dropout="0.1"
export MaxGradNorm="1.0"

export Copy=true
export ReuseCopy=true
export Cov=true
export PositionEncoding=false

export ShareEmbeddings=true
export CopyLossBySeqLength=false

export ContextGate="both"
export InputFeed=1

export EXP_NAME="$DATA_NAME-$TOKEN_NAME-$TARGET_TYPE-rnn-BS$BatchSize-OPT$Optimizer-LR$LearningRate-Layer$LAYER-Dim$HIDDEN-Emb$EMBED-Dropout$Dropout-Copy$Copy"

export PATHON_PATH="/ihome/pbrusilovsky/rum20/.conda/envs/py36/bin/"
export ROOT_PATH="/zfs1/pbrusilovsky/rum20/kp/OpenNMT-kpg"
export DATA_PATH="data/keyphrase/$TOKEN_NAME/$DATA_NAME"
export MODEL_PATH="models/keyphrase/$TOKEN_NAME-one2seq/$TOKEN_NAME-one2seq-kp20k-v2/$EXP_NAME"
export EXP_DIR="output/keyphrase/$TOKEN_NAME-one2seq/$TOKEN_NAME-one2seq-kp20k-v2/$EXP_NAME/"
export TENSORBOARD_PATH="runs/keyphrase/$TOKEN_NAME/$EXP_NAME/"
export WANDB_PROJECT_NAME="kp20k-meng17-one2one"

cmd="python train.py -config config/train/pt/config-rnn-keyphrase-crc.yml -exp $EXP_NAME -data $DATA_PATH -vocab $DATA_PATH.vocab.pt -save_model $MODEL_PATH -exp_dir $EXP_DIR -tensorboard_log_dir $TENSORBOARD_PATH -tgt_type $TARGET_TYPE -batch_size $BatchSize -train_steps $TrainSteps -save_checkpoint_steps $CheckpointSteps -layers $LAYER -word_vec_size $EMBED -rnn_size $HIDDEN -optim $Optimizer -learning_rate $LearningRate -dropout $Dropout -context_gate $ContextGate  -input_feed $InputFeed -master_port $MASTER_PORT -wandb_project $WANDB_PROJECT_NAME"

if [ "$Copy" = true ] ; then
    cmd+=" -copy_attn"
fi
if [ "$ReuseCopy" = true ] ; then
    cmd+=" -reuse_copy_attn"
fi
if [ "$Cov" = true ] ; then
    cmd+=" -coverage_attn"
fi
if [ "$PositionEncoding" = true ] ; then
    cmd+=" -position_encoding"
fi
if [ "$ShareEmbeddings" = true ] ; then
    cmd+=" -share_embeddings"
fi
if [ "$CopyLossBySeqLength" = true ] ; then
    cmd+=" -copy_loss_by_seqlength"
fi

#cmd+=" > output/keyphrase/$TOKEN_NAME/nohup_$EXP_NAME.log &"

echo $TARGET_TYPE
echo $cmd

$cmd
#$cmd