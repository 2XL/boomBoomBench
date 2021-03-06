#!/bin/bash


echo 'Pop Up BeBe'
#echo -e 'Esto es \e[0;31mrojo\e[0m y esto es \e[1;34mazul resaltado\e[0m'

if [ $# -lt 1 ]
then
        echo "Usage : $0 |summon|config|run|status|"
        exit
fi

function preconfig(){
	echo 'Setup vagrant and virtualbox'

	slaves=($(<data.slaves.txt))

	if which sshpass; then
	    echo 'sshpass/OK'
	else
		echo 'Install sshpass'
		sudo apt-get install sshpass
	    echo 'sshpass/OK'
	fi

    pass=$(more sshpwd)
	for i in "${!slaves[@]}";do

		  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
		  # push puppet file to remote and make
		  host=${slaves[$i]}
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
	      git clone --recursive -b benchbox https://github.com/2XL/PuppetEssential.git;
		  fi;
	      echo $pass  | sudo -S PuppetEssential/scripts/installVagrantVBox.sh
		  echo byby $host;
		  "  & # -> install vagrant -> otherwise comment it
	done
}


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
    pass=$(more sshpwd)
	echo 'Push resource to each slave'
	for i in "${!slaves[@]}";do

	  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
	  # push puppet file to remote and make
	  host=${slaves[$i]}

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
      git clone --recursive -b benchbox https://github.com/2XL/PuppetEssential.git;
	  fi;

	  if [ -d BenchBox ]; then
	  cd BenchBox/;
	  git pull;
	  cd ~;
	  else
      git clone -b chenglong https://github.com/RaulGracia/BenchBox.git;
	  fi;
      PuppetEssential/scripts/installDependencies.sh


	  echo byby $host;






	  " & # -> install vagrant -> otherwise comment it

	done

}

function config(){
	echo 'push profile type to each client: '
	# push again profile



	if [ -s 'data.profile.txt' ]; then
		result='data.slaves.profile.txt';
		rm $result;
		IFS=$'\n' # new lines are the only separators
		data=($(<data.profile.txt));
		echo "${data[@]}"
		for line in "${data[@]}"; do
			# echo $profile # converteix files en columnes...
			profile=$(echo $line | cut -f1 -d ' ')
			replica=$(echo $line | cut -f2 -d ' ')

			# echo $profile
			# echo $replica
			for i in $(seq 0 $replica); do
				echo "$profile-$i" >> $result;
			done

		done
	fi;

	echo 'Push resource to each slave'
	slaves=($(<data.slaves.txt))
	profil=($(<data.slaves.profile.txt))
	pass=$(more sshpwd)
	for i in "${!slaves[@]}";do

	  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
	  # push puppet file to remote and make
	  host=${slaves[$i]}

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
	pass=$(more sshpwd)
	for i in "${!slaves[@]}";do

	  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
	  # push puppet file to remote and make
	  host=${slaves[$i]}
	  sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
	     echo 'run some script from scripts.sh  or just run vagrant up '
	     echo 'check if system is ready';
	     if [ -d PuppetEssential ]; then
	     cd PuppetEssential/;
	     git pull;
	     echo ---------------------------------------------------- ;
	     ls -l *.box
         vagrant -v;
         VBoxManage --version;
	     echo ---------------------------------------------------- ;
	     VBoxManage list runningvms | wc -l > running
		 #if [ -r running ]; then
		 #vagrant provision;
		 #else
	     vagrant up;
         vagrant provision;
	     #fi
	     else
	     echo 'Vagrant Project Not Loaded!!??'
	     fi
	     echo 'Launch stacksync client...'
	     # stacksync; # aquest hauria de ser dins del puppet a cada sandBox
      echo byby $host;
	  "  & # to run in parallel with  &
		# els arranco pero parece ser que no les llega a todos...
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
	  echo byby $host;
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
		echo $pass  | sudo -S rm /usr/lib/milax-labdeim/autoapaguin.sh;
		echo 'OK';
	    echo byby $host;
	  "
	done
}

function scan_d2xx(){
	nmap 10.21.2.1-25 -p 22 | grep 'Nmap scan' | awk '{print $5}' > data.slaves.txt
}

function scan_d1xx(){
	nmap 10.21.1.1-25 -p 22 | grep 'Nmap scan' | awk '{print $5}' > data.slaves.txt
}


function stop_clear(){

	slaves=($(<data.slaves.txt))
	for i in "${!slaves[@]}";do
	 host=${slaves[$i]}
	  pass=$(more sshpwd)
	  sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
	    echo 'Stop all running virtual machines, project';
		cd PuppetEssential;
		vagrant destroy -f;
		cd;
		rm -rf PuppetEssential;
		echo 'OK';
	  echo byby $host;
	  " & # matar en paralelo...
	done
}

function shutdown(){

	slaves=($(<data.slaves.txt))
	pass=$(more sshpwd)
	for i in "${!slaves[@]}";do
	 host=${slaves[$i]}
		sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
		echo 'shutdown!!!'
		echo $pass  | sudo -S shutdown -h 0
	  "  # matar en paralelo...
	done
}


# cridar aquesta funció despres de haver fet un clone del repositori
function credentials(){

	IFS=$'\n'
	ownckey=($(<data.slaves.credential.owncloud.txt))
	stackey=($(<data.slaves.credential.stacksync.txt))
	slaves=($(<data.slaves.txt))
	pass=$(more sshpwd)
	for i in "${!slaves[@]}";do
	 host=${slaves[$i]}
		sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no "
		echo 'push stackey & stackey to home directory'
		echo ${stackey[$i]}  > PuppetEssential/stacksync.key
		echo ${ownckey[$i]}  > PuppetEssential/owncloud.key
		echo 'fin copy -- credential pushed to sandBox /vagrant/[stacksync.key,owncloud.key]'
		echo 'merge credential with config.xml template'
		echo 'TODO,'
		# script en sandbox que configura el config.xml amb aquests credecials

		echo 'Setup config.xml with stacksync.key with'
		 # the virtual machines will find the key at their /vagrant directory
		 # also the config.xml ill be here. -> / vagrant/config.xml
		 ls;
		 cd PuppetEssential/scripts;
		 ./config.xml.sh; # stacksync
		 ./config.cfg.sh; # owncloud

		echo 'Setup [owncloud.cfg], owncloudsync.sh with owncloud.key'

	  "  # matar en paralelo...
	done


}


function keygen(){

echo "Connecting to syncServer"

serverIp='10.30.232.39'

date
echo 'Password is: stacksync_pass'

psql -h $serverIp -d stacksync_db -U stacksync_user -t -A -F"," \
                -c "select id, name, swift_account, swift_user, email from user1 where name ~ 'demo' " \
				-o 'user1.csv'
# --pset footer | -t  :: amb header o sense.
ls -l user1.csv
}


function update(){

	echo 'Make the remote host pull the latest repo version'

}



echo "option: $1"

case $1 in

	preconfig)
		# check vagrant and virtual box are installed in the host
		preconfig
	;;
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
		scan_d2xx
	;;
	destroy)
		stop_clear
	;;

	shutdown)
		shutdown
		;;

	rmi)
		# allow random method invocation, at the remote hosts and retrieve them as log. file
	;;

	credentials)
		# push the credentials to the running nodes
		credentials
	;;

	keygen)
		keygen
	;;

	*)
	echo "Usage: scan|summon|config|run|status|clean|keepalive|stop_clear"
	;;
esac





echo "Release BeBe"