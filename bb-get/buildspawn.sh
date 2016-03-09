#!/bin/sh 

# Run the user build script with SUDO previlegies 

declare -a SYMLINK=""
declare -a SCRIPT=""
declare SPAWN_PATH="/usr/share/buildspawn"
declare SCRIPT=""


spawn () {
	printf "%s\n" "Starting script $*"
	declare -r SCRIPT_PATH=`dirname $*`
	printf "%s\n" "SCRIPT_PATH = $SCRIPT_PATH"
	declare -r SCRIPT_NAME=`basename $*`
	printf "%s\n" "SCRIPT_NAME = $SCRIPT_NAME"
	if [ true ] ; then
		cd ${SCRIPT_PATH}
		./${SCRIPT_NAME} &	
		cd ${SPAWN_PATH}
		rm ${SCRIPT_NAME}
	fi 
}

printf "%s\n" "Image factory is started!"


cd ${SPAWN_PATH}

while true ; do
	SYMLINK=( * )
	
	if [ ! "${SYMLINK}" = "*" ] ; then
		printf "%s\n" "Found ${#SYMLINK[@]} symlinks:"
		printf "%s\n" "${SYMLINK[@]}" 
	
		for (( i=0; i<${#SYMLINK[@]}; i ++)) ; do
			SCRIPT[$i]=`readlink ${SYMLINK[$i]}`
			printf "%s\n" "Script run on ${SCRIPT[$i]}"
			spawn "${SCRIPT[$i]}" 
		done
		
		SYMLINK=""
		SCRIPT=""
	else
		sleep 3
	fi
	
done
