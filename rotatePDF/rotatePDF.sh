#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk"
checkPrograms

# Ask for range
Rotate=$(kdialog --menu "Chose rotation (clockwise):" East "90°" South "180°" West "270°");
if [[ $? != 0 ]]; then
    exit;
fi

# Parse the selected file
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for save file
        fMessage="Rotated"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}";
        pdftk "${arg}" cat 1-end${Rotate} output "${saveFile}"
    fi
done
