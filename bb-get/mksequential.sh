#! /bin/bash

# Script create sequential export for the given product/machine

declare -rx SCRIPT=${0##*/}
SCRIPT_PATH="$PWD"

printf "%s\n" "SCRIPT_PATH=$SCRIPT_PATH"

#Local variables
if [ "$SCRIPT_PATH" = "/opt/exports/release" ] ; then
	
	exportdir="/opt/exports/release"
	sequentialdir="/opt/exports/sequential-release"
	tmpdir="/tmp"
else
	exportdir="$SCRIPT_PATH"
	sequentialdir="$SCRIPT_PATH/sequential-release"
	tmpdir="/tmp"
fi

printf "%s\n" "exportdir=$exportdir"
printf "%s\n" "sequentialdir=$sequentialdir"
printf "%s\n" "tmpdir=$tmpdir"

rel="dev"
start=""
end=""
product=""
releases=""

start_index=""
end_index=""

command="normal"

# Exit causes
EXIT_SUCCESS=0
EXIT_FAIL_PRODUCT_ID_NOT_PROVIDED=193
EXIT_FAIL_NO_START_RELEASE_DIR_FOUND=194
EXIT_FAIL_INVALID_OPTION=195
EXIT_FAIL_ONLY_OPTIONS=196
EXIT_FAIL_MACHINE_NOT_PROVIDED=197

# This function takes one parameter - command to execute
# Run it with disabled output and return the result. 
#  
function execute ()
{
    $* >/dev/null
    return $?
}
export -f execute

# This function takes one parameter - command to execute
# Run it with disabled output and check the result. In case of fault it will
# leave that is denoted by capital L.
function executeL ()
{
	#Redirect standard error stream to standard output
	2>&1
	#Execute the command
    $* >/dev/null
    #Check the return result, if it fails exit
    if [ $? -ne 0 ]; then
    	echo "" | tee -a $update_log_file
    	echo "ERROR: executing $*" | tee -a $update_log_file
        echo "" | tee -a $update_log_file
        exit $? 
    fi
}
export -f executeL

# This function generates the list of the packages from opkg status file in the
# following form:
#	$package_$version_$arch
# Parameteres:
# 	$1 - (input)  Full file name to status file
#   $2 - (output) Output file for the full package names list(package_version_arch)  
# Returns:
#	0 - Success
#	1 - Failure
#   
function extract_packages ()
{
	_package_list=$2
	exec 3< $1
	
	PACKAGE_PREFIX="Package: "
	VERSION_PREFIX="Version: "
	ARCH_PREFIX="Architecture: "
	
	_package=""
	_version=""
	_arch=""
	
	if [ ! -f ${_package_list} ] ; then
		printf "%s\n" "File ${_package_list} is not found! "
		return 1;
	fi

	tmpfile=`mktemp $tmpdir/exctract_packages_XXXXXX.tmp`
	  
	while read LINE <&3 ; do
	
		# Check either the read line with package name, version or arch	
		echo "${LINE}" | grep -q "${PACKAGE_PREFIX}"
		package_flag=$?
		echo "${LINE}" | grep -q "${VERSION_PREFIX}"
		version_flag=$?
		echo "${LINE}" | grep -q "${ARCH_PREFIX}"
		arch_flag=$?

		# If the line was with the package name, store it localy	
		if [ $package_flag -eq 0 ] ; then
			_package="${LINE#$PACKAGE_PREFIX*}"
		fi

		# If the line was with the package version, store it localy	
		if [ $version_flag -eq 0 ] ; then
			_version="${LINE#$VERSION_PREFIX*}"
		fi

		# If the line was with the package arch, store it localy	and as the
		# arch is the last thing we need, write the package line to tmpfile
		if [ $arch_flag -eq 0 ] ; then
			_arch="${LINE#$ARCH_PREFIX*}"
			echo "${_package}_${_version}_${_arch}" >> ${tmpfile}
		fi
	done

	sort -f ${tmpfile} > $_package_list
	executeL rm $tmpfile
	
	return 0 
}
export -f extract_packages


# This functions lists all available product releases
# Return:
#   0 : Success
#   1 : No any product releases were found
function get_releases ()
{
	pdlist=""

	executeL pushd $PWD
	executeL cd ${exportdir}
	pdlist=( $(ls -1 | grep ${product}) )
	executeL popd

	#If there is no any product folder found, return 1
	if [ -z "${pdlist}" ] ; then 
		return 1;
	fi
	
	# Remove product name and dot delimiter from directories list and save it in 
	# in the releases global variable
	for (( i=0; i < ${#pdlist[@]} ; i++ )) ; do
	releases[$i]=${pdlist[$i]##${product}.}
	done
		
	return 0;	
}

# This function will compare two lists of the packages and will write back the
# list of new and upgraded packages in the list2
# Parameters:
#	1 :  Input file with the list1 of the packages
#   2 :  Input file with the list2 of the packages
#   3 :  Otput file with the list of new packages in list2 
#	4 :	 Otput file with the list of upgraded packages in list2
# Return:
#	0 : Success
#	1 : Failure
function diff_packages ()
{
	#Save parameters locally
	list1=$1
	list2=$2
	#New packages
	np=$3
	#Upgrade packages
	up=$4
	
	if [ ! -f $list1 ] ; then 
		printf "%s\n" "File $list1 is not found!"
		return 1;
	fi
	
	if [ ! -f $list2 ] ; then 
		printf "%s\n" "File $list2 is not found!"
		return 1;
	fi

	if [ ! -f $np ] ; then 
		printf "%s\n" "File $np is not found!"
		return 1;
	fi

	if [ ! -f $up ] ; then 
		printf "%s\n" "File $up is not found!"
		return 1;
	fi

	# Stream list2 	
	exec 4< $list2
	
	while read line2 <&4 ; do
	
		# Retrieve version and the package name 	
		version2=${line2#*_}
		_package=${line2%*_$version}

		# Read the same package record from the list1 
		line1=( $(grep ${_package} $list1) ) 
	
			
		if [ -n $line1 ] ; then
			version1=${line1#*_};
		
			# Compare versions from list1 and list2, if they are different
			# the package was upgraded	
			if [ "$version1" != "$version2" ] ; then
				echo $line2 >> $up
			fi
		else
			#The package name was not found in the list, so it's a new one!
			echo $line2 >> $np	
		fi	
	done
	
	#Closing file descriptor &3
	exec 4<&-

	return 0;	
}
export -f diff_packages
	

while [ $# -gt 0 ]; do
  case $1 in
    --help | -h) 
    printf "%s\n"             
    printf "%s\n" "Make sequential release exports for the certain product"
	printf "%s\n"
	printf "%s\n" "Usage: $SCRIPT [options]"
	printf "%s\n"
	printf "%s\n" "Options:"
	printf "%s\n"
	printf "%s\t%s\n" "-p, --product"   "Mandatory. Exported product ID" 
	printf "%s\n"
	printf "%s\t%s\n" "-s, --start"     "Optional. Release number which is going to be used as a base"
	printf "\t\t%s\n"                   "If it is not provided, first available release is taken."
	printf "%s\n"
	printf "%s\t%s\n" "-r, --release"   "Optional. Processing release build of the product"
	printf "%s\n"
	printf "%s\t%s\n" "-e, --end"       "Optional. All releases in between start and up to"
	printf "\t\t%s\n"                   "including this are exported. If it is not provided,"
	printf "\t\t%s\n"                   "the last available one is used instead."
	printf "%s\t%s\n" "-l, --list"   	"List available releases" 
	printf "%s\n"
	printf "%s\t%s\n" "-h, --help"       "This help"
	printf "%s\n"
	printf "%s\n" "Examples:"
	printf "%s\n" "To make sequential export for all available releases, using first one as a base" 
	printf "\t%s\n" "$SCRIPT -p gstproto"
	printf "%s\n"
	printf "%s\n" "To make gstproto sequential release" 
	printf "\t%s\n" "$SCRIPT  -p iptft -s r02 -e r05"
	printf "%s\n"
	exit $EXIT_SUCCESS
    ;;

    --product| -p) shift;	product=$1 ; shift
    	continue 
    ;;
    
    --start| -s) shift;	start=$1 ; shift
    	continue 
    ;;
    
    --release | -r) shift;	
    	rel="rel"; 
    	continue 
    ;;
    
	--end| -e)  shift; end=$1; shift
    	continue
    ;;
    
    --list| -l) shift; 
    	command="list"
    	continue
    ;;
    
    
	-*)  printf "%s\n" "Switch $1 not supported" >&2; exit $EXIT_FAIL_INVALID_OPTION ;;
	
	*)   printf "%s\n" "Only options are allowed!" >&2; exit $EXIT_FAIL_ONLY_OPTIONS ;;
esac
done

printf "%s\n" "product=$product"
printf "%s\n" "start=$start"
printf "%s\n" "end=$end"
printf "%s\n" "rel=$rel"

    	
if [ -z $product ] ; then
	printf "%s\n" "You must specify the product ID"
	printf "%s\n" "Use $SCRIPT --help for more details"
	exit $EXIT_FAIL_PRODUCT_ID_NOT_PROVIDED
fi

if [ "${command}" = "list" ] ; then
	get_releases
	printf "\n%s\n" "Available releases for $product:"
	printf "\t%s\n" ${releases[@]}
	exit $EXIT_SUCCESS
else
	get_releases
fi

printf "%s\n" "Start sequential export for the product $product"
printf "%s\n" "from $start to $end release"


printf "%s" "Start point release folder check ... "
if [ ! -d "${exportdir}/${product}.${start}" ] ; then
	printf "%s\n" "Failed"
	printf "%s\n" "Start point ${product}.${start} release folder is not found"
	exit $EXIT_FAIL_NO_START_RELEASE_DIR_FOUND
fi
printf "%s\n" "Ok"

printf "%s" "End point release folder check ... "
if [ ! -d "${exportdir}/${product}.${end}" ] ; then
	printf "%s\n" "Failed"
	printf "%s\n" "End point ${product}.${end} release folder is not found"
	exit $EXIT_FAIL_NO_END_RELEASE_DIR_FOUND
fi
printf "%s\n" "Ok"

#Searching for start and end index
for (( i=0; i<${#releases[@]}; i++ )) ; do
	if [ "${releases[$i]}" = "${start}" ] ; then
		start_index=$i;
	fi	
	
	if [ "${releases[$i]}" = "${end}" ] ; then
		end_index=$i;
	fi	
done



declare -a fd_new_packages;
declare -a fd_upgraded_packages;

printf "%s" "Extract package list for base release ${releases[$start_index]} ... "
machines=( $( find ./${product}.${releases[$start_index]}/${rel}/ipk -name opkg.status ) )
	
for (( m=0 ; m<${#machines[*]} ; m++ )) ; do
	machines[$m]=`dirname ${machines[$m]}`
	machines[$m]=${machines[$m]/"./${product}.${releases[$start_index]}/${rel}/ipk/"/}

	touch $tmpdir/${releases[$start_index]}_${machines[$m]}_packages.tmp
	extract_packages "${exportdir}/${product}.${releases[$start_index]}/${rel}/ipk/${machines[$m]}/opkg.status" $tmpdir/${releases[$start_index]}_${machines[$m]}_packages.tmp
done
printf "%s\n" "Ok"

for (( i=$start_index + 1; i<=$end_index; i++ )); do
	
	printf "%s\n" "Gathering available machines information for ${releases[$i]}"
	machines=( $( find ./${product}.${releases[$i]}/${rel}/ipk -name opkg.status ) )
	
	printf "%s\n" "Machines exported for ${product}.${releases[$i]}:"
	printf "%s\n" "${machines[@]}"
	
	for (( m=0 ; m<${#machines[*]} ; m++ )) ; do
		machines[$m]=`dirname ${machines[$m]}`
		machines[$m]=${machines[$m]/"./${product}.${releases[$i]}/${rel}/ipk/"/}
	
		printf "%s" "Activate an array of packages list temp files ... " 
		touch $tmpdir/${releases[$i]}_${machines[$m]}_packages.tmp
		touch $tmpdir/${releases[$i]}_${machines[$m]}_new_packages.tmp
		touch $tmpdir/${releases[$i]}_${machines[$m]}_upgraded.tmp
		printf "%s\n" "Ok"

		printf "%s" "Extract packages list for ${releases[$i]} ... "
		extract_packages "${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/opkg.status" $tmpdir/${releases[$i]}_${machines[$m]}_packages.tmp
		printf "%s\n" "Ok"
	
		printf "%s" "Creating new and upgraded packages list from ${releases[$i]} form ${machines[$m]} ... "
		#diff_packages "${package_list[$i-1]}" "${package_list[$i]}" "${new_packages[$i]}" "${upgraded_packages[$i]}"
		diff_packages $tmpdir/"${releases[$i-1]}_${machines[$m]}_packages.tmp" $tmpdir/"${releases[$i]}_${machines[$m]}_packages.tmp" $tmpdir/"${releases[$i]}_${machines[$m]}_new_packages.tmp" $tmpdir/"${releases[$i]}_${machines[$m]}_upgraded.tmp"
		printf "%s\n" "Ok"
	
		printf "%s" "Copy new and upgraded packages for ${releases[$i]} ... "

		printf "%s" "Create the release directory under sequential-release folder ... "
		executeL mkdir -p ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk
		printf "%s\n" "Ok"
	
		printf "%s" "Create all, arch, and machine sub-folders ... "
		executeL pushd $PWD

		executeL cd ${exportdir}/${product}.${releases[$i]}/${rel}/ipk
		dirs=( $(ls -d -1 */ | grep -v x86_64) )
		executeL popd

		# Removing slash from the directory string. For further processing we need
		# just directory name
		for (( d=0; d < ${#dirs[*]}; d++ )) ; do
	 	dirs[$d]=${dirs[$d]//\//}
		executeL mkdir -p ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}
		done
		printf "%s\n" "Ok"

		# Copy product.version
		#executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/${machines[$m]}/product.version ${sequentialdir}/${product}.${releases[$i]}/${rel}/${machines[$m]}/product.version

		printf "%s" "Copy first level Packages* files ... "
		if [ ! -f ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/Packages ] ; then 
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/Packages ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/Packages.filelist ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/Packages.gz ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/Packages.stamps ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk
		fi
		printf "%s\n" "Ok"
	
		printf "%s" "Copy some common & generic opkg files ... "
		executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/opkg.status ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/opkg.status
		executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/Packages ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/Packages
		executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/Packages.filelist ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/Packages.filelist
		executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/Packages.gz ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/Packages.gz
		executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/Packages.stamps ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${machines[$m]}/Packages.stamps
	
		for (( d=0; d < ${#dirs[*]}; d++ )) ; do
			executeL mkdir -p ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}/Packages ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}/Packages
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}/Packages.filelist ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}/Packages.filelist
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}/Packages.gz ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}/Packages.gz
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}/Packages.stamps ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${dirs[$d]}/Packages.stamps 
		done
		printf "%s\n" "Ok"
 	       
		fd_new_packages=$(( 10*m + 2*i ))
		fd_upgraded_packages=$((10*m  + 2*i + 1 ))	
		eval "exec ${fd_new_packages}<$tmpdir/${releases[$i]}_${machines[$m]}_new_packages.tmp"
		eval "exec ${fd_upgraded_packages}<$tmpdir/${releases[$i]}_${machines[$m]}_upgraded.tmp"
	
		while read line <&${fd_new_packages} ; do
			arch=${line##*_}
			version=${line#*_}
			package=${line%*_$version}
			version=${version%*_$arch}
	
			#Copy the release ipk
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}_${version}_${arch}.ipk ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/
			#Copy dbg, dev, src, docs ipks if they exist
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-???_${version}_${arch}.ipk ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/
		done
	
		while read line <&${fd_upgraded_packages} ; do
			arch=${line##*_}
			version=${line#*_}
			package=${line%*_$version}
			version=${version%*_$arch}
	
			# Copy the release ipk
			executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}_${version}_${arch}.ipk ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/
	
			#Copy doc ipk if it exists
			if [ -f ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-doc_${version}_${arch}.ipk ] ; then 
				executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-doc_${version}_${arch}.ipk ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/
			fi
		
			# Copy dbg ipk
			if [ -f ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-dbg_${version}_${arch}.ipk ] ; then 
				executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-dbg_${version}_${arch}.ipk ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/
			fi
		
			# Copy dev ipk
			if [ -f ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-dev_${version}_${arch}.ipk ] ; then 
				executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-dev_${version}_${arch}.ipk ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/
			fi
		
			# Copy src ipk
			if [ -f ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-src_${version}_${arch}.ipk ] ; then 
				executeL cp ${exportdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/${package}-src_${version}_${arch}.ipk ${sequentialdir}/${product}.${releases[$i]}/${rel}/ipk/${arch}/
			fi
		done 

		# Closing file descriptors	
		eval "exec ${fd_new_packages}<&-"
		eval "exec ${fd_upgraded_packages}<&-"
	 
	done # machines loop
	
	printf "%s\n" "Ok"
done # releases loop 

printf "%s\n" "Creating tar-balls and calculating MD5 checksum" 
executeL pushd $PWD 
executeL cd ${sequentialdir}
for (( i=$start_index + 1; i<=$end_index; i++ )); do
	printf "%s" "Creating ${product}.${releases[$i]} tarball ... "
	executeL tar cvfj ${product}.${releases[$i]}.tar.bz2 ${product}.${releases[$i]}
	md5=`md5sum ${product}.${releases[$i]}.tar.bz2`
 	md5=${md5:0:32}
 	executeL mv  ${product}.${releases[$i]}.tar.bz2 ${product}.${releases[$i]}.${md5}.tar.bz2
  	executeL rm -rf ${product}.${releases[$i]}
	printf "%s\n" "Ok"
done
executeL popd

printf "%s" "Delete temproary files ... "
	rm -f $tmpdir/*_packages.tmp
	rm -f $tmpdir/*_new_packages.tmp
	rm -f $tmpdir/*_upgraded.tmp
printf "%s\n" "Ok"

exit $EXIT_SUCCESS
