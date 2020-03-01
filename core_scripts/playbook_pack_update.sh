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
echo "initialising playbook pack update in directory $(pwd)"
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
echo "running update"

cp /usr/lib/playbook_toolkit/playbook_pack_init.meta ./playbookpack.meta

cp /usr/lib/playbook_toolkit/support_scripts/Launcher.sh ./Launcher.sh
chmod +x ./Launcher.sh

cp /usr/lib/playbook_toolkit/support_scripts/Vaultmgmt.sh ./Vaultmgmt.sh
chmod +x ./Vaultmgmt.sh

cp /usr/lib/playbook_toolkit/support_scripts/PluginsLauncher.sh ./Plugins/PluginsLauncher.sh
chmod +x ./Plugins/PluginsLauncher.sh

echo "update completed"
