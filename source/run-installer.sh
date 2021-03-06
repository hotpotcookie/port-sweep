#!/bin/bash
#----------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[36m"
ENDCOLOR="\e[0m"
#----------
check_curl=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
check_nmap=$(dpkg-query -W -f='${Status}' nmap 2>/dev/null | grep -c "ok installed")
check_ping=$(dpkg-query -W -f='${Status}' iputils-ping 2>/dev/null | grep -c "ok installed")
check_ncat=$(dpkg-query -W -f='${Status}' netcat-openbsd 2>/dev/null | grep -c "ok installed")
check_tor=$(dpkg-query -W -f='${Status}' tor 2>/dev/null | grep -c "ok installed")
check_proxychains=$(dpkg-query -W -f='${Status}' proxychains 2>/dev/null | grep -c "ok installed")
#----------
echo -e "${YELLOW}[sweep]${ENDCOLOR}: Updating Packages ...\n---"
apt-get update -y & wait
echo "---"			
#----------	
if [[ "$check_ping" -eq 0 ]]; then
	echo -e "${YELLOW}[sweep]${ENDCOLOR}: Installing iputils-ping ...\n---"		
	apt-get install iputils-ping -y & wait
	echo "---"		
else
	echo -e "${YELLOW}[sweep]${ENDCOLOR}: iputils-ping have been installed ..."				
fi
if [[ "$check_curl" -eq 0 ]]; then
	echo -e "${YELLOW}[sweep]${ENDCOLOR}: Installing curl ...\n---"		
	apt-get install curl -y & wait
	echo "---"		
else
	echo -e "${YELLOW}[sweep]${ENDCOLOR}: curl have been installed ..."				
fi
if [[ "$check_ncat" -eq 0 ]]; then
	echo -e "${YELLOW}[sweep]${ENDCOLOR}: Installing netcat-openbsd ...\n---"		
	apt-get install netcat-openbsd -y & wait
	echo "---"		
else
	echo -e "${YELLOW}[sweep]${ENDCOLOR}: netcat-openbsd have been installed ..."				
fi
#----------
check_curl=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
check_nmap=$(dpkg-query -W -f='${Status}' nmap 2>/dev/null | grep -c "ok installed")
check_ncat=$(dpkg-query -W -f='${Status}' netcat-openbsd 2>/dev/null | grep -c "ok installed")
if [[ "$check_nmap" -eq 1 && "$check_ncat" -eq 1 && "$check_curl" -eq 1 ]]; then
	echo -e "${YELLOW}[sweep]${ENDCOLOR}: Dependencies have been met successfully"
	: '
	if [[ "$check_tor" -eq 0 || "$check_proxychains" -eq 0 ]]; then
		echo "---"				
		echo -e "${YELLOW}[sweep]${ENDCOLOR}: Some dependencies for proxy chaining are seems to be missing ..."		
		echo -en "${YELLOW}[sweep]${ENDCOLOR}: Do you want them to be installed and configured right now ?"; read -p " (Y/y) " opt
		#----------		
		if [[ $opt == "Y" || $opt == "y" ]]; then
			if [[ "$check_tor" -eq 0 ]]; then
				echo -e "${YELLOW}[sweep]${ENDCOLOR}: Installing tor ...\n---"		
				apt-get install tor -y & wait
				echo "---"						
			else
				echo -e "${YELLOW}[sweep]${ENDCOLOR}: tor have been installed ..."								
			fi
			if [[ "$check_tor" -eq 0 ]]; then
				echo -e "${YELLOW}[sweep]${ENDCOLOR}: Installing proxychains ...\n---"		
				apt-get install proxychains -y & wait
				echo "---"						
			else
				echo -e "${YELLOW}[sweep]${ENDCOLOR}: proxychains have been installed ..."								
			fi
			#----------						
			echo -e "${YELLOW}[sweep]${ENDCOLOR}: Restarting tor service ..."					
			sudo service tor restart -y & wait
			echo -e "${YELLOW}[sweep]${ENDCOLOR}: Copying config file on /etc/proxychains.conf ..."
			cp /etc/proxychains.conf /etc/proxychains.conf.bak			
			sed -i '/#dynamic_chain/c\dynamic_chain' /etc/proxychains.conf 
			sed -i '/strict_chain/c\#strict_chain' /etc/proxychains.conf
			cp /etc/proxychains.conf $PWD/temp/proxychains.conf.sweep.lock
			chmod 444 $PWD/temp/proxychains.conf.sweep.lock
			echo -e "${YELLOW}[sweep]${ENDCOLOR}: Dependencies have been met successfully"			
		fi
	fi '
	exit 0						
fi
