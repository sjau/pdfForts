#!/bin/bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="unzip zip sed pdftk gs kdialog basename kate libreoffice unoconv"
checkPrograms



function createStamp
{
	stampDir="${tmpStorage}/stampDir_${docNr}_${pgNr}"
	mkdir -p "${stampDir}"
	echo "cp $tplSelected $stampDir/stamp.odt"
	cp "${tplSelected}" "${stampDir}/stamp.odt"
	cd "${stampDir}"
	unzip "stamp.odt"
	rm "stamp.odt"
	sed -e "s|_l1_|${line1}|g" -e "s|_l2_|${line2}|g" -e "s|_l3_|${line3}|g" -e "s|_n_|${nr}|g" -e "s|_a_|${doc}|g" -e "s|_p_|${pg}|g" "content.xml" > "new_content.xml"
	mv "new_content.xml" "content.xml"
	zip -D -X -0 "stamp.odt" mimetype
	zip -D -X -9 -r "stamp.odt" . -x mimetype \*/.\* .\* \*.png \*.jpg \*.jpeg
	zip -D -X -0 -r "stamp.odt" . -i \*.png \*.jpg \*.jpeg

	case "${selectedConverter}" in
			1) # Unoconv selected
				unoconv -f pdf "stamp.odt"
				if [ ! -f "stamp.pdf" ]
				then
					unoconv -f pdf "stamp.odt"
				fi
				;;
			2) # LibreOffice selected
				if [ "$(pidof soffice.bin)" ]
				then
					kdialog --error "LibreOffice is running! Please close LibreOffice before continuing.

Notice: Unoconv can be run even if LibreOffice is running!"
				fi
				libreoffice --headless --invisible --convert-to pdf "${stampDir}/stamp.odt"
				;;
	esac
	if [[ ! -f "stamp.pdf" ]]
	then
		kdialog --error "Couldn't convert the .odt file to a .pdf. Please try to switch between Unoconv and LibreOffice.

Also make sure that if you selected LibreOffice that it wasn't running.

If the problem continues to appear, please file a bug report at: https://github.com/sjau/pdfForts"
		exit;
	fi
	mv "${stampDir}/stamp.pdf" "${stampPDF}/${pgNr}.pdf"
}



function handlePDF
{
	docNr="${1}";
	pdfFile="${2}";
	fileBase="${3}";
	fileExt="${4}";

	pgDir="${tmpStorage}/pgDir_${docNr}"
	mkdir -p "${pgDir}"

	# Burst pdf into single pages
	pdftk "${pdfFile}" burst output "${pgDir}/pages__%04d.pdf"
	mv "doc_data.txt" "${pgDir}/"

	# Loop through single pages
	pg="1";

	# Get filename and and append the pdfmarks file for the bookmarks
	echo "|${fileBase}|${curPage}" >> "${bookMarks}"

	for file in "${pgDir}/"*.pdf ;
	do
		# Get Zeros before page number
		countZero "${pg}"
		pgNr="${addZero}${pg}"

		# Create stamp PDF
		createStamp

		# Add the created stamp to current page
		echo "pdftk '${file}' stamp '${stampPDF}/${pgNr}.pdf' output '${docDir}/${docNr}_${pgNr}.pdf'"
		pdftk "${file}" stamp "${stampPDF}/${pgNr}.pdf" output "${docDir}/${docNr}_${pgNr}.pdf"

		curPage=$((curPage+1))
		pg=$((pg+1))
	done
}



function setFinalDocName
{
	docNrEnd=$((${doc}-1))
	if [[ "$docNrStart" -eq "$docNrEnd" ]]
	then
		destFile="${destDir}/${savefile} ${docNrStart}.pdf"
	else
		destFile="${destDir}/${savefile} ${docNrStart} - ${docNrEnd}.pdf"
	fi
	echo "gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile='${destFile}' '${docDir}/'*pdf  '${pdfMarks}'"
	gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="${destFile}" "${docDir}/"*pdf  "${pdfMarks}"
}



# Run some common functions
createTmpDir
deleteTmpDir
checkConfig "stampPDF"
sortFiles "$@"



# Create additional tmp dirs
docDir="${tmpStorage}/doc"
mkdir -p "${docDir}"
stampPDF="${tmpStorage}/stampPDF"
mkdir -p "${stampPDF}"



# Prompt for document number
doc=`kdialog --title "Document number" --inputbox "At what number shall the document numbering commence?"` || exit;
docNrStart="${doc}"



# Prompt for template selection
selectTemplate



# Check config for options
confValue='odtConvert="unoconv"		# Set to unoconv or libreoffice'
chkConfOption "${odtConvert}" "${confValue}"



# Prompt for converter selection
selectedConverter=`kdialog --radiolist "Select converter tool" 1 "Unoconv (recommended)" on 2 "LibreOffice" off` || exit;



# Start total page count for pdf bookmarks
pdfMarks="${tmpStorage}/pdfmarks"
bookMarks="${tmpStorage}/bookmarks.txt"
curPage="1";


# Loop through the sorted files
for curFile in "${filesSorted[@]}"
do
	# Get doc zeros
	countZero "${doc}"
	docNr="${addZero}${doc}"

	# Get file info and dir name
	fileBase=$(basename "${curFile%.*}")
	fileExt=$(basename "${curFile##*.}")
	fPath=$(readlink -f "${curFile}")
	destDir=$(dirname "${fPath}")
	# Start the file manipulation
	handlePDF "${docNr}" "${curFile}" "${fileBase}" "${fileExt}"
	((doc++))
done


unset "curPage"
convertBookmarkToPdfmark "${bookMarks}"
setFinalDocName "${curFile}"

exit;
