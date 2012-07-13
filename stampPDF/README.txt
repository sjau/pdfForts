stampPDF
--------


PREREQUISITES

- KDE / Dolphin
- kdialog
- ghostscript
- pdftk
- imagemagick
- bash
- basename (part of coreutils)



HOWTO

In order to use this script do the following:

1) run the install.sh script to copy the files to the necessary locations

2) wait a short while until KDE/Dolphin picks up the new service menu entry

3) right-click a pdf, select "Actions" and select "Stamp documents and create PDF"

4) for the first run, it copies the default config file to your user home and
   opens it in Kate, so that you can alter the default values

5) after closing kate the script exits; it's not being run the first time

6) now select a bunch of PDF files and run it again, it will ask you at which document
   numer it shall begin to number

7) you'll end up with a combined pdf where each page is numbered


NOTICE: The PDFs are being parsed alphabetically!
