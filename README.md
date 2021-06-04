# Contents
1. [Description](#Description)
2. [Raw data](#Raw_data)
3. [Generated data](#Generated_data)
4. [Instructions to reproduce the analysis](#Instructions)
5. [License](#License)
6. [Citation](#Citation)

---

# 1 Description <a name="Description"></a>

This repository assembles the materials to reproduce the findings of my thesis entitled _Protest in Postcommunist Democracies: The  Legacies of Repression and Mobilization_ (2021) in R and Stata.

## Author

Philippe Joly 
- [Website](https://philippejoly.net/)
- [ORCID](https://orcid.org/0000-0002-4278-9439)

## Abstract of the thesis

This thesis examines the conditions that favor or hinder the spread of nonviolent protest in postcommunist democracies. Nonviolent protest—that is, the involvement in extra-representational activities such as demonstrations, petitions, and boycotts—is an indicator of the vitality of civil society in democracies. This type of activism complements conventional forms of political participation such as voting. More spontaneous and less institutionalized, protest raises awareness about new issues, gives a voice to marginalized groups, and allows people to influence policy-making between elections. Many studies have shown that citizens of Central and Eastern European countries are less active in protest activities than their peers in Western Europe. Yet, the extent of and causes underlying the East-West participation gap are still debated in the literature. Using repeated cross-national survey data stretching over 16 years in a large number of new and old European democracies, the thesis sheds new light on the sources of the European protest divide. It argues that, to better understand the development of protest activism in postcommunist democracies, scholars have to shift their attention from current contextual determinants of political participation to biographical trajectories. Inspired by theories of political socialization, the project examines how early exposure to (1) repression and (2) mobilization during the transition to democracy has shaped the protest behavior of different generations in Central and Eastern Europe. The thesis develops new approaches to measure these types of exposure and examines their effect on protest using multilevel age-period-cohort models. The empirical analysis is structured around three chapters, consisting of two cross-national studies and a comparison of East and West Germans. The results reveal that early exposure to repression has a lasting effect on demonstration attendance but not on petition signing nor on participation in boycotts. Furthermore, the type of repression experienced by citizens determines the direction of the effect on demonstrations. Citizens exposed to civil liberties restrictions during their youth tend to participate more later in life; the opposite is true for citizens exposed to personal integrity violations. From a micro perspective, only exposure to the most extreme form of repression, political violence, depresses participation in the long term. At the same time, there is little evidence that exposure to mobilization during the transition to democracy moderates the East-West protest gap. A close look at East Germans’ protest behavior shows that, even in a society that went through massive mobilization during the collapse of communism, current participation is better explained by a legacy of repression than by a legacy of transitional mobilization. By generating new insights into the relation between regime change and civil society, this project bridges and contributes to the fields of political behavior, social movements, and democratization.

## What this repository contains

* `data/` stores the master dataset (`master.dta`), produced by merging various openly available datasets. The folder also contains two subfolders `raw/`, which contains raw data (survey data and macro-level indicators), and `temp/`, which will store temporary datasets produced on the fly before merging. 
* `figures/` contains empty subfolders where figures will be saved in different formats: GPH, PDF, and PNG.
* `r_scripts/` contains R scripts to produce the master dataset in the appropriate order. The subfolder `functions/` contains R functions used in many scripts. 
* `stata_files/` contains Stata do-files in the appropriate order to run the analysis and export tables and figures. The subfolder `dir/` contains the do-file `00_mydirectory.do`, which loads the working directory into global macros (see [Instructions](#Instructions) below). `estimates/` is an empty subfolder where model estimates will be stored. `logfiles/` is an empty subfolder where Stata logfiles will be stored. The subfolder `programs/` contains a series of do-files. Files with names like `export_*.do` are programms exporting tables and figures. The subfolder`schemes/` contains the file [`minimal.scheme`](stata_files/scheme/minimal.scheme), a Stata scheme I designed.
* `tables/` contains an empty subfolder where tables will be saved in TEX format.

# 2 Raw data <a name="Raw_data"></a>

The master dataset on which are based the figures and the tables combines data from different sources (_please consult the conditions of use of these datasets_):

Arbeitskreis “Volkswirtschaftliche Gesamtrechnungen der Länder” (Ed.). (2018). Bruttoinlandsprodukt, Bruttowertschöpfung in den Ländern der Bundesrepublik Deutschland 1991 bis 2017. Stuttgart: Statistisches Landesamt Baden-Württemberg.

Boix, C., Miller, M., & Rosato, S. (2013). A Complete Data Set of Political Regimes, 1800-2007. Comparative Political Studies, 46(12), 1523–1554. https://doi.org/10.1177/0010414012463905

Coppedge, M., Gerring, J., Knutsen, C. H., Lindberg, S. I., Teorell, J., Altman, D., . . . Ziblatt, D. (2019b). V-Dem Country-Year Dataset v9. Varieties of Democracy (V-Dem) Project. Retrieved from https://doi.org/10.23696/vdemcy19

ESS. (2017). European Social Survey, Rounds 1-8 Data. Bergen: NSD - Norwegian Centre for Research Data, Data Archive and distributor of ESS data for ESS ERIC.

EVS. (2015). European Values Study Longitudinal Data File 1981-2008, ZA4804 Data file, Version 3.0.0. Cologne: GESIS Data Archive.

World Bank. (2018). World Development Indicators. Retrieved from https://datacatalog.worldbank.org/dataset/world-development-indicators

# 3 Generated data <a name="Generated_data"></a>

Transformations operated on these datasets are described in a series of R scripts. `r_scripts/00_master.R` calls the scripts sequentially. Data is generated by recoding existing variables. For most variables, this involved minimal transformation (e.g., renaming or merging categories together). 

## Social classes

Social classes were coded using [scripts provided by Daniel Oesch](http://people.unil.ch/danieloesch/scripts/). These do-files recode occupation variables in the ESS to create 5-, 8-, or 16-class schemas. This paper uses the 5-class schema. More information on how to use the scripts in R can be found [here](http://philippejoly.net/files/code/oesch-class-ess-R/vignette.html).

See:

Oesch, Daniel. 2006a. "Coming to Grips with a Changing Class Structure: An Analysis of Employment Stratification in Britain, Germany, Sweden and Switzerland." _International Sociology_ 21(2):263-88.

Oesch, Daniel. 2006b. _Redrawing the Class Map: Stratification and Institutions in Britain, Germany, Sweden and Switzerland_. Houndmills, Basingstoke, Hampshire: Palgrave Macmillan.

# 4 Instructions to reproduce the analysis <a name="Instructions"></a>
A few steps are necessary to run the analysis. If you want to start from the final dataset, you can skip Step 2.

## Necessary software

R is used to generate the master dataset and Stata 16 is used to run the analysis and export the tables and the figures. 

## Step 1: Clone the repository

* Clone or download the repository on your own computer. 

## Step 2: Generate the master dataset 

* In RStudio, open the project `thesis.Rproj`.
* Run `r_scripts/00_master.R` to generate the master dataset.

## Step 3: Set up your working directory for Stata

* Before running the analysis you have to map your working directory in global macros. If you cloned the repository, the only change you need to make is to save the path to your local copy of the repository.
* Update the do-file `stata_files/dir/00_mydirectory.do` to save the path to your working directory.
* Run `stata_files/dir/00_mydirectory.do`.

### Step 4: Run the analysis

* Run `00_master.do`. 

# 5 License <a name="License"></a>

## Code

Code associated with this project carries the following license: [![License:MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# 6 Citation <a name="Citation"></a>

You can refer to this repository as:

Joly, P. (2021). _Protest in Postcommunist Democracies: The Legacies of Repression and Mobilization_. Dissertation. Humboldt-Universität zu Berlin. 
