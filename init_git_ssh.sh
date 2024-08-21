#!/bin/bash

#Copy .ssh folder
cp -r /home/${USER_NAME}/scratch/tkarch/.ssh/ /home/${USER_NAME}
git config --global credential.helper store
git config --global user.email tristan.karch@gmail.com
git config --global user.name tristan-ka

#Start ssh
sudo service ssh start

sleep infinity

