#! /bin/bash
################################################################################
#This script is a wrapper for bitbake command to simplify product build        # 
#procedure                                                                     #
# Author: Andrei Mironenko <amironenko@paralleldynamic.com>                    #
#                                                                              #
# Copyright(C) 2015 Parallel Dynamic Ltd.                                      #
# This file is licensed under the terms of the GNU General Public License      #
# version 2. This program  is licensed "as is" without any warranty of any kind#
# whether express or implied.                                                  #
################################################################################

################################################################################
#  Declaring variables                                                         #
################################################################################

declare RELEASE=""
declare COMMAND=""
declare PRODUCT=""
declare -i DEVFLAG=0


#declare SERVER="xw6400"
#declare GITROOT="/opt/github"

#git@github.com:andreimironenko/oe-davinci.git
declare SERVER="github.com"
declare GITROOT="andreimironenko/"


declare OEBASE=`pwd`
declare ARAGO="arago"
declare ARAGO_BITBAKE="arago-bitbake"
declare ARAGO_OE_DEV="arago-oe-dev"
declare PD_APPS="pd-apps"
declare PD_SYSTEM="pd-system"
declare PD_APPS_DEV="pd-apps-dev"
declare PD_SYSTEM_DEV="pd-system-dev"

declare BB_GET_GITDIR="/opt/github/oe/packages/bb-get.git"
declare BB_GET_INSTALLDIR="/usr/share/oe/bb-get"
declare BB_GET_INSTALLDIR="./"
declare OE_DOWNLOADS_DIR="/usr/share/oe/downloads"

declare PRODUCTS_DIR="${GITROOT}/products"

declare DEVURLS_CONF="devurls.conf"
declare OEURLS_CONF="oeurls.conf"
declare OEDEVURLS_CONF="oedevurls.conf"
declare PRODUCTURLS_CONF="producturls.conf"


# Check the existense of devurls.conf in the OE base directory
# if it's not present then the default configuration is used.
# WARNING! It's only used for development builds
printf "%s" "Parsing $DEVURLS_CONF ... "
if [ -f ./$DEVURLS_CONF ] ; then
  DEVDIRS=( $(awk '!/^($|[[:space:]]*#)/{print $1;}' ./$DEVURLS_CONF) )
  DEVURLS=( $(awk '!/^($|[[:space:]]*#)/{print $2;}' ./$DEVURLS_CONF) )
  DEVBRANCHES=( $(awk '!/^($|[[:space:]]*#)/{print $3;}' ./$DEVURLS_CONF) )
else
  DEVDIRS=( $(awk '!/^($|[[:space:]]*#)/{print $1;}' $BB_GET_INSTALLDIR/$DEVURLS_CONF) )
  DEVURLS=( $(awk '!/^($|[[:space:]]*#)/{print $2;}' $BB_GET_INSTALLDIR/$DEVURLS_CONF) )
  DEVBRANCHES=( $(awk '!/^($|[[:space:]]*#)/{print $3;}' $BB_GET_INSTALLDIR/$DEVURLS_CONF) )
fi

for (( d = 0; d < ${#DEVURLS[@]}; d++ )) ; do
 
     DEVURLS[$d]="${GITROOT}${DEVURLS[$d]}"
done
printf "%s\n" "Ok"

printf "%s" "Parsing $OEURLS_CONF ... "
if [ -f ./$OEURLS_CONF ] ; then
  OEDIRS=( $(awk '!/^($|[[:space:]]*#)/{print $1;}' ./$OEURLS_CONF) )
  OEURLS=( $(awk '!/^($|[[:space:]]*#)/{print $2;}' ./$OEURLS_CONF) )
  OEBRANCHES=( $(awk '!/^($|[[:space:]]*#)/{print $3;}' ./$OEURLS_CONF) )
else
  OEDIRS=( $(awk '!/^($|[[:space:]]*#)/{print $1;}' $BB_GET_INSTALLDIR/$OEURLS_CONF) )
  OEURLS=( $(awk '!/^($|[[:space:]]*#)/{print $2;}' $BB_GET_INSTALLDIR/$OEURLS_CONF) )
  OEBRANCHES=( $(awk '!/^($|[[:space:]]*#)/{print $3;}' $BB_GET_INSTALLDIR/$OEURLS_CONF) )
fi

for (( d = 0; d < ${#OEURLS[@]}; d++ )) ; do
 
     OEURLS[$d]="${GITROOT}${OEURLS[$d]}"
done
printf "%s\n" "Ok"


printf "%s" "Parsing $OEDEVURLS_CONF ... "
if [ -f ./$OEDEVURLS_CONF ] ; then
	OEDEVDIRS=( $(awk '!/^($|[[:space:]]*#)/{print $1;}' ./$OEDEVURLS_CONF) )
	OEDEVURLS=( $(awk '!/^($|[[:space:]]*#)/{print $2;}' ./$OEDEVURLS_CONF) )
	OEDEVBRANCHES=( $(awk '!/^($|[[:space:]]*#)/{print $3;}' ./$OEDEVURLS_CONF) )
else
	OEDEVDIRS=( $(awk '!/^($|[[:space:]]*#)/{print $1;}' $BB_GET_INSTALLDIR/$OEDEVURLS_CONF) )
	OEDEVURLS=( $(awk '!/^($|[[:space:]]*#)/{print $2;}' $BB_GET_INSTALLDIR/$OEDEVURLS_CONF) )
	OEDEVBRANCHES=( $(awk '!/^($|[[:space:]]*#)/{print $3;}' $BB_GET_INSTALLDIR/$OEDEVURLS_CONF) )
fi

for (( d = 0; d < ${#OEDEVURLS[@]}; d++ )) ; do
 
    OEDEVURLS[$d]="${GITROOT}${OEDEVURLS[$d]}"
done
printf "%s\n" "Ok"


printf "%s" "Parsing $PRODUCTURLS_CONF ... "
if [ -f ./$PRODUCTURLS_CONF ] ; then
	PRODUCTDIRS=( $(awk '!/^($|[[:space:]]*#)/{print $1;}' ./$PRODUCTURLS_CONF) )
	PRODUCTURLS=( $(awk '!/^($|[[:space:]]*#)/{print $2;}' ./$PRODUCTURLS_CONF) )
	PRODUCTBRANCHES=( $(awk '!/^($|[[:space:]]*#)/{print $3;}' ./$PRODUCTURLS_CONF) )
else
	PRODUCTDIRS=( $(awk '!/^($|[[:space:]]*#)/{print $1;}' $BB_GET_INSTALLDIR/$PRODUCTURLS_CONF) )
	PRODUCTURLS=( $(awk '!/^($|[[:space:]]*#)/{print $2;}' $BB_GET_INSTALLDIR/$PRODUCTURLS_CONF) )
	PRODUCTBRANCHES=( $(awk '!/^($|[[:space:]]*#)/{print $3;}' $BB_GET_INSTALLDIR/$PRODUCTURLS_CONF) )
fi

for (( d = 0; d < ${#PRODUCTURLS[@]}; d++ )) ; do
 
    PRODUCTURLS[$d]="${GITROOT}${PRODUCTURLS[$d]}"
done
printf "%s\n" "Ok"


#declare USER=`whoami`
#declare USER="andrei"
declare USER="git"

declare -rx SCRIPT=${0##*/}


# This function takes one parameter - command to execute
# Run it with disabled output and return the result. 
#  
function execute ()
{
    #Redirect standard error stream to standard output
    2>&1
	
    $* &> /dev/null
    return $?
}
export -f execute

# This function takes one parameter - command to execute
# Run it with disabled output and check the result. In case of fault it will
# leave that is denoted by capital L.
function executeL ()
{
	#Store command
	_cmd=$*
	
	#Execute the command
        err_msg="$($* 2>&1 > /dev/null)"
    
        #Store exit code 
	err_code=$?
	
    #Check the return result, if it fails exit
    if [ "$err_code" -ne "0" ]; then
        exit_msg="ERROR: executing ${_cmd} returns ${err_code} and error message:"
        echo $exit_msg
        echo $err_msg
        exit ${_err_code}
    fi
}
export -f executeL


# This function will check OE base directory and report if it is a development 
# or release setup
# Return values:
# 	0 - release setup
# 	1 - development setup
function is_dev 
{
	
	for d in $OEDEVDIRS ; do
		if [ ! -d $d ] ; then
			return 0
		fi
	done
	
	return 1;
}

# This fucntion will query user to answer, run an action and will return 
#  0 - if answer was no
#  1 - if answer was yes

# param1 - "yes" message
# param2 - "yes" action
# param3 - "no" message
# param4 - "no" action

function ask_yes_no 
{
declare -i RES

while  true; do
  read $REPLY
  if [ "$REPLY" = "y" -o "$REPLY" = "Y" ] ; then
    printf "%s\n" "$1"
    eval $2
    RES=1
    break
  elif [ "$REPLY" = "n" -o "$REPLY" = "N" ] ; then
	printf "%s\n" "$3"
    eval $4
    RES=1
    break
  else
    echo "Use Y/N:"
    continue
  fi
done	

return ${RES} 
}


# This function will check either given directory is a git one 
#
# param1   - absolute path to the git directory to check
# 
# Return values:
# 	0        - it is a git directory 
#   non-zero - it is not a git directory

function is_git 
{
    local gitdir=$1

    #Store the current directory
    execute pushd ${PWD} 
    cd ${gitdir}

    #Check either we can execute "git status" on this directory
    git status &> /dev/null
    local git_status=$?

    #return to the original destination
    execute popd

    return $git_status
}



# This function will check git directory and report if it is clean or 
# contains modifications or untracked files
#
#param1   - absolute path to the git directory to check
# 
# Return values:
#	0 - cleaned 
#	1 - contains modified and not checked-in files

function is_git_clean 
{
    local gitdir=$1 

    #Store the current directory
    execute pushd ${PWD} 

    execute cd ${gitdir}

    #Check either any modified or untracked files exist in the directory  
    git status | grep -e "modified"  &> /dev/null

    if [ $? -eq 0 ] ; then
        execute popd
        return 1
    fi

    execute popd
    return 0 
}


# This function will check git directory and report if it is clean or 
# contains modifications or untracked files, and if the currently active  
# branch is synched to the remote
#
# param1   - absolute path to the git directory to check
# 
# Return values:
# 	0 - synched 
#       1 - remote branch does not exist
#       2 - is not synched with the remote

function is_git_synched 
{
    local gitdir=$1 

    #Store the current directory
    execute pushd ${PWD} 

    cd ${gitdir}

    
    local branch=`git branch | grep -F "*" | sed -e 's/*//g'`
    branch="${branch// /}"

    git remote show origin | grep ${branch} | grep "tracked" &> /dev/null
    local remote_status=$?
    if [ ${remote_status} -ne 0 ] ; then
        execute popd
        return 1
    fi 

    local current_revision=`git rev-parse HEAD`
    git rev-list origin/${branch} | grep ${current_revision} &> /dev/null
    push_status=$?
    if [ ${push_status} -ne 0 ] ; then
	execute popd
	return 2
    fi


    execute popd
    return 0 
}




function install_handler 
{
	
	for (( i=0; i < ${#OEDIRS[*]} ; i ++ )) ; do
	
		printf "%s\n" "Start cloning/updating ${OEURLS[$i]} overlay "
		if [ -d ${OEDIRS[$i]} ] ; then
			execute cd ${OEDIRS[$i]}
			execute git pull origin master
			execute git fetch origin master --tags
	
			current_branch=`git branch | grep -F "*" | sed -e 's/*//g'`
			#Removing any spaces
			current_branch="${current_branch// /}"
			# If it's not, checkout it with --track option
			if [ "$current_branch" != "master" ] ; then
	
				remote_status=`git remote show origin | grep ${current_branch} | grep "tracked"`
				remote_status=$?
	
				if [  "$remote_status" -eq "0" ] ; then 
					execute git pull origin ${current_branch}
	               	execute git fetch origin ${current_branch} --tags
				else
	                printf "%s\n" "Warning: Please consider pushing your ${current_branch} branch to EBS"
	            	printf "%s\n" "At the moment local branch is not tracked, update is skipped"
				fi
	
			fi	
			execute cd ${OEBASE} 
		else	 
			execute git clone $USER@$SERVER:${OEURLS[$i]} ${OEDIRS[$i]}
			execute cd ${OEBASE}/${OEDIRS[$i]}
			if [ "${OEBRANCHES[$i]}" != "master" ] ; then
				execute git checkout --track origin/${OEBRANCHES[$i]}
			fi
			execute cd ${OEBASE} 

		fi
	done

if [ "$DEVFLAG" = "1" ] ; then
	
	printf "%s\n" "Start cloning OE overlays"
	
	for (( i=0; i < ${#OEDEVDIRS[*]} ; i ++ )) ; do
	
		printf "%s\n" "Start cloning/updating ${OEDEVURLS[$i]} overlay "
		if [ -d ${OEDEVDIRS[$i]} ] ; then
			execute cd ${OEDEVDIRS[$i]}
			execute git pull origin master
			execute git fetch origin master --tags
	
			current_branch=`git branch | grep -F "*" | sed -e 's/*//g'`
			#Removing any spaces
			current_branch="${current_branch// /}"
			# If it's not, checkout it with --track option
			if [ "$current_branch" != "master" ] ; then
	
				remote_status=`git remote show origin | grep ${current_branch} | grep "tracked"`
				remote_status=$?
	
				if [  "$remote_status" -eq "0" ] ; then 
					execute git pull origin ${current_branch}
	               	execute git fetch origin ${current_branch} --tags
				else
	                printf "%s\n" "Warning: Please consider pushing your ${current_branch} branch to EBS"
	            	printf "%s\n" "At the moment local branch is not tracked, update is skipped"
				fi
	
			fi	
			execute cd ${OEBASE} 
		else	 
			execute git clone $USER@$SERVER:${OEDEVURLS[$i]} ${OEDEVDIRS[$i]}
			execute cd ${OEBASE}/${OEDEVDIRS[$i]}
			if [ "${OEDEVBRANCHES[$i]}" != "master" ] ; then
				execute git checkout --track origin/${OEDEVBRANCHES[$i]}
			fi
			execute cd ${OEBASE} 
		fi
	done

		
	printf "%s\n" "Start cloning development packages"
	declare -i index
	for ((index=0; index < ${#DEVDIRS[*]}; index ++)) ; do
		
		printf "%s\n" "Start cloning/updating ${DEVURLS[$index]} development package"
		if [ -d $OEBASE/${DEVDIRS[$index]} ] ; then
			execute cd $OEBASE/${DEVDIRS[$index]}
			execute git pull origin ${DEVBRANCHES[$index]}
			execute git fetch origin ${DEVBRANCHES[$index]} --tags
			# Check if the current branch match the one from devurls.sh
			current_branch=`git branch | grep -F "*" | sed -e 's/*//g'`
			#Removing any spaces
			current_branch="${current_branch// /}"
			# If it's not, checkout it with --track option
			if [ "$current_branch" != "${DEVBRANCHES[$index]}" ] ; then

				remote_status=`git remote show origin | grep ${current_branch} | grep "tracked"`
				remote_status=$?

				if [  "$remote_status" -eq "0" ] ; then 
					execute git pull origin ${current_branch}
                                	execute git fetch origin ${current_branch} --tags
				else
                                    printf "%s\n" "Warning: Please consider pushing your ${current_branch} branch to EBS"
                                    printf "%s\n" "At the moment local branch is not tracked, update is skipped"
				fi

			fi	
			execute cd $OEBASE 
		else 
			execute git clone $USER@$SERVER:${DEVURLS[$index]} ${DEVDIRS[$index]}
			execute cd ${OEBASE}/${DEVDIRS[$index]}
			if [ "${DEVBRANCHES[$index]}" != "master" ] ; then
				execute git checkout --track origin/${DEVBRANCHES[$index]}
			fi
			execute cd ${OEBASE} 
		fi
	done

else
	#Release build handling
	
	#The product and its release must be specified
	if [ -z "${PRODUCT}" -o -z "${PRODUCT_RELEASE}" ] ; then
		printf "%s\n" "Either product and/or product release was not provided!"
		printf "%s\n" "Usage for release build:"
		printf "%s\t\n" "bb-get install -r r03-rc2 gstproto" 
		exit 193 
	fi

	if [ ! -d $OEBASE/pd-products ] ; then	
		execute mkdir -p $OEBASE/pd-products
	fi
	
	cd $OEBASE/pd-products
	if [ -d $OEBASE/pd-products/$PRODUCT ] ; then
		printf "%s\n" "$PRODUCT product folder already exists"
		printf "%s\n" "Make sure you use empty folder for the getting product release build environment!"
		exit 194	
	else
		execute git clone $USER@$SERVER:${GITROOT}/products/$PRODUCT.git
		execute cd $OEBASE/pd-products/$PRODUCT
		execute git reset --hard ${PRODUCT_RELEASE} 
		execute cd $OEBASE 
	fi

	source $OEBASE/pd-products/$PRODUCT/release.inc

	# Check that there is no any overlay folder exist
	dirs=( $( ls -1 ) )
	if [ ${#dirs[*]} -ne 0 ] ; then
		printf "%s\n" "OE overlay folder(s) are already exists:"
		printf "%s\n" "${dirs[@]}"
		printf "%s\n" "Make sure you use empty folder for the getting product release build environment!"
		#exit 194	 			 	
	fi
	execute git clone $USER@$SERVER:$ARAGO_URL $ARAGO
	cd $OEBASE/$ARAGO
	if [ ! -z "${OEREVS[0]}" ] ; then
		execute git reset --hard "${OEREVS[0]}"
	fi
	cd $OEBASE
	
	execute git clone $USER@$SERVER:$ARAGO_BITBAKE_URL $ARAGO_BITBAKE
	cd $OEBASE/$ARAGO_BITBAKE
	if [ ! -z "${OEREVS[1]}" ] ; then
		execute git reset --hard "${OEREVS[1]}"
	fi
	cd $OEBASE
	
	execute git clone $USER@$SERVER:$ARAGO_OE_DEV_URL $ARAGO_OE_DEV
	cd $OEBASE/$ARAGO_OE_DEV
	if [ ! -z "${OEREVS[2]}" ] ; then
		git reset --hard "${OEREVS[2]}"
	fi
	cd $OEBASE
	
	execute git clone $USER@$SERVER:$PD_APPS_URL $PD_APPS 
	cd $OEBASE/$PD_APPS
	if [ ! -z "${OEREVS[3]}" ] ; then
		git reset --hard "${OEREVS[3]}"
	fi
	cd $OEBASE
	
	execute git clone $USER@$SERVER:$PD_SYSTEM_URL $PD_SYSTEM
	cd $OEBASE/$PD_SYSTEM
	if [ ! -z "${OEREVS[4]}" ] ; then
		git reset --hard "${OEREVS[4]}"
	fi
	cd $OEBASE
fi

printf "%s\n" "Start cloning OE overlays"
	
for (( i=0; i < ${#PRODUCTDIRS[*]} ; i ++ )) ; do
	
	printf "%s\n" "Start cloning/updating ${PRODUCTURLS[$i]} overlay "
	if [ -d ${PRODUCTDIRS[$i]} ] ; then
		execute cd ${PRODUCTDIRS[$i]}
		execute git pull origin master 
		execute git fetch origin master --tags

		current_branch=`git branch | grep -F "*" | sed -e 's/*//g'`
		#Removing any spaces
		current_branch="${current_branch// /}"
		# If it's not, checkout it with --track option
		if [ "$current_branch" != "master" ] ; then
	
			remote_status=`git remote show origin | grep ${current_branch} | grep "tracked"`
			remote_status=$?
	
			if [  "$remote_status" -eq "0" ] ; then 
				execute git pull origin ${current_branch}
               	execute git fetch origin ${current_branch} --tags
			else
                printf "%s\n" "Warning: Please consider pushing your ${current_branch} branch to EBS"
            	printf "%s\n" "At the moment local branch is not tracked, update is skipped"
			fi
	
		fi	
		execute cd ${OEBASE} 
	else	 
		execute git clone $USER@$SERVER:${PRODUCTURLS[$i]} ${PRODUCTDIRS[$i]}
		execute cd ${OEBASE}/${PRODUCTDIRS[$i]}
		if [ "${PRODUCTBRANCHES[$i]}" != "master" ] ; then
			execute git checkout --track origin/${PRODUCTBRANCHES[$i]}
		fi
		execute cd ${OEBASE} 
	fi
done





printf "%s\n" "Fetching downloads folder..."
#rsync -av $OE_DOWNLOADS_DIR ./

printf "%s\n" "Getting OE build environment has completed" 	

return 0
}




# This function will try to update the software package  
#
# param1   - relative path to OEBASE (to oe-dev folder) 
# param2   - package git URL
# param3   - default package branch (in most cases it's master)
# 
# Return values:
# 	0 	- successfull 
# 	1	- the directory is not cleaned, it's contains modified or untracked files   
#	2	- the directory is not synched with the remote
#   	3	- pull request has failed, most like reason - conflicts	
#   	4	- local branch is not tracked with the remote
#	5	- pull request for the default branch has failed

function update_package
{
	local gitdir=$1
	local giturl=$2
	local default_branch=$3

	# Error causes	
	local success=0
        local err_not_git=1
	local err_not_cleaned=2
	local err_not_synched=3
	local err_pull_failed=4
	local err_not_tracked=5
	local err_default_pull_failed=6

	printf "%s" "Updating ${gitdir} ... "
	
	#Save current directory in the stack
	execute pushd ${PWD}

	if [ -d ${OEBASE}/${gitdir} ] ; then
		
		# Check if the directory is git directory 
	       	is_git "${OEBASE}/${gitdir}"
		local git_status=$?
		if [ $git_status -ne 0 ] ; then 
			printf "%s\n" "Skipped"	
			printf "%s\n\n" "Warning: This is not a git repository!"
	        	execute popd
	        	return $err_not_git 
		fi	
		
		# Check if the directory has modified or untracked files
		# if this is a case then skipp an update for this folder
		# and notify the user 
	       	is_git_clean "${OEBASE}/${gitdir}"
		local clean_status=$?
		if [ $clean_status -ne 0 ] ; then 
			printf "%s\n" "Skipped"	
			printf "%s\n\n" "Warning: There are some modified not checked in files"
	        	execute popd
	        	return $err_not_cleaned 
		fi	
			
		# Check either the current branch is synched with the remote
		is_git_synched "${OEBASE}/${gitdir}"	
		local synched_status=$?
		if [ $synched_status -eq 1 ] ; then 
			printf "%s\n" "Skipped"	
			printf "%s\n\n" "Warning: The remote branch does not exist"
	        	execute popd
	        	return $err_not_synched 
		fi
		
		if [ $synched_status -eq 2 ] ; then 
			printf "%s\n" "Skipped"	
			printf "%s\n\n" "Warning: The local branch is not synched with the remote"
	        	execute popd
	        	return $err_not_synched 
		fi

		execute cd ${OEBASE}/${gitdir} 
		current_branch=`git branch | grep -F "*" | sed -e 's/*//g'`
		#Removing any spaces
		current_branch="${current_branch// /}"

		# First pull the defaul_branch	
		execute git pull origin  ${default_branch}
		if [ "$?" -ne "0" ] ; then
			printf "%s\n" "Skipped"	
			printf "%s\n\n" "Warning: The git pull for the default branch has failed"
			execute popd
			return $err_default_pull_failed
		fi
		execute git fetch origin ${default_branch}  --tags
	
		if [ "${current_branch}" != ${default_branch} ] ; then
			# Check either the remote branch does exist?			
			git remote show origin | grep ${current_branch} | grep "tracked" &> /dev/null
                        remote_status=$?  

			if [  $remote_status -eq 0 ] ; then 
				# Pull the changes from the remote branch	
				execute git pull origin ${current_branch}
				if [ $? -ne 0 ] ; then
				    printf "%s\n" "Skipped"
				    printf "%s\n\n" "Warning: The git pull has failed for the current branch"

				    execute popd
				    return $err_pull_failed
				fi
               			execute git fetch origin ${current_branch} --tags
			else
				printf "%s\n" "Skipped"
				printf "%s\n\n" "Warning: The current branch is not tracked with the remote" 

				execute popd
				return $err_not_tracked
			fi
		fi	
	else
		# This directory does not exist yet, just clone it 
		execute git clone ${USER}@${SERVER}:${giturl} ${OEBASE}/${gitdir}
		# and checkout default branch
		execute cd ${OEBASE}/${gitdir}	 
		execute git checkout --track origin/${default_branch}	
	fi

	# Restore current directory from the stack

	printf "%s\n" "Ok"	
	execute popd	
	return $success 
} 




function update_handler
{
	
	printf "\n%s\n" "===================================================================="
	printf "%s\n" "Start updating OE packages"
	printf "\n%s\n" "===================================================================="
		
	
	for (( i=0; i < ${#OEDIRS[*]} ; i ++ )) ; do
		update_package ${OEDIRS[$i]} ${OEURLS[$i]} ${OEBRANCHES[$i]} 
	done
			
	for (( i=0; i < ${#OEDEVDIRS[*]} ; i ++ )) ; do
		update_package ${OEDEVDIRS[$i]} ${OEDEVURLS[$i]} ${OEDEVBRANCHES[$i]} 
	done
		
	printf "\n%s\n" "===================================================================="
	printf "\n%s\n" "Start updating development packages"
	printf "\n%s\n" "===================================================================="
	declare -i index
	for ((index=0; index < ${#DEVDIRS[*]}; index ++)) ; do
		update_package ${DEVDIRS[$index]} ${DEVURLS[$index]} ${DEVBRANCHES[$index]} 
	done
	

	printf "\n%s\n" "===================================================================="
	printf "\n%s\n" "Start updating products"
	printf "\n%s\n" "===================================================================="
   	declare -i index
	for ((index=0; index < ${#PRODUCTDIRS[*]}; index ++)) ; do
		update_package ${PRODUCTDIRS[$index]} ${PRODUCTURLS[$index]} ${PRODUCTBRANCHES[$index]} 
	done
	
	execute cd $OEBASE 


	printf "%s\n" ""
	printf "%s" "Syncing downloads folder ... "
	execute rsync -av $OE_DOWNLOADS_DIR ./
	printf "%s\n" "Ok"

	return 0
}






function status_handler
{
	declare -i index
	declare -a modified
	declare -a unsynced
	declare -i m=0
	declare -i u=0
	declare branch
	declare sync_status
	
	printf "%s" "Examining the status for all non-development OE overlays ..."
	for ((index=0; index < ${#OEDIRS[*]}; index ++)) ; do
		cd ${OEBASE}/${OEDIRS[$index]}
		git status | grep -e "modified" -e "Untracked" > /dev/null
		
		if [ "$?" -eq 0 ] ; then
			modified[$m]=${OEDIRS[$index]}
			let "m++"
		fi
		
		branch=`git branch | grep -F "*" | sed -e 's/*//g'`
		branch="${branch// /}"
		sync_status=( $(git diff --name-only origin/${branch}) )
		
		if [ ${#sync_status[*]} -ne 0 ] ; then
			unsynced[$u]=${OEDIRS[$index]}
			(( u++ ))
		fi
	done
	printf "%s\n" "Done"	

	is_dev
	if [ $? -eq 0 ] ; then
	printf "%s" "Examining the status for all development OE overlays ..."
		for ((index=0; index < ${#OEDEVDIRS[*]}; index ++)) ; do
			cd ${OEBASE}/${OEDEVDIRS[$index]}
			git status | grep -e "modified" -e "Untracked" > /dev/null
		
			if [ "$?" -eq 0 ] ; then
				modified[$m]=${OEDEVDIRS[$index]}
				(( m++ ))
			fi
			
		branch=`git branch | grep -F "*" | sed -e 's/*//g'`
		branch="${branch// /}"
		sync_status=( $(git diff --name-only origin/${branch}) )
		
		if [ ${#sync_status[*]} -ne 0 ] ; then
			unsynced[$u]=${OEDEVDIRS[$index]}
			(( u++ ))
		fi
		
		done
				
		for ((index=0; index < ${#DEVDIRS[*]}; index ++)) ; do
			cd ${OEBASE}/${DEVDIRS[$index]}
			git status | grep -e "modified" -e "Untracked" > /dev/null
		
			if [ "$?" -eq 0 ] ; then
				modified[$m]=${DEVDIRS[$index]}
				(( m++ ))
			fi
			
			branch=`git branch | grep -F "*" | sed -e 's/*//g'`
			branch="${branch// /}"
		
			sync_status=( $(git diff --name-only origin/${branch}) )
		
			if [ ${#sync_status[*]} -ne 0 ] ; then
			unsynced[$u]=${DEVDIRS[$index]}
			(( u++ ))
			fi
		done
	printf "%s\n" "Done"	
	fi
	
	printf "%s" "Examining the status for all products ..."
	for ((index=0; index < ${#PRODUCTDIRS[*]}; index ++)) ; do
		cd ${OEBASE}/${PRODUCTDIRS[$index]}
		git status | grep -e "modified" -e "Untracked" > /dev/null
		
		if [ "$?" -eq 0 ] ; then
			modified[$m]=${PRODUCTDIRS[$index]}
			let "m++"
		fi
		
		branch=`git branch | grep -F "*" | sed -e 's/*//g'`
		branch="${branch// /}"
		sync_status=( $(git diff --name-only origin/${branch}) )
		
		if [ ${#sync_status[*]} -ne 0 ] ; then
			unsynced[$u]=${PRODUCTDIRS[$index]}
			(( u++ ))
		fi
	done
	printf "%s\n" "Done"	

	
	printf "\n"
	printf "%s\n" "Got the following results:"
	printf "\n%s\n" "Number of dirty repos: ${#modified[*]}"
	if [ ${#modified[*]} -ne 0 ] ; then 
		printf "%s\n" "${modified[@]}"
	fi
	
	printf "\n%s\n" "Number of unsynced repos: ${#unsynced[*]}"
	if [ ${#unsynced[*]} -ne 0 ] ; then 
		printf "%s\n" "${unsynced[@]}"
	fi
	
	return 0
}


function describe_handler
{
	printf "%s\n"
	printf "%s\n" "============================================================"
	printf "%s\n" " OE overlays"
	printf "%s\n" "============================================================"
	
	for ((index=0; index < ${#OEDIRS[*]}; index ++)) ; do
		cd ${OEBASE}/${OEDIRS[$index]}
		echo ""
		printf "%s\n" "--------------------------------------------------------"
		printf "%s\n" "${OEDIRS[$index]}  "
		printf "%s\n" "--------------------------------------------------------"
		printf "%s\n" "last commit"
		printf "  "
	 	git describe
	 	printf "%s\n" "branches"
		git branch		 
		printf "%s\n" "--------------------------------------------------------"
	done
	
	# Check either the build environment as a development environment
	is_dev
	if [ $? -eq 0 ] ; then
		for ((index=0; index < ${#OEDEVDIRS[*]}; index ++)) ; do
			cd ${OEBASE}/${OEDEVDIRS[$index]}
			echo ""
			printf "%s\n" "--------------------------------------------------------"
			printf "%s\n" "${OEDEVDIRS[$index]}  "
			printf "%s\n" "--------------------------------------------------------"
			printf "%s\n" "last commit"
			printf "  "
			git describe
			printf "%s\n" "branches"
			git branch		
			printf "%s\n" "--------------------------------------------------------"
		done
		
	printf "%s\n"
	printf "%s\n" "============================================================"
	printf "%s\n" " Development packages"
	printf "%s\n" "============================================================"		
		for ((index=0; index < ${#DEVDIRS[*]}; index ++)) ; do
			cd ${OEBASE}/${DEVDIRS[$index]}
			echo ""	
			printf "%s\n" "--------------------------------------------------------"
			printf "%s\n" "${DEVDIRS[$index]}  "
			printf "%s\n" "--------------------------------------------------------"
			printf "%s\n" "last commit"
			printf "  "
			git describe
			printf "%s\n" "branches"
			git branch	
			printf "%s\n" "--------------------------------------------------------"
		done
	fi
	
	printf "%s\n"
	printf "%s\n" "============================================================"
	printf "%s\n" " Products"
	printf "%s\n" "============================================================"		
	product_list=( $( ls -1 ${OEBASE}/pd-products ) )
	for (( index = 0; index < ${#product_list[@]}; index ++ )) ; do
		cd ${OEBASE}/pd-products/${product_list[$index]}
		
		echo ""
		printf "%s\n" "--------------------------------------------------------"
		printf "%s\n" "${product_list[$index]} "
		printf "%s\n" "--------------------------------------------------------"
		printf "%s\n" "last commit"
		printf "  "
		git describe
		printf "%s\n" "branches"
		git branch	
		printf "%s\n" "--------------------------------------------------------"
	done
	
	return 0
}


function freeze_handler
{
	#Prelimenary check
	is_dev
	if [ $? -eq 0 ] ; then
		printf "%s\n" "This is not a development setup!"
		printf "%s\n" "Freeze command can only be used with dev. builds"
		return 1 
	fi
	
	if [ -z ${PRODUCT} ] ; then
		#List all available products
		product_list=( $( ls -1 ${PRODUCTS_DIR} ) )
		for (( index = 0; index < ${#product_list[@]}; index ++ )) ; do
			product_list[$index]=${product_list[$index]/.git/}
			printf "%s\n" "Updating release.inc for ${product_list[$index]}"
			releaseinc="${OEBASE}/pd-products/${product_list[$index]}/release.inc"
			if [ -f ${releaseinc} ] ; then
				rm ${releaseinc}
				touch ${releaseinc}
				echo "#####################################################################" >> ${releaseinc}
				echo "# Don't edit. Automatically generated file!                         #" >> ${releaseinc}
				echo "# Use                                                               #" >> ${releaseinc}
				echo "#   bb-get freeze productId                                         #" >> ${releaseinc}
				echo "#####################################################################" >> ${releaseinc}
				status=""
				echo "declare -a OEREVS=(" >> ${releaseinc}
				for ((d=0 ; d < ${#OEDIRS[*]}; d++ )) ; do
					status=`git --git-dir=${OEDIRS[$d]}/.git describe`
					echo "$status \\" >> ${releaseinc}  	
				done
				echo ")" >> ${releaseinc}
			fi
		done
	else
		declare -i d=0;
		declare releaseinc="${OEBASE}/pd-products/${PRODUCT}/release.inc"
		printf "%s\n" "Updating release.inc for ${PRODUCT}"
		rm ${releaseinc}
		touch ${releaseinc}
		echo "#####################################################################" >> ${releaseinc}
		echo "# Don't edit. Automatically generated file!                         #" >> ${releaseinc}
		echo "# Use                                                               #" >> ${releaseinc}
		echo "#   bb-get freeze productId                                         #" >> ${releaseinc}
		echo "#####################################################################" >> ${releaseinc}
		status=""
		echo "declare -a OEREVS=(" >> ${releaseinc}
		for (( ; d < ${#OEDIRS[*]}; d++ )) ; do
			status=`git --git-dir=${OEDIRS[$d]}/.git describe`
			echo "$status \\" >> ${releaseinc}  	
		done
		echo ")" >> ${releaseinc}
	fi
	
	return 0
}

function list_handler
{
	if [ -z "${PRODUCT}" ] ; then
		printf "\n" 
		printf "%s\n" "Available products:"
		product_list=( $( ls -1 ${PRODUCTS_DIR} ) )
		for (( index = 0; index < ${#product_list[@]}; index ++ )) ; do
			product_list[$index]=${product_list[$index]/.git/}
		done
		printf "%s\n" "${product_list[@]}"
	else
		printf "\n" 
		printf "%s\n" "Available $PRODUCT releases:"
		execute git --git-dir=${PRODUCTS_DIR}/${PRODUCT}.git tag -l
	fi
	
	return 0
}

declare -i params_count=$#
declare -a params=($@)
#COMMAND=$1

#printf "%s\n" "Number of parameters: $#" 
#printf "%s\n" "Parameters: ${params[*]}"


# Process command line...
while [ $# -gt 0 ]; do
  case $1 in
    --help | -h) 
    printf "%s\n"             
    printf "%s\n" "Installing product or development build environment"
	printf "%s\n"
	printf "%s\n" "Usage: $SCRIPT command[install|status|describe|update|list|freeze] [options] [product]"
	printf "%s\n"
	printf "%s\n" "Options:"
	printf "%s\t%s\n" "-d, --dev"     "Install development environment which includes"
	printf "\t\t%s\n"                 "pd-apps-dev and pd-system-dev"
	printf "%s\n"
	printf "%s\t%s\n" "-r, --release" "Product release number as r03 or r03-rc04"
	printf "%s\n"
	printf "%s\t%s\n" "-v, --version" "Version of $SCRIPT"
	printf "%s\n"
	printf "%s\t%s\n" "-h, --help"    "This help"
	printf "%s\n"
	printf "%s\n" "Use cases:"
	printf "%s\n"
	printf "%s\t%s\n" "bb-get install -d"	
	printf "\t\t\t%s\n"		"Dev. only. Clone all OE and dev. packages from Git."
	printf "\t\t\t%s\n"		"All available products are installed."
	printf "%s\n"
	printf "%s\t%s\n" "bb-get install -d gstproto"	
	printf "\t\t\t%s\n"		"Dev. only. As above but only one product gstproto"
	printf "\t\t\t%s\n"		"is installed. For both cases it's git cutting edge"
	printf "%s\n"
	printf "%s\t%s\n" "bb-get install -r r03-rc2 gstproto"
	printf "\t\t\t%s\n"		"Rel.only. Installing release build environment for"
	printf "\t\t\t%s\n"		"product release candidate r03-rc02"
	printf "%s\n"
	printf "%s\t%s\n" "bb-get status"
	printf "\t\t\t%s\n"		"Query for status of all OE overlays and development"
	printf "\t\t\t%s\n"		"packages. It will list the repositories with"
	printf "\t\t\t%s\n"		"uncommited and untracked content as well as"
	printf "\t\t\t%s\n"		"non-pushed commits"
	printf "%s\n"
	printf "%s\t%s\n" "bb-get describe"
	printf "\t\t\t%s\n"		"Run git describe against each of OE overlays,"
	printf "\t\t\t%s\n"		"development packages and product folders"
	printf "%s\n"
	printf "%s\t%s\n" "bb-get update"
	printf "\t\t\t%s\n"		"Dev. only. Run git pull against each of OE overlays,"
	printf "\t\t\t%s\n"		"development packages and product folders"
	printf "%s\n"
	printf "%s\t%s\n" "bb-get list"
	printf "\t\t\t%s\n"		"List all available products for the build"
	printf "%s\n"
	printf "%s\t%s\n" "bb-get list gstproto"
	printf "\t\t\t%s\n"		"List all available gstproto product releases and"
	printf "\t\t\t%s\n"		"release candidates"
	printf "%s\n"
	printf "%s\t%s\n" "bb-get freeze gstproto"
	printf "\t\t\t%s\n"		"Dev. only. Freeze the build to prepare a new product"
	printf "\t\t\t%s\n"		"release. It will update product release.inc with"
	printf "\t\t\t%s\n"		"the current commit numbers of all OE overlays."
	printf "%s\n"
	printf "%s\t%s\n" "bb-get freeze"
	printf "\t\t\t%s\n"		"Dev.only. As above but freeze all installed products"
	printf "%s\n"
	exit 0
    ;;
    
    --dev | -d)  shift; DEVFLAG=1; ;;
    --release| -r)  shift; PRODUCT_RELEASE=$1; ;;
    --version| -v) shift;
    GIT_SCRIPT_VERSION=`git --git-dir=$BB_GET_GITDIR describe`
    INSTALLED_SCRIPT_VERSION=`git --git-dir=$BB_GET_INSTALLDIR/.git describe`
    INSTALLED_SCRIPT_VERSION=${INSTALLED_SCRIPT_VERSION:7}
    GIT_SCRIPT_VERSION=${GIT_SCRIPT_VERSION:7}
    printf "%s\n" "Currently installed version  $INSTALLED_SCRIPT_VERSION"
    printf "%s\n" "Latest git version $GIT_SCRIPT_VERSION"
    
    exit 0;
    ;; 
        
	-*)     printf "%s\n" "Switch not supported" >&2; exit 1   ;;
	
	 *)     if [ -z "$COMMAND" ] ; then 
				case $1 in
					install)
						COMMAND=$1
						;;
					status)
						COMMAND=$1
						break
						;;
					describe)
						COMMAND=$1
						break
						;;
					update)
						COMMAND=$1
						break
						;;
					list)
						COMMAND=$1
						;;
					freeze)
						COMMAND=$1
						;;
					*)
						printf "%s\n" "Unknown command" 
						exit 1
						;;
				esac
				shift
			else
				PRODUCT=$1
				shift;
			fi  
			;;
esac
done

#printf "%s\n" "command = $COMMAND"
#printf "%s\n" "release = $RELEASE"
#printf "%s\n" "dev.flag = $DEVFLAG"

case $COMMAND in
	
	install)
		printf "%s\n" "Install handler"
		printf "%s\n" "PRODUCT=$PRODUCT"
		printf "%s\n" "PRODUCT_RELEASE=$PRODUCT_RELEASE"
		printf "%s\n" "DEV.FLAG=$DEVFLAG"
		install_handler 
		;;
		
	list)
		printf "%s\n" "List handler"
		printf "%s\n" "PRODUCT=$PRODUCT"
		list_handler
		;;
		
	status)
		printf "%s\n" "Status handler"
		status_handler
		;;
		
	describe)
		printf "%s\n" "Describe handler"
		describe_handler
		;;
		
	update)
		printf "%s\n" "Update handler"
		update_handler
		;;
	
		
	freeze)
		printf "%s\n" "Freeze handler"
		printf "%s\n" "PRODUCT=$PRODUCT"
		freeze_handler
		;;
		
		*)
		printf "%s\n" "Unknown command" 
		exit 1
		;;
esac
	


exit 0
