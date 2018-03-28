#!/bin/bash

nas=/NAS
rrfileserver=ADMBS_$(hostname)
logfile=/Users/user/syncFS.log
date=$(date +%H_%M)

function usage {
	echo "setup crontab as follow"
	echo "00 00 * * * /Users/user/syncFS.sh &> /Users/user/syncFS.log"
}

function mountnas {
	if [ ! -e $nas/ ]
	then
	  sudo mkdir -p $nas
	  sudo mount -o rw -t nfs 192.168.1.10:/Fileserver $nas
	  if [ $? = 0  ]; then
		echo "NAS has been mount"
	  else
	  	echo "NAS mount Failed"
	  	exit 1
	  fi
	fi
}

function umountnas {
	sudo umount -f $nas && sudo rm -rf $nas
#	if [ $? == 0  ]; then
#	  sudo rm -rf $nas
#	  echo "NAS Umont with Success"
#	else
#          echo "Umount NAS Failed, Check!!!!"
#	fi
}

function syncfolder {
	rrfolderlist=(
######## ADD SHARED FOLDER BELOW one per line between sigle quote ###########
	'Accounts'
	'Design'
	'HR'
	'IT'
	'Marketing'
	'Shared Folder'
	'Users'
######## ADD SHARED FOLDER ABOVE one per line between sigle quote ###########
	)
	for rrfolder in "${rrfolderlist[@]}"; do
	  touch $logfile
	  date >> $logfile
	  echo "Sync $rrfolder folder..." >> $logfile
	  rsync -avzr --no-owner --no-perms --no-group "/$rrfolder" $nas/$rrfileserver/ >> $logfile 2>&1
#	  rsync -avzr --no-owner --no-perms --no-group "/$rrfolder" $nas/$rrfileserver/ ### Only for testing
	    if [ $? == 0  ]
	      then
	        result=Successful
	      else
	        result=Failed                
	      fi
	  mail -s "Backup $rrfolder - $result" "emailaddres@domain.com" < $logfile
	  rm $logfile
	done
}

####### Main Script ###############
### Run Mount NAS via NFS Function#
  mountnas
  sleep 2
### Run Sync Folders Function #####
  syncfolder
### Run Umount NAS Function #######
  umountnas
####### END Script ################
