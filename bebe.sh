#!/bin/bash


echo 'Pop Up BeBe'

#echo -e 'Esto es \e[0;31mrojo\e[0m y esto es \e[1;34mazul resaltado\e[0m'


nmap 10.21.2.5-8 | grep 'Nmap scan' | awk '{print $5}' > data.slaves.txt

slaves=($(<data.slaves.txt))
profil=($(<data.slaves.profile.txt))


if which sshpass; then
    echo 'sshpass/OK'
else
	echo 'Install sshpass'
	sudo apt-get install sshpass
    echo 'sshpass/OK'
fi

if which expect; then
    echo 'expect/OK'
else
	echo 'Install expect'
	sudo apt-get install expect
    echo 'expect/OK'
fi

echo 'Push resource to each slave'
for i in "${!slaves[@]}";do

  printf "%s\t%s\t%s\n" "$i" "$host" "${profil[$i]}"
  # push puppet file to remote and make
  host=${slaves[$i]}
  pass=$(more sshpwd)
  sshpass -p "$pass" ssh milax@$host -t -oStrictHostKeyChecking=no '
  echo "";

  if [ -d PuppetEssential ]; then
  cd PuppetEssential/; git pull; cd ~;
  else
  git clone -b benchbox https://github.com/2XL/PuppetEssential.git;
  fi;
  echo "byby $host";
  '

done

# todo install
# virtual box
# vagrant
# download precise box







echo 'Release BeBe'
