**** Methods
* Merging the depression dataset to NHANES dataset
merge 1:1 seqn using Depression_data

* Keep only observations where age is between 30 and 60
keep if ridageyr >= 30 & ridageyr <= 60

* Depression Variable
egen Depression = rowtotal(dpq010 dpq020 dpq030 dpq040 dpq050 dpq060 dpq070 dpq080 dpq090), missing

* Recode Depression variable
recode Depression (0 = 0) (1/max = 1), gen(Depression_recode)
* Label the recoded variable
label define Depression_label 0 "No" 1 "Yes"
label values Depression_recode Depression_label
tabulate Depression_recode

* Depression
summarize Depression,detail

* Decriptive statistics
* Gender
tabulate riagendr

* Age
* Recode Age variable
recode ridageyr (min/44 = 0) (45/max = 1), gen(ridageyr_recode)

* Label the Age variable
label define ridageyr_label 0 "Young Population" 1 "Old Population"
label values ridageyr_recode ridageyr_label
tabulate ridageyr_recode

* RIDRETH3 (Race-Ethnicity for oversample of Asian Americans)
label define race_ethnicity_label 1 "Mexican American" 2 "Hispanic" 3 "Non-Hispanic White" 4 "Non-Hispanic Black" 6 "Non-Hispanic Asian" 7 "Non-Hispanic Multiracial "
label values ridreth3 race_ethnicity_label
tabulate ridreth3

* DMDEDUC2 (Highest level of education completed)
label define education_lbll 1 "Less 9th grade" 2 "9-11th grade" 3 "High school graduate/GED" 4 "Some college or AA degree" 5 "College graduate or higher" 7 "Refused" 9 "Don't Know"
label values dmdeduc2 education_lbll
* Set Refused and Don't Know responses to missing values
recode dmdeduc2 (7 9 = .)

* indfmpir (Ratio to Family Income)
gen family_income = .
replace family_income = 1 if indfmpir < 1 
replace family_income = 2 if indfmpir == 1
replace family_income = 3 if indfmpir > 1
label define family_income_label 1 "< 1" 2 "= 1" 3 "> 1"
label values family_income family_income_label
tabulate family_income

* Main exposure (Length of time lived in the US)
gen dmdyrusz_filled = .
replace dmdyrusz_filled = 1 if dmdyrusz <= 5 & !missing(dmdyrusz)
replace dmdyrusz_filled = 2 if dmdyrusz > 5
label define length_US_label 1 "<= 5" 2 "> 5" 
label values dmdyrusz_filled length_US_label
tabulate dmdyrusz_filled

* Histograms for continuous variables
histogram Depression, title("Distribution of Depression in the US") xtitle("Depression") ylabel(#10, nogrid) xlabel(#10, nogrid)

*Identifying the Outliers
extremes Depression, iqr(3)

* Replace the outliers
winsor2 Depression, replace cut(0,90)


* Drop the outliers
winsor2 Depression, replace cut(0,90)

* Find Missing values
mdesc

* Exclude missing values from the analysis
tabulate dmdeduc2 if dmdeduc2 < .

* EXPOSURE (LENGTH OF TIME IN THE US)
tabulate dmdyrusz_filled riagendr
tabulate dmdyrusz_filled riagendr, cell nofreq
tabulate dmdyrusz_filled riagendr, chi2

tabulate dmdyrusz_filled ridageyr_recode
tabulate dmdyrusz_filled ridageyr_recode, cell nofreq
tabulate dmdyrusz_filled ridageyr_recode, chi2

tabulate dmdyrusz_filled ridreth3
tabulate dmdyrusz_filled ridreth3, cell nofreq 
tabulate dmdyrusz_filled ridreth3, chi2

tabulate dmdyrusz_filled dmdeduc2
tabulate dmdyrusz_filled dmdeduc2, cell nofreq
tabulate dmdyrusz_filled dmdeduc2, chi2

tabulate dmdyrusz_filled family_income
tabulate dmdyrusz_filled family_income, cell nofreq
tabulate dmdyrusz_filled family_income, chi2

* Conduct ANOVA
anova Depression dmdyrusz_filled

tabulate Depression_recode dmdyrusz_filled
tabulate Depression_recode dmdyrusz_filled, cell nofreq
tabulate Depression_recode dmdyrusz_filled, chi2


* OUTCOME (DEPRESSION) CATEGORICAL
tabulate Depression_recode riagendr
tabulate Depression_recode riagendr, cell nofreq
tabulate Depression_recode riagendr, chi2

tabulate Depression_recode ridageyr_recode
tabulate Depression_recode ridageyr_recode, cell nofreq
tabulate Depression_recode ridageyr_recode, chi2

tabulate Depression_recode ridreth3
tabulate Depression_recode ridreth3, cell nofreq 
tabulate Depression_recode ridreth3, chi2

tabulate Depression_recode dmdeduc2
tabulate Depression_recode dmdeduc2, cell nofreq
tabulate Depression_recode dmdeduc2, chi2

tabulate Depression_recode family_income
tabulate Depression_recode family_income, cell nofreq
tabulate Depression_recode family_income, chi2


* OUTCOME (DEPRESSION) Continuous
tabulate riagendr
summarize Depression riagendr
summarize Depression riagendr, detail
anova Depression riagendr

tabulate ridageyr_recode
summarize Depression ridageyr_recode
summarize Depression ridageyr_recode, detail
anova Depression ridageyr_recode

tabulate ridreth3
summarize Depression ridreth3
summarize Depression ridreth3, detail
anova Depression ridreth3

tabulate dmdeduc2
summarize Depression dmdeduc2
summarize Depression dmdeduc2, detail
anova Depression dmdeduc2

tabulate family_income
summarize Depression family_income
summarize Depression family_income, detail
anova Depression family_income


*Linear Regression
* 1. EXAMINE THE CONTINOUS DEPRESSION SCORE OUTCOME - This is the dependent variable for the linear regression analysis */

regress Depression i.dmdyrusz_filled
regress Depression i.ridageyr_recode 
regress Depression i.dmdeduc2 
regress Depression i.family_income 

* Full Model 1
regress Depression i.dmdyrusz_filled ridageyr_recode i.family_income ib3.dmdeduc2 

* Full Model 2
regress Depression i.dmdeduc2 i.ridageyr_recode i.dmdyrusz_filled##i.family_income


*Logistic Regression
* QUESTION 1: What is the prevalence of depression in your sample? */
logistic Depression_recode i.dmdyrusz_filled 
logistic Depression_recode i.ridageyr_recode 
logistic Depression_recode i.dmdeduc2 
logistic Depression_recode i.family_income 

* Model 1
logistic Depression_recode i.dmdyrusz_filled ridageyr_recode i.family_income ib3.dmdeduc2 

* Model 2
logistic Depression_recode i.dmdeduc2 i.ridageyr_recode i.dmdyrusz_filled##i.family_income
