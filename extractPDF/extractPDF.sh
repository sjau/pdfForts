#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk"
checkPrograms

# Run some common functions
createTmpDir
deleteTmpDir

# Ask for range
Range=$(guiInput "Define pages" "Set the pages you want to extract.
Values are to be seperated by a white space.
You can also enter a range of pages, e.g.

3-6 15 21-24 37-end 10

That would extract the pages 3-6, page 17, pages 21-24, pages 37 to the end, page 10.

The order is defines by your range.

" "1-end")

# Parse the selected file
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        fMessage="Extracted"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}"
        pdftk "${arg}" cat ${Range} output "${tmpStorage}/finalfile.pdf"
        mv "${tmpStorage}/finalfile.pdf" "${saveFile}"
    fi
done
