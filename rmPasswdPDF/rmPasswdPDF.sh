#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk"
checkPrograms

# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for password entry
        fName=${arg##*/}
        Passwd=$(guiPassword "Password" "Enter the password for '${fName}'")

        # Prompt for save file
        fMessage="no Pwd"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}";
        pdftk "${arg}" input_pw ${Passwd} output "${saveFile}"
    fi
done

exit;
