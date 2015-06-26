#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="sed pdftk gs kdialog basename"
checkPrograms


# Ask for Settings
Color=$(kdialog --menu "Chose Color Mode:" Keep "Keep current" Gray "Convert to Grayscale" BW "Convert to B/W");
Resolution=$(kdialog --menu "Set Image Resolution:" Keep "Keep current" 600 "Convert to 600 dpi" 300 "Convert to 300 dpi" 200 "Convert to 200 dpi" 150 "Convert to 150 dpi" Custom "Set custom resolution");

if [[ "${Resolution}" = "Custom" ]]
then
    Resolution=$(kdialog --title "Set Custom Image Resolution" --inputbox "Set your custom resolution, e.g. use 100 for 100x100 dpi")
fi

if [[ $? != 0 ]]
then
	exit;
fi

# Run some common functions
createTmpDir
deleteTmpDir


# Parse the selected file
for arg ;
do
	# Test if it is a file
	if [[ -f "${arg}" ]]
	then
		fName=$(basename "${arg}")
		fileNoExt=${arg%.*}
		# Prompt for save file
		Name=$(kdialog --getsavefilename "${fileNoExt} - quality.pdf");
		if [[ $? != 0 ]]
		then
			exit;
		fi
		curFile="${arg}"
		# Check if color change is required
		if [[ "${Color}" = "Gray" ]]
		then
                    convert "${curFile}" -colorspace gray "${tmpStorage}/gray.pdf"
                    curFile="${tmpStorage}/gray.pdf"
                fi
                if [[ "${Color}" = "BW" ]]
                then
                    convert "${curFile}" -colorspace gray -colors 2 -normalize "${tmpStorage}/bw.pdf"
                    curFile="${tmpStorage}/bw.pdf"
                fi
                
                # Check if resolution change is required
                if [[ "${Resolution}" != "Keep" ]]
                then
                    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dDownsampleColorImages=true -dColorImageResolution=${Resolution} -dNOPAUSE  -dBATCH -sOutputFile="${tmpStorage}/resize.pdf" "${curFile}"
                    curFile="${tmpStorage}/resize.pdf"
                fi
                mv "$curFile" "${Name}"
	fi
done


exit;