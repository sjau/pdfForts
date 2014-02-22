#!/bin/bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk kdialog basename"
checkPrograms



while [[ "${PasswdChk}" != "OK" ]]
do
	# Ask for password
	Passwd1=$(kdialog --title "Password" --password "Please enter a password");
	if [[ $? != 0 ]]; then
		exit;
	fi
	Passwd2=$(kdialog --title "Password Confirmation" --password "Re-enter the password");
	if [[ $? != 0 ]]; then
		exit;
	fi
	# Check if the passwords are the same
	if [[ "${Passwd1}" = "${Passwd2}" ]]
	then
		Passwd="${Passwd1}"

		if [[ -n "${Passwd}" ]]
		then
			PasswdChk="OK"
		else
			kdialog --error "You can't set an empty password."
		fi
	else
		kdialog --error "The supplied passwords do not match.
Please try again."
	fi
done



# Loop through the selected files
for arg ;
do
	# Test if it is a file
	if [[ -f "${arg}" ]]
	then
		fMessage="with Pwd"
		fExt="pdf"
		getSaveFile "${arg}" "${fMessage}" "${fExt}"
		pdftk "${arg}" output "${saveFile}" user_pw "${Passwd}"
	fi
done
