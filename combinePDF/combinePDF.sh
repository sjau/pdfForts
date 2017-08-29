#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk gs recode"
checkPrograms


# Run some common functions
createTmpDir
deleteTmpDir
sortFiles "$@"


# Prompt whether to add each individual pdf as seperate bookmark entry
docBookmarks=$(guiYesNo "Shall the pdf names also added as bookmark entries?") || exit;


# Prompt for level between individual pdf name and existing bookmarks
levelBookmarks=$(guiYesNo "Shall the pdf names be a superior category?") || exit;

# Prompt file save name
pathName="${filesSorted[1]%/*}"
fMessage="Combined"
fExt="pdf"
getSaveFile "PDFs.pdf" "${fMessage}" "${fExt}"


# Loop through the sorted files
h="1"
curPage="0"
for curFile in "${filesSorted[@]}"; do
    getFileInfo "${curFile}"
    padZero "${h}"
    curDocLoc="${tmpStorage}/${paddedCount}${h}"
    pdftk "${curFile}" dump_data >> "${curDocLoc}.txt.html"
    cat "${curDocLoc}.txt.html" | recode html..utf8 > "${curDocLoc}.txt"
    pdftk "${curFile}" cat output "${curDocLoc}.pdf"
    bookMarks="${tmpStorage}/bm${paddedCount}${h}.txt"
    convertMetaToBookmark "${curDocLoc}.txt"
    convertBookmarkToPdfmark "${bookMarks}"
    curPage=$((curPage + curDocPages))
    ((h++))
done
# Combine the files and send it to final destination
cd "${tmpStorage}" || guiError "Couldn't change directory."
gs -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile="${tmpStorage}/finalfile.pdf" -c "userdict /opdfmark systemdict /pdfmark get put /pdfmark {cleartomark} def" -f *.pdf -c "/pdfmark userdict /opdfmark get def" -f pdfmarks >> "gs.txt"  2>&1
mv "${tmpStorage}/finalfile.pdf" "${saveFile}"
