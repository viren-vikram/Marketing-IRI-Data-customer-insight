proc print data=cc.panel_gr_yr1(obs=10);run;

proc sort data=cc.panel_gr_yr1;by colupc week iri_key;run;
proc sort data=cc.yr_1_c2;by colupc week iri_key;run;

proc print data=cc.p_yr1(obs=10);run;

proc print data=cc.yr_1_c2(obs=10);run;

data cc.yr_1_c3;
set cc.yr_1_c2 (drop= SY GE VEND ITEM UNITS DOLLARS F D PR upc L1 L3 L4 L9 Level _STUBSPEC_1527RC VOL_EQ 
PRODUCT_TYPE SUGAR_CONTENT 
PROCESS TEXTURE FORM TYPE_OF_COMBINATION STYLE item_f vend_f b_size);
run;
proc sort data=cc.yr_1_c3;by colupc week iri_key;run;

data cc.p_yr1;
merge cc.panel_gr_yr1(in=b) cc.yr_1_c3;	
by colupc week iri_key;
if b;
run;

proc print data=cc.p_yr1(obs=10);run;

data cc.b_sw_1;
set cc.p_yr1 ;
if L2='KETCHUP';
run;

proc print data=cc.b_sw_1(obs=10);run;

data cc.b_sw_2;
set cc.b_sw_1;
if L5 = "HEINZ" THEN BRAND = 1;
else if L5="DEL MONTE" THEN BRAND = 2;
else if L5="HUNTS" THEN BRAND = 3;
else BRAND = 4; 
run;

proc contents data=cc.b_sw_2(obs=10);run;
proc print data=cc.b_sw_2(obs=50);run;


proc sort data = cc.b_sw_2;by panid week colupc;run;

data cc.b_sw_3;
set cc.b_sw_2;
by panid week colupc;
if first.colupc then t_units=0;    
   t_units + units;
run;

data cc.b_sw_4;
set cc.b_sw_3;
by panid week colupc;
if first.colupc then t_sales=0;    
   t_sales + dollars;
if last.colupc;
run;

data cc.b_sw_5;
set cc.b_sw_4;
by panid week colupc;
if first.colupc then t_sales=0;    
   t_sales + dollars;
if last.colupc;
run;

proc print data=cc.b_sw_4(obs=10);run;
proc sort data=cc.b_sw_4;by panid week;run;
proc sort data=cc.b_sw_5;by panid week descending t_sales;run:

data cc.b_sw_6;
set cc.b_sw_5;
by panid week;
if first.week;
run;

proc sort data=cc.b_sw_6;by panid;run;

proc sql;
create table cc.b_sw_7 as
select panid, count(*) as count
from cc.b_sw_6
group by panid
having count = 1;
run;

proc sql;
 create table cc.b_sw_8 as
 select * 
 from cc.b_sw_6
where panid not in (select panid from cc.b_sw_7); 
 quit;

PROC freq data= cc.b_sw_8 ORDER=FREQ;
table L5;RUN;

proc sort data=cc.b_sw_8; by panid week;run;

data cc.b_sw_9; 
set cc.b_sw_8; 
length row_col $ 12; 
by panid week; 
preid = lag(BRAND); 
if first.panid then preid=.;
if preid ne . and BRAND ne . then row_col=compress(put(preid,3.))||'_'||left(put(brand,3.)); 
else row_col='Not defined';
options nocenter; 

data cc.b_sw_10;
set cc.b_sw_9;
if  row_col="Not defined" then delete;
run;

proc print data=cc.b_sw_10;run;
proc sort data=cc.b_sw_10;by panid ;run;

proc freq noprint; 
table row_col / out=mtrx (keep=row_col count);

proc print data=mtrx;run;
proc sort data=mtrx;by row;run; 

data mtrx_1(drop =count); 
set mtrx(drop = row_col col) ; 
by row;
if first.row then t_count = 0;
t_count + count;
if last.row;
run;

proc print data=mtrx_1;run;

data mtrx_2;
merge mtrx mtrx_1;
by row;
run;

proc print data=mtrx_4;run;
proc contents data=mtrx_2;run;

data mtrx_3;
set mtrx_2;
count=(count/t_count)*100;

data mtrx_4; 
set mtrx_3; 
row=scan(row_col,1,'_'); 
col=scan(row_col,2,'_');

data mtrx_5;
set mtrx_4;
if row="1" then row="HEINZ";
if row="2" then row="DEL MONTE";
if row="3" then row="HUNTS";
if row="4" then row="OTHERS";
if col="1" then col="HEINZ";
if col="2" then col="DEL MONTE";
if col="3" then col="HUNTS";
if col="4" then col="OTHERS";
run;

proc sort data=mtrx_5;by row;run;
proc transpose out=xx (drop=_name_ _label_); 
by row; 
var count; 
id col;run;

proc print data=xx;
run;

