pdfForts
========

This is just a bunch of bash script to make work easier in KDE/Dolphin as actions.

![Screenshot of the servicemenu](servicemenu.png "Screenshot of the servicemenu")




PREREQUISITES
-------------

Each of the script has other prerequisites. Most of them require one or more of the following:

- Dolphin
- KDialog / or Zenity
- pdftk
- imagemagick
- zip
- unzip
- bash
- libreoffice
- tesseract & tesseract language package(s)
- sed

if you're using Nixos, just use the pdfForts.nix file instead.


addPasswdPDF
------------

This script adds a password to the PDFs.



attachPDF
------------

This lets you add files to your PDF files. However scripts like stamp and combine remove them. So add them at the end.



bookmarkPDF
-----------

Lets you edit the current bookmarks and apply them to the PDF.



combinePDF
----------

Combine PDFs and maintain bookmarks.



extractPDF
----------

This script lets you extract one or more pages from  PDF.



extractTextPDF
----------

This script lets you extract text from a PDF.



metaPDF
-------

Add meta data to a PDF.


ocrPDF
-----------

This script converts image PDFs to text files using tesseract.



pdfaPDF
-----------

This script converts an existing PDF into a PDF/A file.



qualityPDF
-----------

This script lets you convert images to grayscale or b/w and also alter the resolution of images.



rmPasswdPDF
-----------

This script creates a copy of a PDF without password. The password must be known.



rotatePDF
---------

Rotate a PDF by 90°, 180°, 270° clockwise.



searchablePDF
---------

Make an image PDF searchable for text.



stampPDF
--------

This script just adds a document number and page number on a bunch of selcted pdfs.



watermarkPDF
-----------

Lets you add a watermark accross the PDF.
