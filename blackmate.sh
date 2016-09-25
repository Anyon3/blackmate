#!/bin/bash
#
# Blackmate v0.41
#
# Description : BlackMate is a menu generator for the BlackArch Linux os tools, made for the wm xfce4.
#		It will fetch the latest database of BlackArch and create an entry for each of them in the menu.
#		Start from the version 0.4, the support for mate desktop is removed.
#		You may run the script as often a new added tools is available.
#		  
#
# Author : Dimitri Mader -> dimitri@linux.com
# Url : https://github.com/Anyon3/blackmate
# Gnu / GPL v3

#Check if the script have the root permission
if [[ $EUID -ne 0 ]]; then
   printf 'Blackmate must run with root permission (use sudo or the script will fail)';
   exit 1;
fi

  printf "[*] Creating the new menu entry\n";

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
        cat /usr/share/blackmate/dfdir | sed 's/^Name=.*/Name='$c'/' | 
	        sed 's/^Icon=.*/Icon=BlackArch-'$c'/' > /usr/share/desktop-directories/BlackArch-$c.directory
    
  done

  #Fetch the current icons theme in use 
  printf "[*] Update the icons theme in use\n";

  if [[ -f /home/$SUDO_USER/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]]; then

     thic=`cat /home/$SUDO_USER/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml | grep IconThemeName | 
   		        sed 's/<property name="IconThemeName" type="string" value\="//' | tr -d '"/>' | tr -d ' '`;

  #If the file do not exist, we assume the current theme is the default one (gnome)
  else
     thic=`echo gnome`;
  fi
 
  #Copy the extra icons into the icons theme
  cp /usr/share/blackmate/menu-i/* /usr/share/icons/$thic/32x32/apps/ 2> /dev/null || true
  
  #Set the proper chown and chmod
  chown $SUDO_USER:$SUDO_USER /usr/share/icons/$thic/32x32/apps/ -R 2> /dev/null || true
  chmod 755 /usr/share/icons/$thic/32x32/apps/ -R 2> /dev/null || true

  #Download and generate the latest tools list
  printf "[*] Download the tools list, please wait...\n";

  mkdir /usr/share/blackmate/tmp
  wget -q -P /usr/share/blackmate/ https://mirror.yandex.ru/mirrors/blackarch/blackarch/os/x86_64/blackarch.db.tar.gz 
  tar -zxf /usr/share/blackmate/blackarch.db.tar.gz -C /usr/share/blackmate/tmp

  #Terminal to use for the blackarch entry
  terminal=`echo xfce4-terminal`;
  
  printf "[*] Generating the menu, please wait...\n";

  #Start to loop each tools, set $subc as subcategorie and $tname as name of the tool 
  for u in $( ls --color=auto /usr/share/blackmate/tmp/ | sort ); do

	  #Subcategorie
	  subc=`cat /usr/share/blackmate/tmp/$u/desc | sed 's/blackarch//' | 
		        sed '/^\s*$/d' | sed -n '/%GROUPS%/{n;p}' | sed 's/-//'`;

	   #Check the group of the current tool, if empty, go to the next iteration
	   if [[ -z "$subc" ]]; then
	   	  continue 1; 
	   fi
	   
	   #Name of the tool
	   tname=`cat /usr/share/blackmate/tmp/$u/desc | sed 's/blackarch//' | 
			          sed '/^\s*$/d' | sed -n '/%NAME%/{n;p}' | cut -d "-" -f 2`;

	   #Set categorie of the subcategorie tool branche
	   if [[ $subc == "code-audit" ]] || [[ $subc == 'decompiler' ]] || 
		      [[ $subc == 'disassembler' ]] || [[ $subc == 'reversing' ]]; then

    		namecat=`echo X-BlackArch-Audit;`;

	   elif [[ $subc == 'automation' ]]; then
		 
    		namecat=`echo X-BlackArch-Automation;`;

	   elif [[ $subc == 'backdoor' ]] || [[ $subc == 'keylogger' ]] || 
		        [[ $subc == 'malware' ]]; then

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

	   elif [[ $subc == 'exploitation' ]] || [[ $subc == 'social' ]] || 
		        [[ $subc == 'spoof' ]] || [[ $subc == 'fuzzer' ]]; then

	    namecat=`echo X-BlackArch-Exploitation;`;

	   elif [[ $subc == 'forensic' ]] || [[ $subc == "anti-forensic" ]]; then

	    namecat=`echo X-BlackArch-Forensic;`;

	   elif [[ $subc == 'honeypot' ]]; then

	    namecat=`echo X-BlackArch-Honeypot;`;

	   elif [[ $subc == 'mobile' ]]; then

	    namecat=`echo X-BlackArch-Mobile;`;
	 
	   elif [[ $subc == 'networking' ]] || [[ $subc == 'fingerprint' ]] || 
		        [[ $subc == 'firmware' ]] || [[ $subc == 'tunnel' ]] ; then

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

  printf "[*] Cleanup...\n";

  #Move the .desktop to the right directory
  mv /usr/share/blackmate/ba-*.desktop /usr/share/applications

  #Delete tmp directory
  rm -rf /usr/share/blackmate/tmp/
  rm /usr/share/blackmate/blackarch.db.tar.gz

  echo "[*] Done, in order to have a correct display of the new menu, you may need to restart xfce4";
