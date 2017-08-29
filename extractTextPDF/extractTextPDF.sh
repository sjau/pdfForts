#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftotext"
checkPrograms

# Run some common functions
createTmpDir
deleteTmpDir

# Prompt to maintain the layout
tplSelect=$(guiYesNo "Maintain Layout? Select YES if you want the extracted text to reflect the layout of the PDF.")
case "${?}" in
    1) # Yes selected
        layout="-layout"
        ;;
    2) # No selected
        layout=""
        ;;
esac


# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt file save name
        fMessage="Extracted Text"
        fExt="txt"
        getSaveFile "${arg}" "${fMessage}" "${fExt}"
        pdftotext ${layout} "${arg}" "${tmpStorage}/finalfile.pdf"
        mv "${tmpStorage}/finalfile.pdf" "${saveFile}"
    fi
done
