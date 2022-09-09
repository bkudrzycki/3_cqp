﻿* Encoding: UTF-8.
*1. Set root folder, e.g. '/Volumes/nadel/research/Data/PhDs/Bart 2022/Paper 3 - CQP'.
cd '/Users/kudrzycb/polybox/Youth Employment/2 CQP/Paper'.

*2. Import stata data.
get stata file="data/stata/youth_survey_merged.dta".

*3. Save as sav.
save outfile 'data/youth_survey_merged.sav'.
