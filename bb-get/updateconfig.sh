#!/bin/sh

#Using 3 stage process to get the branch name
# 1. List all the branches
# 2. Find a string with "*", which means active branch
# 3. Remove unwanted *
# WARNING:
# Removing * is mandatory, the bash `` command will list the content of
# the folder if the * symbol is present in the output!
# try to run branch=`git branch` and see the content of this variable

branch=`git branch | grep -F "*" | sed -e 's/*//g'`
#Removing any left spaces
branch="${branch// /}"

version=`git describe`
#package=${version%_*}
remotes=( $(git remote -vv) )
version=${version#*_}
version="$branch-$version"
#Removing any left spaces in the version content
version="${version// /}"

package=${remotes[1]##*/}
package=${package%.git}
git status | grep -e "modified" -e "Untracked" > /dev/null
		
if [ "$?" -eq 0 ] ; then
	version=${version}+
fi

pd_url="http://www.paralleldynamic.com"
configure_ac_init=`grep AC_INIT configure.ac`
ac_init="AC_INIT([$package], [$version], [support@hparalleldynamic.com], [$package], [$pd_url])"
printf "%s\n" "configure_ac_init=$configure_ac_init"
printf "%s\n" "ac_init=$ac_init"

if [ "$ac_init" = "$configure_ac_init" ] ; then
	printf "%s\n" "Configuration has not been changed"
	exit 0
fi

#Defining replacement strings
version_str="#define VERSION \"$version\""
package_str="#define PACKAGE \"$package\""
package_bugreport_str="#define PACKAGE_BUGREPORT \"support@paralleldynamic.com\""
package_name_str="#define PACKAGE_NAME \"$package\""
package_string_str="#define PACKAGE_STRING \"$package $version\""
package_tarname_str="#define PACKAGE_TARNAME \"$package\""
package_url_str="#define PACKAGE_URL \"www.paralleldynamic.com\""
package_version_str="#define PACKAGE_VERSION \"$version\""

#Calculate the position of each string in the config.h
version_ln=`grep -nF "#define VERSION \"" config.h`
version_ln=${version_ln%:*}

package_ln=`grep -nF "#define PACKAGE \"" config.h`
package_ln=${package_ln%:*}

package_bugreport_ln=`grep -nF "#define PACKAGE_BUGREPORT" config.h`
package_bugreport_ln=${package_bugreport_ln%:*}

package_name_ln=`grep -nF "#define PACKAGE_NAME" config.h`
package_name_ln=${package_name_ln%:*}

package_string_ln=`grep -nF "#define PACKAGE_STRING" config.h`
package_string_ln=${package_string_ln%:*}

package_tarname_ln=`grep -nF "#define PACKAGE_TARNAME" config.h`
package_tarname_ln=${package_tarname_ln%:*}

package_url_ln=`grep -nF "#define PACKAGE_URL" config.h`
package_url_ln=${package_url_ln%:*}

package_version_ln=`grep -nF "#define PACKAGE_VERSION" config.h`
package_version_ln=${package_version_ln%:*}

#Replace the required lines of config.h
cp config.h config.h.0
sed "$version_ln s/.*/$version_str/" config.h.0 > config.h.tmp
cp config.h.tmp config.h.0

sed "$package_ln s/.*/$package_str/" config.h.0 > config.h.tmp
cp config.h.tmp config.h.0

sed "$package_bugreport_ln s/.*/$package_bugreport_str/" config.h.0 > config.h.tmp
cp config.h.tmp config.h.0

sed "$package_name_ln s/.*/$package_name_str/" config.h.0 > config.h.tmp
cp config.h.tmp config.h.0

sed "$package_string_ln s/.*/$package_string_str/" config.h.0 > config.h.tmp
cp config.h.tmp config.h.0

sed "$package_tarname_ln s/.*/$package_tarname_str/" config.h.0 > config.h.tmp
cp config.h.tmp config.h.0

sed "$package_url_ln s/.*/$package_url_str/" config.h.0 > config.h.tmp
cp config.h.tmp config.h.0

sed "$package_version_ln s/.*/$package_version_str/" config.h.0 > config.h.tmp
cp config.h.tmp config.h.0

#Compare generated file with 
cmp -s config.h.0 config.h
if [ $? == "1" ] ; then 
	cp config.h.0 config.h
fi

#Remove tmp file
rm config.h.tmp
rm config.h.0

exit 0

