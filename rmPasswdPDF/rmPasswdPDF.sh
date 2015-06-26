#!/usr/bin/env bash

# Loop through the selected files
for arg ;
do
	# Test if it is a file
	if [[ -f "${arg}" ]]
	then
		# Prompt for password entry
        fName=$(basename "${arg}")
		Passwd=$(kdialog --title "Password" --inputbox "Enter the password for \"${fName}\"")
		if [[ $? != 0 ]]
		then
			exit;
		fi
		fileNoExt=${arg%.*}
		pdftk "${arg}" input_pw ${Passwd} output "${fileNoExt} - no Pwd.pdf"
	fi
done

exit;
