#!/bin/bash
#
# Blackmate v0.2
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

   echo "[*] Creating the new menu entry";

  #Clean any previous application entry and categorie entry
  rm /usr/share/applications/ba-*.desktop 2> /dev/null || true 
  rm /usr/share/desktop-directories/BlackArch*.directory 2> /dev/null || true

  #Update X.BlackArch.menu
  cp /usr/share/blackmate/X-BlackArch.menu /etc/xdg/menus/applications-merged/X-BlackArch.menu

  #Copy the directory file BlackArch (Blackarch -> categorie -> tools...)
  cp /usr/share/blackmate/BlackArch.directory /usr/share/desktop-directories/

  #Generate the new categorie entry menu
  for u in $( ls --color=auto /usr/share/blackmate/menu-i/ | sort ); do  
    
    c=`echo $u | sed 's/BlackArch-//' | sed 's/\.png//'`;

    cat /usr/share/blackmate/dfdir | sed 's/^Name=.*/Name='$c'/' | sed 's/^Icon=.*/Icon=BlackArch-'$c'/' > /usr/share/desktop-directories/BlackArch-$c.directory
    
  done
 
  #Update the default icons of blackarch-menu by the blackmate one
  cp /usr/share/blackmate/menu-i/* /usr/share/icons/hicolor/32x32/apps/ 2> /dev/null || true 

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
   subc=`cat /usr/share/blackmate/tmp/$u/desc | sed 's/blackarch//' | sed '/^\s*$/d' | sed -n '/%GROUPS%/{n;p}' | sed 's/-//'`;

   #Check the group of the current tool, if empty, go to the next iteration
   if [[ -z "$subc" ]]; then
   	continue 1; 
   fi
   
   #Name of the tool
   tname=`cat /usr/share/blackmate/tmp/$u/desc | sed 's/blackarch//' | sed '/^\s*$/d' | sed -n '/%NAME%/{n;p}' | cut -d "-" -f 2`;

  #Set categorie of the subcategorie tool branche
  if [[ $subc == "code-audit" ]] || [[ $subc == 'decompiler' ]] || [[ $subc == 'disassembler' ]] || [[ $subc == 'reversing' ]]; then

    namecat=`echo X-BlackArch-Audit;`;

  elif [[ $subc == 'automation' ]]; then
     
    namecat=`echo X-BlackArch-Automation;`;

  elif [[ $subc == 'backdoor' ]] || [[ $subc == 'keylogger' ]] || [[ $subc == 'malware' ]]; then

    namecat=`echo X-BlackArch-Backdoor;`;

  elif [[ $subc == 'binary' ]]; then

    namecat=`echo X-BlackArch-Binary;`;

  elif [[ $subc == 'bluetooth' ]]; then

    namecat=`echo X-BlackArch-Bluetooth;`;

  elif [[ $subc == 'cracker' ]]; then

    namecat=`echo X-BlackArch-Cracker;`;

  elif [[ $subc == 'crypto' ]]; then

    namecat=`echo X-BlackArch-Crypto;`;

  elif [[ $subc == 'defensive' ]]; then

    namecat=`echo X-BlackArch-Defensive;`;

  elif [[ $subc == 'dos' ]]; then

    namecat=`echo X-BlackArch-Dos;`;

  elif [[ $subc == 'exploitation' ]] || [[ $subc == 'social' ]] || [[ $subc == 'spoof' ]] || [[ $subc == 'fuzzer' ]]; then

    namecat=`echo X-BlackArch-Exploitation;`;

  elif [[ $subc == 'forensic' ]] || [[ $subc == "anti-forensic" ]]; then

   namecat=`echo X-BlackArch-Forensic;`;

  elif [[ $subc == 'honeypot' ]]; then

   namecat=`echo X-BlackArch-Honeypot;`;

  elif [[ $subc == 'mobile' ]]; then

   namecat=`echo X-BlackArch-Mobile;`;
 
  elif [[ $subc == 'networking' ]] || [[ $subc == 'fingerprint' ]] || [[ $subc == 'firmware' ]] || [[ $subc == 'tunnel' ]] ; then

   namecat=`echo X-BlackArch-Networking;`;

  elif [[ $subc == 'scanner' ]] || [[ $subc == 'recon' ]] ; then

   namecat=`echo X-BlackArch-Scanning;`;

  elif [[ $subc == 'sniffer' ]]; then

   namecat=`echo X-BlackArch-Sniffer;`;

  elif [[ $subc == 'voip' ]]; then

   namecat=`echo X-BlackArch-Voip;`;

  elif [[ $subc == 'webapp' ]]; then

   namecat=`echo X-BlackArch-Webapp;`;

  elif [[ $subc == 'windows' ]]; then

   namecat=`echo X-BlackArch-Windows;`;

  elif [[ $subc == 'wireless' ]]; then

   namecat=`echo X-BlackArch-Wireless;`;

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
