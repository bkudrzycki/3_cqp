clear all
set more off

set seed 350393

import excel "/Users/kudrzycb/polybox/Youth Employment/2 CQP/Paper/data/Liste_Candidats_CQP_2018_avec_Notes.xlsx", sheet("Liste_Candidats_CQP_2018") firstrow clear

gen apps = 1
gen res = 1 if RESERVIST == "Oui"
gen sel = 1 if SELECTED == "Oui"
egen NOM_et_PRENOMS_PATRON = concat(NOMPATRON PRENOMSPATRON),  punct(" ")

collapse (sum) apps res sel, by(NOM_et_PRENOMS_PATRON)

export excel using "/Users/kudrzycb/polybox/Youth Employment/2 CQP/Paper/data/selected_new", firstrow(variables) replace



