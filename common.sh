function createTmpDir
{
	# Create temporary dir
	tmpDir='pdfForts.XXXXXXXXXX';
	tmpStorage=$(mktemp -t -d "${tmpDir}") || {
		kdialog --error "Couldn't create temporary dir"
		exit 1;
	}
}


function deleteTmpDir
{
	trap 'rm -rf "${tmpStorage}"' 0		# remove directory when script finishes
	trap 'exit 2' 1 2 3 15				# terminate script when receiving signal
}


function checkConfig
{
	curScript="${0}"
	fullName=$(basename "${curScript}")
	baseName="${fullName%.*}"

	# Test if config exists
	userConfig="${HOME}/.pdfForts/${baseName}.conf"
	if [ ! -f "${userConfig}" ]
	then
		# User config does not exist, copy default to user
		mkdir -p "${HOME}/.pdfForts/"
		cp "/usr/share/kde4/services/ServiceMenus/pdfForts/${baseName}.conf" "${userConfig}"

		kdialog --msgbox "No configuration file for ${baseName} has been found.
A default one was copied to ${userConfig}.
Please edit that one to suit your needs.

Next Kate will be opened with the config file."

		kate -b "${userConfig}"

        kdialog --msgbox "You have now a user config for ${baseName}.
Retry again on the PDF files."

        exit;
	fi
	source "${userConfig}"
}


function getSaveFile
{
	fFile="${1}"
	fMessage="${2}"
	fExt="${3}"
	fName=${fFile%.*}
	newFile=`kdialog --getsavefilename "${fName} - ${message}.${fExt}"`;
	if [ $? != 0 ]; then
		exit;
	fi
}


function countZero
{
	stringCheck="${1}"
	unset "addZero"
	stringLength=$(echo "${#stringCheck}")
	case "${stringLength}" in
		1) addZero="00000" ;;
		2) addZero="0000" ;;
		3) addZero="000" ;;
		4) addZero="00" ;;
		5) addZero="0" ;;
	esac
}



function sortFiles
{
	files="${1}"

	# Create empty array
	declare -a filesUnsorted=();
	# Loop through files
	for files ;
	do
		# Test if it is a file
		if [ -f "${files}" ]
		then
			filesUnsorted=("${filesUnsorted[@]}" "${files}")
		fi
	done
	# Sort selected files alphabetically
	readarray -t filesSorted < <(for a in "${filesUnsorted[@]}"; do echo "$a"; done | sort)
}



function convertBookmarkData
{
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
	numberOfPages=0

	mapfile -t fileContent < "${bookmarkFile}"

	bookmarkLine=1
	for lineContent in "${fileContent[@]}"
	do
		unset arrLine
		IFS='|' read -ra arrLine <<< "${lineContent}"
		curDash="${#arrLine[0]}"
		curLvl=$((${curDash} / 2))
		curTitle="${arrLine[1]}"
		curNr="${arrLine[2]}"
		levelArr["${bookmarkLine}"]="${curLvl}"
		titleArr["${bookmarkLine}"]="${curTitle}"
		numberArr["${bookmarkLine}"]="${curNr}"
		((bookmarkLine++))
	done

	# Loop through the array in reverse order
	lastLevel=0
	for ((x=${#titleArr[@]}; x >= 1; --x))
	do
		curTitle="${titleArr[$x]}"
		curLevel="${levelArr[$x]}"
		curNumber="${numberArr[$x]}"

		# Equal level or sublevel
		if [ "${curLevel}" -ge "${lastLevel}" ]
		then
			page=$(($curPage + $curNumber))
			lvl[$curLevel]=$(( lvl[$curLevel] += 1 ))
			outputArr[$x]="[/Title (${curTitle}) /Page ${page} /OUT pdfmark"
			lastLevel="${curLevel}"
		fi

		# Parent level
		if [ "${curLevel}" -lt "${lastLevel}" ]
		then
			page=$(($curPage + $curNumber))
			lvl[$curLevel]=$(( lvl[$curLevel] += 1 ))
			subLvl=$((${curLevel}+1))
			outputArr[$x]="[/Count ${lvl[${subLvl}]} /Title (${curTitle}) /Page ${page} /OUT pdfmark"
			lvl[${subLvl}]="0"
			lastLevel="${curLevel}"
		fi

	done

	for (( a = 0 ; a <= ${#outputArr[@]} ; a++ )) do
		if [[ "${outputArr[$a]}" ]]
		then
			echo "${outputArr[$a]}" >> "${tmpStorage}/pdfmarks"
		fi
	done

}


function selectTemplate
{
	# Prompt to use default template or custom template
	tplSelect=`kdialog --title "Default template dialog" --yesnocancel "Press YES if you want to use the default template located at ${defaultTemplate}

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
}