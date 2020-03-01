#!/bin/bash

ABSPATH=$(readlink -f "$0")
ABSDIR=$(dirname "$ABSPATH")
ABSPATHNOEXT=${ABSPATH%%.*}
SCRIPTNAMENOEXT=${ABSPATHNOEXT##*/}

# check to see if being run from playbook pack
if test -f "$ABSDIR/../../../playbookpack.meta"; then
  # in playbook pack
  echo "Building ansible instance folder structure ....."
  uuid=$(uuidgen)
  uuid=${uuid^^}

  playbookfolder=$ABSDIR
  playbookfoldername="$(basename "$playbookfolder" )"

  cd "$playbookfolder" || exit

  mkdir "../../instances/$uuid"
  echo "Importing base files/folders"
  cp -R ../base/.  "../../instances/$uuid"
  echo "Importing playbook spersific files/folders"
  cp -R -f "$playbookfolder/."  "../../instances/$uuid"

  mkdir "../../instances/$uuid/configpacks"
  echo "Importing base config packs"
  cp -R ../../../ConfigPacks/base/. "../../instances/$uuid/configpacks"
  echo "Importing playbook config packs"
  cp -R "../../../ConfigPacks/$playbookfoldername/". "../../instances/$uuid/configpacks"

  if [ "$(ls ../../../ConfigPacksVault/base/)" ]; then
    echo "Importing base vault locked config packs"
    cp -R ../../../ConfigPacksVault/base/. "../../instances/$uuid/configpacks"
    basepackvault=true
  else
    echo "No vault locked config packs found in base config packs"
    basepackvault=false
  fi

  if [ "$(ls "../../../ConfigPacksVault/$playbookfoldername/")" ]; then
    echo "Importing playbook vault locked config packs"
    cp -R "../../../ConfigPacksVault/$playbookfoldername/." "../../instances/$uuid/configpacks"
    playbookpackvault=true
  else
    echo "No vault locked config packs found in playbook config packs"
    playbookpackvault=false
  fi

  echo "protecting ansible instance ....."

  chmod -R 750 "../../instances/$uuid/"

  echo "Accessing ansible instance ....."

  cd "../../instances/$uuid/" || exit
# endof playbook pack only section
fi

  if [ -f ./requirements.yml ]
  then
    if [ -s ./requirements.yml ]
    then
      echo "Loading required modules"
      ansible-galaxy install -r requirements.yml --roles-path=roles
    else
      echo "No modules to load"
    fi
  else
    echo "No modules file defined"
  fi

if test -f "$ABSDIR/../../../playbookpack.meta"; then
  # in playbook pack
  if  $playbookpackvault && $basepackvault
  then
    echo "Both vaults active"
    ansible-playbook --vault-id basevault@prompt --vault-id playbookvault@prompt "$SCRIPTNAMENOEXT.yml"
  else
    if $playbookpackvault
    then
      echo "playbook vault active"
      ansible-playbook --vault-id playbookvault@prompt  "$SCRIPTNAMENOEXT.yml"
    else
      if $basepackvault
      then
        echo "Base vault active"
        ansible-playbook --vault-id basevault@prompt  "$SCRIPTNAMENOEXT.yml"
      else
        echo "No vault active"
        ansible-playbook "$SCRIPTNAMENOEXT.yml"
      fi
    fi 
  fi
  # endof playbook pack only section
else
  # only when not in playbook pack
  if [ "$(ls "./group_vars/vault/")" ]; then
    echo "vault locked file(s) found please enter vault id string"
    echo "eg. --vault-id basevault@prompt --vault-id playbookvault@prompt"
    read -r -p "" vaultstring
    ansible-playbook "$vaultstring $SCRIPTNAMENOEXT.yml"
  else
    echo "No vault active"
    ansible-playbook "$SCRIPTNAMENOEXT.yml"
  fi
  # endof non-paybookpack section
fi

# check to see if being run from playbook pack
if test -f "$ABSDIR/../../../playbookpack.meta"; then
  cd ../../../ || exit
  rm -rf "./Ansible/instances/$uuid/"
fi
# endof playbook pack only section
