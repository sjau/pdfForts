#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk kdialog basename cuneiform hocr2pdf"
checkPrograms


# Ask for Settings
Lang=$(cuneiform -l)
Language=$(kdialog --title "Language Setting" --inputbox "${Lang}");

if [[ "${?}" != 0 ]]
then
	exit;
fi

# Run some common functions
createTmpDir
#deleteTmpDir

# Parse the selected file
for arg ;
do
	# Test if it is a file
	if [[ -f "${arg}" ]]
	then
		fName=$(basename "${arg}")
		fileNoExt=${arg%.*}
		# Prompt for save file
		Name=$(kdialog --getsavefilename "${fileNoExt} - searchable.pdf");
		if [[ "${?}" != 0 ]]
		then
			exit;
		fi
		
                cd "${tmpStorage}"
		
		pdftk "${arg}" burst output "pages__%04d.pdf"

#		echo "usage: ./pdfocr.sh document.pdf ocr-sfw split lang author title"

		for curFile in "pages__"*.pdf ;
                do
                        convert -normalize -density 300 -depth 8 "${curFile}" "${curFile}.png"
                done
                
                for curFile in "pages__"*.png ;
                do
                    cuneiform -l "${Language}" -f hocr -o "${curFile}.html" "${curFile}"
                    # Check if cuneiform has encountered a problem, if so, make a blank .html file
                    if [[ "${?}" != 0 ]]
                    then
                        touch "${curFile}.html"
                    fi
                    hocr2pdf -i "${curFile}" -n -r 300 -o "${curFile}.new.pdf" < "${curFile}.html"
                    
                done
 
                pdftk "pages__"*.new.pdf cat output "${Name}"

	fi
done

exit;
