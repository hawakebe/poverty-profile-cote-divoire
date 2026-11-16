********************************************************************************
*****   Création d'un profil de pauvreté des ménages ivoiriens en 1998   *****
********************************************************************************
* NOM, Prénom : GUERRAZ Matteo & KEBE Hawa
* Date création : 14/12/2025
* Date dernière modification : 08/01/2026
********************************************************************************

	clear all
	capture log close
	version 16

**************************** Chemins d'accès et log ****************************

* Chemin d'accès aux données brutes (raw) et chemin d'accès vers le dossier de travail où sont enregistrées les données (processed) :

	global raw "/Users/hawakebe/Cours_pauvrete/Enquête_ENV98-20251001/ENV98"

	global processed "/Users/hawakebe/Cours_pauvrete/Processed"

	global NOM "GUERRAZKEBE" // Remplacé par nos noms en majuscules

	log using "$processed/Profil_Pauvreté_$NOM.log", replace
	
* Nous repartons du fichier .dta de la séance 4 

	use "$processed/Exercice_Seance4_CORRIGE", clear 

* Remarque : Unité d’analyse fixe --> nous avons choisi d'évaluer la pauvreté au niveau individuel, les caractéristiques étant liées à l'emploi individuelles.
	
	summ taille_men, meanonly

	di "Nombre total d'individus = " r(sum) // Nombre total d'individus = 24589

* Remarque : Le nombre total d’individus dans notre échantillon est de 24 589 (somme des tailles de ménage pour les 4 198 ménages). Pour extrapoler les résultats à la population totale ivoirienne, ces 24 589 individus pondérés par poids_fw_indiv représentent environ 16 millions d’individus. Cette extrapolation permet de dresser un profil de pauvreté au niveau national.

********************************************************************************
*************   		Profil général de la pauvreté en CIV   	  **************
********************************************************************************

* Extrême pauvreté

	tab pauvre_ext [fw=poids_fw_indiv]
	
/*
	 pauvre_ext |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  9,035,350       55.22       55.22
          1 |  7,328,586       44.78      100.00
------------+-----------------------------------
      Total | 16,363,936      100.00
*/

* Remarque : L'estimation par les poids nous indique qu'en 1998, la Côte d'Ivoire comptait  16 363 936 d'habitants.

* Indicateurs FGT (incidence, profondeur & sévérité de la pauvreté)

	ssc install povdeco
	povdeco conso_tete [fw=poids_fw_indiv], pl(162800)

/*

Warning: conso_tete has 1 values = 0. Used in calculations
 
Foster-Greer-Thorbecke poverty indices, FGT(a)

----------------------------------------------
  All obs |        a=0         a=1         a=2
----------+-----------------------------------
          |    0.74034     0.34168     0.19280
----------------------------------------------
FGT(0): headcount ratio (proportion poor)
FGT(1): average normalised poverty gap
FGT(2): average squared normalised poverty gap

*/

********************************************************************************
********************           Emploi & pauvreté            ********************
********************************************************************************

* Import du fichier contenant les informations sur l'emploi et création de la variable d'intérêt

	use  "$raw/niv06.dta", clear 

	tab s1q46 // "Avez-vous travaillé pour au moins 1h au cours des 7 derniers jours ?" (oui=1 & non=2)
	
/*      s1q46 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |     10,039       50.95       50.95
          2 |      9,664       49.05      100.00
------------+-----------------------------------
      Total |     19,703      100.00
*/
	tab s1q49 // "Avez-vous un emploi, même si vous n'avez pas travaillé les 7 derniers jours ?" (oui=1 & non=2)
	
/*      s1q49 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        595        6.18        6.18
          2 |      9,035       93.82      100.00
------------+-----------------------------------
      Total |      9,630      100.00
*/

/* 
Remarque : s1q46 capture le travail effectif récent et s1q49 permet de détecter l’emploi même en l’absence de travail récent. Le tableau s1q46 montre que 50,95 % des individus ont travaillé au moins 1 heure au cours des 7 derniers jours, tandis que 49,05 % n’ont pas travaillé. Le tableau s1q49 indique que seulement 6,18 % des répondants déclarent avoir un emploi même s’ils n’ont pas travaillé la semaine dernière. Il est important de noter que ce tableau ne comporte que 9 630 répondants, contre 9 664 attendus (le nombre de personnes n’ayant pas travaillé selon s1q46). Cette légère perte d’observations est probablement liée à des problèmes d’enquête ou d’attrition. 
*/

	gen travail = .
	replace travail = 1 if s1q46==1 | s1q49==1 
	replace travail = 0 if s1q49==2

	label define travail_label 1 "En emploi" 0 "Sans emploi"
	label value travail travail_label 
	
	tab travail
	
/*    travail |      Freq.     Percent        Cum.
------------+-----------------------------------
Sans emploi |      9,035       45.96       45.96
  En emploi |     10,625       54.04      100.00
------------+-----------------------------------
      Total |     19,660      100.00
*/
	
	egen id_indiv = group(menage idcode)
	label var id_indiv "Identifiant individuel unique"

	keep menage id_indiv travail

	merge m:1 menage using "$processed/Exercice_Seance4_KEBE.dta"
	
/*    Result                           # of obs.
    -----------------------------------------
    not matched                             5
        from master                         5  (_merge==1)
        from using                          0  (_merge==2)

    matched                            23,957  (_merge==3)
    -----------------------------------------
*/
	tab _merge
	
/*                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |          5        0.02        0.02
            matched (3) |     23,957       99.98      100.00
------------------------+-----------------------------------
                  Total |     23,962      100.00
*/

	drop if _merge == 1 // (5 observations deleted) --> 5 ménages dont les informations n’ont pas pu être appariées avec le fichier individuel. Ce sont peut-être des ménages qui n'ont pas répondu aux questions en lien avec le travail. 

	drop _merge 
	compress
	save "$processed/Profil_Pauvreté_1_$NOM.dta", replace

* Profil A 

	tabstat pauvre pauvre_ext [fw=poids_fw_indiv], by(travail)

/*
Summary statistics: mean
  by categories of: travail 

    travail |    pauvre  pauvreté extrême
------------+--------------------
Sans emploi |    .75753  .4333947
  En emploi |  .8241337  .5652367
------------+--------------------
      Total |  .7909027  .4994561
---------------------------------
*/
	
	tabstat povgap sqpovgap [fw=poids_fw_indiv], by(travail)
	
/*
Summary statistics: mean
  by categories of: travail 

    travail |    povgap  sqpovgap
------------+--------------------
Sans emploi |  .3351776  .1836039
  En emploi |  .4177329  .2484266
------------+--------------------
      Total |  .3765431  .2160843
---------------------------------
*/
	
* Profil B (illustratif, non extrapolé)

	tabulate travail if pauvre==1 

/*
    travail |      Freq.     Percent        Cum.
------------+-----------------------------------
Sans emploi |      6,450       44.68       44.68
  En emploi |      7,986       55.32      100.00
------------+-----------------------------------
      Total |     14,436      100.00
*/

* Test de significativité

	proportion pauvre [fw=poids_fw_indiv], over(travail)
	
/* 
Proportion estimation               Number of obs   =  114955175

----------------------------------------------------------------
               |                                   Logit
               | Proportion   Std. Err.     [95% Conf. Interval]
---------------+------------------------------------------------
pauvre@travail |
0 Sans emploi  |     .24247   .0000566      .2423591    .2425809
  0 En emploi  |   .1758663   .0000502       .175768    .1759647
1 Sans emploi  |     .75753   .0000566      .7574191    .7576409
  1 En emploi  |   .8241337   .0000502      .8240353     .824232
----------------------------------------------------------------
*/

/*
Remarque : Le nombre d'observations affiché (114 955 175) est anormalement élevé par rapport à la taille réelle de notre échantillon. Cela est dû à l'utilisation des poids individuels (poids_fw_indiv) dans la commande proportion (STATA multiplie les observations par ces valeurs). Ce problème est récurrent dans les suivantes proportion de nos tests de significativité. Nous n'interpréterons uniquement les résultats de la régression.
*/

	reg pauvre i.travail // i. car on compare des groupes, pas un effet linéaire (même si même résultat que sans i.)
	
/*
      Source |       SS           df       MS      Number of obs   =    19,655
-------------+----------------------------------   F(1, 19653)     =     36.09
       Model |  7.02589867         1  7.02589867   Prob > F        =    0.0000
    Residual |  3826.17095    19,653  .194686356   R-squared       =    0.0018
-------------+----------------------------------   Adj R-squared   =    0.0018
       Total |  3833.19685    19,654  .195033929   Root MSE        =    .44123

------------------------------------------------------------------------------
      pauvre |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
     travail |
  En emploi  |   .0379372   .0063151     6.01   0.000      .025559    .0503153
       _cons |   .7139694   .0046422   153.80   0.000     .7048703    .7230686
------------------------------------------------------------------------------
*/

********************************************************************************
*************  Catégorie socio-professionnelle (CSP) & pauvreté   **************
********************************************************************************

* Import du fichier contenant les informations sur la CSP et création de la variable d'intérêt

	use  "$raw/niv07.dta", clear 

	tab s1q57b // "Votre catégorie socio-professionnelle ?"

/*
     s1q57b |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         49        0.46        0.46
          2 |        128        1.20        1.67
          3 |         52        0.49        2.15
          4 |         29        0.27        2.43
          5 |         14        0.13        2.56
          6 |         23        0.22        2.78
          7 |         47        0.44        3.22
          8 |         48        0.45        3.67
          9 |        336        3.16        6.83
         10 |        391        3.68       10.51
         11 |        146        1.37       11.88
         12 |        141        1.33       13.21
         13 |        128        1.20       14.41
         14 |      1,853       17.43       31.84
         15 |         49        0.46       32.30
         16 |        319        3.00       35.31
         17 |      2,376       22.35       57.66
         18 |         75        0.71       58.36
         19 |      4,213       39.63       98.00
         20 |        201        1.89       99.89
         21 |         12        0.11      100.00
------------+-----------------------------------
      Total |     10,630      100.00
*/
	
	gen CSP = .
	replace CSP = 1 if s1q57b >= 1 & s1q57b <= 4
	replace CSP = 2 if s1q57b >= 5 & s1q57b <= 7 | s1q57b == 15
	replace CSP = 3 if s1q57b >= 8 & s1q57b <= 13
	replace CSP = 4 if s1q57b == 14
	replace CSP = 5 if s1q57b == 17 
	replace CSP = 6 if s1q57b == 19 
	replace CSP = 7 if s1q57b == 16 | s1q57b == 18 | s1q57b == 20 | s1q57b == 21

	label define CSP_label 1 "Fonctionnaires" 2 "Métiers à responsabilité" 3 "Ouvriers & employés" 4 "Indépendants non agricole" 5 "Agriculteurs indépendants" 6 "Aides familiales" 7 "Autres"
	label value CSP CSP_label 

	tab CSP
	
/*                     CSP |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
          Fonctionnaires |        258        2.43        2.43
 Métier à responsabilité |        133        1.25        3.68
       Ouvrier & employé |      1,190       11.19       14.87
Indépendant non agricole |      1,853       17.43       32.30
 Agriculteur indépendant |      2,376       22.35       54.66
           Aide familial |      4,213       39.63       94.29
                  Autres |        607        5.71      100.00
-------------------------+-----------------------------------
                   Total |     10,630      100.00
*/
	
	egen id_indiv = group(menage idcode)
	label var id_indiv "Identifiant individuel unique"

	keep id_indiv CSP
	
	merge 1:1 id_indiv using "$processed/Profil_Pauvreté_1_$NOM.dta"
	
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             5
        from master                         5  (_merge==1)
        from using                          0  (_merge==2)

    matched                            23,957  (_merge==3)
    -----------------------------------------
*/

	tab _merge
	
/*
                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |          5        0.02        0.02
            matched (3) |     23,957       99.98      100.00
------------------------+-----------------------------------
                  Total |     23,962      100.00
*/
	drop if _merge == 1 // (5 observations deleted)
	drop _merge

	compress
	save "$processed/Profil_Pauvreté_2_$NOM.dta", replace
	
* Profil A 

	tabstat pauvre pauvre_ext [fw=poids_fw_indiv], by(CSP)
/*
Summary statistics: mean
  by categories of: CSP 

             CSP |    pauvre  pa~e_ext
-----------------+--------------------
  Fonctionnaires |  .4723749   .130835
Métier à respons |  .4126196  .1506092
Ouvrier & employ |  .6355525  .2713383
Indépendant non  |  .7324974  .3907233
Agriculteur indé |  .8833126  .6406495
   Aide familial |  .8998331  .6917142
          Autres |  .7787243  .4729563
-----------------+--------------------
           Total |  .8239179  .5651622
--------------------------------------
*/
	
	tabstat povgap sqpovgap [fw=poids_fw_indiv], by(CSP)

/*
Summary statistics: mean
  by categories of: CSP 

             CSP |    povgap  sqpovgap
-----------------+--------------------
  Fonctionnaires |   .139267  .0542639
Métier à respons |  .1305956   .054784
Ouvrier & employ |  .2345242  .1104165
Indépendant non  |  .3060038  .1602051
Agriculteur indé |  .4585485  .2759362
   Aide familial |  .5007607  .3132354
          Autres |  .3628215  .1978781
-----------------+--------------------
           Total |  .4176273  .2483519
--------------------------------------
*/
	
* Profil B (illustratif, non extrapolé)

	tabulate CSP if pauvre==1 

/*
                     CSP |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
          Fonctionnaires |        103        1.29        1.29
 Métier à responsabilité |         46        0.58        1.87
       Ouvrier & employé |        620        7.76        9.63
Indépendant non agricole |      1,164       14.57       24.20
 Agriculteur indépendant |      1,920       24.04       48.24
           Aide familial |      3,688       46.18       94.42
                  Autres |        446        5.58      100.00
-------------------------+-----------------------------------
                   Total |      7,987      100.00
*/

* Test de significativité

	proportion pauvre [fw=poids_fw_indiv], over(CSP)

/*
Proportion estimation                            Number of obs   = 57,592,586

-----------------------------------------------------------------------------
                            |                                   Logit
                            | Proportion   Std. Err.     [95% Conf. Interval]
----------------------------+------------------------------------------------
                 pauvre@CSP |
          0 Fonctionnaires  |   .5276251   .0004183      .5268051    .5284449
 0 Métier à responsabilité  |   .5873804   .0006038      .5861965    .5885633
       0 Ouvrier & employé  |   .3644475   .0002069      .3640421     .364853
0 Indépendant non agricole  |   .2675026   .0001493        .26721    .2677954
 0 Agriculteur indépendant  |   .1166874   .0000961      .1164992    .1168759
           0 Aide familial  |   .1001669   .0000575      .1000542    .1002798
                  0 Autres  |   .2212757   .0002426      .2208005    .2217515
          1 Fonctionnaires  |   .4723749   .0004183      .4715551    .4731949
 1 Métier à responsabilité  |   .4126196   .0006038      .4114367    .4138035
       1 Ouvrier & employé  |   .6355525   .0002069       .635147    .6359579
1 Indépendant non agricole  |   .7324974   .0001493      .7322046      .73279
 1 Agriculteur indépendant  |   .8833126   .0000961      .8831241    .8835008
           1 Aide familial  |   .8998331   .0000575      .8997202    .8999458
                  1 Autres  |   .7787243   .0002426      .7782485    .7791995
-----------------------------------------------------------------------------
*/

	reg pauvre i.CSP // la plupart des CSP présentent des différences de pauvreté significatives

/*
      Source |       SS           df       MS      Number of obs   =    10,626
-------------+----------------------------------   F(6, 10619)     =    218.21
       Model |  217.725599         6  36.2875998   Prob > F        =    0.0000
    Residual |  1765.87058    10,619  .166293491   R-squared       =    0.1098
-------------+----------------------------------   Adj R-squared   =    0.1093
       Total |  1983.59618    10,625  .186691405   Root MSE        =    .40779

-------------------------------------------------------------------------------------------
                   pauvre |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------------+----------------------------------------------------------------
                      CSP |
 Métier à responsabilité  |  -.0533601   .0435302    -1.23   0.220    -.1386874    .0319671
       Ouvrier & employé  |   .1217836   .0280052     4.35   0.000     .0668882     .176679
Indépendant non agricole  |   .2292849   .0270987     8.46   0.000     .1761664    .2824034
 Agriculteur indépendant  |   .4095368   .0267319    15.32   0.000     .3571372    .4619364
           Aide familial  |   .4761609   .0261538    18.21   0.000     .4248946    .5274272
                  Autres  |   .3367488   .0303144    11.11   0.000      .277327    .3961706
                          |
                    _cons |   .3992248    .025388    15.72   0.000     .3494597      .44899
-------------------------------------------------------------------------------------------
*/

********************************************************************************
*********  	 			  Type de contrat & pauvreté				   *********
********************************************************************************

* Import du fichier contenant les informations sur le type de contrat et création de la variable d'intérêt

	use  "$raw/niv08.dta", clear 

	tab s1q63 // "Type de contrat avec l'employeur (page 14 du questionnaire)?"; ici, on est par définition que sur des gens en emploi dans l'échantillon et non l'échantillon entier. 
	
/*
      s1q63 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        256        2.42        2.42
          2 |        989        9.33       11.75
          3 |        374        3.53       15.28
          4 |      8,977       84.72      100.00
------------+-----------------------------------
      Total |     10,596      100.00
*/

	label define contrat_label 1 "CDD" 2 "CDI" 3 "Contrat verbal" 4 "Aucun contrat"
	label value s1q63 contrat_label 
	rename s1q63 contrat

	tab contrat
	
/*       contrat |      Freq.     Percent        Cum.
---------------+-----------------------------------
           CDD |        256        2.42        2.42
           CDI |        989        9.33       11.75
Contrat verbal |        374        3.53       15.28
 Aucun contrat |      8,977       84.72      100.00
---------------+-----------------------------------
         Total |     10,596      100.00
*/
	
	egen id_indiv = group(menage idcode)
	label var id_indiv "Identifiant individuel unique"

	keep id_indiv contrat
	
	merge 1:1 id_indiv using "$processed/Profil_Pauvreté_2_$NOM.dta"
	
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             5
        from master                         5  (_merge==1)
        from using                          0  (_merge==2)

    matched                            23,957  (_merge==3)
    -----------------------------------------
*/
	
	tab _merge
	
/*
                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |          5        0.02        0.02
            matched (3) |     23,957       99.98      100.00
------------------------+-----------------------------------
                  Total |     23,962      100.00
*/
	
	drop if _merge == 1 // (5 observations deleted)
	drop _merge

	compress
	save "$processed/Profil_Pauvreté_3_$NOM.dta", replace
	
* Profil A 

	tabstat pauvre pauvre_ext [fw=poids_fw_indiv], by(contrat)
	
/*
Summary statistics: mean
  by categories of: contrat 

       contrat |    pauvre  pa~e_ext
---------------+--------------------
           CDD |   .546648  .2182048
           CDI |  .6264768  .2872579
Contrat verbal |  .6028832  .1655543
 Aucun contrat |  .8584722  .6150957
---------------+--------------------
         Total |  .8234457  .5642012
------------------------------------
*/
	
	tabstat povgap sqpovgap [fw=poids_fw_indiv], by(contrat)

/*
Summary statistics: mean
  by categories of: contrat 

       contrat |    povgap  sqpovgap
---------------+--------------------
           CDD |   .196903  .0934649
           CDI |  .2480672  .1268105
Contrat verbal |  .1960956  .0838699
 Aucun contrat |  .4477405  .2699036
---------------+--------------------
         Total |  .4171382  .2478949
------------------------------------
*/

* Profil B (illustratif, non extrapolé)

	tabulate contrat if pauvre==1 

/*
       contrat |      Freq.     Percent        Cum.
---------------+-----------------------------------
           CDD |        111        1.39        1.39
           CDI |        551        6.92        8.32
Contrat verbal |        195        2.45       10.77
 Aucun contrat |      7,100       89.23      100.00
---------------+-----------------------------------
         Total |      7,957      100.00
*/	

* Test de significativité

	proportion pauvre [fw=poids_fw_indiv], over(contrat)
	
/*
Proportion estimation                  Number of obs   = 57,377,303

-------------------------------------------------------------------
                  |                                   Logit
                  | Proportion   Std. Err.     [95% Conf. Interval]
------------------+------------------------------------------------
   pauvre@contrat |
           0 CDD  |    .453352   .0004223      .4525245    .4541797
           0 CDI  |   .3735232   .0002155      .3731009    .3739458
0 Contrat verbal  |   .3971168   .0003873      .3963579    .3978762
 0 Aucun contrat  |   .1415278   .0000496      .1414306    .1416251
           1 CDD  |    .546648   .0004223      .5458203    .5474755
           1 CDI  |   .6264768   .0002155      .6260542    .6268991
1 Contrat verbal  |   .6028832   .0003873      .6021238    .6036421
 1 Aucun contrat  |   .8584722   .0000496      .8583749    .8585694
-------------------------------------------------------------------
*/

	reg pauvre i.contrat
	
/*
      Source |       SS           df       MS      Number of obs   =    10,592
-------------+----------------------------------   F(3, 10588)     =    182.31
       Model |  97.2268352         3  32.4089451   Prob > F        =    0.0000
    Residual |  1882.25721    10,588  .177772687   R-squared       =    0.0491
-------------+----------------------------------   Adj R-squared   =    0.0488
       Total |  1979.48404    10,591  .186902469   Root MSE        =    .42163

---------------------------------------------------------------------------------
         pauvre |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
----------------+----------------------------------------------------------------
        contrat |
           CDI  |   .1235347   .0295664     4.18   0.000     .0655789    .1814904
Contrat verbal  |   .0877966   .0342016     2.57   0.010      .020755    .1548383
 Aucun contrat  |   .3576689   .0267252    13.38   0.000     .3052825    .4100554
                |
          _cons |   .4335937   .0263519    16.45   0.000      .381939    .4852485
---------------------------------------------------------------------------------
*/

********************************************************************************
****************          Cumul d'emplois & pauvreté            ****************
********************************************************************************

* Import du fichier contenant les informations sur le cumul d'emploi et création de la variable d'intérêt

	use  "$raw/niv11.dta", clear 
	
	tab s1cq1 // "En plus de votre emploi (ou activité prinicipale), exercez-vous d'autres emplois ?" (oui=1 & non=2)

/*
      s1cq1 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,212       11.63       11.63
          2 |      9,211       88.37      100.00
------------+-----------------------------------
      Total |     10,423      100.00

*/
	
	tab s1cq4 // "Dans cet emploi secondaire, quel est votre catégorie socio-professionnelle ?"

/*
      s1cq4 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |          1        0.08        0.08
          2 |          2        0.17        0.25
          3 |          1        0.08        0.33
          4 |          4        0.33        0.66
          5 |          2        0.17        0.83
          6 |          4        0.33        1.16
          8 |          2        0.17        1.33
          9 |          8        0.66        1.99
         10 |         15        1.24        3.23
         11 |          8        0.66        3.90
         12 |         15        1.24        5.14
         13 |          7        0.58        5.72
         14 |        558       46.27       51.99
         15 |         17        1.41       53.40
         16 |          3        0.25       53.65
         17 |        307       25.46       79.10
         18 |         10        0.83       79.93
         19 |         63        5.22       85.16
         20 |         35        2.90       88.06
         21 |        144       11.94      100.00
------------+-----------------------------------
      Total |      1,206      100.00

*/

	gen cumul_emplois = .
	replace cumul_emplois = 1 if s1cq1==1 
	replace cumul_emplois = 0 if s1cq1==2

	label define cumul_label 1 "Cumul d'emplois" 0 "Un seul emploi"
	label value cumul_emplois cumul_label 
	
	tab cumul_emplois
	
/*
  cumul_emplois |      Freq.     Percent        Cum.
----------------+-----------------------------------
 Un seul emploi |      9,211       88.37       88.37
Cumul d'emplois |      1,212       11.63      100.00
----------------+-----------------------------------
          Total |     10,423      100.00
*/
	
	egen id_indiv = group(menage idcode)
	label var id_indiv "Identifiant individuel unique"

	keep id_indiv cumul_emplois

	merge 1:1 id_indiv using "$processed/Profil_Pauvreté_3_$NOM.dta"
	
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             5
        from master                         5  (_merge==1)
        from using                          0  (_merge==2)

    matched                            23,957  (_merge==3)
    -----------------------------------------
*/
	
	tab _merge
	
/*                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |          5        0.02        0.02
            matched (3) |     23,957       99.98      100.00
------------------------+-----------------------------------
                  Total |     23,962      100.00

*/
	
	drop if _merge == 1 // (5 observations deleted)
	drop _merge 
	compress
	save "$processed/Profil_Pauvreté_4_$NOM.dta", replace
	
* Profil A 

	tabstat pauvre pauvre_ext [fw=poids_fw_indiv], by(cumul_emplois)
	
/*	
Summary statistics: mean
  by categories of: cumul_emplois 

  cumul_emplois |    pauvre  pa~e_ext
----------------+--------------------
 Un seul emploi |  .8218772  .5594022
Cumul d'emplois |  .8330627  .6183577
----------------+--------------------
          Total |  .8230475  .5655707
-------------------------------------
*/
	
	tabstat povgap sqpovgap [fw=poids_fw_indiv], by(cumul_emplois)
	
/*
Summary statistics: mean
  by categories of: cumul_emplois 

  cumul_emplois |    povgap  sqpovgap
----------------+--------------------
 Un seul emploi |    .41385  .2450101
Cumul d'emplois |  .4475129  .2746097
----------------+--------------------
          Total |  .4173722  .2481071
-------------------------------------
*/
	

* Profil B (illustratif, non extrapolé)

	tabulate cumul_emplois if pauvre==1 
	
/*
  cumul_emplois |      Freq.     Percent        Cum.
----------------+-----------------------------------
 Un seul emploi |      6,919       88.52       88.52
Cumul d'emplois |        897       11.48      100.00
----------------+-----------------------------------
          Total |      7,816      100.00
*/

* Test de significativité

	proportion pauvre [fw=poids_fw_indiv], over(cumul_emplois)
	
/*
Proportion estimation                     Number of obs   = 56,652,619

----------------------------------------------------------------------
                     |                                   Logit
                     | Proportion   Std. Err.     [95% Conf. Interval]
---------------------+------------------------------------------------
pauvre@cumul_emplois |
   0 Un seul emploi  |   .1781228   .0000537      .1780175    .1782281
  0 Cumul d'emplois  |   .1669373   .0001532      .1666373    .1672378
   1 Un seul emploi  |   .8218772   .0000537      .8217719    .8219825
  1 Cumul d'emplois  |   .8330627   .0001532      .8327622    .8333627
----------------------------------------------------------------------
*/

	reg pauvre i.cumul_emplois
	
/*
      Source |       SS           df       MS      Number of obs   =    10,419
-------------+----------------------------------   F(1, 10417)     =      0.65
       Model |  .122570406         1  .122570406   Prob > F        =    0.4187
    Residual |  1952.56464    10,417  .187440207   R-squared       =    0.0001
-------------+----------------------------------   Adj R-squared   =   -0.0000
       Total |  1952.68721    10,418   .18743398   Root MSE        =    .43294

----------------------------------------------------------------------------------
          pauvre |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
   cumul_emplois |
Cumul d'emplois  |  -.0107017    .013234    -0.81   0.419    -.0366427    .0152394
           _cons |   .7514118   .0045118   166.54   0.000     .7425678    .7602558
----------------------------------------------------------------------------------
*/	

********************************************************************************
********************          Faits stylisés         ********************
********************************************************************************
	
* Travail des enfants

	use  "$raw/niv03.dta", clear 
	
	tab s1q6a
	
/*
      s1q6a |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        670        2.72        2.72
          1 |        638        2.59        5.32
          2 |        664        2.70        8.02
          3 |        762        3.10       11.12
          4 |        679        2.76       13.88
          5 |        709        2.88       16.76
          6 |        778        3.16       19.92
          7 |        781        3.18       23.10
          8 |        835        3.40       26.49
          9 |        698        2.84       29.33
         10 |        820        3.33       32.67
         11 |        592        2.41       35.07
         12 |        757        3.08       38.15
         13 |        626        2.55       40.70
         14 |        578        2.35       43.05
         15 |        630        2.56       45.61
         16 |        574        2.33       47.94
         17 |        553        2.25       50.19
         18 |        725        2.95       53.14
         19 |        502        2.04       55.18
         20 |        647        2.63       57.81
         21 |        408        1.66       59.47
         22 |        491        2.00       61.47
         23 |        457        1.86       63.32
         24 |        343        1.39       64.72
         25 |        544        2.21       66.93
         26 |        382        1.55       68.48
         27 |        319        1.30       69.78
         28 |        396        1.61       71.39
         29 |        231        0.94       72.33
         30 |        554        2.25       74.58
         31 |        246        1.00       75.58
         32 |        346        1.41       76.99
         33 |        256        1.04       78.03
         34 |        220        0.89       78.93
         35 |        365        1.48       80.41
         36 |        240        0.98       81.39
         37 |        182        0.74       82.13
         38 |        286        1.16       83.29
         39 |        151        0.61       83.90
         40 |        366        1.49       85.39
         41 |        151        0.61       86.00
         42 |        189        0.77       86.77
         43 |        160        0.65       87.42
         44 |        126        0.51       87.94
         45 |        264        1.07       89.01
         46 |        147        0.60       89.61
         47 |        133        0.54       90.15
         48 |        150        0.61       90.76
         49 |        120        0.49       91.25
         50 |        242        0.98       92.23
         51 |         84        0.34       92.57
         52 |        118        0.48       93.05
         53 |        120        0.49       93.54
         54 |        108        0.44       93.98
         55 |        110        0.45       94.43
         56 |        100        0.41       94.83
         57 |         53        0.22       95.05
         58 |        108        0.44       95.49
         59 |         49        0.20       95.69
         60 |        159        0.65       96.33
         61 |         50        0.20       96.54
         62 |         65        0.26       96.80
         63 |         75        0.30       97.10
         64 |         48        0.20       97.30
         65 |         85        0.35       97.65
         66 |         49        0.20       97.85
         67 |         37        0.15       98.00
         68 |         82        0.33       98.33
         69 |         23        0.09       98.42
         70 |         94        0.38       98.80
         71 |         24        0.10       98.90
         72 |         28        0.11       99.02
         73 |         37        0.15       99.17
         74 |         17        0.07       99.24
         75 |         32        0.13       99.37
         76 |         20        0.08       99.45
         77 |          5        0.02       99.47
         78 |         23        0.09       99.56
         79 |         13        0.05       99.61
         80 |         31        0.13       99.74
         81 |         10        0.04       99.78
         82 |          6        0.02       99.80
         83 |          4        0.02       99.82
         84 |          7        0.03       99.85
         85 |          6        0.02       99.87
         86 |          5        0.02       99.89
         88 |          4        0.02       99.91
         89 |          5        0.02       99.93
         90 |          6        0.02       99.96
         92 |          1        0.00       99.96
         93 |          2        0.01       99.97
         96 |          3        0.01       99.98
         98 |          2        0.01       99.99
         99 |          3        0.01      100.00
------------+-----------------------------------
      Total |     24,594      100.00
*/
	
	egen id_indiv = group(menage idcode)
	label var id_indiv "Identifiant individuel unique"

	rename s1q6a age

	keep id_indiv age

	merge 1:1 id_indiv using "$processed/Profil_Pauvreté_4_$NOM.dta"
	
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           637
        from master                       637  (_merge==1)
        from using                          0  (_merge==2)

    matched                            23,957  (_merge==3)
    -----------------------------------------
*/
	
	tab _merge
	
/*
                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |        637        2.59        2.59
            matched (3) |     23,957       97.41      100.00
------------------------+-----------------------------------
                  Total |     24,594      100.00
*/

	drop if _merge == 1 // (637 observations deleted) --> ces 637 individus du master n’ont pas de correspondance dans le fichier niv03.dta. Ils n'ont probablement pas renseigné leur âge.
	
	drop _merge 
	compress
	save "$processed/Profil_Pauvreté_$NOM.dta", replace
	
	gen age_grp = .
	replace age_grp = 1 if age < 15
	replace age_grp = 2 if age >= 15 & age < 18
	replace age_grp = 3 if age >= 18

	label define age_grp_lbl 1 "Enfants (<15)" 2 "Ados (15–17)" 3 "Adultes (18+)"
	label values age_grp age_grp_lbl
	
	tabulate age_grp travail, row
	
/*
               |        travail
       age_grp | Sans empl  En emploi |     Total
---------------+----------------------+----------
 Enfants (<15) |     3,766      4,654 |     8,420 
               |     44.73      55.27 |    100.00 
---------------+----------------------+----------
  Ados (15–17) |       693        705 |     1,398 
               |     49.57      50.43 |    100.00 
---------------+----------------------+----------
 Adultes (18+) |     4,575      5,262 |     9,837 
               |     46.51      53.49 |    100.00 
---------------+----------------------+----------
         Total |     9,034     10,621 |    19,655 
               |     45.96      54.04 |    100.00 
*/

* Statut d'emploi selon l'âge


	gen adulte = .
	replace adulte = 1 if age >= 18
	replace adulte = 0 if age < 18

	label define adulte_lbl 0 "Enfants / mineurs" 1 "Adultes (18+)"
	label values adulte adulte_lbl

	tabulate adulte travail, row
	
/*
+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

                  |        travail
           adulte | Sans empl  En emploi |     Total
------------------+----------------------+----------
Enfants / mineurs |     4,459      5,359 |     9,818 
                  |     45.42      54.58 |    100.00 
------------------+----------------------+----------
    Adultes (18+) |     4,575      5,262 |     9,837 
                  |     46.51      53.49 |    100.00 
------------------+----------------------+----------
            Total |     9,034     10,621 |    19,655 
                  |     45.96      54.04 |    100.00 
*/

* Incidence de la pauvreté chez les adultes employés et sans emploi

	tabulate travail pauvre if adulte==1

/*
            |        pauvre
    travail |         0          1 |     Total
------------+----------------------+----------
Sans emploi |     1,364      3,211 |     4,575 
  En emploi |     1,378      3,884 |     5,262 
------------+----------------------+----------
      Total |     2,742      7,095 |     9,837 
*/

* Catégorie socio-professionnelle selon la strate de résidence

	tabulate strate CSP, row
	
/*

+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

                    |                                     CSP
             strate | Fonctionn  Métier à   Ouvrier &  Indépenda  Agriculte  Aide fami     Autres |     Total
--------------------+-----------------------------------------------------------------------------+----------
            Abidjan |        91         79        603        598         22         59        104 |     1,556 
                    |      5.85       5.08      38.75      38.43       1.41       3.79       6.68 |    100.00 
--------------------+-----------------------------------------------------------------------------+----------
      Autres villes |       113         32        374        815        197        292        197 |     2,020 
                    |      5.59       1.58      18.51      40.35       9.75      14.46       9.75 |    100.00 
--------------------+-----------------------------------------------------------------------------+----------
   Forêt rurale est |        10         16         96        119        611      1,262         75 |     2,189 
                    |      0.46       0.73       4.39       5.44      27.91      57.65       3.43 |    100.00 
--------------------+-----------------------------------------------------------------------------+----------
 Forêt rurale ouest |        16          0         88        199        683        728        167 |     1,881 
                    |      0.85       0.00       4.68      10.58      36.31      38.70       8.88 |    100.00 
--------------------+-----------------------------------------------------------------------------+----------
      Savane rurale |        28          6         29        121        861      1,872         63 |     2,980 
                    |      0.94       0.20       0.97       4.06      28.89      62.82       2.11 |    100.00 
--------------------+-----------------------------------------------------------------------------+----------
              Total |       258        133      1,190      1,852      2,374      4,213        606 |    10,626 
                    |      2.43       1.25      11.20      17.43      22.34      39.65       5.70 |    100.00 
*/

* Répartition de l’informalité par CSP

	tab CSP contrat, row
/*
+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

                      |                   contrat
                  CSP |       CDD        CDI  Contrat v  Aucun con |     Total
----------------------+--------------------------------------------+----------
       Fonctionnaires |        85        138          4         30 |       257 
                      |     33.07      53.70       1.56      11.67 |    100.00 
----------------------+--------------------------------------------+----------
Métiers à responsabil |        21         57          8         47 |       133 
                      |     15.79      42.86       6.02      35.34 |    100.00 
----------------------+--------------------------------------------+----------
  Ouvriers & employés |       120        365        180        518 |     1,183 
                      |     10.14      30.85      15.22      43.79 |    100.00 
----------------------+--------------------------------------------+----------
Indépendants non agri |         7        119         33      1,678 |     1,837 
                      |      0.38       6.48       1.80      91.34 |    100.00 
----------------------+--------------------------------------------+----------
Agriculteurs indépend |         0         94         15      2,248 |     2,357 
                      |      0.00       3.99       0.64      95.38 |    100.00 
----------------------+--------------------------------------------+----------
     Aides familiales |         2        170         24      3,944 |     4,140 
                      |      0.05       4.11       0.58      95.27 |    100.00 
----------------------+--------------------------------------------+----------
               Autres |        18         40        106        439 |       603 
                      |      2.99       6.63      17.58      72.80 |    100.00 
----------------------+--------------------------------------------+----------
                Total |       253        983        370      8,904 |    10,510 
                      |      2.41       9.35       3.52      84.72 |    100.00 

*/

********************************************************************************
********************           		 Fin            		********************
********************************************************************************

exit

br
