#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Run some common functions
createTmpDir
deleteTmpDir
checkConfig "ocrPDF"

runOCR () {
    i=$1
    for file in "${tmpStorage}/"*.pdf; do
        convert -density 300 -depth 8 "${file}" "${file}.png"
        tesseract "${file}.png" "${file}" -l ${langSel}
        case "${pgSeperator}" in
            0) #Yes selected
                pgSep="------------------- ${i} -------------------"
                echo "${pgSep}" >> "${tmpStorage}/output.txt"
                echo "" >> "${tmpStorage}/output.txt"
                ;;
            1) #No selected
                pgSep=""
                ;;
        esac
        cat "${file}.txt" >> "${tmpStorage}/output.txt"
        echo "" >> "${tmpStorage}/output.txt"
        ((i++))
    done
    mv "${tmpStorage}/output.txt" "${saveFile}"
}


# Prompt to maintain the layout
langSel=$(kdialog --title "Set Language" --inputbox "Set the three letter language code to use on the PDF document.

Using the appropriate language makes the recognition better.

Also make sure you have the actual tesseract language pack installed." "${defaultLanguage}")
if [[ $? != 0 ]]; then
    exit;
fi


pgSeperator=$(kdialog --radiolist "Add a page seperator?:" 0 "yes" on 1 "No" off)
if [[ $? = 3 ]]; then
    exit;
fi


# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for save file
        fMessage="OCR"
        fExt="txt"
        getSaveFile "${arg}" "${fMessage}" "${fExt}"
        pdftk "${arg}" burst output "${tmpStorage}/pages__%04d.pdf"
        runOCR
    fi
done
