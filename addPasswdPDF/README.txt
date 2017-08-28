addPasswdPDF
--------


PREREQUISITES

- KDE / Dolphin
- kdialog / Zenity
- pdftk
- bash



HOWTO

In order to use this script do the following:

1) run the install.sh script to copy the files to the necessary locations

2) wait a short while until KDE/Dolphin picks up the new service menu entry

3) select one or more password PDFs in dolphin, right-click and chose
   "Add password to PDF" from the actions menus

4) You will then be prompted to supply a password

5) it will then cycle through all the PDFs and add the password to each PDF -
   the password protected PDFs will be saved as new files so the original will still be there
