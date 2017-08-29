#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="gs"
checkPrograms

# Run some common functions
createTmpDir
deleteTmpDir

# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for save file
        fMessage="PDFA"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}";
        gs -sDEVICE=pdfwrite -dBATCH -dPDFA -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor -sProcessColorModel=DeviceCMYK -sOutputFile="${tmpStorage}/finalfile.pdf" "${arg}"
        mv "${tmpStorage}/finalfile.pdf" "${saveFile}"
    fi
done
