********************************************************************************
* Project: Dissertation
* Task:    Reproduce the findings of all chapters
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

* Important:

* Run stata_files/dir/00_mydirectory.do before executing this master do-file.
* 	00_mydirectory.do saves your working directory and loads paths to the 
*	folders of the repository in global macros.

set more off

* ______________________________________________________________________________
* Run all do-files

do "${stata_files}01_chap3_graphs.do"

do "${stata_files}02_chap4_descriptives.do"
	
do "${stata_files}03_chap4_analysis.do"

do "${stata_files}04_chap4_robustness.do"
	
do "${stata_files}05_chap5_descriptives.do"
	
do "${stata_files}06_chap5_analysis.do" 
	
do "${stata_files}07_chap6_evs_figure.do"
	
do "${stata_files}08_chap6_analysis.do"
	
do "${stata_files}09_chap6_robustness.do"
	
do "${stata_files}10_chap7_graphs.do"
