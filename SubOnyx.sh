#!/bin/bash

#Author: Onyx Rose
#Date: 11/30/2021
#version: 1.0.0

echo -e "\n********************************************************"
echo      "*                                                      *"
echo      "*   _____ _    _ ____     ____  _   ___     ____   __  *"
echo      "*  / ____| |  | |  _ \   / __ \| \ | \ \   / /\ \ / /  *"
echo      "* | (___ | |  | | |_) | | |  | |  \| |\ \_/ /  \ V /   *"
echo      "*  \___ \| |  | |  _ <  | |  | | .   | \   /    > <    *"
echo      "*  ____) | |__| | |_) | | |__| | |\  |  | |    / . \   *"
echo      "* |_____/ \____/|____/   \____/|_| \_|  |_|   /_/ \_\  *"
echo      "*                                                      *"
echo      "* SubOnyx V1.0.0                                       *"
echo      "* hikihachiman7@gmail.com                              *"
echo      "*                                                      *"
echo -e   "********************************************************\n"


read -p 'Enter the domain name without www ( e.g. example.com) : ' dn

#extracting the domain and  TLD

domain=$(echo "$dn" | cut -f 1 -d ".")
tld=$( echo "$dn" | cut -f 2 -d ".")

#wget processing and ip finding

echo -e  "\n Downloading index ..."
wget -v www.$dn
echo -e "\n index downloaded, proceeding to extract subdomains and requesting zone transferes...\n"
Wsubdomains=$(
for host in $(
        cat index.html | grep -o "[^/]*.$domain\.$tld"|sort -u
); do host $host  | sed 's/ has address / -> /';done
)

#zone transfer requesting

Fsubdomains=$(
for ns in $( host -t ns $dn |cut -f 4 -d" "
);do host -l $dn $ns | sed 's/ has address /->/' && echo -e "\n";done
)

#final output
echo -e "\nWget subdomains:" 
echo  "------------------"
echo "$Wsubdomains"
echo -e "\nZone transfer requests:" 
echo  "------------------"
echo "$Fsubdomains"

#saving the output if the user wants
echo -e "\nDo you want to save the output? "

while read -p " input yes or no [y/Y/yes or n/N/no]: "  userAnswer;
do
        case $userAnswer in
                [yY]*) read -p "Enter filename (e.g output.txt) : " filename
                        echo -e "\n$dn Subdomains" > ${filename} 
                        echo -e "-----------------------------\n">> ${filename}
                       filesave=('echo -e "$Wsubdomains \n $Fsubdomains" >> ${filename}')
                        eval ${filesave}
                        echo -e "\nDone!! \nCheck $filename"
                        rm index.html*
                        break
                        ;;
                [Nn]*) echo -e "\nOkay! \nExiting the script!"
                        rm index.html*
                        exit 0
                        ;;
                    *) echo -e "Please enter a valid input [y or n]"
        esac
done
