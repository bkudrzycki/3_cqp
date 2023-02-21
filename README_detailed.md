# README
This folder was made to facilitate replication of the results and PDF of the paper "Benefits and Costs of Dual and Informal
Apprenticeship in Bénin". 

# Prerequisites
Stata, SPSS, and R (preferably RStudio) are necessary to fully reproduce paper.

The following default path is used in the scripts below: 

"/Volumes/nadel/research/Data/PhDs/Bart 2022/Paper 3 - CQP"

If data is copied into a different directory, path names have to be adjusted where indicated below.

# Replication

The paper can be replicated from raw data in three steps, executed in the following order:

  1. **Open Stata do file "master.do", enter user path if needed and run** 
  
    1.1. It will run **Stata file "cleaning.do"** 
        --> have to change the path several times (each time a new data set is loaded or saved)
        --> the loaded data sets (7 altogether) are to be found in "data/source" folder (saved as .dta or .sav)
        --> the saved data sets (7 altogether) are to be found in "data/stata" folder (saved as .dta)
    1.2. It will run **Stata file "merge.do"**
        --> this file merges all the cleaned and saved data sets from "cleaning.do" into our final working data set "youth_survey_merged.dta"


  2. **Open SPSS syntax "master.sps", enter user path if needed and run** --> this file simply converts our main data set (youth_survey_merged) from .dta (in "data/stata" folder) to .sav (in "data" folder)
  
  
  3. **Open R script "master.R", enter user path if needed and run**      --> This will generate a PDF called "cnb_apprenticeship.pdf" in the "markdown" folder. This is the replicated paper.
    --> This file will run the following files:
    
    3.1. **cleaning.R** (to be found in "code/prep" folder)
        --> does some additional cleaning and merging
        --> saves 3 data sets (all to be found in "data/R"):
            * "fs.rda"
            * "fs_end.rda"
            * "ys.rda"
            
    3.2. **pivot_longer.R** (to be found in "code/prep" folder)
        --> uses 2 previously saved data sets:
            * "fs.rda"
            * "fs_end.rda" 
        --> reshapes data: 1 row, 1 apprentice
        --> saves 4 data sets (all to be found in "data/R"):
            * "base_cqps.rda"
            * "base_trad.rda"
            * "end_cqps.rda"
            * "end_trad.rda"
            
    3.3. **recode.R** (to be found in "code/prep" folder)
        --> uses 7 previously saved data sets (basically those created in the past 2 steps):
            * "fs.rda"
            * "fs_end.rda"
            * "ys.rda"
            * "base_cqps.rda"
            * "base_trad.rda"
            * "end_cqps.rda"
            * "end_trad.rda"
        --> saves 1 data set "df.rda" (to be found in "data" folder)
        
    3.4. **cnb_apprenticeship.Rmd** (to be found in "markdown" folder)
        --> This file will run the following files:
          3.4.1. **tbls_body.R** (to be found in "code" folder) --> contains all the tables for the body of the paper
          3.4.2. **tbls_appendix.R** (to be found in "code" folder)  --> contains all the tables for the appendix of the paper
          3.4.3. **figures.R** (to be found in "code" folder) --> contqins all the figures for the body of the paper
          3.4.4. **appendix-a.Rmd** (to be found in "markdown" folder) --> separate markdown file for first appendix
          3.4.5. **appendix-b.Rmd** (to be found in "markdown" folder)
              --> separate markdown file for second appendix 
              --> even though it is referred to in the main markdown document (cnb_apprenticeship.Rmd), it is not run yet
    

If you have any questions about replicating this paper, please see comments in the scripts above or contact the author at bartlomiej.kudrzycki[at]nadel.ethz.ch
