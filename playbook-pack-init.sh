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
    read -p "do you wish to continue ? (Y/N) " yn
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

touch ./README.md
touch ./Launcher.sh
touch ./Vaultmgmt.sh
touch ./Playbook.sh
touch ./Ansible/.gitkeep
touch ./Resources/.gitkeep
touch ./ConfigPacks/.gitkeep
touch ./ConfigPacksVault/.gitkeep
touch ./Plugins/.gitkeep

chmod +x ./Launcher.sh
cat << 'EOF' > ./Launcher.sh

#!/bin/bash

echo "checking host system compatablity"
printf "."
if ! [ -x "$(command -v dialog)" ]; then
  echo ""
  echo 'Error: dialog is not installed.' >&2
  exit 1
fi
printf "."
if ! [ -x "$(command -v ansible-vault)" ]; then
  echo ""
  echo 'Error: ansible-vault is not installed.' >&2
  exit 1
fi
printf "."
if ! [ -x "$(command -v ansible-galaxy)" ]; then
  echo ""
  echo 'Error: ansible-galaxy is not installed.' >&2
  exit 1
fi
printf "."
if ! [ -x "$(command -v ansible-playbook)" ]; then
  echo ""
  echo 'Error: ansible-playbook is not installed.' >&2
  exit 1
fi
printf "."
if ! [ -x "$(command -v rpl)" ]; then
  echo ""
  echo 'Error: rpl is not installed.' >&2
  exit 1
fi
printf "."
if ! [ -x "$(command -v cat)" ]; then
  echo ""
  echo 'Error: cat is not installed.' >&2
  exit 1
fi
printf "."
if ! [ -x "$(command -v sshpass)" ]; then
  echo ""
  echo 'Error: sshpass is not installed.' >&2
  exit 1
fi
printf "."
printf "."
echo ""
echo "checks OK"
echo ""

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Enviroment Control Launcher" \
    --title "Menu" \
    --clear \
    --cancel-label "Exit" \
    --menu "Please select:" $HEIGHT $WIDTH 8 \
    "1" "Manage Ansible Vault encoded files" \
    "2" "Access Plugins (needs git access to plugin repos)" \
    "3" "Run playbook" \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Program terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  case $selection in
    0 )
      clear
      echo "Program terminated."
      ;;
    1 )
      clear
      ./Vaultmgmt.sh
      ;;
    2 )
      clear
      ./Plugins/PluginsLauncher.sh
      ;;
    3 )
      clear
      ./Playbook.sh
      read -p "Press enter to return to the launcher menu"
      ;;
  esac
done

EOF

chmod +x ./Vaultmgmt.sh
cat << 'EOF' > ./Vaultmgmt.sh
#!/bin/bash

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Launcher  -  Ansible Vault Managment" \
    --title "Menu" \
    --clear \
    --cancel-label "Return to main launcher" \
    --menu "Please select:" $HEIGHT $WIDTH 4 \
    "1" "edit basevault.yml " \
    "2" "edit playbookvault.yml " \
    "3" "change password on basevault.yml " \
    "4" "change password on playbookvault.yml " \
    "5" "create basevault.yml " \
    "6" "create playbookvault.yml " \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Program terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  case $selection in
    0 )
      clear
      echo "Program terminated."
      ;;
    1 )
      clear
      env EDITOR=nano ansible-vault edit --vault-id basevault@prompt ./ConfigPacksVault/base/basevault.yml
      ;;
    2 )
      clear
      env EDITOR=nano ansible-vault edit --vault-id playbookvault@prompt ./ConfigPacksVault/playbook/playbookvault.yml
      ;;
    3 )
      clear
      env EDITOR=nano ansible-vault rekey --vault-id basevault@prompt ./ConfigPacksVault/base/basevault.yml
      ;;
    4 )
      clear
      env EDITOR=nano ansible-vault rekey --vault-id playbookvault@prompt ./ConfigPacksVault/playbook/playbookvault.yml
      ;;
    5 )
      clear
      env EDITOR=nano ansible-vault create --vault-id basevault@prompt ./ConfigPacksVault/base/basevault.yml
      ;;
    6 )
      clear
      env EDITOR=nano ansible-vault create --vault-id playbookvault@prompt ./ConfigPacksVault/playbook/playbookvault.yml
      ;;
  esac
done

EOF

chmod +x ./Playbook.sh
cat << 'EOF' > ./Playbook.sh

#!/bin/bash
echo "Building ansible instance folder structure ....."
uuid=$(uuidgen)
uuid=${uuid^^}

mkdir ./Ansible/instances/$uuid
echo "importing base files/folders"
cp -R ./Ansible/templates/base/.  ./Ansible/instances/$uuid
echo "importing playbook spersific files/folders"
cp -R -f ./Ansible/templates/playbook/.  ./Ansible/instances/$uuid

mkdir ./Ansible/instances/$uuid/configpacks
echo "importing base config packs"
cp -R ./ConfigPacks/base/. ./Ansible/instances/$uuid/configpacks
echo "importing playbook config packs"
cp -R ./ConfigPacks/playbook/. ./Ansible/instances/$uuid/configpacks
echo "importing base vault locked config packs"
cp -R ./ConfigPacksVault/base/. ./Ansible/instances/$uuid/configpacks
echo "importing playbook vault locked config packs"
cp -R ./ConfigPacksVault/playbook/. ./Ansible/instances/$uuid/configpacks
echo "Accessing ansible instance ....."

cd ./Ansible/instances/$uuid/
ansible-galaxy install -r requirements.yml --roles-path=roles
ansible-playbook --vault-id basevault@prompt --vault-id playbookvault@prompt  playbook.yml 

cd ../../../
rm -rf ./Ansible/instances/$uuid/

EOF

cat << 'EOF' > ./README.md
# Ansible Playbook pack to ............
======
## Dependency list
### system installed

 - rpl
 - bash
 - ansible
 - python2-pip
---
please use the Launcher script in this folder to access the functions of this playbook pack

EOF


echo "running stage 2"
mkdir ./Ansible/instances
mkdir ./Ansible/templates

touch ./Ansible/instances/.gitkeep
touch ./Ansible/templates/.gitkeep

mkdir ./ConfigPacks/base
mkdir ./ConfigPacks/playbook
mkdir ./ConfigPacksVault/base
mkdir ./ConfigPacksVault/playbook

touch ./ConfigPacks/base/.gitkeep
touch ./ConfigPacks/playbook/.gitkeep
touch ./ConfigPacksVault/base/.gitkeep
touch ./ConfigPacksVault/playbook/.gitkeep

touch ./Plugins/PluginsLauncher.sh
chmod +x ./Plugins/PluginsLauncher.sh

cat << 'EOF' > ./Plugins/PluginsLauncher.sh

#!/bin/bash
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

cd ./Plugins

while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Enviroment Control Launcher - Plugins Launcher" \
    --title "Menu" \
    --clear \
    --cancel-label "Return to main launcher" \
    --menu "Please select:" $HEIGHT $WIDTH 4 \
    "1" "a plugin target" \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Program terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  case $selection in
    0 )
      clear
      echo "Program terminated."
      ;;
    1 )
      clear
      mkdir ./A-Plugin-Target
      cp ./A-Plugin-Target.sh ./A-Plugin-Target/A-Plugin-Target.sh 
      ./A-Plugin-Target/A-Plugin-Target.sh
      ;;
  esac
done

EOF

touch ./Plugins/A-Plugin-Target.sh
chmod +x ./Plugins/A-Plugin-Target.sh

cat << 'EOF' > ./Plugins/A-Plugin-Target.sh

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

cd ./A-Plugin-Target

while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Enviroment Control Launcher - A-Plugin-Target Launcher" \
    --title "Menu" \
    --clear \
    --cancel-label "Return to main launcher" \
    --menu "Please select:" $HEIGHT $WIDTH 4 \
    "1" "download/update plugins" \
    "2" "launch plugin" \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Program terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  case $selection in
    0 )
      clear
      echo "Program terminated."
      ;;
    1 )
      clear
      echo "Clearing old plugin installes"
      rm -rf ./target1
      echo "Downloading most recent plugin versions"
      git clone git@github.com:example-wosetwh48943g4897/target1.git
      read -p "Press enter to return to the launcher menu"
      ;;
    2 )
      clear
      cd ./target1
      cp -R ../../../ConfigPacks/* ./ConfigPacks
      cp -R ../../../ConfigPacksVault/* ./ConfigPacksVault
      ./Launcher.sh
      cd ../
      ;;
  esac
done

EOF

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

mkdir ./Ansible/templates/playbook

mkdir ./Ansible/templates/playbook/group_vars
mkdir ./Ansible/templates/playbook/host_vars
mkdir ./Ansible/templates/playbook/library
mkdir ./Ansible/templates/playbook/module_utils
mkdir ./Ansible/templates/playbook/filter_plugins
mkdir ./Ansible/templates/playbook/roles
mkdir ./Ansible/templates/playbook/software-to-install
mkdir ./Ansible/templates/playbook/target-scripts
mkdir ./Ansible/templates/playbook/config-items

touch ./Ansible/templates/playbook/group_vars/.gitkeep
touch ./Ansible/templates/playbook/host_vars/.gitkeep
touch ./Ansible/templates/playbook/library/.gitkeep
touch ./Ansible/templates/playbook/module_utils/.gitkeep
touch ./Ansible/templates/playbook/filter_plugins/.gitkeep
touch ./Ansible/templates/playbook/roles/.gitkeep
touch ./Ansible/templates/playbook/software-to-install/.gitkeep
touch ./Ansible/templates/playbook/target-scripts/.gitkeep
touch ./Ansible/templates/playbook/config-items/.gitkeep

echo "running stage 4"


touch ./Ansible/templates/base/ansible.cfg

cat << 'EOF' > ./Ansible/templates/base/ansible.cfg

[defaults]
inventory = ./hosts
remote_tmp = /tmp/.ansible-${USER}/tmp
nocows = 1
host_key_checking = False
record_host_keys = False

[ssh_connection]
ssh_args=-o ForwardAgent=yes
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r

EOF

touch ./Ansible/templates/base/hosts

echo "running stage 5 - example playbook and data"

touch ./Ansible/templates/playbook/playbook.yml
cat << 'EOF' > ./Ansible/templates/playbook/playbook.yml

---
- hosts: localhost
  tasks:
  - name: include var config packs
    include_vars:
      dir: configpacks
      extensions: 
            - yml
      ignore_files: .gitkeep

  - name: IP list
    debug:
      msg:  "{{ iploader.ip_cidr }}"
    loop: "{{ serveriplist }}"
    loop_control:
      loop_var: iploader

EOF

touch ./ConfigPacks/playbook/serverIPs.yml

cat << 'EOF' > ./ConfigPacks/playbook/serverIPs.yml
---
serveriplist:
  - ip_cidr : "10.10.10.10/24"
  - ip_cidr : "11.11.11.11/24"
EOF

touch ./Ansible/templates/playbook/requirements.yml

echo "setup completed"
