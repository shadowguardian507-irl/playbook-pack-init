#!/bin/bash
AUTORUN=false
while getopts "yash" opt; do

  case $opt in
    y) 
      echo "option y"
      AUTORUN=true
    ;;
    a)
      echo "option a"
      AUTORUN=true
    ;;
    s)
      echo "option s"
      AUTORUN=true
    ;;
    h) 
       echo ''
       echo ' option flags are'
       echo ''
       echo ' -a (auto run)'
       echo ' -y (yes)'
       echo ' -s (scripting mode)'
       echo ' all above options result in no confirm prompts please use with care'
       echo ''
       echo ' -h shows this help message' >&2
       exit 1
    ;;
    *) 
       echo ''
       echo 'valid option flags are as follows'
       echo ''
       echo ' -a (auto run)'
       echo ' -y (yes)'
       echo ' -s (scripting mode)'
       echo ' all above options result in no confirm prompts please use with care'
       echo ''
       echo ' -h (help)' >&2
       exit 1
  esac

done
echo "initialising playbook pack structure in directory $(pwd)"
if $AUTORUN
then
  echo "auto run enabled by flag"
else
  while true; do
    read -r -p "do you wish to continue ? (Y/N) " yn
    case $yn in
        [Yy]* ) echo processing ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
  done
fi
echo "running stage 1"
mkdir ./Ansible
mkdir ./Resources
mkdir ./ConfigPacks
mkdir ./ConfigPacksVault
mkdir ./Plugins
mkdir ./roles

touch ./README.md
touch ./Launcher.sh
touch ./Vaultmgmt.sh
touch ./Ansible/.gitkeep
touch ./Resources/.gitkeep
touch ./ConfigPacks/.gitkeep
touch ./ConfigPacksVault/.gitkeep
touch ./Plugins/.gitkeep
touch ./roles/.gitkeep

cp /usr/lib/playbook_toolkit/playbook_pack_init.meta ./playbookpack.meta

cp /usr/lib/playbook_toolkit/support_scripts/Launcher.sh ./Launcher.sh
chmod +x ./Launcher.sh

cp /usr/lib/playbook_toolkit/support_scripts/Vaultmgmt.sh ./Vaultmgmt.sh
chmod +x ./Vaultmgmt.sh

cp /var/lib/playbook_toolkit/default_files/defaultplaybookreadme.md ./README.md

echo "running stage 2"
mkdir ./Ansible/instances
mkdir ./Ansible/templates

touch ./Ansible/instances/.gitkeep
touch ./Ansible/templates/.gitkeep

mkdir ./ConfigPacks/base
mkdir ./ConfigPacksVault/base

touch ./ConfigPacks/base/.gitkeep
touch ./ConfigPacksVault/base/.gitkeep


cp /usr/lib/playbook_toolkit/support_scripts/PluginsLauncher.sh ./Plugins/PluginsLauncher.sh
chmod +x ./Plugins/PluginsLauncher.sh

echo "running stage 3"
mkdir ./Ansible/templates/base

mkdir ./Ansible/templates/base/group_vars
mkdir ./Ansible/templates/base/host_vars
mkdir ./Ansible/templates/base/library
mkdir ./Ansible/templates/base/module_utils
mkdir ./Ansible/templates/base/filter_plugins
mkdir ./Ansible/templates/base/roles
mkdir ./Ansible/templates/base/software-to-install
mkdir ./Ansible/templates/base/target-scripts
mkdir ./Ansible/templates/base/config-items

touch ./Ansible/templates/base/group_vars/.gitkeep
touch ./Ansible/templates/base/host_vars/.gitkeep
touch ./Ansible/templates/base/library/.gitkeep
touch ./Ansible/templates/base/module_utils/.gitkeep
touch ./Ansible/templates/base/filter_plugins/.gitkeep
touch ./Ansible/templates/base/roles/.gitkeep
touch ./Ansible/templates/base/software-to-install/.gitkeep
touch ./Ansible/templates/base/target-scripts/.gitkeep
touch ./Ansible/templates/base/config-items/.gitkeep

echo "running stage 4"

cp /var/lib/playbook_toolkit/default_files/baseansibleconfig.cfg ./Ansible/templates/base/ansible.cfg
cp /var/lib/playbook_toolkit/default_files/defaulthosts ./Ansible/templates/base/hosts

echo "running stage 5 - example playbook and data"
playbook_init -n playbook

cp /var/lib/playbook_toolkit/example_data/defaultplaybook.yml ./Ansible/templates/playbook/playbook.yml
cp /var/lib/playbook_toolkit/example_data/defaultconfigpack.yml ./ConfigPacks/playbook/serverIPs.yml
touch ./Ansible/templates/playbook/requirements.yml

echo "setup completed"
