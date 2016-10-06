
#!/bin/bash

#### Author: Ahmed M. Alawy
#### Date: 07-29-2015
#### Description: Modify Hardware UUID of cloned VirtualBox to match that of the original vm.
#### Problem: Windows machines activation re-triggered on cloning of virtual machine.

#windows virtualbox machines
originalVirtualMachineName="win10-0"
clonedVirtualMachineName="win10-0 Clone"
orgVMUUID=""
clonedVMUUID=""

## define extra string in target UUID string returned by showvminfo
replaceString="Hardware UUID: "
useString=""

function getVMHUUID(){
    #get the hardware UUID for the original machine
    vmHardwareUUID=$(VBoxManage showvminfo "$1" | grep "Hardware UUID")

    ##remove string "Hardware UUID: " returned by showvminfo
    strippedUUIDString=${vmHardwareUUID/$replaceString/$useString}

    if [[ "$1" == "$originalVirtualMachineName" ]]; then
      orgVMUUID=$(echo $strippedUUIDString | sed 's/$useString/$replaceString/g')
      #echo "get original vm <<""$1"">> Hardware UUID: " $orgVMUUID
      printVMHUUID "get original vm"  "$1" "$orgVMUUID"
    else
      clonedVMUUID=$(echo $strippedUUIDString | sed 's/$useString/$replaceString/g')
      #echo "get cloned vm <<""$1"">> Hardware UUID: " $clonedVMUUID
      printVMHUUID "get cloned vm " "$1" "$clonedVMUUID"
    fi
}

function printVMHUUID(){
    echo "$1 <<""$2"">> Hardware UUID: " "$3"
}

function changeClonedVMHUUID(){
    printVMHUUID "--- Changing vm " "$1" "$clonedVMUUID"
    $(VBoxManage modifyvm "$1" --hardwareuuid "$2")
    printVMHUUID "Changed cloned vm " "$1" "$2"
}

##uncomment for testing..
#changeClonedVMHUUID "${clonedVirtualMachineName}"  "a99cf7fa-03b2-4af5-a45b-b590334212c1"

#print out the UUID
echo "--- Getting UUIDs before modification"

#print out the UUID for the original VM]
getVMHUUID "${originalVirtualMachineName}"
getVMHUUID "${clonedVirtualMachineName}"
echo

#print out the UUID
echo "--- Printing UUIDs before modification"

#print out the UUID for the original VM
printVMHUUID "original vm " "${originalVirtualMachineName}" $orgVMUUID
printVMHUUID "cloned vm " "${clonedVirtualMachineName}" $clonedVMUUID
echo

## change the UUID of cloned VM to original VM UUID
changeClonedVMHUUID "${clonedVirtualMachineName}"  "$orgVMUUID"
echo

#print out the UUID
echo "--- Getting UUIDs after modification"
getVMHUUID "${originalVirtualMachineName}"
getVMHUUID "${clonedVirtualMachineName}"
echo

#print out the UUID for the original VM
echo "--- Changed cloned VM UUID"