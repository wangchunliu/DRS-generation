#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00
#SBATCH --mem=100GB


srun ./src/marian_scripts/pipeline.sh config/marian/silver_ci_normal.sh 




