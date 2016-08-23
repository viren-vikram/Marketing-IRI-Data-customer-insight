libname Predmod "E:\Pranesh\GMAT\MS in Analytics\UTD\CoursWork\MKT 6337 - Predictive Marketing Analytics\Project\mustketc\SAS Datasets";

proc print data = Predmod.merge(obs = 20);run;
/* Working on RFM*/
data rfm(keep = Panelist_ID colupc IRI_KEY WEEK UNITS DOLLARS Brand Oz Month Year colupc);
set Predmod.merge;
run;
proc print data = rfm(obs = 20);run;
proc contents data = rfm;run;
data rfm;
set rfm;
monthmod = month+(Year-1)*12;
run;

proc freq data = rfm;table Brand;run;

/*Seperating into 3 different brands*/
proc sql;/*Heinz products*/
create table rfm_Heinz as select * from rfm where Brand in ("HEINZ","HEINZ EZ SQUIRT");

proc sql;/*DEL MONTE products*/
create table rfm_del as select * from rfm where Brand in ("DEL MONTE","DEL MONTE CLASSICS");


proc sql;/*Hunts products*/
create table rfm_Huntz as select * from rfm where Brand in ("HUNTS");

/* Creating rfm matrix for panel id*/
/*Heinz*/
proc sql;
create table rfm_Heinz1 as select Panelist_ID, sum(DOLLARS) as M, count(*) as F, MAX(monthmod) as R, sum(UNITS) as Totunits from rfm_Heinz group by Panelist_ID;
proc print data = rfm_Heinz1(obs = 20);run;
proc rank data = rfm_Heinz1 out = rfm_Heinz2 ties = low groups = 5;
var M F R;
ranks M_score F_score R_score;
run;
proc print data = rfm_heinz2(obs = 100);run;
/*data rfm_heinz2;
set rfm_heinz2;
if M_score = 0 then M_score = -2; else if M_score = 1 then M_score = -1; else if M_score = 3 then M_score = 0;else if M_score = 4 then M_score = 1;else M_score = 2;
if F_score = 0 then F_score = -2; else if F_score = 1 then F_score = -1; else if F_score = 3 then F_score = 0;else if F_score = 4 then F_score = 1;else F_score = 2;
if R_score = 0 then R_score = -2; else if R_score = 1 then R_score = -1; else if R_score = 3 then R_score = 0;else if R_score = 4 then R_score = 1;else R_score = 2;
run;*/
/* Merging this and demos data*/
proc sql;
create table rfm_heinz_l as select * from rfm_heinz2, Predmod.demos as d where rfm_heinz2.Panelist_ID = d.Panelist_ID;
proc sql;
select count(distinct(Panelist_ID)) from Predmod.demos;
proc print data = rfm_heinz_l(obs = 20);run;
data Predmod.rfmheinz(drop = M F R);
set rfm_heinz_l;
run;
/* From the Tableau we can see that M is very imp*/
data Predmod.rfmheinz;
set Predmod.rfmheinz;
M_score = 2*M_score;
Score = M_score+F_score+R_score;
run;
/*Ranking again*/
proc rank data = Predmod.rfmheinz out = Predmod.rfmheinz_o ties = low groups = 3;
var score;
ranks rank;
run;
proc print data = Predmod.rfmheinz_o(obs = 20);run;
proc means data = Predmod.rfmheinz_o;class rank;var Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH Male_Working_Hour_Code Female_Working_Hour_Code Number_of_Dogs Children_Group_Code Marital_Status Number_of_TVs_Used_by_HH IRI_Geography_Number;run;
proc freq data = Predmod.rfmheinz_o;table rank;run;
proc freq data = Predmod.rfmheinz_o;by county;table rank;run;
proc sql;
select county, rank, count(*) from Predmod.rfmheinz_o group by county,rank;

proc sort data = Predmod.rfmheinz_o;by rank;
proc freq data = Predmod.rfmheinz_o;table Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH Male_Working_Hour_Code Female_Working_Hour_Code Number_of_Dogs Children_Group_Code Marital_Status Number_of_TVs_Used_by_HH IRI_Geography_Number county;by rank;run;










/*Del Monte*/
proc sql;
create table rfm_del1 as select Panelist_ID, sum(DOLLARS) as M, count(*) as F, MAX(monthmod) as R, sum(UNITS) as Totunits from rfm_del group by Panelist_ID;
proc print data = rfm_del1(obs = 20);run;
proc rank data = rfm_del1 out = rfm_del2 ties = low groups = 5;
var M F R;
ranks M_score F_score R_score;
run;
proc print data = rfm_del2(obs = 20);run;
/*data rfm_del2;
set rfm_del2;
if M_score = 0 then M_score = -2; else if M_score = 1 then M_score = -1; else if M_score = 3 then M_score = 0;else if M_score = 4 then M_score = 1;else M_score = 2;
if F_score = 0 then F_score = -2; else if F_score = 1 then F_score = -1; else if F_score = 3 then F_score = 0;else if F_score = 4 then F_score = 1;else F_score = 2;
if R_score = 0 then R_score = -2; else if R_score = 1 then R_score = -1; else if R_score = 3 then R_score = 0;else if R_score = 4 then R_score = 1;else R_score = 2;
run;*/
/* Merging this and demos data*/
proc sql;
create table rfm_del_l as select * from rfm_del2, Predmod.demos as d where rfm_del2.Panelist_ID = d.Panelist_ID;
proc sql;
select count(distinct(Panelist_ID)) from Predmod.demos;
proc print data = rfm_del_l(obs = 20);run;
data Predmod.rfmdel(drop = M F R);
set rfm_del_l;
run;
/* From the Tableau we can see that M is very imp*/
data Predmod.rfmdel;
set Predmod.rfmdel;
M_score = 2*M_score;
Score = M_score+F_score+R_score;
run;
/*Ranking again*/
proc rank data = Predmod.rfmdel out = Predmod.rfmdel_o ties = low groups = 3;
var score;
ranks rank;
run;
proc sort data = Predmod.rfmdel_o;by rank;
proc freq data = Predmod.rfmdel_o;table Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH Male_Working_Hour_Code Female_Working_Hour_Code Number_of_Dogs Children_Group_Code Marital_Status Number_of_TVs_Used_by_HH IRI_Geography_Number county;by rank;run;




/*Huntz*/
proc sql;
create table rfm_Huntz1 as select Panelist_ID, sum(DOLLARS) as M, count(*) as F, MAX(monthmod) as R, sum(UNITS) as Totunits from rfm_Huntz group by Panelist_ID;
proc print data = rfm_Huntz1(obs = 20);run;
proc rank data = rfm_Huntz1 out = rfm_Huntz2 ties = low groups = 5;
var M F R;
ranks M_score F_score R_score;
run;
proc print data = rfm_Huntz2(obs = 20);run;
/*data rfm_Huntz2;
set rfm_Huntz2;
if M_score = 0 then M_score = -2; else if M_score = 1 then M_score = -1; else if M_score = 3 then M_score = 0;else if M_score = 4 then M_score = 1;else M_score = 2;
if F_score = 0 then F_score = -2; else if F_score = 1 then F_score = -1; else if F_score = 3 then F_score = 0;else if F_score = 4 then F_score = 1;else F_score = 2;
if R_score = 0 then R_score = -2; else if R_score = 1 then R_score = -1; else if R_score = 3 then R_score = 0;else if R_score = 4 then R_score = 1;else R_score = 2;
run;*/

/* Merging this and demos data*/
proc sql;
create table rfm_Huntz_l as select * from rfm_Huntz2, Predmod.demos as d where rfm_Huntz2.Panelist_ID = d.Panelist_ID;
proc print data = Predmod.rfmhuntz(obs = 20);run;
data Predmod.rfmhuntz(drop = M F R);
set rfm_Huntz_l;
run;
data Predmod.rfmhuntz;
set Predmod.rfmhuntz;
M_score = 2*M_score;
Score = M_score+F_score+R_score;
run;
/*Ranking again*/
proc rank data = Predmod.rfmhuntz out = Predmod.rfmhuntz_o ties = low groups = 3;
var score;
ranks rank;
run;
proc sort data = Predmod.rfmhuntz_o;by rank;
proc freq data = Predmod.rfmhuntz_o;table Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH Male_Working_Hour_Code Female_Working_Hour_Code Number_of_Dogs Children_Group_Code Marital_Status Number_of_TVs_Used_by_HH IRI_Geography_Number county;by rank;run;




















/*-----------------------------Trying to understand Oz-RFM distribution--------------------------------------------*/

proc print data = rfm(obs = 20);run;
/*24 oz table*/
proc sql;
create table rfm24 as select * from rfm where Oz = 24;
proc print data = rfm24(obs = 20);run;
/* Creating rfm matrix for panel id*/
proc sql;
create table rfm24_1 as select Panelist_ID, sum(DOLLARS) as M, count(*) as F, MAX(monthmod) as R, sum(UNITS) as Totunits from rfm24 group by Panelist_ID;
proc print data = rfm24_1(obs = 20);run;
proc means data = rfm24_1;var R F M;run;
proc rank data = rfm24_1 out = rfm24_2 ties = low groups = 3;
var M F R;
ranks M_score F_score R_score;
run;
proc print data = rfm24_2(obs = 20);run;
proc sql;
select M_score, F_score, R_score, avg(R), avg(totunits) from rfm24_2 group by M_score, F_score, R_score;
/*data rfm24_2;
set rfm24_2;
if M_score = 0 then M_score = 1; else if M_score = 1 then M_score = 0; else M_score = -1;
if F_score = 0 then F_score = 1; else if F_score = 1 then F_score = 0; else F_score = -1;
if R_score = 0 then R_score = 1; else if R_score = 1 then R_score = 0; else R_score = -1;
run;*/
proc sql;
create table temp as select * from rfm24_2, Predmod.demos as d where rfm24_2.Panelist_ID = d.Panelist_ID;
proc print data = Predmod.rfm24(obs = 20);run;
data Predmod.rfm24(drop = M F R);
set temp;
run;
/* From the Tableau we can see that M is very imp*/
data Predmod.rfm24;
set Predmod.rfm24;
M_score = 2*M_score;
Score = M_score+F_score+R_score;
run;
/*Ranking again*/
proc rank data = Predmod.rfm24 out = Predmod.rfm24_o ties = low groups = 3;
var score;
ranks rank;
run;
proc sql;
select rank, avg(totunits) from Predmod.rfm24_o group by rank;
/* removing unnecessary demos data*/
data Predmod.rfm24_o(drop = MALE_SMOKE FEM_SMOKE Number_of_Cats Language Number_of_TVs_Hooked_to_Cable HISP_FLAG HISP_CAT HH_Head_Race__RACE2_ Microwave_Owned_by_HH ZIPCODE FIPSCODE market_based_upon_zipcode EXT_FACT);
set Predmod.rfm24_o;
run;
proc print data =Predmod.rfm24_o(obs = 20);run;

/* Running proc factor first to check if i can reduce the demo variables*/
proc factor data = Predmod.rfm24_o(drop = Panelist_ID Totunits M_score F_score R_score Score rank) simple method = prin rotate = varimax reorder plots = (scree initloadings preloadings loadings) score;
run;
/* Only 68% of the variance is explained by the 7 factors..instead of reducing, I will use this results to remove the correlted variables*/
/*1. Male_Working_Hour_Code, Education_Level_Reached_by_Male, Age_Group_Applied_to_Male_HH
2. Age_Group_Applied_to_Female_HH Children_Group_Code
3. Occupation_Code_of_Female_HH HH_OCC
4. Education_Level_Reached_by_Femal HH_EDU
5. IRI_Geography_Number Panelist_Type
6. HH_Head_Race__RACE3_ HH_RACE*/

data Predmod.postcorr(drop = Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Age_Group_Applied_to_Female_HH Occupation_Code_of_Female_HH Education_Level_Reached_by_Femal Panelist_Type HH_Head_Race__RACE3_);
set Predmod.rfm24_o;
run;
proc print data = Predmod.postcorr(obs = 20);run;

/* Ordered Logistic Regression to understand the parameters*/
proc logistic data = Predmod.rfm24_o descending out = logistic;
class Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession COUNTY HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH 
Male_Working_Hour_Code Female_Working_Hour_Code Children_Group_Code Marital_Status Number_of_TVs_Used_by_HH IRI_Geography_Number;
id Panelist_ID;
model rank = Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession COUNTY HH_AGE HH_EDU HH_OCC 
Occupation_Code_of_Male_HH Male_Working_Hour_Code Female_Working_Hour_Code Number_of_Dogs Children_Group_Code Marital_Status 
Number_of_TVs_Used_by_HH IRI_Geography_Number Combined_Pre_Tax_Income_of_HH*Family_Size HH_AGE*HH_EDU Family_Size*Type_of_Residential_Possession 
Combined_Pre_Tax_Income_of_HH*HH_AGE Children_Group_Code*Marital_Status /stb;
run;
proc freq data = Predmod.rfm24_o;table Type_of_Residential_Possession;run;

/*64.4% concordance with only demos data*/
proc logistic data = Predmod.rfm24_o descending out = logistic;
class Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession COUNTY HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH Female_Working_Hour_Code Children_Group_Code Marital_Status IRI_Geography_Number;
id Panelist_ID;
model rank = Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession COUNTY HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH  Female_Working_Hour_Code Number_of_Dogs Children_Group_Code Marital_Status IRI_Geography_Number Combined_Pre_Tax_Income_of_HH*Family_Size HH_AGE*HH_EDU Family_Size*Type_of_Residential_Possession Combined_Pre_Tax_Income_of_HH*HH_AGE Children_Group_Code*Marital_Status /stb;
run;

proc logistic data = Predmod.rfm24_o descending out = logistic;
class Family_Size HH_RACE Type_of_Residential_Possession COUNTY HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH Female_Working_Hour_Code Children_Group_Code Marital_Status IRI_Geography_Number;
id Panelist_ID;
model rank = Family_Size HH_RACE Type_of_Residential_Possession COUNTY HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH  Female_Working_Hour_Code Number_of_Dogs Children_Group_Code Marital_Status IRI_Geography_Number Combined_Pre_Tax_Income_of_HH*Family_Size HH_AGE*HH_EDU Family_Size*Type_of_Residential_Possession Combined_Pre_Tax_Income_of_HH*HH_AGE Children_Group_Code*Marital_Status /stb;
run;

















/*36 oz table*/
proc sql;
create table rfm36 as select * from rfm where Oz = 36;
proc print data = rfm36(obs = 20);run;
/* creating rfm matrix*/
proc sql;
create table rfm36_1 as select Panelist_ID, sum(DOLLARS) as M, count(*) as F, MAX(monthmod) as R, sum(UNITS) as Totunits from rfm36 group by Panelist_ID;
proc print data = rfm36_1(obs = 20);run;
proc rank data =rfm36_1 out = rfm36_2 ties = low groups =3;
var R F M;
ranks M_score F_score R_score;
run;
proc print data = rfm36_2(obs = 20);run;
proc sql;
select M_score, F_score, R_score, avg(M), avg(Totunits) from rfm36_2 group by M_score, F_score, R_score;
/*data rfm36_2;
set rfm36_2;
if M_score = 0 then M_score = -1; else if M_score = 1 then M_score = 0; else M_score = 1;
if F_score = 0 then F_score = -1; else if F_score = 1 then F_score = 0; else F_score = 1;
if R_score = 0 then R_score = -1; else if R_score = 1 then R_score = 0; else R_score = 1;
run;*/
proc sql;
create table temp1 as select * from rfm36_2, Predmod.demos as d where rfm36_2.Panelist_ID = d.panelist_ID;
proc print data = temp1(obs = 20);run;
data Predmod.rfm36(drop = M F R);
set temp1;
run;

/* Understanding the weights using tableau to assign weights for R,F,M*/
data Predmod.rfm36;
set Predmod.rfm36;
M_score = 2*M_score;
Score = M_score+F_score+R_score;
run;
/*Ranking again*/
proc rank data = Predmod.rfm36 out = Predmod.rfm36_o ties = low groups = 3;
var score;
ranks rank;
run;
proc sql;
select rank, avg(totunits) from Predmod.rfm36_o group by rank;
/* Using the same reduced demos file*/
data Predmod.postcorr36(drop = Age_Group_Applied_to_Male_HH Education_Level_Reached_by_Male Age_Group_Applied_to_Female_HH Occupation_Code_of_Female_HH Education_Level_Reached_by_Femal Panelist_Type HH_Head_Race__RACE3_);
set Predmod.rfm36_o;
run;
/* Ordered Logistic Regression to understand the parameters*/
proc logistic data = Predmod.rfm36_o descending out = logistic;
class Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession COUNTY HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH Male_Working_Hour_Code Female_Working_Hour_Code Children_Group_Code Marital_Status Number_of_TVs_Used_by_HH IRI_Geography_Number;
id Panelist_ID;
model rank = Combined_Pre_Tax_Income_of_HH Family_Size HH_RACE Type_of_Residential_Possession COUNTY HH_AGE HH_EDU HH_OCC Occupation_Code_of_Male_HH Male_Working_Hour_Code Female_Working_Hour_Code Number_of_Dogs Children_Group_Code Marital_Status Number_of_TVs_Used_by_HH IRI_Geography_Number Combined_Pre_Tax_Income_of_HH*Family_Size HH_AGE*HH_EDU Family_Size*Type_of_Residential_Possession Combined_Pre_Tax_Income_of_HH*HH_AGE Children_Group_Code*Marital_Status /stb;
run;
/*63.9 % concordance*/
