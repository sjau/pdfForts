#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk"
checkPrograms

# Run some common functions
createTmpDir
deleteTmpDir

# Ask for range
if type kdialog &>/dev/null; then
    Rotate=$(kdialog --checklist "Chose rotation (clockwise):" East "90°" off South "180°" off West "270°" off)
    chkCancelButton "${?}"
else
    Rotate=$(zenity --list --radiolist --text "Chose rotation (clockwise):" --hide-header --column "1" --column "2" FALSE "90°" FALSE "180°" FALSE "270°")
    chkCancelButton "${?}"
    case "${Rotate}" in
        "90°")  Rotate="East" ;;
        "180°") Rotate="South" ;;
        "270°") Rotate="West" ;;
    esac
fi


# Parse the selected file
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for save file
        fMessage="Rotated"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}";
        pdftk "${arg}" cat 1-end${Rotate} output "${tmpStorage}/finalfile.pdf"
        mv "${tmpStorage}/finalfile.pdf" "${saveFile}"
    fi
done
