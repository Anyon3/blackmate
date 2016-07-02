#!/bin/bash
#
# First shot, considering this as an alpha version
#
# Description : BlackMate is a generator menu of the BlackArch tools for the window manager Mate
#               This will create a new entry for the menu and generate for each categories, the .desktop launcher of the tools list.
#				Make sure mate-terminal is available on your system
#				This script need to be start as root 
#
# Author : Dimitri Mader -> dimitri@linux.com
# Gnu / GPL v3

#Check if the script is launch with root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Clean any previous ba-*.desktop 
rm /usr/share/applications/ba-*.desktop 2> /dev/null || true

#Delete the entry Website and add the entry Misc 
rm /usr/share/desktop-directories/BlackArch-Websites.directory 2> /dev/null || true
cp BlackArch-Misc.directory /usr/share/applications/

#Start to loop each categories
for u in $( ls categories/ | sort ); do

  #Set namecat var to his right categorie name

  if [[ "$u" == 'reversing ' ]] || [[ "$u" == 'disassembler' ]] || [[ "$u" == 'binary' ]] || [[ "$u" == 'code-audit' ]] || [[ "$u" == 'analysis' ]] || 
     [[ "$u" == 'debugger' ]] || [[ "$u" == 'decompiler' ]]; then

     namecat=`echo X-BlackArch-CodeAnalysis;`;

  elif [[ "$u" == 'cracker' ]] || [[ "$u" == 'crypto' ]]; then
     
     namecat=`echo X-BlackArch-Cracking;`;

  elif [[ "$u" == 'defensive' ]] || [[ "$u" == 'honeypot' ]]; then

     namecat=`echo X-BlackArch-Defensive;`;

  elif [[ "$u" == 'exploitation' ]] || [[ "$u" == 'automation' ]] || [[ "$u" == 'dos' ]]; then

     namecat=`echo X-BlackArch-Exploitation;`;

  elif [[ "$u" == 'anti-forensic' ]] || [[ "$u" == 'unpacker' ]] || [[ "$u" == 'forensic' ]] || [[ "$u" == 'packer' ]]; then

    namecat=`echo X-BlackArch-Forensic;`;

  elif [[ "$u" == 'malware' ]] || [[ "$u" == 'keylogger' ]] || [[ "$u" == 'backdoor' ]]; then

    namecat=`echo X-BlackArch-Malware;`;

  elif [[ "$u" == 'networking' ]] || [[ "$u" == 'proxy' ]] || [[ "$u" == 'spoofer' ]] || [[ "$u" == 'tunnel' ]] || [[ "$u" == 'spoof' ]]; then

     namecat=`echo X-BlackArch-Networking;`;

  elif [[ "$u" == 'bluetooth' ]] || [[ "$u" == 'nfc' ]] || [[ "$u" == 'wireless' ]]; then

     namecat=`echo X-BlackArch-Wireless;`;

  elif [[ "$u" == 'voip' ]] || [[ "$u" == 'mobile' ]]; then 

     namecat=`echo X-BlackArch-Telephony;`;

  elif [[ "$u" == 'scanner' ]] || [[ "$u" == 'fuzzer' ]] || [[ "$u" == 'fingerprint' ]] || [[ "$u" == 'recon' ]]; then

     namecat=`echo X-BlackArch-Scanning;`;

  elif [[ "$u" == 'sniffer' ]]; then

     namecat=`echo X-BlackArch-Sniffing;`;

  else

     namecat=`echo X-BlackArch-Misc;`;
fi

#Extract name of the tools 
a=`cat categories/$u | awk -F '|' '{ print $1 }'`;

#For each tools of the target categorie
for i in $a; do

  #Parse the default launcher and set his name
  cat dfdesk | sed 's/^Name=.*/Name='$i'/' |
	       #Set the bash command to execute
               sed 's/^Exec=.*/Exec=mate-terminal -e "bash -ic \\"\/usr\/bin\/'$i'; exec bash"\\"/' |
	       #Set the categorie to the launcher && Set the name file to ba-`toolsname`.desktop 
	       sed 's/Categories=.*/Categories='$namecat';/' > ba-$i.desktop
 
  #End of the current tool
  done

#End of the current categorie
done

#Move the .desktop to the right directory
mv ba-*.desktop /usr/share/applications
