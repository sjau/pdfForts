#!/bin/bash

# Ask for range
Range=$(kdialog --title "Define pages" --inputbox "Set the pages you want to extract.
Values are to be seperated by a white space.
You can also enter a range of pages, e.g.

3-6 15 21-24 37-end 10

That would extract the pages 3-6, page 17, pages 21-24, pages 37 to the end, page 10.

The order is defines by your range.

" "1-end");
if [[ $? != 0 ]]
then
	exit;
fi


# Parse the selected file
for arg ;
do
	# Test if it is a file
	if [[ -f "${arg}" ]]
	then
		fName=$(basename "${arg}")
		fileNoExt=${arg%.*}
		# Prompt for save file
		Name=$(kdialog --getsavefilename "${fileNoExt} - extracted.pdf");
		if [[ $? != 0 ]}
		then
			exit;
		fi
		pdftk "${arg}" cat ${Range} output "${Name}"
	fi
done
