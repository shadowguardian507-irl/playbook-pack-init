# playbook pack init and playbook init toolkit

[![Build Status](https://dev.azure.com/shadowguardian507/playbook-pack-init/_apis/build/status/shadowguardian507-irl.playbook-pack-init?branchName=master)](https://dev.azure.com/shadowguardian507/playbook-pack-init/_build/latest?definitionId=1&branchName=master)

## Tool kit management

### Install

* clone this repo to a folder on your system
* run the install.sh script in the root of the repository

### Uninstall (app only, retain support dirs incase you added things to them)

* clone this repo to a folder on your system
* run the uninstall.sh script in the root of the repository

### Full/Purge Uninstall (all installed file and folders, even if you added to them)

* clone this repo to a folder on your system
* run the uninstall_purge.sh script in the root of the repository

## using the tool kit

To make a new playbook pack run the command ' playbook_pack_init ' or ' playbook-pack-init '  
this will make a new playbook pack in the current directory

To make just a playbook (which you can later copy to a pack)  
run the command ' playbook_init ' or ' playbook-init '

The command ' playbook_pack_update ' or ' playbook-pack-update '  
will update a playbook pack in the current directory, to the currently system installed script versions  
  
note the ".pb.sh" files in each playbook folder will not be updated by this command,  
if you want to update those then run the command ' playbook_update ' or ' playbook-update ',  
in each playbook folder of the pack

## Tool kit dependencies

The following apps need to be installed for the tool kit to fully function
* dialog
* ansible-vault
* ansible-galaxy
* ansible-playbook
* rpl
* cat

## Examples of use

### Setup a new pack

![setup a new pack](https://github.com/shadowguardian507-irl/playbook-pack-init-docs/blob/master/Images/run-on-new-folder.png?raw=true)

### First run of main Launcher

![first run of main Launcher](https://github.com/shadowguardian507-irl/playbook-pack-init-docs/blob/master/Images/Main-Launcher.PNG?raw=true)

### Vault managment menu

![vault managment](https://github.com/shadowguardian507-irl/playbook-pack-init-docs/blob/master/Images/Vault-Launcher.PNG?raw=true)

### Add new playbook to the pack

![add new playbook to the pack](https://github.com/shadowguardian507-irl/playbook-pack-init-docs/blob/master/Images/add-playbook-to-pack.PNG?raw=true)
