#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk"
checkPrograms

# Run some common functions
createTmpDir
deleteTmpDir


while [[ "${PasswdChk}" != "OK" ]]; do
    # Ask for password
    Passwd1=$(guiPassword "Password" "Please enter a password");
    Passwd2=$(guiPassword "Password Confirmation" "Re-enter the password");
    # Check if the passwords are the same
    if [[ "${Passwd1}" = "${Passwd2}" ]]; then
        Passwd="${Passwd1}"
        if [[ -n "${Passwd}" ]]; then
            PasswdChk="OK"
        else
            guiError "You can't set an empty password."
        fi
    else
        guiError "The supplied passwords do not match.
Please try again."
    fi
done


# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]
    then
        fMessage="with Pwd"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}"
        pdftk "${arg}" output "${tmpStorage}/finalfile.pdf" user_pw "${Passwd}"
        mv "${tmpStorage}/finalfile.pdf" "${saveFile}"
    fi
done
