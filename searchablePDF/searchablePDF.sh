#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk cuneiform hocr2pdf convert"
checkPrograms

# Run some common functions
createTmpDir
deleteTmpDir

# Ask for Settings
Lang=$(cuneiform -l)
Language=$(guiInput "Language Setting" "${Lang}");

if [[ "${?}" != 0 ]]; then
    exit;
fi

# Parse the selected file
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for save file
        fMessage="Searchable"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}";

        cd "${tmpStorage}" || guiError "Couldn't change directory."

        pdftk "${arg}" burst output "${tmpStorage}/pages__%04d.pdf"

        for curFile in "pages__"*.pdf; do
            convert -normalize -density 300 -depth 8 "${curFile}" "${curFile}.png"
        done

        for curFile in "pages__"*.png; do
            cuneiform -l "${Language}" -f hocr -o "${curFile}.html" "${curFile}"
            # Check if cuneiform has encountered a problem, if so, make a blank .html file
            if [[ "${?}" != 0 ]]; then
                touch "${curFile}.html"
            fi
            hocr2pdf -i "${curFile}" -o "${curFile}.new.pdf" < "${curFile}.html"

        done
        pdftk "pages__"*.new.pdf cat output "${tmpStorage}/finalfile.pdf"
        mv "${tmpStorage}/finalfile.pdf" "${saveFile}"
    fi
done
