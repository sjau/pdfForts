#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


scriptName="addPasswdPDF"
installPath="/usr/bin/pdfForts/"
serviceMenus="/usr/share/kde4/services/ServiceMenus/pdfForts/"
configFile="n"


function installFunc
{
	mkdir -p "${installPath}"
	cp "${scriptName}.sh" "${installPath}"
	chmod 0755 "${installPath}${scriptName}.sh"

	mkdir -p "${serviceMenus}"
	cp "${scriptName}.desktop" "${serviceMenus}"

	if [ "${configFile}" = "y" ]
	then
		cp "${scriptName}.conf" "${serviceMenus}"
	fi
}


function uninstallFunc
{
	rm "${installPath}${scriptName}.sh"
	rm "${serviceMenus}${scriptName}.desktop"

	if [ "${configFile}" = "y" ]
	then
		rm "${serviceMenus}${scriptName}.conf"
	fi
}


function symlinkFunc
{
	curPath=`pwd`
	mkdir -p "${installPath}"
	ln -s "${curPath}/${scriptName}.sh" "${installPath}${scriptName}.sh"

	mkdir -p "${serviceMenus}"
	ln -s "${curPath}/${scriptName}.desktop" "${serviceMenus}${scriptName}.desktop"

	if [ "${configFile}" = "y" ]
	then
		ln -s "${curPath}/${scriptName}.conf" "${serviceMenus}${scriptName}.conf"
	fi
}



case "$1" in
install)  echo "Install the files"
	installFunc
    echo "Copyied files to their location. An entry in Dolphin should appear soon."
	;;
uninstall)  echo "Uninstalling the files"
	uninstallFunc
	echo "Removed files. The entry in Dolphin should disappear soon."
    ;;
symlink)  echo  "Symlinking the files"
	symlinkFunc
	echo "Symlinked files to their location. An entry in Dolphin should appear soon."
    ;;
*) echo "Use: as root: ./install.sh OPTION"
   echo "Possible options:"
   echo "install - this will copy the files to their according location"
   echo "uninstall - this will remove the files from their according location, however it'll leave the config files intact"
   echo "symlink - instead of copying the files to their according location it just symlinks them; this is good for when you update the git repo"
   ;;
esac