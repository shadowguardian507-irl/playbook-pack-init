#!/bin/bash
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

cd ./Plugins || exit

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
