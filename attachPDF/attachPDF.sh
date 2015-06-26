#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk kdialog"
checkPrograms



# Run some common functions
createTmpDir
deleteTmpDir



# Prompt for file selection
cwd=$(pwd);
attach=$(kdialog --getopenfilename "${cwd}") || exit;

# Prompt for page number
pagenumber=$(kdialog --title "Page number" --inputbox "To what page in the PDF shall the file be attached to?") || exit;

# Set bookmark file
noBookmark="${tmpStorage}/noBookmark.pdf"
pdfMarks="${tmpStorage}/pdfmarks"
bookMarks="${tmpStorage}/bookmarks.txt"
metaFile="${tmpStorage}/meta.txt"



# Loop through the selected files
for arg ;
do
	# Test if it is a file
	if [[ -f "${arg}" ]]
	then
		fMessage="File attached"
		fExt="pdf"
		getSaveFile "${arg}" "${fMessage}" "${fExt}"

                pdftk "${arg}" attach_files "${attach}" to_page "${pagenumber}" output "${saveFile}"
	fi
done
