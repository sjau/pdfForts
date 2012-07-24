#!/bin/bash

function createTmpDirs
{
	# Create temporary dirs
	tmpDir='combinePDF.XXXXXXXXXX';
	tmpStorage=`mktemp -t -d "${tmpDir}"` || exit 1
}



function searchNumberArray
{
	needle="${1}"
	haystack="${2}"

	for ((i=0; i < ${#haystack[@]}; ++i))
	do
		if [[ "${haystack[$i]}" =~ "${needle}" ]]
		then
			numberOfPages="${haystack[$i]:15}"
			echo $numberOfPages;
		fi
	done
}



function searchBookmarkArray
{
	needle="${1}"
	haystack="${2}"

	n=1
	for ((i=0; i < ${#haystack[@]}; ++i))
	do
		if [[ "${haystack[$i]}" =~ "${needle}" ]]
		then
			titleArr["${n}"]="${haystack[$i]:15}"
			j=$[i+1]
			k=$[i+2]
			if [[ "${haystack[$j]}" =~ "BookmarkLevel:" ]]
			then
				levelArr["${n}"]="${haystack[$j]:15}"
			fi
			if [[ "${haystack[$k]}" =~ "BookmarkPageNumber:" ]]
			then
				numberArr["${n}"]="${haystack[$k]:20}"
			fi
			((n++))
		fi
	done
}



function bookmarkData
{
	curMeta="${1}"

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
	numberOfPages=0
	

	# Load pdfmark info into array
	old_IFS="${IFS}"
	IFS=$'\n'
	haystack=($(cat "${curMeta}")) # array
	IFS="${old_IFS}"
	searchNumberArray "NumberOfPages" "${haystack}"
	searchBookmarkArray "BookmarkTitle" "${haystack}"

	# Loop through the array in reverse order
	lastLevel=0
	for ((x=${#titleArr[@]}; x >= 0; --x))
	do
		case "${x}" in
			0) 	curTitle=${fName%.*}
				curLevel="0"
				curNumber="1"
				;;
			*) 	curTitle="${titleArr[$x]}"
				curLevel="${levelArr[$x]}"
				curNumber="${numberArr[$x]}"
				;;
		esac

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

	curPage=$(($curPage + $numberOfPages))
}


function metaData
{
	curFile="${1}"
	curTmpDir="${tmpStorage}/${h}"
	mkdir -p "${curTmpDir}"
	n=`echo "${#h}"`
	case "${n}" in
		1) addNr="000" ;;
		2) addNr="00" ;;
		3) addNr="0" ;;
	esac
	fName=`basename "${curFile}"`
	fileNoExt=${curFile%.*}
	pdftk "${curFile}" dump_data > "${curTmpDir}/meta.txt"
	pdftk "${curFile}" cat output "${tmpStorage}/${addNr}${h}.pdf"
	bookmarkData "${curTmpDir}/meta.txt"
	((h++))
}


# Prompt file save name
Name=`kdialog --getsavefilename "New.pdf"`;
if [ $? != 0 ]; then
	exit;
fi



# Create temporar dir
createTmpDirs;


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


# Loop through the sorted files
h=1
curPage=0
for curFile in "${filesSorted[@]}"
do
	metaData "${curFile}"
done


# Combine the files
cd "${tmpStorage}"
gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="new.pdf" *.pdf "pdfmarks"
mv "new.pdf" "${Name}"
rm "${tmpStorage}/*pdf"