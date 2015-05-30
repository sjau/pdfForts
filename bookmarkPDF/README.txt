bookmarkPDF
----------


PREREQUISITES

- KDE / Dolphin
- kate
- pdftk
- ghostscript
- bash
- basename (part of coreutils)
- recode



HOWTO

In order to use this script do the following:

1) run the install.sh script to copy the files to the necessary locations

2) wait a short while until KDE/Dolphin picks up the new service menu entry

3) select one or more PDFs in dolphin, right-click and chose
   "Edit PDF Bookmarks" from the actions menus

4) You will then be prompted to supply a save file name

5) After that Kate will be opened with the current bookmarks inside. Use the follwoing syntax:

		+-|DESCRIPTION|PAGE_NUMBER

	For each sublevel for a bookmark add two more dashes at the beginning:

		+-|DESC. LVL 1|PAGE_NUMBER
		+---|DESC. LVL 1.1|PAGE_NUMBER
		+---|DESC. LVL 1.2|PAGE_NUMBER
		+-----|DESC. LVL 1.2.1|PAGE_NUMBER
		+-----|DESC. LVL 1.2.2|PAGE_NUMBER
		+---|DESC. LVL 1.3|PAGE_NUMBER
		+---|DESC. LVL 1.4|PAGE_NUMBER
		+-----|DESC. LVL 1.4.1|PAGE_NUMBER
		+-------|DESC. LVL 1.4.1.1|PAGE_NUMBER
		+-|DESC. LVL 2|PAGE_NUMBER
		+---|DESC. LVL 2.1|PAGE_NUMBER

	etc.
	
	By default all the sublevels are collapsed. If you want to have sublevels open at the beginning, just replace the starting "+" also with a dash "-".
	
		+-|DESC. LVL 1|PAGE_NUMBER
		+---|DESC. LVL 1.1|PAGE_NUMBER
		----|DESC. LVL 1.2|PAGE_NUMBER
		+-----|DESC. LVL 1.2.1|PAGE_NUMBER
		+-----|DESC. LVL 1.2.2|PAGE_NUMBER
		+---|DESC. LVL 1.3|PAGE_NUMBER
		+---|DESC. LVL 1.4|PAGE_NUMBER
		+-----|DESC. LVL 1.4.1|PAGE_NUMBER
		+-------|DESC. LVL 1.4.1.1|PAGE_NUMBER
		--|DESC. LVL 2|PAGE_NUMBER
		+---|DESC. LVL 2.1|PAGE_NUMBER

    In this case the sublevel "DESC LVL 1.2" and its sublevels are opened. Also "DESC. LVL 2" and its sublevel are open.

    Problem: Sublevels that weren't collapsed in the original file will be collapsed by default. This is due to the fact that the meta data export does not keep track of whether sublevels are collapsed or not.

    
	After editing save the file and close Kate (or just that file)

	NOTICE: Sublevels can only increase one level at a time (e.g. from "--" to "----" but not from "--" to "------".