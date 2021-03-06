#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="unzip zip sed pdftk gs libreoffice unoconv kate"
checkPrograms


createStamp () {
    origDir=$(pwd)
    stampDir="${tmpStorage}/stampDir_${docNr}_${pgNr}"
    mkdir -p "${stampDir}"
    cp "${tplSelected}" "${stampDir}/stamp.odt"
    cd "${stampDir}"
    unzip "stamp.odt"
    rm "stamp.odt"
    sed -e "s|_l1_|${line1}|g" -e "s|_l2_|${line2}|g" -e "s|_l3_|${line3}|g" -e "s|_n_|${nr}|g" -e "s|_a_|${doc}|g" -e "s|_p_|${pg}|g" "content.xml" > "new_content.xml"
    mv "new_content.xml" "content.xml"
    zip -D -X -0 "stamp.odt" mimetype
    zip -D -X -9 -r "stamp.odt" . -x mimetype \*/.\* .\* \*.png \*.jpg \*.jpeg
    zip -D -X -0 -r "stamp.odt" . -i \*.png \*.jpg \*.jpeg

    case "${selectedConverter}" in
        1) # Unoconv selected
            unoconv -f pdf "stamp.odt"
            if [[ ! -f "stamp.pdf" ]]; then
                unoconv -f pdf "stamp.odt"
            fi
            ;;
        2) # LibreOffice selected
            if [[ "$(pidof soffice.bin)" ]]; then
                guiError "LibreOffice is running! Please close LibreOffice before continuing.

Notice: Unoconv can be run even if LibreOffice is running!"
            fi
            libreoffice --headless --invisible --convert-to pdf "${stampDir}/stamp.odt"
            ;;
    esac
    if [[ ! -f "stamp.pdf" ]]; then
        guiError "Couldn't turn the .odt file to a .pdf. Please try to switch between Unoconv and LibreOffice.

Also make sure that if you selected LibreOffice that it wasn't running.

If the problem continues to appear, please file a bug report at: https://github.com/sjau/pdfForts"
        exit;
    fi
    mv "${stampDir}/stamp.pdf" "${stampPDF}/${pgNr}.pdf"
    cd "${origDir}"
}



handlePDF () {
    docNr="${1}";
    pdfFile="${2}";
    fileBase="${3}";
    fileExt="${4}";

    pgDir="${tmpStorage}/pgDir_${docNr}"
    mkdir -p "${pgDir}"

    # Burst pdf into single pages
    pdftk "${pdfFile}" burst output "${pgDir}/pages__%04d.pdf"
    mv "doc_data.txt" "${pgDir}/"

    # Loop through single pages
    pg="1";

    # Get filename and and append the pdfmarks file for the bookmarks
    printf "%s\n" "|${fileBase}|${curPage}" >> "${bookMarks}"

    for file in "${pgDir}/"*.pdf; do
        # Get Zeros before page number
        padZero "${pg}"
        pgNr="${paddedCount}${pg}"

        # Create stamp PDF
        createStamp

        # Add the created stamp to current page
        pdftk "${file}" stamp "${stampPDF}/${pgNr}.pdf" output "${docDir}/${docNr}_${pgNr}.pdf"

        curPage=$((curPage+1))
        pg=$((pg+1))
    done
}



setFinalDocName () {
    docNrEnd=$((${doc}-1))
    if [[ "$docNrStart" -eq "$docNrEnd" ]]; then
        destFile="${destDir}/${savefile} ${docNrStart}.pdf"
    else
        destFile="${destDir}/${savefile} ${docNrStart} - ${docNrEnd}.pdf"
    fi
#    printf "%s\n" "gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile='${destFile}' '${docDir}/'*pdf  '${pdfMarks}'"
#    gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="${destFile}" "${docDir}/"*pdf  "${pdfMarks}"
    cd "${docDir}"
    curpwd=$(pwd)
    printf "%s\n" "$curpwd" > "output.txt"
    for curPDF in *pdf; do
        printf "%s\n" "${curPDF}" >> "output.txt"
        printf "%s\n" "gs -sDEVICE=ps2write -o '${curPDF}.ps' '${curPDF}'" >> "ps.txt"
        gs -sDEVICE=ps2write -o "${curPDF}.ps" "${curPDF}" >> "gs.txt" 2>&1
    done
    printf "%s\n" "gs -sDEVICE=pdfwrite -o '${destFile}' *ps  '${pdfMarks}'"
    gs -sDEVICE=pdfwrite -o "${tmpStorage}/finalfile.pdf" *ps  "${pdfMarks}" >> "final.txt" 2>&1
    mv "${tmpStorage}/finalfile.pdf" "${destFile}"
}



# Run some common functions
createTmpDir
deleteTmpDir
checkConfig "stampPDF"
sortFiles "$@"



# Create additional tmp dirs
docDir="${tmpStorage}/doc"
mkdir -p "${docDir}"
stampPDF="${tmpStorage}/stampPDF"
mkdir -p "${stampPDF}"



# Prompt for document number
doc=$(guiInput "Document number" "At what number shall the document numbering commence?") || exit;
docNrStart="${doc}"



# Prompt for template selection
selectTemplate



# Check config for options
confValue='odtConvert="unoconv"        # Set to unoconv or libreoffice'
chkConfOption "${odtConvert}" "${confValue}"



# Prompt for converter selection
if type kdialog &>/dev/null; then
    selectedConverter=$(kdialog --radiolist "Select converter tool:" 1 "Unoconv (recommended)" on 2 "LibreOffice" off) || exit;
else
    selectedConverter=$(zenity --list --radiolist --text "Select converter tool:" --hide-header --column "1" --column "2" TRUE "Unoconv (recommended)" FALSE "LibreOffice") || exit;
    if [[ "${selectedConverter}" == "Unoconv (recommended)" ]]; then
        selectedConverter="1"
    else
        selectedConverter="2"
    fi
fi


# Start total page count for pdf bookmarks
pdfMarks="${tmpStorage}/pdfmarks"
bookMarks="${tmpStorage}/bookmarks.txt"
curPage="1";


# Loop through the sorted files
for curFile in "${filesSorted[@]}"; do
    # Get doc zeros
    padZero "${doc}"
    docNr="${paddedCount}${doc}"

    # Get file info and dir name
    getFileInfo "${curFile}"
    fPath=$(readlink -f "${curFile}")
    destDir=$(dirname "${fPath}")
    # Start the file manipulation
    handlePDF "${docNr}" "${curFile}" "${fileBase}" "${fileExt}"
    ((doc++))
done


unset "curPage"
convertBookmarkToPdfmark "${bookMarks}"
setFinalDocName "${curFile}"

exit;
