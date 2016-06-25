#!/bin/bash
#
# First shot, considering this as an alpha version
#
# Description : Tools menu generator for gtk based desktop, tested on xfce4 and mate-desktop
#               This will create new .desktop base on the tools list of BlackArch, those shall be move to /usr/share/applications/
#
# Author : Dimitri Mader -> dimitri@linux.com
# Gnu / GPL v3


  for u in $( ls categories/ | sort ); do

  cntools=`wc -l < categories/$u`;

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

a=`cat categories/$u | sed 's/|/\n/g' | sed 's/http.*//' | sed '/^$/d' | sort -r | head -n $cntools`;

  for i in $a; do

         cat gendesk | sed -e 's/Name=.*/Name='$i'/' | sed -e 's/TryExec=.*/TryExec=\/usr\/bin\/'$i'/' | 
		       sed 's/Exec=.*/Exec=sh -c '\''\/usr\/bin\/'$i' -Help;$SHELL'\''/' | 
	               sed -e 's/Categories=.*/Categories='$namecat'/' > ba-$i.desktop
  done

done
