#!/usr/bin/env bash

function createTmpDirs
{
	# Create temporary dirs
	tmpDir='ocrPDF.XXXXXXXXXX';
	tmpStorage=$(mktemp -t -d "${tmpDir}") || exit 1
}



function checkConfig
{
	# Test if config exists
	userConfig="${HOME}/.pdfForts/ocrPDF.conf"
	if [[ ! -f "${userConfig}" ]]
	then
		# User config does not exist, copy default to user
		mkdir -p "${HOME}/.pdfForts/"
		cp "/usr/share/kde4/services/ServiceMenus/pdfForts/ocrPDF.conf" "${HOME}/.pdfForts/"
		kdialog --msgbox "No configuration file for ocrPDF has been found.

A default one was copied to ${HOME}/.pdfForts/ocrPDF.conf.
Please edit that one to suit your needs.

Also make sure that you have according tesseract language files installed.

Next Kate will be opened with the config file."
		kate "${HOME}/.pdfForts/ocrPDF.conf"
        kdialog --msgbox "You have now a user config.\n Retry again on the PDF file."
        exit;
	else
	# Load config values
	source "${HOME}/.pdfForts/ocrPDF.conf"
	fi
}



function runOCR
{
	$i=1
	for file in "${tmpStorage}/"*.pdf ;
	do
		convert -density 300 -depth 8 "${file}" "${file}.png"
		tesseract "${file}.png" "${file}" -l ${langSel}
		case "${pgSeperator}" in
			0) #Yes selected
				pgSep="------------------- ${i} -------------------"
				echo "${pgSep}" >> "${tmpStorage}/output.txt"
				echo "" >> "${tmpStorage}/output.txt"
				;;
			1) #No selected
				pgSep=""
				;;
		esac
		cat "${file}.txt" >> "${tmpStorage}/output.txt"
		echo "" >> "${tmpStorage}/output.txt"
		((i++))
	done
	mv "${tmpStorage}/output.txt" "${newFile}"
}


function cleanUp
{
	rm -Rf  "${tmpStorage}/"*
}


# Check config
checkConfig;
# Create temporary dir
createTmpDirs;



# Prompt to maintain the layout
langSel=$(kdialog --title "Set Language" --inputbox "Set the three letter language code to use on the PDF document.

Using the appropriate language makes the recognition better.

Also make sure you have the actual tesseract language pack installed." "${defaultLanguage}")
if [[ $? != 0 ]]
then
	exit;
fi


pgSeperator=$(kdialog --radiolist "Add a page seperator?:" 0 "yes" on 1 "No" off)
if [[ $? = 3 ]]
then
	exit;
fi


# Loop through the selected files
for arg ;
do
	# Test if it is a file
	if [[ -f "${arg}" ]]
	then
		# Prompt file save name
		fn=${arg%.*}
		newFile=$(kdialog --getsavefilename "${fn}.txt");
		if [[ $? != 0 ]]
		then
			exit;
		fi
		pdftk "${arg}" burst output "${tmpStorage}/pages__%04d.pdf"
		runOCR
		cleanUp
	fi
done
