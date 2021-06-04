********************************************************************************
* Project: Transition Spillovers
* Task:    Save the structure of the working directory
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

* ______________________________________________________________________________
* Declare your own working directory

* Before running this do-file...
* Update and run the do-file `stata_files/dir/00_mydirectory.do` to store the
* path to your own working directory in a global macro ${path}

* ______________________________________________________________________________
* Folders

global data "${path}data/"
	global data_temp "${data}temp/"

global stata_files "${path}stata_files/"
	global programs "${stata_files}programs/"

global estimates "${stata_files}estimates/"
	
global figures "${path}figures/"
	global figures_eps "${figures}eps/"
	global figures_gph "${figures}gph/"
	global figures_pdf "${figures}pdf/"
	global figures_png "${figures}png/"
	
global logfiles "${stata_files}logfiles/"

global scheme "${stata_files}scheme/"

global tables "${path}tables/"
	global tables_tex "${tables}tex/"
	global tables_rtf "${tables}rtf/"

* ______________________________________________________________________________
* Graph scheme

* 	Adds a scheme directory to the beginning of the search path stored in the 
* 	global macro S_ADO.

adopath ++ "${scheme}"
