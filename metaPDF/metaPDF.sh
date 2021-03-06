#!/usr/bin/env bash

source "/usr/bin/pdfForts/common.sh"

# Check for required programs
reqCmds="pdftk gs"
checkPrograms

# Create temporary dirs
createTmpDir
deleteTmpDir
pdfMarkOrig="${tmpStorage}/pdfMarkOrig.txt"
pdfMarks="${tmpStorage}/pdfMarks.txt"

searchArray () {
    needle="${1}"
    haystack="${2}"

    origData["${needle}"]=""

    for ((i=0; i < ${#haystack[@]}; ++i)); do
        if [[ "${haystack[$i]}" =~ "${needle}" ]]; then
            j=$[i+1]
            if [[ "${haystack[$j]}" =~ "InfoValue:" ]]; then
                origData["${needle}"]="${haystack[$j]:11}"
            fi
        fi
    done
}

# Get user real name
IFS=: read -r _ _ _ _ name _ < <(getent passwd $USER);
userName="${name%%,*}"

if [[ "${userName}" == "" ]]; then
    userName=$(whoami)
fi

# Loop through the selected files
for arg; do
    # Test if it is a file
    if [[ -f "${arg}" ]]; then
        # Extract pdfmark info
        pdftk "${arg}" dump_data > "${pdfMarkOrig}"

        # Load pdfmark info into array
        old_IFS="${IFS}"
        IFS=$'\n'
        haystack=($(cat "${pdfMarkOrig}")) # array
        IFS="${old_IFS}"

        # Check for original data
        unset "origData"
        declare -A origData
        searchArray "Author"
        searchArray "CreationDate"
        searchArray "Creator"
        searchArray "Producer"
        searchArray "Title"
        searchArray "Subject"
        searchArray "Keywords"
        searchArray "ModDate"

        # Prompt for password entry
        fName=${arg##*/}
        fileNoExt=${arg%.*}
        author=$(guiInput "Set meta data for '${fName}'" "Set meta data for '${fName}'

Author - The document's author" "${origData[Author]}");

        creationdate=$(guiInput "Set meta data for '${fName}'" "Set meta data for '${fName}'

CreationDate - The date the document was created

* Date should be in this form: (D:YYYYMMDDHHmmSSOHH'mm')
D: is an optional prefix. YYYY is the year. All fields after the year are optional.
MM is the month (01-12), DD is the day (01-31), HH is the hour (00-23), mm are the minutes (00-59), and SS are the seconds (00-59).
The remainder of the string defines the relation of local time to GMT.
O is either + for a positive difference (local time is later than GMT) or - (minus) for a negative difference.
HH' is the absolute value of the offset from GMT in hours, and mm' is the absolute value of the offset in minutes.
If no GMT information is specified, the relation between the specified time and GMT is considered unknown. Regardless of whether or not GMT information is specified, the remainder of the string should specify the local time." "${origData[CreationDate]}");

        creator=$(guiInput "Set meta data for '${fName}'" "Set meta data for '${fName}'

Creator - If the document was converted to PDF from another form, the name of the application that originally created the document" "${origData[Creator]}");

        producer=$(guiInput "Set meta data for '${fName}'" "Set meta data for '${fName}'

Producer - The application that created the PDF from its native form" "${origData[Producer]}");

        title=$(guiInput "Set meta data for '${fName}'" "Set meta data for '${fName}'

Titel - The document's title" "${origData[Title]}");

        subject=$(guiInput "Set meta data for '${fName}'" "Set meta data for '${fName}'

Subject - The document's subject" "${origData[Subject]}");

        keywords=$(guiInput "Set meta data for '${fName}'" "Set meta data for '${fName}'

Keywords - Relevant keywords for this document, seperated by a comma followed by whitespace" "${origData[Keywords]}");

        moddate=$(guiInput "Set meta data for '${fName}'" "Set meta data for '${fName}'

ModDate - The date and time the document was last modified

Date should be in this form: (D:YYYYMMDDHHmmSSOHH'mm')
D: is an optional prefix. YYYY is the year. All fields after the year are optional.
MM is the month (01-12), DD is the day (01-31), HH is the hour (00-23), mm are the minutes (00-59), and SS are the seconds (00-59).
The remainder of the string defines the relation of local time to GMT.
O is either + for a positive difference (local time is later than GMT) or - (minus) for a negative difference.
HH' is the absolute value of the offset from GMT in hours, and mm' is the absolute value of the offset in minutes.
If no GMT information is specified, the relation between the specified time and GMT is considered unknown. Regardless of whether or not GMT information is specified, the remainder of the string should specify the local time." "${origData[ModDate]}");
        # Prompt for save file
        fMessage="Meta"
        fExt="pdf"
        getSaveFile "${arg}" "${fMessage}" "${fExt}"

        metaInfo="[ /Author (${author})
   /CreationDate (${creationdate})
   /Creator (${creator})
   /Producer (${producer})
   /Title (${title})
   /Subject (${subject})
   /Keywords (${keywords})
   /ModDate (${moddate})
   /DOCINFO pdfmark"

        printf "%s\n" "${metaInfo}" > "${pdfMarks}"

        gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="${tmpStorage}/finalfile.pdf" "${arg}" "${pdfMarks}"
        mv "${tmpStorage}/finalfile.pdf" "${saveFile}"
    fi
done


#[ /Author (string)
#/CreationDate (string)
#/Creator (string)
#/Producer (string)
#/Title (string)
#/Subject (string)
#/Keywords (string)
#/ModDate (string)
#/DOCINFO pdfmark

#gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=out.pdf pdfmarkReference.pdf  pdfmarks
