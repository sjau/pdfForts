#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# Set allScripts array
allScripts=( "addPasswdPDF" "extractPDF" "metaPDF" "rmPasswdPDF" "rotatePDF" "stampPDF" )

# Set original path
origPath=`pwd`



function installFunc
{
	for scriptName in "${runScripts[@]}"
	do
		source "${origPath}/${scriptName}/vars.sh"
		cd "${origPath}/${scriptName}"

		mkdir -p "${installPath}"
		cp "${scriptName}.sh" "${installPath}"
		chmod 0755 "${installPath}${scriptName}.sh"

		mkdir -p "${serviceMenus}"
		cp "${scriptName}.desktop" "${serviceMenus}"

		if [ "${configFile}" = "y" ]
		then
			cp "${scriptName}.conf" "${serviceMenus}"
		fi
	done
}


function uninstallFunc
{
	for scriptName in "${runScripts[@]}"
	do
		source "${origPath}/${scriptName}/vars.sh"
		cd "${origPath}/${scriptName}"

		rm "${installPath}${scriptName}.sh"
		rm "${serviceMenus}${scriptName}.desktop"

		if [ "${configFile}" = "y" ]
		then
			rm "${serviceMenus}${scriptName}.conf"
		fi
	done
}


function symlinkFunc
{
	for scriptName in "${runScripts[@]}"
	do
		source "${origPath}/${scriptName}/vars.sh"
		cd "${origPath}/${scriptName}"

		curPath=`pwd`
		mkdir -p "${installPath}"
		ln -s "${curPath}/${scriptName}.sh" "${installPath}${scriptName}.sh"

		mkdir -p "${serviceMenus}"
		ln -s "${curPath}/${scriptName}.desktop" "${serviceMenus}${scriptName}.desktop"

		if [ "${configFile}" = "y" ]
		then
			ln -s "${curPath}/${scriptName}.conf" "${serviceMenus}${scriptName}.conf"
		fi
	done
}


function validParaFunc
{
	paraCheck="${1}"
	# Check if PARAMETER2 is in allScripts array
	for i in "${allScripts[@]}"
	do
		if [ "${i}" == "${paraCheck}" ]
		then
			valFound="OK"
		fi
	done
	# Check if PARAMETER2 is 'all'
	if [ "${paraCheck}" == "all" ]
	then
			valFound="OK"
	fi
	# Check if the $valFound var was set to OK
	if [ "${valFound}" != "OK" ]
	then
		echo "Sorry, no valid PARAMETER2 supplied."
		echo "Please run the script without parameters to see the help."
		echo "e.g.    ./install.sh"
		exit;
	fi
}


case "${2}" in
all) echo ""
	runScripts=( "${allScripts[@]}" )
	;;
*) echo ""
	runScripts=( ${2} )
	;;
esac



case "${1}" in
install) validParaFunc "${2}"
	echo "Install the files"
	installFunc
    echo "Copy files to their location. An entry in Dolphin should appear soon."
	;;
uninstall) validParaFunc "${2}"
	echo "Uninstalling the files"
	uninstallFunc
	echo "Remove files. The entry in Dolphin should disappear soon."
    ;;
symlink) validParaFunc "${2}"
	echo  "Symlinking the files"
	symlinkFunc
	echo "Symlink files to their location. An entry in Dolphin should appear soon."
    ;;
*) echo "Use: run as root: ./install.sh PARAMETER1 PARAMETER2"
   echo ""
   echo ""
   echo "Possible options for PARAMETER1:"
   echo "symlink - instead of copying the files to their according location it just symlinks them; this is good for when you update the git repo --> this is RECOMMENDED"
   echo "install - this will copy the files to their according location"
   echo "uninstall - this will remove the files from their according location, however it'll leave the config files intact"
   echo ""
   echo ""
   echo "Possible options for PARAMETER2"
   echo "all - run on all scripts"
   echo "addPasswdPDF - only run on addPasswdPDF script"
   echo "extractPDF - only run on extractPDF script"
   echo "metaPDF - only run on metaPDF script"
   echo "rmPasswdPDF - only run on rmPasswdPDF script"
   echo "rotatePDF - only run on rotatePDF script"
   echo "stampPDF - only run on stampPDF script"
   ;;
esac
