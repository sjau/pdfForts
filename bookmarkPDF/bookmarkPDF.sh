#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk kdialog basename kate gs recode"
checkPrograms



# Run some common functions
createTmpDir
deleteTmpDir



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
        fMessage="Bookmarks edited"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}"

        extractMetaData "${arg}"
        convertMetaToBookmark "${metaFile}"
        kate -b "${bookMarks}"
        convertBookmarkToPdfmark "${bookMarks}"
        gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="${saveFile}" -c "userdict /opdfmark systemdict /pdfmark get put /pdfmark {cleartomark} def" -f "${noBookmark}" -c "/pdfmark userdict /opdfmark get def" -f "${pdfMarks}"
    fi
done
