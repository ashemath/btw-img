#!/bin/sh

if [ -d venv ] ; then
    . venv/bin/activate;
    test_ansible=$(which ansible-playbook);
    echo "$test_ansible";
    deactivate;
else
    python3 -m venv venv;
fi

if [ -z $test_ansible ] ; then
    . venv/bin/activate;
    pip install --upgrade pip;
    pip install ansible;
    echo "Ansible installed!";
fi

target_ip=$(cat creds/$1.ssh | cut -d"@" -f2)

cat << EOF > ansible/inventory
[all:vars]
ansible_host_key_checking=False
ansible_user="btw"
ansible_private_key_file="creds/$1"

[all]
$1

[target]
$1 ansible_host=$target_ip
EOF
