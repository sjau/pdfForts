#!/bin/bash

function createTmpDirs
{
	# Create temporary dirs
	tmpDir='watermarkPDF.XXXXXXXXXX';
	tmpStorage=`mktemp -t -d "${tmpDir}"` || exit 1
}



function checkConfig
{
	# Test if config exists
	userConfig="${HOME}/.pdfForts/watermarkPDF.conf"
	if [ ! -f "${userConfig}" ]
	then
		# User config does not exist, copy default to user
		mkdir -p "${HOME}/.pdfForts/"
		cp "/usr/share/kde4/services/ServiceMenus/pdfForts/watermarkPDF.conf" "${HOME}/.pdfForts/"
		kdialog --msgbox "No configuration file for watermarkPDF has been found.

A default one was copied to ${HOME}/.pdfForts/watermarkPDF.conf.
Please edit that one to suit your needs.

Next Kate will be opened with the config file."
		kate "${HOME}/.pdfForts/watermarkPDF.conf"
        kdialog --msgbox "You have now a user config.\n Retry again on the PDF file."
        exit;
	else
	# Load config values
	source "${HOME}/.pdfForts/watermarkPDF.conf"
	fi
}

function checkService
{
	curService='soffice.bin'

	if ps ax | grep -v grep | grep $SERVICE > /dev/null
	then
		# Service is already running
		unoconv -f pdf "${tmpStorage}/draft.odt"
	else
		# Service is not running
		unoconv -f pdf "${tmpStorage}/draft.odt"
	fi
		unoconv -f pdf "${tmpStorage}/draft.odt"
		unoconv -f pdf "${tmpStorage}/draft.odt"
}


function createOdt
{
	echo "${tplSelected} ${tmpStorage}/draft.odt"
	cp "${tplSelected}" "${tmpStorage}/draft.odt"
	cd "${tmpStorage}"
	unzip "draft.odt"
	rm "draft.odt"
	sed "s|_replace_|${tplMessage}|g" "content.xml" > "new_content.xml"
	rm "content.xml"
	mv "new_content.xml" "content.xml"
	zip -D -X -0 "draft.odt" mimetype
	zip -D -X -9 -r "draft.odt" . -x mimetype \*/.\* .\* \*.png \*.jpg \*.jpeg
	zip -D -X -0 -r "draft.odt" . -i \*.png \*.jpg \*.jpeg
}



function cleanUp
{
	rm -Rf  "${tmpStorage}/"*
}


checkConfig;



# Prompt to use default template or custom template
tplSelect=`kdialog --title "Default template dialog" --yesnocancel "Press YES if you want to use the default template locatet at
'${defaultTemplate}'

Press NO to select a different template.

NOTICE: All '_replace_' strings in the selected template will be replaced by a string selected later"`
case "${?}" in
	0) # Yes selected
		tplSelected="${defaultTemplate}"
		;;
	1) # No selected
		tplSelected=`kdialog --getopenfilename ${HOME} "*.odt"`;
		if [ $? != 0 ]; then
			exit;
		fi
		;;
	2) # Cancel selected
		exit;
		;;
esac


# Prompt for default text string
tplMessage=`kdialog --title "Text message" --inputbox "Please enter the desired text message" "${defaultText}"`


# Create temporary dir
createTmpDirs;
createOdt;

# Loop through the selected files
for arg ;
do
	# Test if it is a file
	if [ -f "${arg}" ]
	then
		# Prompt file save name
		fn=${arg%.*}
		newFile=`kdialog --getsavefilename "${fn} - ${tplMessage}.pdf"`;
		if [ $? != 0 ]; then
			exit;
		fi
		unoconv -f pdf "${tmpStorage}/draft.odt"
		unoconv -f pdf "${tmpStorage}/draft.odt"
		pdftk "${arg}" multibackground "${tmpStorage}/draft.pdf" output "${newFile}"
		cleanUp
	fi
done
