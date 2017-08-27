createTmpDir () {
    # Create temporary dir
    tmpDir='pdfForts.XXXXXXXXXX';
    tmpStorage=$(mktemp -t -d "${tmpDir}") || {
        guiError "Couldn't create temporary dir"
        exit 1;
    }
}


deleteTmpDir () {
    trap 'rm -rf "${tmpStorage}"' 0     # remove directory when script finishes
    trap 1 2 3 15                       # terminate script when receiving signal
}


checkConfig () {
    curScript="${0}"
    fullName=${curScript##*/}
    baseName="${fullName%.*}"

    # Test if config exists
    userConfig="${HOME}/.pdfForts/${baseName}.conf"
    if [[ ! -f "${userConfig}" ]]; then
        # User config does not exist, copy default to user
        mkdir -p "${HOME}/.pdfForts/"
        cp "/usr/share/kservices5/ServiceMenus/pdfForts/${baseName}.conf" "${userConfig}"

        guiInfo "No configuration file for ${baseName} has been found.
A default one was copied to ${userConfig}.
Please edit that one to suit your needs.

Next Kate will be opened with the config file."

        kate -b "${userConfig}"

        guiInfo "You have now a user config for ${baseName}.
Retry again on the PDF files."
        exit;
    fi
    source "${userConfig}"
}


getSaveFile () {
    fFile="${1}"
    fMessage="${2}"
    fExt="${3}"
    fName=${fFile%.*}
    saveFile=$(guiFileSave "${fName} - ${fMessage}.${fExt}") || exit;
}


getFileInfo () {
    filePath=${1%/*}"/"
    fileName=${1##*/}
    fileBase=${fileName%%.*}
    fileExt=${name##*.}
}


padZero () {
    # Pad the counting to 50 numbers
    unset "paddedCount"
    paddedCount=$(printf "%020d%s\n" "${1}")
}


sortFiles () {
    files="${1}"

    # Create empty array
    declare -a filesUnsorted=();
    # Loop through files
    for files; do
        # Test if it is a file
        if [[ -f "${files}" ]]; then
            filesUnsorted=("${filesUnsorted[@]}" "${files}")
        fi
    done
    # Sort selected files alphabetically
    readarray -t filesSorted < <(for a in "${filesUnsorted[@]}"; do echo "$a"; done | sort)
}


extractMetaData () {
    curFile="${1}"
    pdftk "${curFile}" dump_data > "${metaFile}.html"
    cat "${metaFile}.html" | recode html..utf8 > "${metaFile}"
    pdftk "${curFile}" cat output "${noBookmark}"

}


convertSpecialCharsToASCII () {
    curTitle="${1}"

    # Create associative array where key is the string to look for and value the replacement
    declare -A replArray
    replArray[ä]='\344'
    replArray[ö]='\366'
    replArray[ü]='\374'
    replArray[Ä]='\304'
    replArray[Ö]='\326'
    replArray[Ü]='\334'
    replArray[ß]='\337'

    for k in "${!replArray[@]}"; do
        curTitle="${curTitle//$k/${replArray[$k]}}"
    done
}


convertMetaToBookmark () {
    unset "curTitle"
    unset "curLvl"
    unset "curNr"
    unset "haystack"

    mapfile -t haystack < "${1}"
    needle="BookmarkTitle"

    rm "${bookMarks}"

    if [[ "${docBookmarks}" -eq "1" ]]; then
        if [[ "${levelBookmarks}" -eq "1" ]]; then
            adjustLvl="1"
            echo "+-|${fileBase}|1" >> "${bookMarks}"
        else
            echo "+-|${fileBase}|1" >> "${bookMarks}"
        fi
    fi

    for ((i=0; i < ${#haystack[@]}; ++i)); do
        # Get pages number
        if [[ "${haystack[$i]}" =~ "NumberOfPages:" ]]; then
            curDocPages="${haystack[$i]:15}"
        fi
        # Get bookmark meta data
        if [[ "${haystack[$i]}" =~ "${needle}" ]]; then
            curTitle="${haystack[$i]:15}"
            j=$[i+1]
            k=$[i+2]
            if [[ "${haystack[$j]}" =~ "BookmarkLevel:" ]]; then
                tmpLvl="${haystack[$j]:15}"
                curLvl=$((tmpLvl + adjustLvl))
            fi
            if [[ "${haystack[$k]}" =~ "BookmarkPageNumber:" ]]; then
                curNr="${haystack[$k]:20}"
            fi

            curDash=""
            while [[  "${curLvl}" -gt "1" ]]; do
                curDash="${curDash}--"
                ((curLvl--))
            done
            echo "+-${curDash}|${curTitle}|${curNr}" >> "${bookMarks}"
        fi
    done
}


convertBookmarkToPdfmark () {
    bookmarkFile="${1}"

    unset "titleArr"
    declare -A "titleArr"
    unset "levelArr"
    declare -A "levelArr"
    unset "numberArr"
    declare -A "numberArr"
    unset "outputArr"
    declare -A "outputArr"
    unset "lvl"
    declare -A "lvl"
    unset "fileContent"
    unset "collapseArr"
    declare -A "collapseArr"
    
    numberOfPages=0

    mapfile -t fileContent < "${bookmarkFile}"

    bookmarkLine=1
    for lineContent in "${fileContent[@]}"; do
        unset arrLine
        IFS='|' read -ra arrLine <<< "${lineContent}"
        curDash="${#arrLine[0]}"
        curLvl=$((curDash / 2 - 1))
        curCollapse="${arrLine[0]:0:1}"
        if [[ "${curCollapse}" == "+" ]]; then
            collapseArr["${bookmarkLine}"]="-1"
        else
            collapseArr["${bookmarkLine}"]="1"
        fi
        curTitle="${arrLine[1]}"
        convertSpecialCharsToASCII "${curTitle}"
        curNr="${arrLine[2]}"
        levelArr["${bookmarkLine}"]="${curLvl}"
        titleArr["${bookmarkLine}"]="${curTitle}"
        numberArr["${bookmarkLine}"]="${curNr}"
        ((bookmarkLine++))
    done

    # Loop through the array in reverse order
    lastLevel=0
    for ((x=${#titleArr[@]}; x >= 1; --x)); do
        curTitle="${titleArr[$x]}"
        curLevel="${levelArr[$x]}"
        curNumber="${numberArr[$x]}"
        curCollapseMultiplier="${collapseArr[$x]}"

        # Equal level or sublevel
        if [[ "${curLevel}" -ge "${lastLevel}" ]]; then
            page=$((curPage + curNumber))
            lvl[$curLevel]=$(( lvl[$curLevel] += 1 ))
            outputArr[$x]="[ /Title (${curTitle}) /Page ${page} /OUT pdfmark"
            lastLevel="${curLevel}"

        fi

        # Parent level
        if [[ "${curLevel}" -lt "${lastLevel}" ]]; then
            page=$((curPage + curNumber))
            lvl[$curLevel]=$(( lvl[$curLevel] += 1 ))
            subLvl=$((${curLevel}+1))
            countLvl="${lvl[${subLvl}]}"
            countLvl=$((countLvl * curCollapseMultiplier))
            outputArr[$x]="[ /Count ${countLvl} /Page ${page} /Title (${curTitle}) /OUT pdfmark"
            lvl[${subLvl}]="0"
            lastLevel="${curLevel}"
        fi
    done

    for (( a = 0 ; a <= ${#outputArr[@]} ; a++ )); do
        if [[ "${outputArr[$a]}" ]]; then
            echo "${outputArr[$a]}" >> "${tmpStorage}/pdfmarks"
        fi
    done

}


selectTemplate () {
    # Prompt to use default template or custom template
    tplSelect=$(guiYesNo "Select Default Template" "Press YES if you want to use the default template located at ${defaultTemplate}

Press NO to select a different template.

NOTICE: All '_replace_' strings in the selected template will be replaced by a string selected later")

    case "${tplSelect}" in
        1) # Yes selected 
            tplSelected="${defaultTemplate}"
            ;;
        2) # No selected
            tplSelected=$(guiFileSelect "${HOME}") || exit;
            ;;
    esac
}


checkPrograms () {
    # Check for KDialog or Zenity
    type -P "kdialog" &>/dev/null && continue || {
        type -P "zenity" &>/dev/null && continue || {
            echo "Couldn't find KDialog or Zenity on your system." > "/tmp/pdfFortsError.txt"
            echo "Please install and re-run this script." >> "/tmp/pdfFortsError.txt"
            kate -b "/tmp/pdfFortsError.txt"
            exit 1;
        }
    }

    # Check other required programs
    for curCmd in ${reqCmds}; do
        type -P ${curCmd} &>/dev/null  && continue  || {
            guiError "Couldn't find the '${curCmd} program.

Please install and re-run this script.";
        }
    done
}


chkConfOption () {
    chkOption="${1}"
    confValue="${2}"

    if [[ "${chkOption}" == "" ]]; then
        echo " " >> "${userConfig}"
        echo "${confValue}" >> "${userConfig}"
        guiInfo "Added a new option to the end of your config file located at: "${userConfig}".

Kate will be launched for you to review."

        kate -b "${userConfig}"
    fi
}

guiError () {
    if type kdialog &>/dev/null; then
        kdialog --error "${1}"
    else
        zenity --error --text="${1}"
    fi
    exit 1;
}

guiInfo () {
    if type kdialog &>/dev/null; then
        kdialog --msgbox "${1}"
    else
        zenity --info --text="${1}"
    fi
}

guiPassword () {
    if type kdialog &>/dev/null; then
        local output=$(kdialog --title "${1}" --password "${2}") || exit;
    else
        local output=$(zenity --password --title "${1}") || exit;
    fi
    echo "${output}"
}

guiFileSelect () {
    if type kdialog &>/dev/null; then
        local output=$(kdialog --getopenfilename "${1}") || exit;
    else
        local output=$(zenity --file-selection --filename="${1}/") || exit;
    fi
    echo "${output}"
}

guiFileSave () {
    if type kdialog &>/dev/null; then
        local output=$(kdialog --getsavefilename "${1}") || exit;
    else
        local output=$(zenity --file-selection --save --filename="${1}") || exit;
    fi
    echo "${output}"
}

guiInput () {
    if type kdialog &>/dev/null; then
        local output=$(kdialog --title "${1}" --inputbox "${2}" "${3}") || exit;
    else
        local output=$(zenity --entry --title "${1}" --text="${2}" --entry-text="${3}") || exit;
    fi
    echo "${output}"
}

guiYesNo () {
    if type kdialog &>/dev/null; then
        local output=$(kdialog --radiolist "${1}" 1 "Yes" on 2 "No" off) || exit;
    else
        local output=$(zenity --list --radiolist --text "${1}" --hide-header --column "1" --column "2" TRUE "Yes" FALSE "No") || exit;
        if [[ "${output}" == "Yes" ]]; then
            output="1"
        else
            output="2"
        fi
    fi
    echo "${output}"
}
