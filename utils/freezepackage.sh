#!/bin/sh
#Get package version from git if it's not provided by user
if [ -z $1 ] ; then
	printf "%s\n" "New release tag was not provided!"
	exit 0
else
	git_tag=$1
fi

#Check that the provided release tag has not already been existed
tags=( $(git tag -l) )
for (( t=0; t < ${#tags[@]} ; t ++ )) ; do
	if [ "$git_tag" = "${tags[$t]}" ] ; then
		printf "%s\n" "Provided release tag is already exists!"
		exit 0
	fi
done

#Using 3 stage process to get the branch name
# 1. List all the branches
# 2. Find a string with "*", which means active branch
# 3. Remove unwanted *
# WARNING:
# Removing * is mandatory, the bash `` command will list the content of
# the folder if the * symbol is present in the output!
# try to run branch=`git branch` and see the content of this variable
branch=`git branch | grep -F "*" | sed -e 's/*//g'`
#Removing any spaces
branch="${branch// /}"

if [ "$branch" != "master" ] ; then
	printf "%s\n" "Can't freeze, not a master banch!"
	exit 0
fi

git status | grep -e "modified" -e "Untracked" > /dev/null
if [ "$?" -eq 0 ] ; then
	printf "%s\n" "Can't freeze, there are some either modified or untracked files!"
	exit 0;
fi


sync_status=( $(git diff --name-only origin/${branch}) )
if [ ${#sync_status[*]} -ne 0 ] ; then
	printf "%s\n" "Can't freeze, there some unpushed commits!"
	exit 0
fi

remotes=( $(git remote -vv) )
package=${remotes[1]##*/}
package=${package%.git}
version=${git_tag}
version=${branch}-${version}

printf "%s\n" "package=$package"
printf "%s\n" "version=$version"

printf "%s\n" "Updating the configure.ac with the new release information"
line=`grep -n AC_INIT configure.ac`
line=${line%:*}
pd_url="www.paralleldynamic.com"
str="AC_INIT([$package], [$version], [support@paralleldynamic.com], [$package], [$pd_url])"

printf "%s\n" "line=$line"
printf "%s\n" "$line s/.*/$str/"
sed "$line s/.*/$str/" configure.ac > configure.ac.tmp

cmp -s configure.ac configure.ac.tmp

if [ $? == "1" ] ; then
	printf "%s\n" "Files are different"
	cp configure.ac.tmp configure.ac
	git add configure.ac
fi
rm configure.ac.tmp

# Setting-up LT_VERSION variable
export LT_VERSION=""
LT_VERSION=`git describe`
# Get from the git version in a form 1.2.6, two first numbers i.e. 1.0,
# for LibTool version, last number is not used
LT_VERSION=${LT_VERSION%*.*}
# Replace . with :
LT_VERSION=${LT_VERSION/./:}
# Set the third number - age, it must always be 0, so the final library version
# will be like: 
#  libmoduleA.so.1.0.2
#  libmoduleA.so.1.0
#  libmoduleA.so.1
#  libmoduleA.so
LT_VERSION=${LT_VERSION}:0

printf "%s\n" "LT_VERSION=${LT_VERSION}"
echo "LT_VERSION=$LT_VERSION" > lt_version.mk 
git add lt_version.mk

printf "%s\n" "Updating the ChangeLog with the new commits"
releases=( $(git tag -l) )
previous_release=${releases[${#releases[*]}-1]}
printf "%s\n" "Previous release: ${previous_release}"
last_commit=( $(git describe) )
printf "%s\n" "Last commit: ${last_commit}" 

echo "" 																	  > ChangeLog.tmp
echo "=====================================================================" >> ChangeLog.tmp
echo "RELEASE $git_tag"                                                      >> ChangeLog.tmp
echo "ISSUEDBY $USER"                                                        >> ChangeLog.tmp
printf "%s" "DATE "                                                          >> ChangeLog.tmp
date                                                                         >> ChangeLog.tmp
echo "=====================================================================" >> ChangeLog.tmp
echo "" 																	 >> ChangeLog.tmp
git log --pretty=tformat:"%h %ad %an %s" ${previous_release}..${last_commit} >> ChangeLog.tmp
echo "" 																	 >> ChangeLog.tmp
cat ChangeLog 																 >> ChangeLog.tmp
cp ChangeLog.tmp ChangeLog
rm ChangeLog.tmp
git add ChangeLog

printf "%s\n" "Commiting the changes and creating a new release tag"
git commit -m "Freezing. Release $git_tag"
git push origin master
git tag -a -m "$git_tag" $git_tag
git push --tags



