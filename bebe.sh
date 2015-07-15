#!/bin/bash


echo 'Pop Up BeBe'

#echo -e 'Esto es \e[0;31mrojo\e[0m y esto es \e[1;34mazul resaltado\e[0m'






if [ $# -lt 1 ]
then
        echo "Usage : $0 |summon|config|run|status|"
        exit
fi




# scan de les maquines que hiha disponibles -> data.slaves.txt
# accedir a les maquines i descarregar el repositori de vagrant
function summon(){

	echo "nmap IP range: $1"
	#nmap 10.21.2.5-8 | grep 'Nmap scan' | awk '{print $5}' > data.slaves.txt
	#nmap 10.21.1.3 | grep 'Nmap scan' | awk '{print $5}' > data.slaves.txt

	slaves=($(<data.slaves.txt))
	profil=($(<data.slaves.profile.txt))


	if which sshpass; then
	    echo 'sshpass/OK'
	else
		echo 'Install sshpass'
		sudo apt-get install sshpass
	    echo 'sshpass/OK'
	fi


	echo 'Push resource to each slave'
	for i in "${!slaves[@]}";do

	  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
	  # push puppet file to remote and make
	  host=${slaves[$i]}
	  pass=$(more sshpwd)
	  # -t for interactive
	  sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
	  echo;

	  if [ -d PuppetEssential ]; then
	  cd PuppetEssential/;
	  git pull;
	  echo ${profil[$i]} > profile
	  echo ${profil[$i]} > $host.log
	  cd ~;
	  else
      git clone -b benchbox https://github.com/2XL/PuppetEssential.git;
	  fi;
	  PuppetEssential/scripts/installDependencies.sh

	  echo byby $host;
	  " # & -> install vagrant -> otherwise comment it

	done

}

function config(){
	echo 'push profile type to each client: '
	# push again profile
	echo 'Push resource to each slave'
	slaves=($(<data.slaves.txt))
	profil=($(<data.slaves.profile.txt))
	for i in "${!slaves[@]}";do

	  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
	  # push puppet file to remote and make
	  host=${slaves[$i]}
	  pass=$(more sshpwd)
	  sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
	    if [ -d PuppetEssential ]; then
		cd PuppetEssential/;
			if [ -f profile ]; then
				echo ${profil[$i]} > profile.NEW;
				diff profile profile.NEW > change;
				if [ -s change ]; then

					#rm profile;
					mv profile.NEW profile;
					echo The directory was modified -- $host;
				else
					echo No Change :D
				fi;
				cd ~;
			fi;

		fi
		echo byby $host;
	  "

	done

}

# loop throught the nodes and invoice the benchsuit
function run(){

	slaves=($(<data.slaves.txt))
	profil=($(<data.slaves.profile.txt))
	for i in "${!slaves[@]}";do

	  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
	  # push puppet file to remote and make
	  host=${slaves[$i]}
	  pass=$(more sshpwd)
	  sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
	     echo 'run some script from scripts.sh  or just run vagrant up '
	     echo 'check if system is ready';

	     cd PuppetEssential/;
	     echo ---------------------------------------------------- ;
	     ls -l *.box
         vagrant -v;
         VBoxManage --version;
	     echo ---------------------------------------------------- ;
	     vagrant up;
	  "  &  to run in parallel with  &

	done
}


function status(){

	slaves=($(<data.slaves.txt))
	profil=($(<data.slaves.profile.txt))
	for i in "${!slaves[@]}";do

	  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
	  # push puppet file to remote and make
	  host=${slaves[$i]}
	  pass=$(more sshpwd)
	  sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
	     echo 'access to here and push log to summoner';

	  "
	pass=$(more sshpwd)
	sshpass -p "$pass" scp milax@$host:~/PuppetEssential/*.log ./status


	done

}


function keepalive(){

	#nmap 10.21.2.* | grep 'Nmap scan' | awk '{print $5}' > data.slaves.txt
	slaves=($(<data.slaves.txt))
	profil=($(<data.slaves.profile.txt))
	for i in "${!slaves[@]}";do

	  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
	  # push puppet file to remote and make
	  host=${slaves[$i]}
	  pass=$(more sshpwd)
	  sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
	    echo 'keep file host alive $host!!!';
		sudo rm /usr/lib/milax-labdeim/autoapaguin.sh;
		echo 'OK';
	  "


	done


}

function scan(){
	nmap 10.21.2.* | grep 'Nmap scan' | awk '{print $5}' > data.slaves.txt
}


echo "option: $1"


case $1 in

	summon)
		# summon all the instances and queue install dependencies
		summon $2

		# todo install
		# virtual box
		# vagrant
		# download precise box

	;;
	config)
		# push instances config file form here to each node and load their boxes
		config $2 # -> data.slaves.profile.txt

	;;
	run)
		# vagrant up to all of them
		run # ->
	;;
	status)
		# scp all their log in local child directory ->
		# retrieve information then merge -> ./status
		status
	;;
	clean)
	;;
	keepalive)
		# per mantindre els host vius/ avoid autoshutdown...
		keepalive
	;;
	scan)
		scan
	;;


	*)
	echo "Usage: scan|summon|config|run|status|clean|keepalive"
	;;
esac





echo "Release BeBe"