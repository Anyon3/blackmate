#!/bin/bash
#
# Blackmate v0.1
#
# Description : BlackMate is a menu generator for the BlackArch Linux os tools, made for the wm Mate and xfce4.
#               It will fetch the latest database of BlackArch and create an entry for each of them in the menu
#		You may run the script as often a new added tools is available
#		The script can handle only 1 wm at the same time
#
# Author : Dimitri Mader -> dimitri@linux.com
# Url : https://github.com/Anyon3/blackmate
# Gnu / GPL v3

#Check if the script is launch with root
if [[ $EUID -ne 0 ]]; then
   echo "Blackmate must be run as root" 
   exit 1
fi

#Check if blackmate is running for the first time
if [[ ! -f /usr/share/applications/BlackArch-Misc.directory ]]; then

    echo "[*] Create the entry Misc";

    #Clean any previous ba-*.desktop 
    rm /usr/share/applications/ba-*.desktop 2> /dev/null || true

    #Delete the entry Website and add the entry Misc 
    rm /usr/share/desktop-directories/BlackArch-Websites.directory 2> /dev/null || true
    cp /usr/share/blackmate/BlackArch-Misc.directory /usr/share/applications
fi

#Download and generate the latest tools list
mkdir /usr/share/blackmate/tmp
wget -P /usr/share/blackmate/ https://mirror.yandex.ru/mirrors/blackarch/blackarch/os/x86_64/blackarch.db.tar.gz 
tar -zxf /usr/share/blackmate/blackarch.db.tar.gz -C /usr/share/blackmate/tmp

#Choice between xfce4 and Mate
printf "For which wm Blackmate shall generate the menu ?\n\n [1] Mate\n [2] Xfce4\n\n Answer : ";
read n

  if [[ $n == '2' ]]; then
	terminal=`echo xfce4-terminal`;
  else
	terminal=`echo mate-terminal`;
  fi

echo "[*] Generating the menu, please wait...";

#Start to loop each tools, set $subc as subcategorie and $tname as name of the tool 
for u in $( ls --color=auto /usr/share/blackmate/tmp/ | sort ); do

   #Subcategorie
   subc=`cat /usr/share/blackmate/tmp/$u/desc | sed 's/blackarch//' | sed '/^\s*$/d' | sed -n '/%GROUPS%/{n;p}' | cut -d "-" -f 2`;
   #Name of the tool
   tname=`cat /usr/share/blackmate/tmp/$u/desc | sed 's/blackarch//' | sed '/^\s*$/d' | sed -n '/%NAME%/{n;p}' | cut -d "-" -f 2`;

  #Set categorie of the subcategorie tool branche
  if [[ $subc == 'reversing ' ]] || 
     [[ $subc == 'disassembler' ]] || 
     [[ $subc == 'binary' ]] || 
     [[ $subc == 'code-audit' ]] || 
     [[ $subc == 'analysis' ]] || 
     [[ $subc == 'debugger' ]] || 
     [[ $subc == 'decompiler' ]]; then

	namecat=`echo X-BlackArch-CodeAnalysis;`;

  elif [[ $subc == 'cracker' ]] || 
       [[ $subc == 'crypto' ]]; then
     
	namecat=`echo X-BlackArch-Cracking;`;

  elif [[ $subc == 'defensive' ]] || 
       [[ $subc == 'honeypot' ]]; then

	namecat=`echo X-BlackArch-Defensive;`;

  elif [[ $subc == 'exploitation' ]] || 
       [[ $subc == 'automation' ]] || 
       [[ $subc == 'dos' ]]; then

	namecat=`echo X-BlackArch-Exploitation;`;

  elif [[ $subc == 'anti-forensic' ]] || 
       [[ $subc == 'unpacker' ]] || 
       [[ $subc == 'forensic' ]] || 
       [[ $subc == 'packer' ]]; then

	namecat=`echo X-BlackArch-Forensic;`;

  elif [[ $subc == 'malware' ]] || 
       [[ $subc == 'keylogger' ]] || 
       [[ $subc == 'backdoor' ]]; then

	namecat=`echo X-BlackArch-Malware;`;

  elif [[ $subc == 'networking' ]] || 
       [[ $subc == 'proxy' ]] || 
       [[ $subc == 'spoofer' ]] || 
       [[ $subc == 'tunnel' ]] || 
       [[ $subc == 'spoof' ]]; then

	namecat=`echo X-BlackArch-Networking;`;

  elif [[ $subc == 'bluetooth' ]] || 
       [[ $subc == 'nfc' ]] || 
       [[ $subc == 'wireless' ]]; then

	namecat=`echo X-BlackArch-Wireless;`;

  elif [[ $subc == 'voip' ]] || 
       [[ $subc == 'mobile' ]]; then 

     	namecat=`echo X-BlackArch-Telephony;`;

  elif [[ $subc == 'scanner' ]] || 
       [[ $subc == 'fuzzer' ]] || 
       [[ $subc == 'fingerprint' ]] ||
       [[ $subc == 'recon' ]]; then

     	namecat=`echo X-BlackArch-Scanning;`;

  elif [[ $subc == 'sniffer' ]]; then

     	namecat=`echo X-BlackArch-Sniffing;`;
  else
  
     namecat=`echo X-BlackArch-Misc;`;
fi

  #For each tools of the target categorie
  for i in $tname; do

  #Parse the default launcher and set his name
  cat /usr/share/blackmate/dfdesk | sed 's/^Name=.*/Name='$i'/' |
  #Set the bash command to execute
  sed 's/^Exec=.*/Exec='$terminal' -e "bash -ic \\"\/usr\/bin\/'$i'; exec bash"\\"/' |
  #Set the categorie to the launcher && Set the name file to ba-`toolsname`.desktop 
  sed 's/Categories=.*/Categories='$namecat';/' > /usr/share/blackmate/ba-$i.desktop
 
  #End of the current tool
  done

#End of the current categorie
done

echo "[*] Cleanup...";

#Move the .desktop to the right directory
mv /usr/share/blackmate/ba-*.desktop /usr/share/applications

#Delete tmp directory
rm -rf /usr/share/blackmate/tmp/
rm /usr/share/blackmate/blackarch.db.tar.gz

echo "[*] Done";
