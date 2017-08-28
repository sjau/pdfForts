#!/usr/bin/env bash

if [[ "$(id -u)" != "0" ]]; then
   printf "%s\n" "This script must be run as root" 1>&2
   exit 1
fi


# Set allScripts array
allScripts=( "addPasswdPDF" "attachPDF" "bookmarkPDF" "combinePDF" "extractPDF" "extractTextPDF" "metaPDF" "ocrPDF" "pdfaPDF" "qualityPDF" "rmPasswdPDF" "rotatePDF" "searchablePDF" "stampPDF" "watermarkPDF" )

# Set original path
origPath=$(pwd)



installFunc () {
    for scriptName in "${runScripts[@]}"; do
        source "${origPath}/${scriptName}/vars.sh"
        cd "${origPath}/${scriptName}"

        mkdir -p "${installPath}"
        cp "${scriptName}.sh" "${installPath}"
        chmod 0755 "${installPath}${scriptName}.sh"

        mkdir -p "${serviceMenus}"
        cp "${scriptName}.desktop" "${serviceMenus}"

        if [[ "${configFile}" = "y" ]]; then
            cp "${scriptName}.conf" "${serviceMenus}"
        fi
        if [[ "${templateFile}" = "y" ]]; then
            cp "${templateName}" "${serviceMenus}${templateName}"
        fi
        if [[ ! -f "${installPath}common.sh" ]]; then
            cp "common.sh" "${installPath}"
        fi

    done
}


uninstallFunc () {
    for scriptName in "${runScripts[@]}"; do
        source "${origPath}/${scriptName}/vars.sh"
        cd "${origPath}/${scriptName}"

        rm "${installPath}${scriptName}.sh"
        rm "${serviceMenus}${scriptName}.desktop"

        if [[ "${configFile}" = "y" ]]; then
            rm "${serviceMenus}${scriptName}.conf"
        fi
        if [[ "${templateFile}" = "y" ]]; then
            rm "${serviceMenus}${templateName}"
        fi
        fCount=$(ls -l "${installPath}" | wc -l)
        if [[ "${fCount}" -le "2" ]]; then
            rm "${installPath}common.sh"
        fi
    done
}


symlinkFunc () {
    for scriptName in "${runScripts[@]}"; do
        source "${origPath}/${scriptName}/vars.sh"
        cd "${origPath}/${scriptName}"

        curPath=$(pwd)
        mkdir -p "${installPath}"
        ln -s "${curPath}/${scriptName}.sh" "${installPath}${scriptName}.sh"

        mkdir -p "${serviceMenus}"
        ln -s "${curPath}/${scriptName}.desktop" "${serviceMenus}${scriptName}.desktop"

        if [[ "${configFile}" = "y" ]]; then
            ln -s "${curPath}/${scriptName}.conf" "${serviceMenus}${scriptName}.conf"
        fi
        if [[ "${templateFile}" = "y" ]]; then
            ln -s "${curPath}/${templateName}" "${serviceMenus}${templateName}"
        fi
        if [[ ! -f "${installPath}common.sh" ]]; then
            cp -s "${origPath}/common.sh" "${installPath}common.sh"
        fi
    done
}


validParaFunc () {
    paraCheck="${1}"
    # Check if PARAMETER2 is in allScripts array
    for i in "${allScripts[@]}";  do
        if [[ "${i}" == "${paraCheck}" ]]; then
            valFound="OK"
        fi
    done
    # Check if PARAMETER2 is 'all'
    if [[ "${paraCheck}" == "all" ]]; then
            valFound="OK"
    fi
    # Check if the $valFound var was set to OK
    if [[ "${valFound}" != "OK" ]]; then
        printf "%s\n" "Sorry, no valid PARAMETER2 supplied."
        printf "%s\n" "Please run the script without parameters to see the help."
        printf "%s\n" "e.g.    ./install.sh"
        exit;
    fi
}


case "${2}" in
    all) printf "%s\n" ""
        runScripts=( "${allScripts[@]}" )
        ;;
    *) printf "%s\n" ""
        runScripts=( ${2} )
        ;;
esac



case "${1}" in
    install) validParaFunc "${2}"
        printf "%s\n" "Install the files"
        installFunc
        printf "%s\n" "Copy files to their location. An entry in Dolphin should appear soon."
        ;;
    uninstall) validParaFunc "${2}"
        printf "%s\n" "Uninstalling the files"
        uninstallFunc
        printf "%s\n" "Remove files. The entry in Dolphin should disappear soon."
        ;;
    symlink) validParaFunc "${2}"
        printf "%s\n" "Symlinking the files"
        symlinkFunc
        printf "%s\n" "Symlink files to their location. An entry in Dolphin should appear soon."
        ;;
    *) printf "%s\n" "Use: run as root: ./install.sh PARAMETER1 PARAMETER2"
        printf "%s\n" ""
        printf "%s\n" ""
        printf "%s\n" "Possible options for PARAMETER1:"
        printf "%s\n" "symlink - instead of copying the files to their according location it just symlinks them; this is good for when you update the git repo --> this is RECOMMENDED"
        printf "%s\n" "install - this will copy the files to their according location"
        printf "%s\n" "uninstall - this will remove the files from their according location, however it'll leave the config files intact"
        printf "%s\n" ""
        printf "%s\n" ""
        printf "%s\n" "Possible options for PARAMETER2"
        printf "%s\n" "all - run on all scripts"
        printf "%s\n" "addPasswdPDF - only run on addPasswdPDF script"
        printf "%s\n" "attachPDF - only run on attachPDF script"
        printf "%s\n" "combinePDF - only run combinePDF script"
        printf "%s\n" "extractPDF - only run on extractPDF script"
        printf "%s\n" "extractTextPDF - only run on extractTextPDF script"
        printf "%s\n" "metaPDF - only run on metaPDF script"
        printf "%s\n" "ocrPDF - only run on ocrPDF script"
        printf "%s\n" "pdfaPDF - convert a PDF into a PDF/A"
        printf "%s\n" "qualityPDF - only run on qualityPDF script"
        printf "%s\n" "rmPasswdPDF - only run on rmPasswdPDF script"
        printf "%s\n" "rotatePDF - only run on rotatePDF script"
        printf "%s\n" "searchablePDF - only run on searchablePDF script"
        printf "%s\n" "stampPDF - only run on stampPDF script"
        printf "%s\n" "watermarkPDF - only run watermarkPDF script"
        ;;
esac
