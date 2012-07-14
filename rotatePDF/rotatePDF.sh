#!/bin/bash

# Ask for range
Rotate=`kdialog --menu "Chose rotation (clockwise):" E "90°" S "180°" W "270°"`;
if [ $? != 0 ]; then
	exit;
fi

# Parse the selected file
for arg ;
do
	# Test if it is a file
	if [ -f "${arg}" ]
	then
		fName=`basename "${arg}"`
		fileNoExt=${arg%.*}
		# Prompt for save file
		Name=`kdialog --getsavefilename "${fileNoExt} - rotated.pdf"`;
		if [ $? != 0 ]; then
			exit;
		fi
		pdftk "${arg}" cat 1-end${Rotate} output "${Name}"
	fi
done
