#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftotext"
checkPrograms

# Prompt to maintain the layout
tplSelect=$(kdialog --title "Maintain Layout" --yesnocancel "Press YES if you want the extracted text to reflect the layout of the PDF")
case "${?}" in
    0) # Yes selected
        layout="-layout"
        ;;
    1) # No selected
        layout=""
        ;;
    2) # Cancel selected
        exit;
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

        pdftotext ${layout} "${arg}" "${saveFile}"
    fi
done
