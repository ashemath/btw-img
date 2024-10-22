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

if [ -f ./conf.d/$1.conf ]; then
    . conf.d/debian.build
    admin_user=$ADMIN_USER;
    build_path=$BUILDPATH;
    build_name=$BUILDNAME;
    echo "Admin username is: $admin_user";
    echo "build path is: $build_path";
    echo "build name is: $build_name";
else
    echo "Build requires ADMIN_USER in conf.d/debian.build file";
    echo "Admin username is: $admin_user";
    exit 1;
fi

target_ip=$(cat creds/$1.ssh | cut -d"@" -f2)

admin_passwd=$(./scripts/btwpasswd.py);

cat << EOF > ansible/inventory
[all:vars]
ansible_host_key_checking=False
ansible_user="btw"
admin_user="$admin_user"
admin_passwd="$admin_passwd"
build_name="$build_name"
build_path="$build_path"
ansible_private_key_file="creds/$1"

[all]
$1

[target]
$1 ansible_host=$target_ip
EOF
