#!/bin/bash

declare -a options
declare -a commands

#dialog config options
TERMINAL=$(tty) #Gather current terminal session for appropriate redirection
HEIGHT=20
WIDTH=76
DIALOG_CANCEL=1
DIALOG_ESC=255
CHOICE_HEIGHT=16

#start of menu

#loop to keep menu on return from execution of task
while true; do

  #reset arrays
  options=()
  commands=()
  
  i=1 #Index counter menu

  #build fixed command for 0
  commands[0]='echo "Program terminated."'
  commands[1]='env EDITOR=nano ansible-vault create --vault-id basevault@prompt ./ConfigPacksVault/base/basevault.yml'
  commands[2]='env EDITOR=nano ansible-vault edit --vault-id basevault@prompt ./ConfigPacksVault/base/basevault.yml'
  commands[3]='env EDITOR=nano ansible-vault rekey --vault-id basevault@prompt ./ConfigPacksVault/base/basevault.yml'

  #build fixed menu options
  menuoptiontostore="create vault for base vault"
  options+=("$i" "$menuoptiontostore" )
  ((i=i+1))
  menuoptiontostore="edit vault for base vault"
  options+=("$i" "$menuoptiontostore" )
  ((i=i+1))
  menuoptiontostore="rekey vault for base vault"
  options+=("$i" "$menuoptiontostore" )
  ((i=i+1))

  #build dynamic menu content arrays
  
  while read -r line
  do
    #option array (for dialog menu)
    playbookfolder="$(basename "$line")"

    menuoptiontostore="create vault for $playbookfolder"
    options+=("$i" "$menuoptiontostore" )
    
    commandtostore="env EDITOR=nano ansible-vault create --vault-id playbookvault@prompt './ConfigPacksVault/${playbookfolder}/playbookvault.yml'"
    commands[$i]=$commandtostore

    ((i=i+1))

    menuoptiontostore="edit vault for $playbookfolder"
    options+=("$i" "$menuoptiontostore" )
    
    commandtostore="env EDITOR=nano ansible-vault edit --vault-id playbookvault@prompt './ConfigPacksVault/${playbookfolder}/playbookvault.yml'"
    commands[$i]=$commandtostore
    
    ((i=i+1))
    menuoptiontostore="rekey vault for $playbookfolder"
    options+=("$i" "$menuoptiontostore" )

    commandtostore="env EDITOR=nano ansible-vault rekey --vault-id playbookvault@prompt './ConfigPacksVault/${playbookfolder}/playbookvault.yml'"
    commands[$i]=$commandtostore
    
    ((i=i+1))  

  done < <(find ./Ansible/templates/ -maxdepth 1 -type d | grep -v base | sed -n '1!p')

  #Build the menu with dynamic content
  selection=$(dialog --clear \
                --backtitle "Vault Management Launcher" \
                --title "" \
                --clear \
                --cancel-label "return to main launcher" \
                --menu "Please select an option:"\
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${options[@]}" \
                2>&1 >"$TERMINAL")
  exit_status=$?
  exec 3>&-
  case $exit_status in
    "$DIALOG_CANCEL")
      clear
      echo "Program terminated."
      exit
      ;;
    "$DIALOG_ESC")
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  clear
  eval "${commands[$selection]}"

done
