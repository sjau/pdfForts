#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk convert tesseract kate"
checkPrograms

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
            1) #Yes selected
                pgSep="------------------- ${i} -------------------"
                printf "%s\n" "${pgSep}" >> "${tmpStorage}/output.txt"
                printf "%s\n" "" >> "${tmpStorage}/output.txt"
                ;;
            2) #No selected
                pgSep=""
                ;;
        esac
        cat "${file}.txt" >> "${tmpStorage}/output.txt"
        printf "%s\n" "" >> "${tmpStorage}/output.txt"
        ((i++))
    done
    mv "${tmpStorage}/output.txt" "${saveFile}"
}


# Prompt to maintain the layout
langSel=$(guiInput "Set Language" "Set the three letter language code to use on the PDF document.

Using the appropriate language makes the recognition better.

Also make sure you have the actual tesseract language pack installed." "${defaultLanguage}")

pgSeperator=$(guiYesNo "Add a page seperator?")

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
