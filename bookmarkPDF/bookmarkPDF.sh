#!/bin/bash

function createTmpDirs
{
	# Create temporary dirs
	tmpDir='combinePDF.XXXXXXXXXX';
	tmpStorage=`mktemp -t -d "${tmpDir}"` || exit 1
}



function searchBookmarkArray
{
	needle="${1}"
	haystack="${2}"

	for ((i=0; i < ${#haystack[@]}; ++i))
	do
		if [[ "${haystack[$i]}" =~ "${needle}" ]]
		then
			curTitle="${haystack[$i]:15}"
			j=$[i+1]
			k=$[i+2]
			if [[ "${haystack[$j]}" =~ "BookmarkLevel:" ]]
			then
				curLvl="${haystack[$j]:15}"
			fi
			if [[ "${haystack[$k]}" =~ "BookmarkPageNumber:" ]]
			then
				curNr="${haystack[$k]:20}"
			fi

			curDash=""
			while [  "${curLvl}" -gt "1" ]
			do
				curDash="${curDash}--"
				((curLvl--))
			done

			echo "${curDash}|${curTitle}|${curNr}" >> "${tmpStorage}/bookmark.txt"
		fi
	done
}



function readBookmarkFile
{

	mapfile -t fileContent < "${tmpStorage}/bookmark.txt"

	n=1
	for lineContent in "${fileContent[@]}"
	do
		unset arrLine
		IFS='|' read -ra arrLine <<< "$lineContent"
		curDash="${#arrLine[0]}"
		curLvl=$((${curDash} / 2))
		curTitle="${arrLine[1]}"
		curNr="${arrLine[2]}"
		echo "${curLvl}   -   ${curTitle}   -   ${curNr}"
		levelArr["${n}"]="${curLvl}"
		titleArr["${n}"]="${curTitle}"
		numberArr["${n}"]="${curNr}"
		((n++))
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
	searchBookmarkArray "BookmarkTitle" "${haystack}"

	kate -b "${tmpStorage}/bookmark.txt"

	readBookmarkFile

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


function metaData
{
	curFile="${1}"
	fName=`basename "${curFile}"`
	fileNoExt=${curFile%.*}
	pdftk "${curFile}" dump_data > "${tmpStorage}/meta.txt"
	pdftk "${curFile}" cat output "${tmpStorage}/tmp.pdf"
	bookmarkData "${tmpStorage}/meta.txt"
}


# Prompt file save name
Name=`kdialog --getsavefilename "New.pdf"`;
if [ $? != 0 ]; then
	exit;
fi



# Create temporary dir
createTmpDirs;

# Loop through the selected files
for arg ;
do
	# Test if it is a file
	if [ -f "${arg}" ]
	then
		metaData "${arg}"
	fi
done



# Combine the files
cd "${tmpStorage}"
gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="new.pdf" "tmp.pdf" "pdfmarks"
mv "new.pdf" "${Name}"
rm "${tmpStorage}/*pdf"