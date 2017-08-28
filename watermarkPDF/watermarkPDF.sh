#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="unzip zip sed convert pdftk libreoffice unoconv kate"
checkPrograms

# Run some common functions
createTmpDir
deleteTmpDir
checkConfig "watermarkPDF"


checkService () {
    curService='soffice.bin'

    if ps ax | grep -v grep | grep $SERVICE > /dev/null; then
        # Service is already running
        unoconv -f pdf "${tmpStorage}/draft.odt"
    else
        # Service is not running
        unoconv -f pdf "${tmpStorage}/draft.odt"
    fi
    unoconv -f pdf "${tmpStorage}/draft.odt"
    unoconv -f pdf "${tmpStorage}/draft.odt"
}


createOdt () {
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



# Prompt to use default template or custom template
tplSelect=$(guiYesNo "Default template dialog" "Press YES if you want to use the default template locatet at
'${defaultTemplate}'

Press NO to select a different template.

NOTICE: All '_replace_' strings in the selected template will be replaced by a string selected later")
case "${tplSelect}" in
    1) # Yes selected
        tplSelected="${defaultTemplate}"
        ;;
    2) # No selected
        tplSelected=$(guiFileSelect "${HOME}")
        if [[ $? != 0 ]]; then
            exit;
        fi
        ;;
esac


# Prompt for default text string
tplMessage=$(guiInput "Text message" "Please enter the desired text message" "${defaultText}")


# Create temporary dir
createTmpDirs;
createOdt;

# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Prompt for save file
        fMessage="Watermark"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}";
        libreoffice --headless --invisible --convert-to pdf "${tmpStorage}/draft.odt"
        convert -density 300 "${tmpStorage}/draft.pdf" -quality 90 "${tmpStorage}/draft.png"
        convert "${tmpStorage}/draft.png" -transparent white -background none "${tmpStorage}/draft2.pdf"
        pdftk "${arg}" multistamp "${tmpStorage}/draft2.pdf" output "${saveFile}"
    fi
done
