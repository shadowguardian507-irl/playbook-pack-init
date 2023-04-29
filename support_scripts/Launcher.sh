#!/bin/bash

echo "checking host system compatablity"
printf "."
if ! [ -x "$(command -v playbook_init)" ]; then
  echo ""
  echo 'Error: playbook toolkit is not installed, please download from https://github.com/shadowguardian507-irl/playbook-pack-init and install.' >&2
  exit 1
fi
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
printf "."
echo ""
echo "checks OK"
echo ""

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
  optionsb=()
  commands=()
  i=1 #Index counter menu

  #build fixed command for 0
  commands[0]='echo "Program terminated."'

  #build dynamic menu content arrays
  pausecommand=' && read -p "Press enter to return to the launcher menu"'

  while read -r line
  do
    #option array (for dialog menu)
    playbookfolder="$(basename "$(dirname "$line")" )"
    filenamefull="$(basename "$line")"
    menuoptiontostore="Run $playbookfolder - $(echo "$filenamefull" | cut -f 1 -d '.')"
    options+=("$i" "$menuoptiontostore" )

    #command array (what to run for an option)
    commandtostore="'${line}' ${pausecommand}"
    commands[$i]=$commandtostore
    ((i=i+1))

  done < <(find ./Ansible/templates/ -maxdepth 2 -type f -name "*.pb.sh")

  #build fixed commandsets and menu options
  menuoptiontostore="Add new playbook to pack"
  optionsb+=("$i" "$menuoptiontostore" )
  commands[$i]='playbook_init'
  ((i=i+1))
  menuoptiontostore="Manage Ansible Vault encoded files"
  optionsb+=("$i" "$menuoptiontostore" )
  commands[$i]='./Vaultmgmt.sh'
  ((i=i+1))
  menuoptiontostore="Access Plugins - needs git access to plugin repos"
  optionsb+=("$i" "$menuoptiontostore" )
  commands[$i]='./Plugins/PluginsLauncher.sh'
  ((i=i+1))

  #Build the menu with dynamic content
  selection=$(dialog --clear \
                --backtitle "Enviroment Control Launcher" \
                --title "" \
                --clear \
                --cancel-label "Exit" \
                --menu "Please select an option:"\
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${options[@]}" \
                "" "----------" \
                "${optionsb[@]}" \
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
  eval ${commands[$selection]}

done


