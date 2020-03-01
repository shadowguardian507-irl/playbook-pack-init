#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
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
echo "playbook-pack-init and playbook-init toolkit uninstaller (Program only)"

if $AUTORUN
then
  echo "auto run enabled by flag"
else
  while true; do
    read -p "do you wish to remove this package ? (Y/N) " yn
    case $yn in
        [Yy]* ) echo processing ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
  done
fi
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
# (ref http://refspecs.linuxfoundation.org/FHS_2.3/fhs-2.3.html)
# remove user runnable scripts in /usr/bin 
rm -f /usr/bin/playbook_init
rm -f /usr/bin/playbook_pack_init
rm -f /usr/bin/playbook_pack_update
# backward compat cleanout
rm -f /usr/bin/playbook-init
rm -f /usr/bin/playbook-pack-init
rm -f /usr/bin/playbook-pack-update

# remove supporting folders (scripts only)
rm -rf /usr/lib/playbook_toolkit








