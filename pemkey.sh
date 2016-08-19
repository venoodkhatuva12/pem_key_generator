#!/bin/bash
#author: Vinood NK
#script to Add user and generate Pem file for Login
#Usage : Adduser , generate pemfile, and add in sudoer.

#Check whether root user is running the script
  if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
  fi
read -p "Please Enter the Username : " user
user_present="`cat /etc/passwd | grep $user | grep -v grep | wc -l`"
  if [ "$user_present" == "1" ]; then
       	echo -e "\nUser $user already present No need to create .. "
       	echo -e "\nGenertaing keys for $user ... "
  else
       	adduser $user
  fi
read -p "Please Enter the Hostname : " hostname

ssh-keygen -t rsa -f $user

mkdir /home/$user/.ssh
cat $user.pub > /home/$user/.ssh/authorized_keys
chmod -R 700 /home/$user/.ssh/
chown -R $user:$user /home/$user/.ssh/
mv $user /tmp/$hostname-$user.pem

read -p "Do you want to add this User to Sudoer(Yes/No)? : " response
sudoers_present="`cat /etc/sudoers | grep $user | grep -v grep | wc -l`"
  if [ "$sudoers_present" -ge "1" ]; then
       	echo -e "\nEntry for user in sudoers already exsist !!"
  else
       	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
       	then
       	   sudo sed -i "95 i $user   ALL=(ALL)       ALL" /etc/sudoers
       	else
       	    exit
       	fi
  fi
rm -f $user $user.pub
echo -e "\n Keys generated successfully ...\n"
echo -e "\n Please find pem for user $user at  /tmp/$hostname-$user.pem"
