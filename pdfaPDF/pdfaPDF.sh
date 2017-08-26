#!/usr/bin/env bash

# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        fName=$(arg##*/)
        fileNoExt=${arg%.*}
        # Prompt for save file
        Name=$(kdialog --getsavefilename "${fileNoExt} - PDFA.pdf");
        if [[ $? != 0 ]]; then
            exit;
        fi
        gs -dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor -sProcessColorModel=DeviceCMYK -sDEVICE=pdfwrite -sOutputFile="${Name}" "${arg}"
    fi
done
