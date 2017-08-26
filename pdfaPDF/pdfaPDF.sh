#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="gs"
checkPrograms

# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for save file
        fMessage="PDFA"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}";
        gs -dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor -sProcessColorModel=DeviceCMYK -sDEVICE=pdfwrite -sOutputFile="${saveFile}" "${arg}"
    fi
done
