FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu20.04

ENV GROUP_NAME=DHLAB-unit
ENV GROUP_ID=11703
ENV USER_NAME=tkarch
ENV USER_ID=125666

# Install build tools and libraries
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        pkg-config \
        software-properties-common

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    git  \
    curl  \
    vim  \
    unzip  \
    wget  \
    tmux  \
    screen  \
    wget \
    sudo

RUN DEBIAN_FRONTEND=noninteractive apt-get install openssh-client
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-11-jdk
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y htop

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Debug: USER_ID=$USER_ID, GROUP_ID=$GROUP_ID, USER_NAME=$USER_NAME, GROUP_NAME=$GROUP_NAME"

# Create a group and user
RUN groupadd -g $GROUP_ID $GROUP_NAME
RUN useradd -ms /bin/bash -u $USER_ID -g $GROUP_ID $USER_NAME

# Add new user to sudoers
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add Conda & Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
ENV CONDA_PREFIX=/home/${USER_NAME}/.conda
ENV CONDA=/home/${USER_NAME}/.conda/condabin/conda

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p ${CONDA_PREFIX} && \
    rm miniconda.sh && \
    ${CONDA} config --set auto_activate_base false && \
    ${CONDA} init bash && \
    ${CONDA} create --name myenv python=3.11

ENV PATH="/home/${USER_NAME}/.conda/envs/myenv/bin:$PATH"

RUN /home/${USER_NAME}/.conda/condabin/conda create -n myenv python=3.11 pip

RUN /home/${USER_NAME}/.conda/condabin/conda run -n myenv pip install --upgrade pip setuptools
RUN /home/${USER_NAME}/.conda/condabin/conda run -n myenv pip install numpy scipy \
    scikit-learn pandas sentencepiece
RUN /home/${USER_NAME}/.conda/condabin/conda run -n myenv pip install torch
RUN /home/${USER_NAME}/.conda/condabin/conda run -n myenv pip install transformers accelerate

# Update PATH environment variable and install updates and required packages
# Note: Using Docker, we don't typically use 'export' for setting ENV variables, instead, we use the ENV instruction
ENV PATH="/home/${USER_NAME}/.conda/envs/myenv/bin:/home/${USER_NAME}/.local/bin:$PATH"
#
#ENV PATH="/home/${USER_NAME}/.conda/envs/myenv/bin:$PATH"
ENV HF_HOME="/home/${USER_NAME}/dhlab-data/data/${USER_NAME}-data/.cache/"

# Perform system update using apt-get
# Note: Running 'sudo' is not typically necessary in Dockerfiles as commands run as root by default
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## setup openSSH
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "${USER_NAME}:${USER_NAME}" | chpasswd
EXPOSE 22

#Set the working directory
WORKDIR /home/$USER_NAME/app

#Copy app directory
COPY . .

# Change ownership of the copied files to the new user and group
RUN chown -R $USER_NAME:$GROUP_NAME /home/$USER_NAME/app

#Switch user
USER $USER_NAME

ENV PATH="/home/${USER_NAME}/.conda/envs/myenv/bin:$PATH"
ENV PATH="/home/${USER_NAME}/.conda/envs/myenv/bin:/home/${USER_NAME}/.local/bin:$PATH"
# ENV PATH="/home/${USER_NAME}/.conda/condabin/:$PATH"

ENV HF_HOME="/home/${USER_NAME}/dhlab-data/data/tkarch-data/.cache/"

# Env variables for shortcuts
ENV STORE="/home/tkarch/dhlab-data/data/tkarch-data"
ENV GITSOURCE="git@github.com:tristan-ka/open-question-generator.git"

RUN chmod +x init_git_ssh.sh

#Sleep for ever
ENTRYPOINT [ "init_git_ssh.sh" ]
CMD ["sleep", "infinity"]
