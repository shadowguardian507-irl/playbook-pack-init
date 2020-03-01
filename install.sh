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
echo "playbook-pack-init and playbook-init toolkit installer"

if $AUTORUN
then
  echo "auto run enabled by flag"
else
  while true; do
    read -p "do you wish to install this package ? (Y/N) " yn
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
# put user runnable scripts in /usr/bin 
cp $ABSDIR/core_scripts/playbook_init.sh /usr/bin/playbook_init
cp $ABSDIR/core_scripts/playbook_update.sh /usr/bin/playbook_update
cp $ABSDIR/core_scripts/playbook_pack_init.sh /usr/bin/playbook_pack_init
cp $ABSDIR/core_scripts/playbook_pack_update.sh /usr/bin/playbook_pack_update

# make user runnable scripts executable
chmod +x /usr/bin/playbook_init
chmod +x /usr/bin/playbook_update
chmod +x /usr/bin/playbook_pack_init
chmod +x /usr/bin/playbook_pack_update
# backward compat
ln -s /usr/bin/playbook_init /usr/bin/playbook-init
ln -s /usr/bin/playbook_update /usr/bin/playbook-update
ln -s /usr/bin/playbook_pack_init /usr/bin/playbook-pack-init
ln -s /usr/bin/playbook_pack_update /usr/bin/playbook-pack-update

# make supporting folders
mkdir /usr/lib/playbook_toolkit
mkdir /usr/lib/playbook_toolkit/support_scripts
mkdir /var/lib/playbook_toolkit
mkdir /var/lib/playbook_toolkit/default_files
mkdir /var/lib/playbook_toolkit/example_data

# put scripts and default/resource files in place
cp -R $ABSDIR/support_scripts/* /usr/lib/playbook_toolkit/support_scripts
cp -R $ABSDIR/default_files/*  /var/lib/playbook_toolkit/default_files
cp -R $ABSDIR/example_data/*  /var/lib/playbook_toolkit/example_data

# tag meta
cp $ABSDIR/meta/playbook_init.meta /usr/lib/playbook_toolkit/playbook_init.meta
cp $ABSDIR/meta/playbook_pack_init.meta /usr/lib/playbook_toolkit/playbook_pack_init.meta








