#!/bin/bash

#Copy .ssh folder
cp -r /home/${USER_NAME}/dhlab-data/data/tkarch-data/.ssh/ /home/${USER_NAME}
git config --global credential.helper store
git config --global user.email tristan.karch@gmail.com
git config --global user.name tristan-ka

#Start ssh
sudo service ssh start

#Copy .cache folder for HF credentials
# cp -r /home/${USER_NAME}/dhlab-data/data/tkarch-data/.cache/ /home/${USER_NAME}
sleep infinity