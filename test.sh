#!/usr/bin/env bash




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
