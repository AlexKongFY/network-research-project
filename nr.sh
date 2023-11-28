#!/bin/bash

# Student name: Alex Kong
# Student code: s3
# Unit / Class code: cfc130623
# Trainer name: James Lim

# Project Scope 1: Network Remote Control

##################################################################################################################

# Objectives
# - The bash script is comparable to Debian based Linux OS like Kali linux or Ubuntu.
# - Able to work under a terminal with GUI or without GUI.

##################################################################################################################

# 1. Installations and Anonymity Check.
# Part 1 - Install the needed applications
# Part 2 - If the applications are already installed. If installed, don't install them again.

##################################################################################################################


# Methods:
# check if the needed applications are installed on local machine.
# create a function to check it
# if not installed, prompt the local machine to install before automation starts.

function check_install() 
{
	# check tor apt is installed or not
	tor_apt=$(apt-cache show tor | grep Package | awk '{print $2}')

	if [ $tor_apt == "tor" ]
	then 
		echo "[#] tor is already installed."
	else
		sudo apt-get -y install tor
	fi 


	# check nipe apt is installed or not
	nipe_apt=$(locate *nipe.pl)

	if [ ! -z $nipe_apt ]
	then 
		echo "[#] nipe is already installed."
	else
		sudo git clone https://github.com/htrgouvea/nipe && cd nipe
		sudo cpanm --installdeps .
	fi 

	# check whois is installed or not
	whois_apt=$(apt-cache show whois | grep Package | awk '{print $2}')

	if [ $whois_apt == "whois" ]
	then 
		echo "[#] whois is already installed."
	else
		sudo apt-get -y install whois
	fi 

	# check geoiplookup is installed or not
	geo_apt=$(apt-cache show geoip-bin | grep Package | uniq | awk '{print $2}')

	if [ $geo_apt == "geoip-bin" ]
	then 
		echo "[#] geoiplookup is already installed."
	else
		sudo apt-get -y install geoip-bin
	fi 

	# check nmap is installed or not
	nmap_apt=$(apt-cache show nmap | grep Package | uniq | awk '{print $2}')

	if [ $nmap_apt == "nmap" ]
	then 
		echo "[#] nmap is already installed."
	else
		sudo apt-get -y install nmap
	fi 


	# check sshpass is installed or not for automate ssh login to remote server
	sshpass_apt=$(apt-cache show sshpass | grep Package | awk '{print $2}')

	if [ $sshpass_apt == "sshpass" ]
	then 
		echo "[#] sshpass is already installed."
	else
		sudo apt-get -y install sshpass
	fi 
	
}


##################################################################################################################

# 3. Results
# Part 1 - Save the whois data into file on the remote server
# Part 3 - Create a log and audit your data collection.	

# 1. Installations and Anonymity Check.
# Part 5 - Allow user to specify the address/URL to whois from remote server; save into a variable

# 2. Automatically scan the remote server for open ports.
# Part 3 - Get the remote server to check the whois of the given address/URL

##################################################################################################################

# Methods:
# create a function to log the whois searches in remote server 
# whoisdata is the log file for whois searches
# ftp file transfer from remote server to 

function createlog()
{
	
# create a new whois file log
touch whoisdata
echo "[#] A whoisdata file is created."

	
# in remote server to create a log on whois
echo " ============ whois data ============ " >> whoisdata

	# create to input url as a variable and 
	function checkurl() 
	{
	# Manual input url variable as $checkurl
	echo "[#] Whois to scan domain or IP address: "
	read checkurl 

	# check url by the registrant country
	find_url_country=$(whois $checkurl | grep -i country | grep -i Registrant | awk '{print $3}')

	# check if else statement for 
	if [ ! -z $find_url_country ]
	then 
		echo "[#] The url country code is $find_url_country." 
	else
		echo "[!] Invalid domain or IP address."
	fi	
	}
	
# set date as a variable for timestamping the whois data searches
current_time=$(date -u)

# store user input of url
# for loop to check url on whois 3 times
# only record each whois search into the whois data
for i in {1..3}
do 
	# reuse checkurl function for 3 times to update whoisdata
	checkurl $1
	echo "$current_time - [+] whois collected for: $checkurl" >> whoisdata
		
	# check if there is any url country code exist and record into whoisdata log
	if [ -z $find_url_country ]
	then
		# create a invalid variable if country code is not found.
		invalid="Not Available"	
		echo "$current_time - [+] url country code of $checkurl: $invalid" >> whoisdata
	else
		echo "$current_time - [+] url country code of $checkurl: $find_url_country" >> whoisdata
	fi
done

# check and give the output whoisdata information
cat whoisdata
echo " "

}


##################################################################################################################


# 1. Installations and Anonymity Check.
# Part 3 - Check if network connection is anonymous; if not, alert the user and exit.
# Part 4 - If the network connection is anonymous, display the spoofed country name.

##################################################################################################################

# Methods:
# Check if the current network connection is anonymous or not. If not, exit the function.
# Check spoofed country name if network connection is anonymous..
# find the nipe folder and stored as a variable. 

function anonymous_checker()
{
# check intital external ip address
ext_ip1=$(curl -s ifconfig.io)

# locate the nipe folder
nipe=$(locate *nipe)

# cd into nipe folder
cd $nipe

# run nipe application 
sudo perl nipe.pl restart

# check any changes in external ip address
ext_ip2=$(curl -s ifconfig.io)

# if statement both external ip address are same not, then echo for spoof country name and its ip address
if [ $ext_ip2 != $ext_ip1 ]
then 
	echo "[+] You are anonymous on the network connection."
	location=$(geoiplookup $ext_ip2 | awk -F, '{print $2}')
	echo "[+] The spoofed IP address is $ext_ip2."
	echo "[+] The spoofed country is $location."
else
	echo "[-] Exiting the program..."
	exit 1
fi 

}


##################################################################################################################


# 2. Automatically scan the remote server for open ports
# Part 1 - Connect to remote server via SSH
# Part 2 - Display the details of the remote server (country, IP and Uptime)

##################################################################################################################

# Methods:
# needs to run in parallel with sshpass login to remote server ssh
# create a function to run some commands in ssh remote server
# Check the remote server details
# check whois is installed or not
# Provide the external ip address, country and uptime

function auto_after_ssh ()
{

echo "[#] Opening ssh in remote server"	

	
# check if whois is installed or not in remote server
whois_apt=$(apt-cache show whois | grep Package | awk '{print $2}')

if [ ! -z $whois_apt ]
then 
	echo "[#] whois is already installed."
	echo "[#] Checking remote server details ....."
	echo " "
else
	sudo apt-get -y install whois
fi 


# check remote server external ip address 
remote_ip=$(curl -s ifconfig.io)
remote_country=$(whois $remote_ip | grep -i country | grep -v ZZ | uniq | awk '{print $2}')
echo " "
echo "[#] Remote Server external IP address is $remote_ip."


# whois checker for external ip address's country code of remote server
echo "[#] Remote Server country code(s): "
echo "[#] $remote_country"


# check remote server uptime
echo "[#] Uptime of remote server....  "
uptime
echo " "	
}


# Methods:
# create remote server login ssh function
# nmap scan for ssh port open on that particular remote server
# connect remote server via ssh
function remote_login()
{
# manual input ip address of remote server 
echo "[+] Enter the remote server ip address: "
read IPx
# manual input user and password of remote server
echo "[+] Enter remote server username: "
read USERNAME 
echo "[+] Enter remote server password: "
read PASSCODE
echo " "

# nmap scan any open ports of remote server on IP address on port 22 ssh 
echo "[#] Running nmap ....."

# Store nmap result as a variable
echo "[#] Scanning for open ports ....."
line=$(nmap $IPx -p 22 -Pn -sV | tail -n 5 | head -n -4)

# if statement to check if port open for ssh from nmap result
if [[ $line == *"open"* && $line == *"ssh"* ]]
then
	echo "[#] Open port for SSH found."
	echo "[#] Connecting SSH to remote server..."
	echo " "
	
	
else
	echo "[-] Exiting the program..."
	exit 1
fi 


# connect to remote server via ssh # by sshpass and run a function to check remote server details and perform a whois searches
sshpass -p "$PASSCODE" ssh -p 22 $USERNAME@$IPx "$(typeset -f auto_after_ssh); auto_after_ssh"
	
}

	
##################################################################################################################

# 3. Results
# Part 2 - Collect the file from the remote computer via FTP or HTTP or any other unsecure protocols
# Part 4 - The log needs to be saved in the local machine.

##################################################################################################################

# Methods:
# create an overall main function to run the network remote control

function main() 
{

	# Welcome message
	echo "[#] Welcome to network remote control script"
	sleep 1
	echo "[#] Checking system requirements .... "
	echo " "

	# start with check installation function on local machine
	check_install
	sleep 1

	# start anonymous checker on local machine network status
	anonymous_checker
	sleep 1

	# start ssh login into remote server
	remote_login
	
	# Ensure ftp service port is opened for remote server for later automate ftp file transfer.
	sshpass -p "$PASSCODE" ssh -p 22 $USERNAME@$IPx "sudo -S service vsftpd restart"
	echo "[#] Starting FTP service on remote server ....... "

	# run the createlog for whois data
	sshpass -p "$PASSCODE" ssh -p 22 $USERNAME@$IPx "$(typeset -f createlog); createlog"
	
	# changing file permission of whoisdata file in remote server
	sshpass -p "$PASSCODE" ssh -p 22 $USERNAME@$IPx "sudo -S chmod 666 whoisdata"
	

	# exit the ssh server of remote server
	echo "[#] Exiting ssh service for remote server."
	
	# Automate a ftp file transfer to get whoisdata from remote server to local machine and close by itself.
	echo "[#] ftp transferring whoisdata file from remote server to local machine."	
	curl -s --user $USERNAME:$PASSCODE ftp://$IPx/whoisdata >> /home/kali/Desktop/NR_project_3/whoisdata
	sleep 1
	
	# if statement to check whoisdata file in local machine
	log_file=$(locate *local_whoisdata)
	if  [ -z $log_file ]
	then 
		echo "[#] Whois data is saved in the local machine."
	else
		echo "[-] Error! Whois data is not saved into the local machine. Please check with remote server." 
	fi
	
	# exit the main function
	echo "[#] Exit the network remote control....."
	exit 1	

}

main
