#!/bin/bash
  AUTORUN=false
  while getopts ":n:a:h:" opt; do

    case $opt in
      n)
        playbookname=${OPTARG}
        echo "playbook name set to = $playbookname"
        AUTORUN=true
      ;;
      a)
        if test -f "$(pwd)/playbookpack.meta"; then
          echo 'running in playbook pack so -a not valid'
          exit
        else
          AUTORUN=true
        fi
      ;;
      h)
        echo ''
        echo ' option flags are'
        echo ''
        echo ' -a y  (only valid if not in playbook pack) '
        echo ' -n nameofplaybook'
        echo ' above option result in no confirm prompts please use with care'
        echo ''
        echo ' -h shows this help message' >&2
        exit 1
      ;;
      *)
        echo ''
        echo ' option flags are'
        echo ''
        echo ' -a y   (only valid if not in playbook pack) '
        echo ' -n nameofplaybook'
        echo ' above option result in no confirm prompts please use with care'
        echo ''
        echo ' -h shows this help message' >&2
        exit 1
    esac
  done


# check to see if being run from playbook pack
if test -f "$(pwd)/playbookpack.meta"; then
  # in playbook pack

  if $AUTORUN
  then
    echo "auto run enabled by flag creating specified playbook"
  else

    while true; do
      read -r -p "add playbook to pack ? (Y/N) " yn
      case $yn in
        [Yy]* ) echo "processing" ; break;;
        [Nn]* ) echo "aborting creation of playbook"; exit;;
        * ) echo "Please answer y or n.";;
      esac
    done
    IINITLOOP=true
    while $IINITLOOP; do
      read -r -p "what is the playbook name ? " playbookname

      while true; do
        read -r -p "playbook name set to - $playbookname - is this correct? (Y/N)" ynb
        case $ynb in
          [Yy]* ) echo "processing"; IINITLOOP=false; break;;
          [Nn]* ) echo "retrying"; break;;
              * ) echo "Please answer y or n.";;
        esac
      done

    done

  fi
  echo "makeing folder structures"
  mkdir "./ConfigPacks/$playbookname"
  mkdir "./ConfigPacksVault/$playbookname"
  touch "./ConfigPacks/$playbookname/.gitkeep"
  touch "./ConfigPacksVault/$playbookname/.gitkeep"

  mkdir "./Ansible/templates/$playbookname"

  mkdir "./Ansible/templates/$playbookname/group_vars"
  mkdir "./Ansible/templates/$playbookname/group_vars/vars"
  mkdir "./Ansible/templates/$playbookname/group_vars/vault"
  mkdir "./Ansible/templates/$playbookname/host_vars"
  mkdir "./Ansible/templates/$playbookname/library"
  mkdir "./Ansible/templates/$playbookname/module_utils"
  mkdir "./Ansible/templates/$playbookname/filter_plugins"
  mkdir "./Ansible/templates/$playbookname/roles"
  mkdir "./Ansible/templates/$playbookname/software-to-install"
  mkdir "./Ansible/templates/$playbookname/target-scripts"
  mkdir "./Ansible/templates/$playbookname/config-items"

  touch "./Ansible/templates/$playbookname/group_vars/.gitkeep"
  touch "./Ansible/templates/$playbookname/group_vars/vars/.gitkeep"
  touch "./Ansible/templates/$playbookname/group_vars/vars/.gitkeep"
  touch "./Ansible/templates/$playbookname/host_vars/.gitkeep"
  touch "./Ansible/templates/$playbookname/library/.gitkeep"
  touch "./Ansible/templates/$playbookname/module_utils/.gitkeep"
  touch "./Ansible/templates/$playbookname/filter_plugins/.gitkeep"
  touch "./Ansible/templates/$playbookname/roles/.gitkeep"
  touch "./Ansible/templates/$playbookname/software-to-install/.gitkeep"
  touch "./Ansible/templates/$playbookname/target-scripts/.gitkeep"
  touch "./Ansible/templates/$playbookname/config-items/.gitkeep"

  cp /usr/local/lib/playbook_toolkit/support_scripts/playbook.pb.sh ./Ansible/templates/"$playbookname"/playbook.pb.sh
  chmod +x "./Ansible/templates/$playbookname/playbook.pb.sh"

  cp /usr/local/lib/playbook_toolkit/playbook_pack_init.meta ./Ansible/templates/"$playbookname"/playbook_init.meta

  touch "./Ansible/templates/$playbookname/playbook.yml"
  touch "./Ansible/templates/$playbookname/requirements.yml"

else
  # not in playbook pack
  if $AUTORUN
  then
    echo "auto run enabled by flag creating specified playbook"
  else

    while true; do
      read -r -p "make playbook folder structure in current folder ' $(pwd) ' ? (Y/N) " yn
      case $yn in
        [Yy]* ) echo "processing" ; break;;
        [Nn]* ) echo "aborting creation of playbook"; exit;;
        * ) echo "Please answer y or n.";;
      esac
    done

  fi
  echo "makeing folder structures"

  touch "./.gitkeep"
  mkdir "./group_vars"
  mkdir "./group_vars/vars"
  mkdir "./group_vars/vault"
  mkdir "./host_vars"
  mkdir "./library"
  mkdir "./module_utils"
  mkdir "./filter_plugins"
  mkdir "./roles"
  mkdir "./software-to-install"
  mkdir "./target-scripts"
  mkdir "./config-items"

  touch "./group_vars/.gitkeep"
  touch "./group_vars/vars/.gitkeep"
  touch "./group_vars/vault/.gitkeep"
  touch "./host_vars/.gitkeep"
  touch "./library/.gitkeep"
  touch "./module_utils/.gitkeep"
  touch "./filter_plugins/.gitkeep"
  touch "./roles/.gitkeep"
  touch "./software-to-install/.gitkeep"
  touch "./target-scripts/.gitkeep"
  touch "./config-items/.gitkeep"

  cp /usr/local/lib/playbook_toolkit/support_scripts/playbook.pb.sh ./playbook.pb.sh
  chmod +x "./playbook.pb.sh"

  cp /usr/local/lib/playbook_toolkit/playbook_init.meta ./playbook.meta

  cp /var/lib/playbook_toolkit/default_files/baseansibleconfig.cfg ./ansible.cfg
  cp /var/lib/playbook_toolkit/default_files/defaulthosts ./hosts
  
  touch "./playbook.yml"
  touch "./requirements.yml"

fi








