#!/usr/bin/env bash

# Prompt to maintain the layout
tplSelect=$(kdialog --title "Maintain Layout" --yesnocancel "Press YES if you want the extracted text to reflect the layout of the PDF")
case "${?}" in
	0) # Yes selected
		layout="-layout"
		;;
	1) # No selected
		layout=""
		;;
	2) # Cancel selected
		exit;
		;;
esac


# Loop through the selected files
for arg ;
do
	# Test if it is a file
	if [[ -f "${arg}" ]]
	then
		# Prompt file save name
		fn=${arg%.*}
		newFile=$(kdialog --getsavefilename "${fn}.txt");
		if [[ $? != 0 ]]
		then
			exit;
		fi
		pdftotext ${layout} "${arg}" "${newFile}"
	fi
done
