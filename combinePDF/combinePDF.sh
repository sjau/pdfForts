#!/bin/bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk gs kdialog basename"
checkPrograms



# Run some common functions
createTmpDir
deleteTmpDir
sortFiles "$@"



# Prompt whether to add each individual pdf as seperate bookmark entry
docBookmarks=$(kdialog --radiolist "Shall the pdf names also added as bookmark entries?" 1 "Yes" on 2 "No" off) || exit;



# Prompt for level between individual pdf name and existing bookmarks
levelBookmarks=$(kdialog --radiolist "Shall the pdf names be a superior category?" 1 "Yes" on 2 "No" off) || exit;



# Prompt file save name
pathName="${filesSorted[1]%/*}"
saveFile=$(kdialog --getsavefilename "${pathName}/Combined.pdf") || exit;



# Loop through the sorted files
h="1"
curPage="0"
for curFile in "${filesSorted[@]}"
do
	fileBase=$(basename "${curFile%.*}")
	countZero "${h}"
	curDocLoc="${tmpStorage}/${addZero}${h}"
	pdftk "${curFile}" dump_data >> "${curDocLoc}.txt"
	pdftk "${curFile}" cat output "${curDocLoc}.pdf"
	bookMarks="${tmpStorage}/bm${addZero}${h}.txt"
	convertMetaToBookmark "${curDocLoc}.txt"
	convertBookmarkToPdfmark "${bookMarks}"
	curPage=$((curPage + curDocPages))
	((h++))
done


# Combine the files
cd "${tmpStorage}"
gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="new.pdf" *.pdf "pdfmarks"
mv "new.pdf" "${saveFile}"


exit;
