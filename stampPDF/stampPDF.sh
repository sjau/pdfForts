#!/bin/bash

############################### Todo #################################
# - adjust resolution of pdfs so the stamp will always be "the same" #
# - use a relative path in the bash script for the .png file         #
######################################################################


function createStampElements
{
	tmpStorage="${1}"
	borderColor="${2}"
	borderStrokeColor="${3}"

	# Top: 230x2px , top row white, bottom custom		*--------------------------------------------------------------*
	# Bottom: as #top but inverted						|                                                       |  Nr. |
	# left: 2x57px, left white, right custom			|                                                       |      |
	# right: 2x57px, as # left but inverted				|            MAIN                                       |  Doc |
	# middle: 2x57, left white, right custom			|                                                       |------|   --> middle
	# horizontal: 31x2px, top white, bottom custom		|                                                       | pg.  |
	#													*--------------------------------------------------------------*
	#Dim:  230x61
	#Main: 195x61   2px   |

	# Create frame elements
	convert -size 230x3 xc:${borderStrokeColor} -fill ${borderColor} -draw "line 1,1,228,1"	"${tplDir}/horizontal.png"
	convert -size 3x57  xc:${borderStrokeColor} -fill ${borderColor} -draw "line 1,0,1,57"	"${tplDir}/vertical.png"
	convert -size 31x3  xc:${borderStrokeColor} -fill ${borderColor} -draw "line 0,1,31,1"	"${tplDir}/middle.png"

}


function createStampText
{
	tmpStorage="${1}"
	tmpX="${2}"
	tmpY="${3}"
	tmpName="${4}"
	tmpSize="${5}"
	tmpText="${6}"
	tmpFont="${7}"
	tmpAlign="${8}"
	tmpColor="${9}"
	tmpStrokeColor="${10}"

	# Enhance dimensions
	tmpX2=$[tmpX*4]
	tmpY2=$[tmpY*4]

	# Create 4x bigger
	convert -size ${tmpX2}x${tmpY2} xc:transparent -font ${tmpFont} -pointsize ${tmpSize} -fill ${tmpColor} -gravity ${tmpAlign} \
		-stroke ${tmpStrokeColor} -strokewidth 10		-annotate +0+0 "${tmpText}" \
		-stroke none									-annotate +0+0 "${tmpText}" \
		"${tplDir}/${tmpName}1.png"

	# Resize to desired dimensions
	convert "${tplDir}/${tmpName}1.png" -resize ${tmpX}x${tmpY}  "${tplDir}/${tmpName}.png"
	rm "${tplDir}/${tmpName}1.png"
}


function createStampAssemble
{
	tmpStorage="${1}"

	convert -size 230x61 xc:transparent "${tplDir}/proto.png"
	convert "${tplDir}proto.png" \
		-gravity NorthWest \
		-draw "image Over 0,0,0,0		'${tplDir}/horizontal.png'" \
		-draw "image Over 0,58,0,0		'${tplDir}/horizontal.png'" \
		-draw "image Over 0,2,0,0		'${tplDir}/vertical.png'" \
		-draw "image Over 227,2,0,0		'${tplDir}/vertical.png'" \
		-draw "image Over 195,2,0,0		'${tplDir}/vertical.png'" \
		-draw "image Over 197,42,0,0	'${tplDir}/middle.png'" \
		-draw "image Over 2,2,0,0		'${tplDir}/mainStampArea.png'" \
		-draw "image Over 197,2,0,0		'${tplDir}/nrStampArea.png'" \
		"${tplDir}/complete.png"
		rm "${tplDir}/proto.png"
}


function checkConfig
{
	# Test if config exists
	userConfig="${HOME}/.pdfForts/stampPDF.conf"
	if [ ! -f "${userConfig}" ]
	then
		# User config does not exist, copy default to user
		mkdir -p "${HOME}/.pdfForts/"
		cp "/usr/share/kde4/services/ServiceMenus/stampPDF/stampPDF.conf" "${HOME}/.pdfForts/"
		kdialog --msgbox "No configuration file for stampPDF has been found.\n A default one was copied to ${HOME}/.pdfForts/stampPDF.conf.\n Please edit that one to suit your needs.\n Next Kate will be opened with the config file."
		kate "${HOME}/.pdfForts/stampPDF.conf"
        exit;
	fi
}


function createBasicTemplate
{
	# Create basic template without docNr and pgNr and assemble
	createStampElements "${tmpStorage}" "${borderColor}" "${borderStrokeColor}"
	createStampText "${tmpStorage}" "193" "57" "mainStampArea" "60" "${mainText}" "${mainFont}" "${mainAlign}" "${mainColor}" "${mainStrokeColor}"
	createStampText "${tmpStorage}" "31" "20" "nrStampArea" "60"  "${nrText}" "${nrFont}" "${nrAlign}" "${nrColor}" "${nrStrokeColor}"
	createStampAssemble "${tmpStorage}"
}


function setFinalDocName
{
	docNrEnd=$((${docNr}-1))
	# Get path from where script was called
	destDir=`dirname "${curFile}"`
	if [ "$docNrStart" -eq "$docNrEnd" ]
	then
		destFile="${destDir}/act. ${docNrStart}.pdf"
	else
		destFile="${destDir}/act. ${docNrStart} - ${docNrEnd}.pdf"
	fi
	# put all created files into one pdf
	#pdftk "${actDir}/act. "*pdf cat output "${destFile}"

	gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="${destFile}" "${actDir}/act. "*pdf  "${pdfMarks}"


#	rm "${tmpStorage}/"*
#	rm "${tmpStorage}/act/"*
}


function handlePDF
{
	docNr="${1}";
	pdfFile="${2}";
	fileBase="${3}";
	fileExt="${4}";
	stampImage="${5}";
	tmpStorage="${6}";
	grayScale="${7}";
	resizeImage="${8}";
	res="${9}"

	rm "${pgDir}/"*pdf


	# Burst pdf into single pages
	pdftk "${pdfFile}" burst output "${pgDir}/pages__%04d.pdf"
	mv doc_data.txt "${pgDir}"

	# Loop through single pages
	pg="1";

	# Get filename and and append the pdfmarks file for the bookmarks
	fName=`basename "${pdfFile} .pdf"`
	echo "[/Title (${fName}) /Page ${curPage} /OUT pdfmark" >> "${pdfMarks}"

	for file in "${pgDir}/"*.pdf ;
	do
		# Check dimensions of current page
		convert "${file}" "${file}.png";
		dims=`identify -format "%wx%h" "${file}.png"`;

		# Create pageNr text 
		createStampText "${tplDir}" "31" "15" "pgStampArea" "45" "${pg}" "${pgFont}" "${pgAlign}" "${pgColor}" "${pgStrokeColor}"

		# Assemble final stamp
		convert "${tplDir}/complete.png" \
			-gravity NorthWest \
			-draw "image Over 197,22,0,0 '${tplDir}/docStampArea.png'" \
			-draw "image Over 197,44,0,0 '${tplDir}/pgStampArea.png'" \
			"${tplDir}/stamp.png"

		convert -size 260x65 xc:transparent "${tplDir}/border.png"
		convert "${tplDir}/border.png" \
			-gravity Center \
			-draw "image Over 0,0,0,0 '${tplDir}/stamp.png'" \
			"${tplDir}/border_new.png"

		# Make empty image
		convert -size ${dims} xc:transparent "${tplDir}/empty.png"
		convert "${tplDir}/empty.png"	\
			-gravity NorthEast \
			-draw "image Over 0,0,0,0 '${tplDir}/border_new.png'" \
			"${tplDir}/new_act.png"

		# Add the created stamp to current page
		convert "${tplDir}/new_act.png" "${pgDir}/new_act.pdf"
		n=`echo "${#pg}"`
		case "${n}" in
			1) addNr="000" ;;
			2) addNr="00" ;;
			3) addNr="0" ;;
		esac
		pdftk "${file}" stamp "${pgDir}/new_act.pdf" output "${pgDir}/new_file_${pg}.pdf"
#		mv "${tmpStorage}/new_file_${pg}.pdf" "${file}"
		n=`echo "${#pg}"`
		case "${n}" in
			1) addPgNr="000" ;;
			2) addPgNr="00" ;;
			3) addPgNr="0" ;;
		esac
		n=`echo "${#docNr}"`
		case "${n}" in
			1) addDocNr="000" ;;
			2) addDocNr="00" ;;
			3) addDocNr="0" ;;
		esac
		mv "${pgDir}/new_file_${pg}.pdf" "${pgDir}/pdf_act_${addDocNr}${docNr}_${addPgNr}${pg}.pdf"

		curPage=$((curPage+1))
		pg=$((pg+1))
	done

	# Combine all stamped pages into one PDF
#	if [ "${grayScale}" == "1" ]
#	then
#		# grayscale combine
#		pdftk "${tmpStorage}/pages__"*pdf cat output "${tmpStorage}/grayscale.pdf"
#		gs -sOutputFile="${tmpStorage}/act/act. ${docNr}.pdf" \
#			-sDEVICE=pdfwrite \
#			-sColorConversionStrategy=Gray \
#			-dProcessColorModel=/DeviceGray \echo ${filesUnsorted[@]} >> "${tmpStorage}/files1.txt"
#			-dCompatibilityLevel=1.4 "${tmpStorage}/grayscale.pdf" < /dev/null
#	else
		# default combine
		pdftk "${pgDir}/pdf_act_"*pdf cat output "${actDir}/act. ${addDocNr}${docNr}.pdf"
#	fi

	# Remove temporary files
	rm "${pgDir}/"*pdf
	rm "${tmpStorage}/act/*.pdf*"

}

function createTmpDirs
{
	# Create temporary dirs
	tmpDir='stampPDF.XXXXXXXXXX';
	tmpStorage=`mktemp -t -d "${tmpDir}"` || exit 1
	#tmpStorage="/tmp/XXXXXXXX/"
	mkdir -p "${tmpStorage}/act"
	mkdir -p "${tmpStorage}/pages"
	mkdir -p "${tmpStorage}/tpl"
	actDir="${tmpStorage}/act/"
	pgDir="${tmpStorage}/pages/"
	tplDir="${tmpStorage}/tpl/"
}

function loadConfig
{
	# Load config values
	source "${HOME}/.stampPDF/stampPDF.conf"
}





checkConfig;
loadConfig;
createTmpDirs;
createBasicTemplate;



# Prompt for document number, grayscale conversion, image resize
docNr=`kdialog --title "Document number" --inputbox "At what number shall the document numbering commence?"`;
docNrStart="${docNr}"
#grayScale=`kdialog --radiolist "Convert all documents to grayscale? (very slow on PDFs)" 1 "Yes" off  0  "No" on`;
#resizeImage=`kdialog --radiolist "Resize image to max A4 dimensions?" 1 "Yes" off  0  "No" on`;



# Create empty array
declare -a filesUnsorted=();

# Loop through the selected files
for arg ;
do
	# Test if it is a file
	if [ -f "${arg}" ]
	then
		filesUnsorted=("${filesUnsorted[@]}" "${arg}")
	fi
done

# Sort selected files alphabetically
readarray -t filesSorted < <(for a in "${filesUnsorted[@]}"; do echo "$a"; done | sort)


# Start total page count for pdf bookmarks
pdfMarks="${tmpStorage}/pdfmarks"
rm "${pdfMarks}"
curPage="1";


# Loop through the sorted files
for curFile in "${filesSorted[@]}"
do
	# Create docNr text
	createStampText "${tmpStorage}" "31" "20" "docStampArea" "60" "${docNr}" "${docFont}" "${docAlign}" "${docColor}" "${docStrokeColor}"
#	m "${tmpStorage}/act/*.pdf*"

	# Get file type
	fileBase="${curFile%.*}"
	fileExt="${curFile##*.}"
	fileLowerExt="${fileExt,,}"
	# Start the file manipulation
	case "$fileLowerExt" in
		pdf) handlePDF "${docNr}" "${curFile}" "${fileBase}" "${fileExt}" "${stampImage}" "${tmpStorage}" "${grayScale}" "${resizeImage}" "${res}";;
		*) handleImage "${docNr}" "${curFile}" "${fileBase}" "${fileExt}" "${stampImage}" "${tmpStorage}" "${grayScale}" "${resizeImage}" "${res}";;
	esac
	((docNr++))
done


setFinalDocName;



exit;



















# Set resizing options; currently set at 200dpi for A4
#res[1]="100x100";
#res[2]="826x1169";




#####################################################################################################################################
#####################################################################################################################################



function resizeImage
{
	file="$1";
	res="$2";
	dpi="${res[1]}";
	px="${res[2]}";

	# Resampling file / changing dpi
	convert "$file" -resample $dpi\> "$file.resample.png"
	# Shrinking file / adjusting pixels
	convert "$file.resample.png" -resize $px\>  "$file"

}



function handleImage
{
	docNr="$1";
	imgFile="$2";
	fileBase="$3";
	fileExt="$4";
	stampImage="$5";
	tmpStorage="$6";
	grayScale="$7";
	resizeImage="$8";
	res="$9";

	# Copy image file to tempory storage
	file="$tmpStorage/image.$fihttp://images.sjau.ch/img/aa32769f.pngleExt"
	cp "$imgFile" "$file"

	# Resize and resample if required
	if [ "$resizeImage" == "1" ]
	then
		resizeImage "$file" "$res";
	fi

	# Check dimensions of the image
	dims=`identify -format "%wx%h" "$file"`;

	# Create overlay image that contains stamp
	i="1";
	createOverlayStamp "$stampImage" "$docNr" "$i" "$tmpStorage" "$dims"

	# Add stamp to image
	convert "$file" \
		-draw "image Over 0,0,0,0 '$tmpStorage/new_act.png'" \
		"$tmpStorage/new_file.png"

	# Convert to pdf
	if [ "$grayScale" == "1" ]
	then
		# grayscale pdf
		convert "$tmpStorage/new_file.png" -colorspace gray "$tmpStorage/act/act. $docNr.pdf"
	else
		# default pdf
		convert "$tmpStorage/new_file.png" "$tmpStorage/act/act. $docNr.pdf"
	fi

	# Remove temporary files
	rm "$tmpStorage/"*
}


