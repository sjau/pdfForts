#!/usr/bin/env bash

# Ask for range
Rotate=$(kdialog --menu "Chose rotation (clockwise):" East "90°" South "180°" West "270°");
if [[ $? != 0 ]]; then
    exit;
fi

# Parse the selected file
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        fName=${arg##*/}
        fileNoExt=${arg%.*}
        # Prompt for save file
        Name=$(kdialog --getsavefilename "${fileNoExt} - rotated.pdf")
        if [[ $? != 0 ]]; then
            exit;
        fi
        pdftk "${arg}" cat 1-end${Rotate} output "${Name}"
    fi
done
