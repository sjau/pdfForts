#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

cp "rmPasswdPDF.sh" "/usr/bin/"
chmod 0755 "/usr/bin/rmPasswdPDF.sh"

cp "rmPasswdPDF.desktop" "/usr/share/kde4/services/ServiceMenus/"
