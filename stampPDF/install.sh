#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

cp "stampPDF.sh" "/usr/bin/"
chmod 0755 "/usr/bin/stampPDF.sh"

cp "stampPDF.desktop" "/usr/share/kde4/services/ServiceMenus/"

mkdir -p "/usr/share/kde4/services/ServiceMenus/stampPDF"
cp "stampPDF.conf" "/usr/share/kde4/services/ServiceMenus/stampPDF/"
