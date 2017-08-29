#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="gs convert"
checkPrograms

# Run some common functions
createTmpDir
deleteTmpDir

# Ask for Settings
if type kdialog &>/dev/null; then
    Color=$(kdialog --checklist "Chose Color Mode:" Keep "Keep current" off Gray "Convert to Grayscale" off BW "Convert to B/W" off)
    chkCancelButton "${?}"
else
    Color=$(zenity --list --radiolist --text "Chose Color Mode:" --hide-header --column "1" --column "2" FALSE "Keep current" FALSE "Convert to Grayscale" FALSE "Convert to B/W")
    chkCancelButton "${?}"
    case "${Color}" in
        "Keep current")             Color="Keep" ;;
        "Convert to Grayscale")     Color="Gray" ;;
        "Convert to B/W")           Color="BW" ;;
    esac
fi

if type kdialog &>/dev/null; then
    Resolution=$(kdialog --checklist "Set Image Resolution:" Keep "Keep current" off 600 "Convert to 600dpi" off 300 "Convert to 300dpi" off 200 "Convert to 200dpi" off 150 "Convert to 150dpi" off Custom "Set custom resolution" off )
    chkCancelButton "${?}"
else
    Resolution=$(zenity --list --radiolist --text "Set Image Resolution:" --hide-header --column "1" --column "2" FALSE "Keep current" FALSE "Convert to 600dpi" FALSE "Convert to 300dpi" FALSE "Convert to 200dpi" FALSE "Convert to 150dpi" FALSE "Set custom resolution")
    chkCancelButton "${?}"
    case "${Resolution}" in
        "Keep current")         Resolution="Keep" ;;
        "Convert to 600dpi")    Resolution="600dpi" ;;
        "Convert to 300dpi")    Resolution="300dpi" ;;
        "Convert to 200dpi")    Resolution="200dpi" ;;
        "Convert to 150dpi")    Resolution="150dpi" ;;
        "Custom")               Resolution="Custom" ;;
    esac
fi

if [[ "${Resolution}" == "Custom" ]]; then
    Resolution=$(guiInput "Set Custom Image Resolution" "Set your custom resolution, e.g. use 100 for 100x100dpi") || exit;
fi

# Parse the selected file
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for save file
        fMessage="Quality"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}";

        curFile="${arg}"
        # Check if color change is required
        if [[ "${Color}" = "Gray" ]]; then
            convert "${curFile}" -colorspace gray "${tmpStorage}/gray.pdf"
            curFile="${tmpStorage}/gray.pdf"
        fi
        if [[ "${Color}" = "BW" ]]; then
            convert "${curFile}" -colorspace gray -colors 2 -normalize "${tmpStorage}/bw.pdf"
            curFile="${tmpStorage}/bw.pdf"
        fi

        # Check if resolution change is required
        if [[ "${Resolution}" != "Keep" ]]; then
            gs -sDEVICE=pdfwrite -dBATCH -dCompatibilityLevel=1.4 -dDownsampleColorImages=true -dColorImageResolution=${Resolution} -dNOPAUSE -sOutputFile="${tmpStorage}/resize.pdf" "${curFile}"
            curFile="${tmpStorage}/resize.pdf"
        fi
        mv "$curFile" "${saveFile}"
    fi
done
