#!/bin/bash

#this section lists groups as follows:
#excluding system or program groups
#only including groups with the ID speficied in login.defs
#excluding groups that match created users

group="$[$(getent group | awk 'END {print NR}')]"
groupcounter=1
numbercounter=1
arraycount=1
printcounter=1

min=$(grep "^UID_MIN" /etc/login.defs | grep -Eo '[0-9]{1,9}')
max=$(grep "^UID_MAX" /etc/login.defs | grep -Eo '[0-9]{1,9}')


passwd_vs_group() {
    groupline=$( getent group | awk "NR==$groupcounter" )
    groupID=$( grep "^$groupline" /etc/group | awk -F':' '{print $3}' )
   # this is wrong groupID=$( getent passwd "^$groupline" | awk -F':' '{print $3}' ) 
    groupname=$(printf "${groupline%:*:*:}")
    compare=$( grep -c "^$groupname:" /etc/passwd)
}
group_array() {
array[$arraycount]=$groupname
    numbercounter=$[$numbercounter+1]
    arraycount=$[arraycount+1]
}
print_group_array() {
    printf "${array[$printcounter]}\n"
    printcounter=$[$printcounter+1]
}

printf " ----------------------------------------------\n"
while [[ "$groupcounter" -lt "$group" ]]; do
	passwd_vs_group #gather group and user details to compare 
	if [ "$compare" -le 0 ] && [ "$groupID" -ge "$min" ] && [ "$groupID" -le "$max" ]; then #compare user vs group data
		group_array #only capture data in array where a user and group do not match etc.
	fi
    groupcounter=$[$groupcounter+1]
done
	while [ "$printcounter" -lt "$numbercounter" ]; do #now print the array
		print_group_array
	done
printf " ----------------------------------------------\n"
