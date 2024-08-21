#!/usr/bin/env zsh

source ~/.zshrc

WANDB_API_KEY=`python -c "import wandb; print(wandb.api.api_key)"`

runai submit \
        --name exp \
        --interactive \
        --gpu 1 \
        --cpu 2 --cpu-limit 2 --memory 80G --memory-limit 80G \
        --image ic-registry.epfl.ch/dhlab/llm-exploration:interactive \
        --pvc dhlab-scratch:/home/tkarch/scratch \
        --environment EPFML_LDAP=tkarch \
        --environment USER_NAME=tkarch \
        --environment USER_ID=125666 \
        --environment WANDB_API_KEY=$WANDB_API_KEY --command -- ./init_git_ssh.sh sleep infinity
