#!/bin/sh
export PATH=$PATH:~/.local/bin/
ansible-playbook -v --extra-vars "taskname=copy_ssh" ansible/playbook.yml
#ansible-playbook -v --extra-vars "taskname=heroku" ansible/playbook.yml
ansible-playbook -v --extra-vars "taskname=finish_messages" ansible/playbook.yml
