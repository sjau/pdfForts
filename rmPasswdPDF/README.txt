rmPasswdPDF
--------


PREREQUISITES

- KDE / Dolphin
- kdialog
- pdftk
- bash



HOWTO

In order to use this script do the following:

1) run the install.sh script to copy the files to the necessary locations

2) wait a short while until KDE/Dolphin picks up the new service menu entry

3) select one or more password protected PDFs in dolphine, right-click and chose
   "Remove password from PDF" from the actions menus

4) it will cycle through all the PDFs and ask for the password for each of the PDFs

5) if correct password as supplied, it will leave the original untouched but save another
   copy without password.
